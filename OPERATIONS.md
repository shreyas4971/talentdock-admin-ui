# TalentDock Operations Manual

## 1. Startup Instructions
Deploying the application requires Docker and Docker Compose.
1. Copy `.env.example` to `.env` and configure securely.
2. Ensure you drop your Google Service Account key in the root directory named `gcs-key.json`.
3. Run the orchestration:
   ```bash
   docker-compose up -d --build
   ```
4. Perform the initial database migration:
   ```bash
   docker-compose exec api npx prisma db push
   ```

## 2. Daily Administration
- **Admin Portal**: Access via `http://admin.talentdock.local` (Port 80 via Nginx routing).
- **Careers Portal**: Access via `http://careers.talentdock.local`.
- **Database Management**: Access `http://localhost:5050` to use pgAdmin (credentials in `.env`).

## 3. Logging Locations
- Backend API logs are output utilizing Winston and persisted to the host machine via a Docker volume bind.
- **Access Logs**: `logs/combined.log`
- **Error Logs**: `logs/error.log`
- NGINX Access/Error logs are standard output via `docker-compose logs nginx`.

## 4. Backup & Restore Procedure
- **Backup**: 
  ```bash
  docker-compose exec db pg_dump -U talentdock_user -d talentdock_db -F c -f /var/lib/postgresql/data/backup.dump
  ```
- **Restore**:
  ```bash
  docker-compose exec db pg_restore -U talentdock_user -d talentdock_db -1 /var/lib/postgresql/data/backup.dump
  ```

## 5. Upgrade Instructions
When deploying a new version (e.g., pulling v1.1.0):
1. `git pull origin main`
2. `docker-compose down`
3. `docker-compose up -d --build`
4. `docker-compose exec api npx prisma db push` (To apply any schema extensions).

## 6. Common Troubleshooting
- **Resumes failing to upload**: Ensure `gcs-key.json` is physically present, mapped correctly in `docker-compose.yml`, and the bucket name matches `.env`. Check `logs/error.log` for `@google-cloud/storage` auth exceptions.
- **Flutter Web showing 404 on refresh**: Ensure NGINX routing rules in `nginx/nginx.conf` are intact. The internal containers use `try_files $uri /index.html` locally.
- **Database Connection Refused**: Verify the `api` container environment variable `DATABASE_URL` accurately matches the `db` container credentials.
