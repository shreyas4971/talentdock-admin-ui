# ADR-0001: Approval and Freezing of Architecture v1.0

## Status
Accepted

## Date
2026-07-05

## Context
The TalentOS platform aims to serve as a comprehensive HR and talent management suite starting with the Recruitment module. To ensure scalability, ease of maintenance, and the seamless addition of future modules without major refactoring, an architecture needs to be established upfront.

## Decision
We decided to adopt a Monorepo architecture managed via standard tooling, splitting the solution into:
- Two distinct Flutter applications (`apps/admin_flutter`, `apps/candidate_flutter`).
- Two Node.js services (`services/api` for sync REST endpoints, `services/worker` for async background processing).
- Shared Dart/Flutter packages (`talentos_design_system`, `talentos_models`, `shared_api`, `shared_utils`).
- A highly abstract, plugin-based interface approach for external dependencies (Storage, Notifications, AI, Search) preventing vendor lock-in.
- An event-driven architecture using domain events for decoupled side-effects.
- A PostgreSQL database managed by Prisma ORM featuring a logical Document metadata layer and Feature Flags.

This architecture is marked as **Frozen v1.0**.

## Consequences
- **Positive**: High code reusability across apps. Clear separation of concerns (Sync API vs Async processing). Vendor independence for AI/Storage. Future HR modules can plug straight in.
- **Negative**: Higher initial setup complexity. Requires strict adherence to the defined package boundaries and dependency injection principles. Developers must be comfortable with asynchronous event flows.
