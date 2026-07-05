# TalentOS MVP v1 Architecture

> [!NOTE]
> The original "Frozen Architecture v1.0" and frontend architecture plans are preserved as the blueprint for the Future Enterprise Edition. This document defines the simplified rules governing the MVP.

## Tech Stack
- **Frontend**: Flutter Web (Admin + Candidate applications only).
- **Backend**: Node.js + Express.
- **Database**: PostgreSQL (via Prisma ORM).
- **Storage**: Google Cloud Storage (GCS).
- **State Management**: Riverpod (Standard `AsyncValue`).
- **Routing**: GoRouter.
- **API Client**: Dio.

## Architectural Simplifications
1. **Direct Controllers**: Express controllers will interact directly with simple Prisma services. We are completely bypassing the Unit of Work (UoW) and CQRS patterns.
2. **No Event Queues**: BullMQ, Redis, and internal EventBuses are stripped out. All operations are synchronous.
3. **Native UI Components**: We will utilize standard Flutter Material 3 widgets (`TextFormField`, native `DataTable`) instead of bespoke Form Frameworks or custom tables.
4. **Standard State**: Bypassing the custom `TalentState` class in favor of native Riverpod patterns.

## Database Schema Limit
To maintain speed, the database schema is restricted to four core tables:
1. `Users`
2. `Positions`
3. `Candidates`
4. `CandidateDocuments`

All other abstractions (Timelines, Audits, Advanced Metadata) are deferred to the Enterprise edition.
