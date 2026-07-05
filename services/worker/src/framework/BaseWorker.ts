import { Job, Worker, WorkerOptions } from 'bullmq';
import { AnyZodObject } from 'zod';
import Redis from 'ioredis';
import { QueueName } from 'shared_events';

export abstract class BaseWorker<T> {
  protected worker: Worker;
  
  constructor(
    queueName: QueueName,
    private redis: Redis,
    private schema: AnyZodObject,
    options: Omit<WorkerOptions, 'connection'>
  ) {
    this.worker = new Worker(
      queueName,
      async (job: Job) => {
        // Validate payload
        const parseResult = this.schema.safeParse(job.data);
        if (!parseResult.success) {
          throw new Error(`Invalid job payload: ${JSON.stringify(parseResult.error)}`);
        }

        const payload = parseResult.data as any;
        const jobId = payload.jobId || job.id;

        // Idempotency check via Redis SETNX
        const lockKey = `job:lock:${queueName}:${jobId}`;
        const acquired = await this.redis.setnx(lockKey, '1');
        
        if (!acquired) {
          console.log(`Job ${jobId} already processed (idempotency triggered).`);
          return;
        }

        // 24 hour expiry on idempotency lock
        await this.redis.expire(lockKey, 60 * 60 * 24);

        await this.process(job, payload);
      },
      {
        connection: this.redis,
        ...options,
      }
    );

    this.worker.on('failed', (job, err) => {
      console.error(`Job ${job?.id} failed:`, err.message);
    });
  }

  protected abstract process(job: Job, payload: T): Promise<void>;
}
