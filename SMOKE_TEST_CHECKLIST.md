# TalentOS Smoke Test Checklist

**Environment:** Production (v1.0.0)
**Date:** [YYYY-MM-DD]
**Tester:** [Name]

## Authentication
- [ ] Log in with valid admin credentials.
- [ ] Verify JWT token securely persists across page reloads.

## Position Management
- [ ] Create a new Position (Draft).
- [ ] Edit the Position to change it to "Published".
- [ ] Verify the Position immediately appears on the public Candidate Portal.

## Candidate Portal
- [ ] Navigate to `http://careers.talentos.local`.
- [ ] Click on the newly published position.
- [ ] Fill out all required fields (First Name, Last Name, Email, Phone, Years Exp).
- [ ] Upload a test PDF Resume (< 10MB).
- [ ] Submit Application.
- [ ] Verify the Success page loads with a generated `REC-YYYY-XXXXXX` Reference ID.

## Candidate Management
- [ ] Return to the Admin Dashboard.
- [ ] Verify the "Total Applications" and "Applications Today" counts have incremented.
- [ ] Navigate to the Candidates list.
- [ ] Verify the new candidate is visible.
- [ ] Click the candidate and successfully download the test PDF Resume (Verify GCS connection).
- [ ] Change the candidate status from `APPLIED` to `INTERVIEW`.

## Export & Telemetry
- [ ] Click "Export to Excel" and verify the downloaded `.xlsx` file contains the candidate.
- [ ] Return to the Dashboard and verify the following Analytics counters incremented:
  - Positions Created
  - Applications Submitted
  - Status Changes
  - Excel Exports

## Feedback
- [ ] Click the Feedback icon in the AppBar.
- [ ] Submit a test feedback entry.
- [ ] Navigate to the Feedback Board route and verify the entry appears.

**Overall Result:** [PASS / FAIL]
**Notes / Defects:** 
