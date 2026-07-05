# Environment Strategy

To ensure TalentOS maintains high operational stability during the Product Discovery phase and beyond, all deployments must adhere to a strict three-tier environment architecture.

## 1. Local Environment
- **Purpose**: Active development, debugging, and experimentation.
- **Infrastructure**: Running natively via Node/Flutter CLI or locally spun Docker Compose.
- **Data**: Mock data, seeded manually. Uses Local Storage emulators or mocked GCS logs.

## 2. Staging Environment
- **Purpose**: Pre-production validation, UAT (User Acceptance Testing), and final RFC sign-off.
- **Infrastructure**: Identical to Production (Docker Compose + Nginx proxy), hosted on a distinct cloud VM.
- **Data**: Anonymized clone of Production data, or highly representative fake data. Tied to a separate `staging-bucket` in GCS.

## 3. Production Environment
- **Purpose**: The live, operational tool utilized by recruiters.
- **Infrastructure**: Production VM (or Kubernetes in the future), secured with HTTPS, strict firewall rules, and daily cron backups.
- **Data**: Live Candidate Resumes, real feedback telemetry.

## Deployment Promotion Rules
Code flows strictly in one direction:
`Local` → *Pull Request* → `Staging` → *UAT Sign-off* → `Production`

*Hotfixes* (for critical zero-day bugs) may be expedited to Staging, but must still pass UAT before Production deployment.
