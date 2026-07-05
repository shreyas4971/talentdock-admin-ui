# LESSONS_LEARNED.md

## Successful Architectural Decisions
- **Unified TypeScript Contracts (Deferred but Validated)**: While MVP circumvented strictly typed OpenAPI generation in favor of velocity, the domain-driven abstractions successfully preserved boundaries, making the eventual migration safe.
- **Flutter Web (CanvasKit)**: Yielded pixel-perfect synchronization across Admin and Candidate portals using unified Material 3 tooling.
- **Prisma ORM**: Allowed schema adjustments (like adding `UserFeedback` and standardizing `Position` metrics) instantly with zero downtime.

## Deferred Over-Engineering
- **CQRS & Event Bus (BullMQ/Redis)**: Intentionally archived into `docs/future`. Local monolithic endpoints handled file uploading seamlessly without complex asynchronous queue scaling.
- **Unit of Work & Result Pattern**: Skipped in favor of rapid Express controller error handling. Saved days of boilerplate generation while hitting the strict timeline.
- **Riverpod TalentState**: Rolled back to standard `AsyncValue`, which handled loading/error semantics perfectly without requiring custom sealed classes.

## Libraries & Tools that Worked Well
- `multer` + `@google-cloud/storage`: Native streaming directly from Flutter's `file_picker` (via `PlatformFile.bytes`) was highly resilient.
- `exceljs`: Executed fast native XLSX generation synchronously without stalling the node thread.
- `go_router`: Excellent declarative navigation for deeply nested candidate application pages.

## Pain Points Encountered
- **Windows Environment Execution**: Required strict usage of `.cmd` suffixes (`npm.cmd`, `npx.cmd`) to bypass PowerShell `UnauthorizedAccess` execution policies.
- **Flutter Web Multipart File Uploads**: Requires explicit buffer parsing (`bytes`) from `file_picker`, as the default path mapping fails silently on web engines.

## Recommendations for Future Modules
- **Reintroduce Code Generation**: Begin migrating MVP contracts strictly through OpenAPI generators when data scales.
- **Transition to Node Streams**: The current `multer.memoryStorage()` works perfectly for 10MB resumes, but will crash under heavy concurrent traffic. Stream directly to GCS in v2.
