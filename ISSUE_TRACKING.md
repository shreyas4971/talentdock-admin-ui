# Issue Tracking Convention

To maintain order during the Product Discovery and Operational phases, all project work must be categorized using the following prefix taxonomy in your issue tracker (Jira/Linear/GitHub Issues) and corresponding Git branch names.

## Taxonomy

1. **BUG-###**
   - **Definition**: A defect in an existing, deployed feature (e.g., File upload timing out, UI overlapping on mobile).
   - **Workflow**: Can be executed immediately during a Code Freeze.
   - **Branch**: `fix/BUG-###-short-description`

2. **RFC-###**
   - **Definition**: A formal Request for Comment proposing a new feature or architectural pivot.
   - **Workflow**: Must be drafted as a Markdown file in `rfcs/`, reviewed, and formally Approved before any code is written.
   - **Branch**: `feature/RFC-###-short-description`

3. **TASK-###**
   - **Definition**: Routine maintenance, dependency bumps, or operational chores (e.g., renewing SSL certificates, rotating JWT secrets).
   - **Workflow**: Executed alongside bug fixes.
   - **Branch**: `chore/TASK-###-short-description`

## Priorities
- **P0 (Critical)**: Production is down. Immediate hotfix required.
- **P1 (High)**: Core workflow blocked, no workaround exists.
- **P2 (Medium)**: Core workflow impacted, but a workaround exists.
- **P3 (Low)**: Cosmetic issue or minor annoyance.
