import { Queue } from 'bullmq';
import { NodeEventBus } from './NodeEventBus';
import { IEventBus } from './IEventBus';
import { env } from '../config/env';
import { 
  EventNames, 
  QueueNames, 
  CandidateApplicationCreatedSchema, 
  CandidateApplicationCreatedPayload 
} from 'shared_events';
import { logger } from '../utils/logger';

export const eventBus: IEventBus = new NodeEventBus();

// Connection is required for BullMQ queues
const connection = {
  host: new URL(env.REDIS_URL).hostname,
  port: Number(new URL(env.REDIS_URL).port) || 6379
};

const resumeQueue = new Queue(QueueNames.RESUME_PROCESSING, { connection });

export function setupEventDispatcher() {
  eventBus.subscribe(EventNames.CANDIDATE_APPLICATION_CREATED, async (rawPayload) => {
    // Validate payload
    const result = CandidateApplicationCreatedSchema.safeParse(rawPayload);
    if (!result.success) {
      logger.error({ error: result.error, payload: rawPayload }, 'Invalid event payload received in dispatcher');
      return;
    }
    
    const payload: CandidateApplicationCreatedPayload = result.data;
    
    // Dispatch to BullMQ Queue
    await resumeQueue.add('process-resume', payload, {
      jobId: payload.jobId, // ensure bullmq doesn't duplicate this job
      attempts: 3,
      backoff: { type: 'exponential', delay: 2000 }
    });
    
    logger.info({ jobId: payload.jobId, correlationId: payload.correlationId }, 'Dispatched job to ResumeProcessing queue');
  });
}
