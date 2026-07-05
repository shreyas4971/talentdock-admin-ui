# Technical Debt Register (TECH_DEBT.md)

*Prioritized by Impact*

### 1. File Upload Streaming
**Impact**: High
**Description**: Currently using `multer.memoryStorage()` for candidate resumes. This works for MVP scale but buffers entire files in RAM before uploading to GCS. It will cause Node OOM crashes under high concurrency.
**Remedy**: Migrate to stream parsing directly to Google Cloud Storage (e.g., `multer-google-storage`).

### 2. Manual API Contracts
**Impact**: High
**Description**: Flutter HTTP calls (via `Dio`) and backend controllers are manually mirrored. Changes to one will break the other silently without generated bindings.
**Remedy**: Adopt OpenAPI spec generation (via Swagger/tsoa) and `openapi-generator-cli` for Flutter.

### 3. Application State Architecture
**Impact**: Medium
**Description**: `AsyncValue` and manual `setState` are heavily utilized instead of the unified `TalentState` + Use Case abstraction. It works but fragments loading/error logic across widgets.
**Remedy**: Resurrect the `TalentState` Riverpod boilerplate.

### 4. Logging & Observability
**Impact**: Medium
**Description**: Backend utilizes standard `console.log`. No centralized tracing or error aggregation exists.
**Remedy**: Implement `winston` / `pino` and export to Datadog or Sentry.
