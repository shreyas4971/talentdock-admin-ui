# Code Freeze Policy (v1.0.x)

**Status:** ACTIVE

TalentOS Recruitment is currently under a strict **Product Discovery Code Freeze**.

## 1. Allowed Changes
During this period, the only permitted merges into the `develop` and `main` branches are:
- **Bug Fixes:** Resolving confirmed defects in existing MVP features.
- **Security Patches:** Updating vulnerable dependencies or closing security loopholes.
- **Deployment Fixes:** Adjusting Docker, Nginx, or CI/CD pipelines to maintain operational stability.
- **Operational Improvements:** Adding telemetry, logs, or metrics that do not alter the user experience.

## 2. Prohibited Changes
- **No New Features:** Any request that introduces new behavior, UI screens, or workflows is strictly prohibited.
- **No Architectural Refactoring:** Unless classified as a critical hotfix to prevent system collapse.

## 3. The RFC Process
Any request for a new feature or workflow change must be directed through the formal RFC Process.
1. Copy `RFC_TEMPLATE.md`.
2. Fill out the business justification.
3. Submit as a PR to the `rfcs/` directory.
4. Wait for the Quarterly Product Review.

*The Code Freeze will automatically lift once the Discovery Review Trigger is officially fired and the v1.1 scope is locked.*
