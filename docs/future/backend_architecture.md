# Backend Architecture (Frozen v1.0)

The backend is split into two distinct Node.js services inside the monorepo: `services/api` and `services/worker`.

## 1. Services Separation

### `services/api`
The synchronous REST API layer.
- Handles incoming HTTP requests.
- Validates data via Zod.
- Commits changes to the Database via Prisma.
- Emits **Domain Events** (e.g., `eventBus.emit('CandidateApplied', payload)`).
- Does **not** perform heavy blocking tasks (no PDF generation, no AI parsing).

### `services/worker`
The asynchronous background processing layer.
- Connects to the Redis queue (BullMQ).
- Listens for## Queues & Background Workers
Heavy lifting (PDF parsing, Emailing, AI matching) is offloaded to a separate Node.js `worker` service. We use **BullMQ** on top of Redis to handle job scheduling, retries, exponential backoffs, and Dead Letter Queues (DLQs).

### Idempotency
Workers MUST be built to be idempotent. They use Redis `SETNX` commands based on the job's payload `jobId` and `QueueName` to ensure that duplicate job executions do not repeat side-effects.

### Queue Dashboard
Bull Board is used to monitor Queues. It is hosted within the `worker` service Express app and secured behind the centralized JWT Authentication middleware requiring the `admin` role. It can be dynamically disabled in production via environment variables.

## Internal Event-Driven Architecture (Phase 2B)

The API is fully decoupled from the background worker via an abstract `IEventBus`.
1. The domain models inside the API publish strictly-typed hierarchical events (e.g., `candidate.application.created`) using `NodeEventBus`.
2. A centralized `dispatcher` listens to these events, enforces Zod validation, and schedules BullMQ jobs.
3. **Correlation IDs** are injected into all payloads allowing end-to-end tracing across API, Database, and Worker logs.

### Shared Contracts & Events
To prevent duplication across the monorepo, we utilize Node Workspaces (`packages/shared_events` and `packages/shared_contracts`).
- `packages/shared_events`: Houses strongly typed Event Names, Queue Names, and Zod Schemas enforcing standard payload metadata (Event Name, Version, Timestamp, Correlation ID, Payload Version, Organization ID). All Worker payloads are validated against these standard Zod schemas before processing.
- `packages/shared_contracts`: Houses DTOs, API Requests/Responses, Pagination, Error Enums, and Filter interfaces to be shared across the backend ecosystem and the Flutter frontend.

## Clean Architecture & Domain Layer (Phase 3)

The API logic structure enforces strict Clean Architecture separation:
- **Presentation Layer**: Thin Express controllers parsing DTOs and injecting UoW/EventBus dependencies into Application commands. Returns standard `ApiSuccessResponse` and `ApiErrorResponse` shapes.
- **Application Layer**: Contains distinct Use Case classes split into `commands/` and `queries/`. Executes business logic orchestrations wrapped inside the Unit of Work.
- **Domain Layer**: Houses rich Domain Entities (`PositionEntity`) representing exact lifecycle rules. Emits typed exceptions (`DomainError`, `NotFoundError`, `ConflictError`, `BusinessRuleViolation`).
- **Infrastructure Layer**: Translates the generalized Domain interfaces into Prisma ORM transactions and queries.

### Unit of Work (UoW) Pattern
Rather than injecting `PrismaClient` into Application controllers, Use Cases execute operations securely inside an `IUnitOfWork`. `PrismaUnitOfWork` implements this under the hood utilizing Prisma's `$transaction` callback, exposing repositories isolated to the active transaction. This prevents data fragmentation and side-effects.

### Specification Pattern
Instead of sprawling custom repository logic, `ISpecification<T>` handles dynamic and composite logic abstractions, maintaining repository interface cleanliness.

### Post-Commit Event Architecture
Domain Events MUST ONLY be emitted by the Application Layer after the UoW `.execute()` block completes successfully, preventing orphan worker jobs corresponding to rolled-back operations.

### Architecture Tests
We enforce strict architectural boundary isolation using static analysis (`eslint-plugin-import`). The `.eslintrc.json` prevents the Domain and Application layers from ever importing ORM tooling (`@prisma/client`) or presentation layers (`express`), failing the build if boundaries are breached.
// Example Controller in services/api
async function submitApplication(req, res) {
  const application = await createApplication(req.body);
  
  // Decoupled side-effects
  eventBus.publish('DomainEvent.CandidateApplied', {
    applicationId: application.id,
    candidateId: application.candidateId
  });

  res.status(201).json(application);
}
```
An event listener maps `DomainEvent.CandidateApplied` to queue jobs in BullMQ, which are subsequently processed by `services/worker`.

## 3. SearchService Abstraction

The API interfaces strictly with an `ISearchService`.
While Phase 1 will implement this using PostgreSQL full-text search (`tsvector`), the interface allows seamless swapping to Meilisearch or Elasticsearch for Phase 2 without touching any business logic.

## 4. OpenAPI Generation Strategy

We will use `swagger-jsdoc` mapped to our Zod validation schemas (via `@asteasolutions/zod-to-openapi`) to automatically generate an OpenAPI 3.0 JSON specification at runtime.
This JSON will be served via Swagger UI at `/api/docs` and provided as a downloadable Postman Collection at `/api/docs/postman`.
