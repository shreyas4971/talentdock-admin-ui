# RFC 001: Duplicate Candidate Detection

**Title:** Duplicate Candidate Detection
**Requester:** Recruitment Team
**Date Requested:** 2026-07-05

## Problem Statement
Candidates often submit multiple applications across different open positions, or re-apply after being rejected. Currently, the system treats each submission as a completely isolated profile, polluting the candidate pool and leading to redundant screening calls by recruiters who are unaware of the candidate's past history.

## Frequency of Requests
High. Occurs regularly during high-volume recruitment drives where candidates aggressively apply to all open roles.

## Current Workaround
Recruiters manually search the candidate's name or email in the Candidate List before initiating contact.

## Expected Business Benefit
- Significant reduction in wasted recruiter screening time.
- Better candidate experience (not treating past applicants as strangers).
- Cleaner, more accurate analytics for sourcing pipelines.

## Estimated Complexity
Medium

## Priority
High

## Decision
[Pending Review]

## Proposed Architecture
When a candidate application is submitted, a background job or pre-save hook will compute a match probability score against existing candidate records.
Detection vectors should include:
- Exact matches on `email`.
- Exact matches on `phone`.
- Exact matches on `linkedinUrl` (after URL normalization).
- (Future) Resume text similarity using basic NLP or LLM embedding distance.

If a match is found, the new application will either:
1. Hard-link to the existing underlying Candidate profile (requires decoupling Application from Candidate conceptually if not already done).
2. Or flag the application visually in the UI with a "Possible Duplicate" alert, allowing the recruiter to merge them manually.
