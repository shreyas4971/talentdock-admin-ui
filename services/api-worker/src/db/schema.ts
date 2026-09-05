import { sqliteTable, text, integer, index, uniqueIndex } from 'drizzle-orm/sqlite-core';

// 1. Users (Admin Auth)
export const users = sqliteTable('users', {
  id: text('id').primaryKey(),
  email: text('email').notNull().unique(),
  passwordHash: text('password_hash').notNull(),
  name: text('name').notNull().default('Admin'),
  role: text('role').notNull().default('ADMIN'),
  createdAt: text('created_at').notNull(),
  updatedAt: text('updated_at').notNull(),
});

// 2. Positions
export const positions = sqliteTable('positions', {
  id: text('id').primaryKey(),
  title: text('title').notNull(),
  department: text('department').notNull().default('Engineering'),
  location: text('location').notNull().default('Remote'),
  employmentType: text('employment_type').notNull().default('Full-time'),
  experience: text('experience').notNull().default('1-3 Years'),
  minExperience: integer('min_experience').default(0),
  maxExperience: integer('max_experience').default(5),
  relevantExperience: integer('relevant_experience').default(0),
  noticePeriod: text('notice_period').default('30 Days'),
  immediateJoiner: integer('immediate_joiner', { mode: 'boolean' }).default(false),
  skills: text('skills').default('[]'),
  status: text('status').notNull().default('DRAFT'), // DRAFT, PUBLISHED, ARCHIVED
  isPinned: integer('is_pinned', { mode: 'boolean' }).notNull().default(false),
  shortDescription: text('short_description'),
  description: text('description'),
  responsibilities: text('responsibilities'), // JSON stringified array
  requirements: text('requirements'), // JSON stringified array
  benefits: text('benefits'), // JSON stringified array
  createdAt: text('created_at').notNull(),
  updatedAt: text('updated_at').notNull(),
}, (table) => ({
  statusIdx: index('positions_status_idx').on(table.status),
}));

// 3. Candidates
export const candidates = sqliteTable('candidates', {
  id: text('id').primaryKey(),
  firstName: text('first_name').notNull(),
  lastName: text('last_name').notNull(),
  email: text('email').notNull().unique(),
  phone: text('phone'),
  city: text('city'),
  state: text('state'),
  dob: text('dob'),
  highestEducation: text('highest_education'),
  employmentStatus: text('employment_status'),
  totalExperience: text('total_experience'),
  currentCompany: text('current_company'),
  currentDesignation: text('current_designation'),
  expectedSalary: text('expected_salary'),
  currentSalary: text('current_salary'),
  noticePeriod: text('notice_period'),
  joiningDate: text('joining_date'),
  additionalInfo: text('additional_info'),
  tags: text('tags').default('[]'), // JSON stringified array
  createdAt: text('created_at').notNull(),
  updatedAt: text('updated_at').notNull(),
}, (table) => ({
  emailIdx: index('candidates_email_idx').on(table.email),
}));

// 4. Applications
export const applications = sqliteTable('applications', {
  id: text('id').primaryKey(),
  referenceId: text('reference_id').notNull().unique(), // e.g. REC-2026-000001
  candidateId: text('candidate_id').notNull().references(() => candidates.id),
  positionId: text('position_id').notNull().references(() => positions.id),
  status: text('status').notNull().default('APPLIED'), // APPLIED, REVIEW, INTERVIEW, OFFER, REJECTED
  hasDecision: integer('has_decision', { mode: 'boolean' }).notNull().default(false),
  isOpened: integer('is_opened', { mode: 'boolean' }).notNull().default(false),
  createdAt: text('created_at').notNull(),
  updatedAt: text('updated_at').notNull(),
}, (table) => ({
  candidatePositionUnique: uniqueIndex('applications_candidate_position_unique_idx').on(table.candidateId, table.positionId),
  candidateIdx: index('applications_candidate_idx').on(table.candidateId),
  positionIdx: index('applications_position_idx').on(table.positionId),
  statusIdx: index('applications_status_idx').on(table.status),
  refIdx: index('applications_ref_idx').on(table.referenceId),
}));

// 5. Candidate Documents (R2 Metadata)
export const candidateDocuments = sqliteTable('candidate_documents', {
  id: text('id').primaryKey(),
  applicationId: text('application_id').notNull().references(() => applications.id),
  candidateId: text('candidate_id').notNull().references(() => candidates.id),
  documentType: text('document_type').notNull().default('RESUME'), // RESUME, SUPPORTING
  fileName: text('file_name').notNull(),
  mimeType: text('mime_type').notNull(),
  fileSize: integer('file_size').notNull(),
  storageKey: text('storage_key').notNull(), // Path in R2
  createdAt: text('created_at').notNull(),
});

// 6. Candidate Notes
export const candidateNotes = sqliteTable('candidate_notes', {
  id: text('id').primaryKey(),
  candidateId: text('candidate_id').notNull().references(() => candidates.id),
  authorId: text('author_id'),
  content: text('content').notNull(),
  createdAt: text('created_at').notNull(),
  updatedAt: text('updated_at').notNull(),
});

// 7. Candidate Timeline
export const candidateTimeline = sqliteTable('candidate_timeline', {
  id: text('id').primaryKey(),
  applicationId: text('application_id').notNull().references(() => applications.id),
  eventType: text('event_type').notNull(), // APPLICATION_SUBMITTED, STATUS_CHANGED, NOTE_ADDED, INTERVIEW_SCHEDULED
  description: text('description').notNull(),
  createdAt: text('created_at').notNull(),
});
