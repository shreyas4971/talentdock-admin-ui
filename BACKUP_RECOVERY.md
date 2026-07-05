# Backup & Recovery Verification (BACKUP_RECOVERY.md)

### Objective
Ensure TalentOS PostgreSQL application data and GCS unstructured data can be reliably recovered in the event of a critical failure.

### Test Protocol (Executed: 2026-07-05)

1. **Backup PostgreSQL**
   - Command: `pg_dump -U user -h localhost -d talentos_db -F c -f talentos_backup.dump`
   - Outcome: **Success**. Backup file successfully localized to disk.

2. **Database Scrubbing**
   - Command: `psql -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"`
   - Outcome: **Success**.

3. **Restore PostgreSQL to a Clean Environment**
   - Command: `pg_restore -U user -d talentos_db -1 talentos_backup.dump`
   - Outcome: **Success**. Tables and records fully verified.

4. **Verify Google Cloud Storage Synchronization**
   - Checked `CandidateDocument.storageKey` against GCS Bucket console.
   - Outcome: **Success**. Soft-delete retention and pathing remained aligned. Resumes successfully downloaded via the Admin UI.

5. **Application Verification**
   - Bootstrapped Express and Flutter Admin Web.
   - Verified Search, Filtering, and Authentication.
   - Outcome: **Success**. No orphaned records or synchronization drifts detected between SQL pointers and GCS objects.

### Operational Guidelines
- **RPO (Recovery Point Objective)**: 24 Hours (Nightly pg_dump cron jobs).
- **RTO (Recovery Time Objective)**: < 2 Hours.
- Automated backups must be exported out of the local availability zone into encrypted cold storage (e.g., S3 Glacier / GCS Archive).
