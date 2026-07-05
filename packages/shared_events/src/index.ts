import { z } from 'zod';

// Queue Names
export const QueueNames = {
  RESUME_PROCESSING: 'resume_processing_queue',
  EMAIL: 'email_queue',
  NOTIFICATION: 'notification_queue',
  EXPORT: 'export_queue',
  AI: 'ai_queue',
  DOCUMENT: 'document_queue',
} as const;

export type QueueName = typeof QueueNames[keyof typeof QueueNames];

// Event Names (Hierarchical)
export const EventNames = {
  CANDIDATE_APPLICATION_CREATED: 'candidate.application.created',
  CANDIDATE_APPLICATION_UPDATED: 'candidate.application.updated',
} as const;

export type EventName = typeof EventNames[keyof typeof EventNames];

// Event Versions
export const EventVersions = {
  V1: '1.0',
} as const;

// Base Zod Schema for every event/job payload
export const BasePayloadSchema = z.object({
  jobId: z.string(),
  eventName: z.string(),
  eventVersion: z.string(),
  correlationId: z.string().uuid(),
  organizationId: z.string(),
  timestamp: z.string().datetime(),
  payloadVersion: z.string(),
});

// Specific Event Schemas
export const CandidateApplicationCreatedSchema = BasePayloadSchema.extend({
  eventName: z.literal(EventNames.CANDIDATE_APPLICATION_CREATED),
  data: z.object({
    candidateId: z.string(),
    candidateApplicationId: z.string(),
    resumeDocumentId: z.string().optional(),
  }),
});

export type CandidateApplicationCreatedPayload = z.infer<typeof CandidateApplicationCreatedSchema>;

// Generic Job Payload structure for BullMQ
export interface JobPayload<T> {
  jobId: string;
  correlationId: string;
  organizationId: string;
  candidateId?: string;
  candidateApplicationId?: string;
  timestamp: string;
  payloadVersion: string;
  data: T;
}
