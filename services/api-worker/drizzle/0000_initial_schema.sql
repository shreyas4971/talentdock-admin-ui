-- D1 SQLite Migration: 0000_initial_schema.sql
-- TalentDock V1 Backend Schema

CREATE TABLE IF NOT EXISTS `users` (
	`id` text PRIMARY KEY NOT NULL,
	`email` text NOT NULL UNIQUE,
	`password_hash` text NOT NULL,
	`name` text DEFAULT 'Admin' NOT NULL,
	`role` text DEFAULT 'ADMIN' NOT NULL,
	`created_at` text NOT NULL,
	`updated_at` text NOT NULL
);

CREATE TABLE IF NOT EXISTS `positions` (
	`id` text PRIMARY KEY NOT NULL,
	`title` text NOT NULL,
	`department` text DEFAULT 'Engineering' NOT NULL,
	`location` text DEFAULT 'Remote' NOT NULL,
	`employment_type` text DEFAULT 'Full-time' NOT NULL,
	`experience` text DEFAULT '1-3 Years' NOT NULL,
	`status` text DEFAULT 'DRAFT' NOT NULL,
	`is_pinned` integer DEFAULT 0 NOT NULL,
	`short_description` text,
	`description` text,
	`responsibilities` text,
	`requirements` text,
	`benefits` text,
	`created_at` text NOT NULL,
	`updated_at` text NOT NULL
);
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS `positions_status_idx` ON `positions` (`status`);

CREATE TABLE IF NOT EXISTS `candidates` (
	`id` text PRIMARY KEY NOT NULL,
	`first_name` text NOT NULL,
	`last_name` text NOT NULL,
	`email` text NOT NULL UNIQUE,
	`phone` text,
	`city` text,
	`state` text,
	`dob` text,
	`highest_education` text,
	`employment_status` text,
	`total_experience` text,
	`current_company` text,
	`current_designation` text,
	`expected_salary` text,
	`current_salary` text,
	`notice_period` text,
	`joining_date` text,
	`additional_info` text,
	`tags` text DEFAULT '[]',
	`created_at` text NOT NULL,
	`updated_at` text NOT NULL
);
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS `candidates_email_idx` ON `candidates` (`email`);

CREATE TABLE IF NOT EXISTS `applications` (
	`id` text PRIMARY KEY NOT NULL,
	`reference_id` text NOT NULL UNIQUE,
	`candidate_id` text NOT NULL,
	`position_id` text NOT NULL,
	`status` text DEFAULT 'APPLIED' NOT NULL,
	`has_decision` integer DEFAULT 0 NOT NULL,
	`is_opened` integer DEFAULT 0 NOT NULL,
	`created_at` text NOT NULL,
	`updated_at` text NOT NULL,
	FOREIGN KEY (`candidate_id`) REFERENCES `candidates`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`position_id`) REFERENCES `positions`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS `applications_candidate_idx` ON `applications` (`candidate_id`);
CREATE INDEX IF NOT EXISTS `applications_position_idx` ON `applications` (`position_id`);
CREATE INDEX IF NOT EXISTS `applications_status_idx` ON `applications` (`status`);
CREATE INDEX IF NOT EXISTS `applications_ref_idx` ON `applications` (`reference_id`);

CREATE TABLE IF NOT EXISTS `candidate_documents` (
	`id` text PRIMARY KEY NOT NULL,
	`application_id` text NOT NULL,
	`candidate_id` text NOT NULL,
	`document_type` text DEFAULT 'RESUME' NOT NULL,
	`file_name` text NOT NULL,
	`mime_type` text NOT NULL,
	`file_size` integer NOT NULL,
	`storage_key` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`application_id`) REFERENCES `applications`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`candidate_id`) REFERENCES `candidates`(`id`) ON UPDATE no action ON DELETE no action
);

CREATE TABLE IF NOT EXISTS `candidate_notes` (
	`id` text PRIMARY KEY NOT NULL,
	`candidate_id` text NOT NULL,
	`author_id` text,
	`content` text NOT NULL,
	`created_at` text NOT NULL,
	`updated_at` text NOT NULL,
	FOREIGN KEY (`candidate_id`) REFERENCES `candidates`(`id`) ON UPDATE no action ON DELETE no action
);

CREATE TABLE IF NOT EXISTS `candidate_timeline` (
	`id` text PRIMARY KEY NOT NULL,
	`application_id` text NOT NULL,
	`event_type` text NOT NULL,
	`description` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`application_id`) REFERENCES `applications`(`id`) ON UPDATE no action ON DELETE no action
);
