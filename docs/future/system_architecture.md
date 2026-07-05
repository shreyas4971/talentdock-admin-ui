# System Architecture & Workflows

## Candidate Lifecycle Specification & Kanban Pipeline

The platform uses a state-machine-like approach for applications, visualized as a Kanban board.

**States:**
`APPLIED` -> `UNDER_REVIEW` -> `TECHNICAL_REVIEW` -> `HR_REVIEW` -> `OFFER` -> `HIRED` | `REJECTED`

**Lifecycle Actions:**
- **Drag-and-Drop**: Moving a card in the Kanban board triggers a `PUT /applications/:id/status` request.
- **Timeline Binding**: Every state transition automatically generates a `CandidateTimeline` event. The timeline is append-only; history is never lost.
- **Activity Feed**: Significant transitions (e.g., `OFFER`, `HIRED`) broadcast to the Organization's `ActivityFeed`.

## Global Search Architecture

Search must be instantaneous and span multiple entities.

**Implementation Details:**
- **Indexing**: A text index in PostgreSQL (or integration with a specialized search engine like ElasticSearch/Meilisearch in the future).
- **Behavior**: When querying "esp32 5 years ahmedabad":
  1. Tokenizer splits keywords.
  2. Query searches `Candidate.skills`, `Candidate.address`, `Position.title`, `CandidateApplication.tags`.
  3. Returns a unified list of Candidates and Positions matching the criteria.

## Resume Versioning Flow

Candidates may apply to multiple jobs or update their resume during the process.

**Flow:**
1. Candidate uploads `Resume_v2.pdf`.
2. Storage Provider saves to `organizations/{org}/candidates/{candidate_id}/documents/Resume_v2.pdf`.
3. Database `CandidateDocument` is created with `version: 2` and `isCurrent: true`. The previous document's `isCurrent` is set to `false`.
4. Administrators viewing the profile see the current resume by default, with a dropdown to view historical versions.

## Notification Architecture

Separate from the Activity Feed.

- **Activity Feed**: An audit trail of what happened in the system (e.g., "Admin John closed position XYZ").
- **Notification Center**: Actionable alerts directed at a specific user (e.g., "You have a technical interview in 15 minutes", "New application requires your review").
- **Delivery**: Notifications are saved to the Database, pushed via WebSockets (or Polling fallback) to the Flutter client, and dispatched to the `NotificationProvider` (Email/Push) based on user preferences.
