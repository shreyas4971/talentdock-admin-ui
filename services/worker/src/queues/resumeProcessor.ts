import { Job } from 'bullmq';
import Redis from 'ioredis';
import { BaseWorker } from '../framework/BaseWorker';
import { 
  QueueNames, 
  CandidateApplicationCreatedSchema, 
  CandidateApplicationCreatedPayload 
} from 'shared_events';

export class ResumeProcessor extends BaseWorker<CandidateApplicationCreatedPayload> {
  constructor(redis: Redis) {
    super(QueueNames.RESUME_PROCESSING, redis, CandidateApplicationCreatedSchema, {
      concurrency: 5,
    });
  }

  protected async process(job: Job, payload: CandidateApplicationCreatedPayload): Promise<void> {
    console.log(`[ResumeProcessor] Processing candidate application ${payload.data.candidateApplicationId} for org ${payload.organizationId} (Correlation: ${payload.correlationId})`);
    // mock processing
    await new Promise(resolve => setTimeout(resolve, 500));
  }
}
