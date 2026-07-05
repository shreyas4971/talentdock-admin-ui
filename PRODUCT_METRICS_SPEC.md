# Product Metrics Dashboard Specification

*This document outlines the requirements for extending the v1.0.0 Admin Dashboard analytics in a future release.*

## Objective
To evolve the existing simple counters into actionable trend data that identifies operational bottlenecks and system health issues without relying on third-party telemetry tools.

## 1. Recruitment Metrics (Business Domain)
These metrics measure the efficiency of the hiring pipeline.
- **Applications per Position**: Average ratio to determine which roles are over/under-performing.
- **Time to First Review**: The average duration (in days) between `APPLICATION_SUBMITTED` and the first status change by a recruiter.
- **Time to Shortlist**: The average duration from application to `INTERVIEW` status.
- **Time to Hire**: Total lifecycle duration from application to `HIRED` status.
- **Rejection Rate**: Percentage of applications moving to `REJECTED` per position.

## 2. System Metrics (Technical Domain)
These metrics measure platform stability and friction points.
- **Resume Upload Failures**: Count of 500s or timeouts during GCS transfers. High rates indicate networking or configuration issues.
- **Average Application Completion Time**: Time spent by the candidate on the application form before successful submission.
- **Excel Exports**: Frequency of exports. (Spikes indicate recruiters are bypassing the UI to work in Excel, highlighting missing UI features).
- **Feedback Submitted**: Trend line of user-reported issues.
- **Login Failures**: Tracked 401s to identify potential brute-force or credential confusion.

## Implementation Approach
- Display these as visual trend cards (line/bar charts) on the Admin Dashboard using a Flutter charting library (e.g., `fl_chart`).
- Introduce an aggregation cron-job or rely on SQL aggregations if performance allows.
