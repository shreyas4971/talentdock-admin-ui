# Operational Dashboard Specification

*This document defines the requirements for a future dedicated System Operations Dashboard, intended for System Administrators rather than Recruiters.*

## Objective
Provide real-time observability of TalentOS infrastructure health, enabling proactive maintenance during the Product Discovery phase.

## Required Metrics

1. **Application Uptime**
   - Current status of the Express API and Postgres DB.
   - 30-day trailing uptime percentage.

2. **Error Rates**
   - Count of `5xx` responses in the last 24 hours.
   - Count of Authentication Failures (`401/403`) in the last 24 hours.

3. **Backup Status**
   - Timestamp of the last successful PostgreSQL backup.
   - File size of the last backup (to detect sudden data loss anomalies).

4. **Storage Usage**
   - Total GB utilized in the Google Cloud Storage bucket.
   - Projected runway before quota limits are reached.

5. **Operational Activity**
   - **Active Recruiters**: Count of distinct `admin` logins in the last 7 days.
   - **Active Positions**: Count of `PUBLISHED` positions currently routing traffic.
   - **Recent Feedback**: Count of `NEW` entries in the Feedback Tracker.

6. **Issue Tracker Sync**
   - Count of Open `BUG-###` tickets in the repository.

## Implementation Approach
- Display within the Admin Flutter application under a strictly RBAC-gated `/system-ops` route.
- Alternatively, export these metrics to Grafana/Datadog if infrastructure scales.
