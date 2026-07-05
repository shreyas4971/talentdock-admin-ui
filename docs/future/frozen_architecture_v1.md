# TalentOS - Frozen Architecture v1.0

This document is the definitive master specification for the TalentOS platform. The architecture described herein is **FROZEN** and serves as the strict guideline for all code generation and implementation.

## 1. Monorepo Structure

The project utilizes a monorepo to ensure seamless code sharing and version consistency across all applications and backend services.

```text
talentos/
├── apps/
│   ├── admin_flutter/          # Internal administrator dashboard
│   └── candidate_flutter/      # Public-facing candidate portal
├── services/
│   ├── api/                    # Primary REST API (Node.js/Express)
│   └── worker/                 # Background job processor (Node.js/BullMQ)
├── packages/
│   ├── talentos_design_system/ # UI components, themes, colors, typography
│   ├── talentos_models/        # Shared DTOs, Freezed data classes
│   ├── shared_api/             # Dio HTTP client, endpoint definitions
│   └── shared_utils/           # Formatters, validators, extensions
├── infrastructure/             # Docker compose, Terraform, K8s manifests
├── docs/                       # Architecture diagrams, API specs
└── scripts/                    # CI/CD, Monorepo management (Melos, Turbo)
```

## 2. Shared Package Specifications

To eliminate duplication across `admin_flutter` and `candidate_flutter`:
- **`talentos_design_system`**: A strict UI library. Apps may only use standard Flutter layout widgets (`Column`, `Row`) and MUST import all buttons, cards, typography, and colors from this package.
- **`talentos_models`**: Pure Dart models (generated via Freezed) shared across all client apps, ensuring type-safe parity with the backend OpenAPI schema.
- **`shared_api`**: A pre-configured Dio instance with Interceptors (Auth, Retry, Logging) and Repository contracts.
- **`shared_utils`**: Date formatters, regex patterns, file size calculators, and generic helper functions.

## 3. Event-Driven Architecture

The backend utilizes Domain Events to decouple core business logic from side effects.
When a domain action occurs, an event is emitted internally (e.g., via Node `EventEmitter` or Redis PubSub), and listeners react accordingly.

**Core Domain Events:**
- `CandidateApplied`
- `ResumeUploaded`
- `InterviewScheduled`
- `OfferAccepted`
- `PositionClosed`

*Example Flow*: When a REST controller handles application submission, it commits to the DB and emits `CandidateApplied`. A listener picks this up and pushes a job to the `worker` service to parse the resume, while another listener updates the timeline.

## 4. Generalized Worker Architecture

The `services/worker` is a distinct scalable service processing the background queue. It is generalized to handle all heavy or external-bound tasks:
- **`ResumeParsingTask`**: Communicates with the AI Plugin.
- **`EmailDeliveryTask`**: Communicates with the Notification Plugin.
- **`NotificationDispatchTask`**: Pushes alerts to WebSockets/FCM.
- **`PDFGenerationTask`**: Generates offer letters or candidate summaries.
- **`ExportGenerationTask`**: Compiles large CSV/Excel files for analytics.

## 5. Abstraction Specifications

### SearchService Abstraction
PostgreSQL full-text search will be used initially, but business logic will interface strictly through `ISearchService`.
```typescript
interface ISearchService {
  indexDocument(indexName: string, document: any): Promise<void>;
  search(indexName: string, query: string, filters: any): Promise<any[]>;
}
// Implementations: PostgresSearchProvider, ElasticsearchProvider, MeilisearchProvider
```

### Feature Flag Architecture
A central configuration module allowing dynamic toggling of capabilities per Organization/Tenant.
```json
{
  "org_id": "uuid",
  "flags": {
    "module_recruitment": true,
    "module_payroll": false,
    "ai_resume_parsing": true,
    "advanced_analytics": false
  }
}
```

## 6. Document Metadata Layer

Physical files are separated from their logical representation. The database does not care if the file is in AWS S3 or LocalStorage.
The `CandidateDocument` table stores logical metadata (MIME type, original name, logical ID). The `StorageProvider` maps the logical ID to a physical path/URL.

## 7. Namespace & Application IDs

All generated identifiers must support the future expansion of modules.
Format: `TOS-{MODULE_CODE}-{YEAR}-{SEQUENCE}`
- Recruitment Application: `TOS-REC-2026-000001`
- Employee Record: `TOS-EMP-2026-000045`
- Asset Tag: `TOS-AST-2026-000112`

## 8. OpenAPI Generation Strategy

The backend `services/api` will generate the OpenAPI 3.0 specification automatically based on code annotations or Zod schemas (using `swagger-jsdoc` or `zod-openapi`). 
This spec will automatically generate a Postman Collection accessible at `/api/docs/postman`.

## 9. Future Module Boundaries

TalentOS is architected to seamlessly plug in the following namespaces without breaking the core `Organizations`, `Users`, or `Settings` models:
- **Recruitment** (Current)
- **Employees**
- **Attendance**
- **Assets**
- **Payroll**
- **Performance**
- **Documents**
- **Visitors**
- **Settings** (Global)
