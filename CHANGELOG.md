# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-07-05
### Added
- **Authentication**: JWT-based secure authentication.
- **Position Management**: Full CRUD capabilities for open job postings.
- **Candidate Applications**: Candidate portal for applying and natively uploading resumes.
- **Candidate Management**: Admin filtering, searching, and status tracking (Applied -> Hired).
- **Excel Export**: Node.js pipeline generating `.xlsx` natively based on dynamic UI filters.
- **Feedback Module**: Internal feedback tracker routing UX requests directly to the DB.
- **Usage Analytics**: Real-time counter of system interactions integrated into the Dashboard.
- **Production Configs**: Docker Compose, Nginx, and Winston logging for stable deployment.
