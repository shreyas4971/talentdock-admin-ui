# REST API Documentation (v1)

*All endpoints prefixed with `/api/v1`*

## Settings & Organization
- `GET /branding` (Public - retrieves org colors/logo for Candidate Portal)
- `PUT /branding` (Admin - updates branding)
- `GET /tags` (List internal tags)
- `POST /tags` (Create new tag)

## Positions & Templates
- `GET /templates/positions`
- `POST /templates/positions`
- `POST /positions/from-template/:templateId` (Generates a position based on a template)

## Candidates (Global Profile)
- `GET /candidates`
- `GET /candidates/:id`
- `POST /candidates/merge` (Future: Merges two duplicate candidate profiles based on email/phone)

## Candidate Applications (Kanban)
- `GET /applications`
  - *Query Params*: `kanban=true` (Returns structured lists per status)
- `PUT /applications/:id/status` (Moves card between Kanban columns)
- `POST /applications/:id/tags` (Applies an internal tag)
- `GET /applications/:id/documents/history` (Retrieve versioned document history)

## Intelligent Search & Filters
- `GET /search/global?q=esp32+ahmedabad`
- `POST /users/me/saved-filters` (Save a custom filter combination)
- `GET /users/me/saved-filters`

## Activity & Notifications
- `GET /notifications` (User's unread notifications)
- `PUT /notifications/:id/read`
- `GET /activity-feed` (Chronological feed of organization events)
