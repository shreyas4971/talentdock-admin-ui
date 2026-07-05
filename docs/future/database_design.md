# Database Design & Schema (Frozen v1.0)

This schema reflects the Frozen v1.0 architecture for the TalentOS platform.

## Key Updates
- **Document Metadata Layer**: `Document` is a logical record; the storage provider handles the physical mapping.
- **Application IDs**: Uses the `TOS-REC-YYYY-XXXX` format.
- **Feature Flags**: Added an `OrganizationFeatureFlag` model to support module toggling.

## Prisma Schema

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Organization {
  id                String             @id @default(uuid())
  name              String
  branding          Branding?
  featureFlags      OrganizationFeatureFlag?
  
  users             User[]
  candidates        Candidate[]
  positions         Position[]
  positionTemplates PositionTemplate[]
  
  activityFeed      ActivityFeed[]
  createdAt         DateTime           @default(now())
  updatedAt         DateTime           @updatedAt
  deletedAt         DateTime?
}

model OrganizationFeatureFlag {
  id             String       @id @default(uuid())
  organizationId String       @unique
  organization   Organization @relation(fields: [organizationId], references: [id])
  flags          Json         // e.g., { "module_recruitment": true, "ai_parsing": true }
  updatedAt      DateTime     @updatedAt
}

// ... Branding and User models remain identical to previous iteration ...

model CandidateApplication {
  id             String       @id // Format: TOS-REC-2026-000001
  candidateId    String
  candidate      Candidate    @relation(fields: [candidateId], references: [id])
  positionId     String
  position       Position     @relation(fields: [positionId], references: [id])
  status         String       @default("APPLIED") 
  
  documents      CandidateDocument[]
  timeline       CandidateTimeline[]
  
  createdAt      DateTime     @default(now())
  updatedAt      DateTime     @updatedAt
  deletedAt      DateTime?
}

// Logical Document Metadata Layer
model CandidateDocument {
  id             String               @id @default(uuid())
  applicationId  String
  application    CandidateApplication @relation(fields: [applicationId], references: [id])
  logicalName    String               // e.g., Resume_v1
  mimeType       String               // application/pdf
  sizeBytes      Int
  storageKey     String               // Opaque reference passed to StorageProvider
  version        Int                  @default(1)
  isCurrent      Boolean              @default(true)
  createdAt      DateTime             @default(now())
}
```
*(Other models including Candidate, Position, Tags, etc. remain unchanged from previous iteration)*
