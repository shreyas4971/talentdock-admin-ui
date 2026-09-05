import { Hono } from 'hono';
import { eq, count } from 'drizzle-orm';
import { Env } from '../types';
import { getDb } from '../db/client';
import { candidates, applications, candidateDocuments, candidateTimeline, positions } from '../db/schema';
import { R2StorageService } from '../storage/r2';

const applicationsRoute = new Hono<{ Bindings: Env }>();

/**
 * Helper to generate reference ID: REC-YYYY-000001
 */
async function generateReferenceId(db: any): Promise<string> {
  const currentYear = new Date().getFullYear();
  const total = await db.select({ count: count(applications.id) }).from(applications).get();
  const nextNum = (Number(total?.count) || 0) + 1;
  return `REC-${currentYear}-${String(nextNum).padStart(6, '0')}`;
}

const MAX_RESUME_SIZE = 2 * 1024 * 1024; // 2,097,152 bytes (2 MiB)

function isPdfBuffer(buffer: ArrayBuffer): boolean {
  if (buffer.byteLength < 5) return false;
  const bytes = new Uint8Array(buffer, 0, 5);
  // '%PDF-' ASCII: 0x25, 0x50, 0x44, 0x46, 0x2D
  return bytes[0] === 0x25 && bytes[1] === 0x50 && bytes[2] === 0x44 && bytes[3] === 0x46 && bytes[4] === 0x2D;
}

applicationsRoute.post('/', async (c) => {
  try {
    const contentType = c.req.header('content-type') || '';
    let body: any = {};
    const resumeFiles: File[] = [];

    if (contentType.includes('multipart/form-data')) {
      const formData = await c.req.formData();
      formData.forEach((value, key) => {
        if (typeof value === 'object' && value !== null && 'name' in value) {
          const fileObj = value as unknown as File;
          if (key === 'resume' || key === 'resumeFile' || key.toLowerCase().includes('resume')) {
            resumeFiles.push(fileObj);
          }
        } else {
          body[key] = value;
        }
      });
    } else {
      body = await c.req.json().catch(() => ({}));
    }

    // Required Field Validations
    const positionId = body.positionId;
    const firstName = body.firstName?.trim();
    const lastName = body.lastName?.trim();
    const email = body.email?.toLowerCase().trim();

    if (!positionId) {
      return c.json({ success: false, message: 'Position ID is required' }, 400);
    }
    if (!firstName || !lastName) {
      return c.json({ success: false, message: 'First name and Last name are required' }, 400);
    }
    if (!email || !email.includes('@')) {
      return c.json({ success: false, message: 'Valid email is required' }, 400);
    }

    // Resume validations
    if (resumeFiles.length === 0) {
      return c.json({ success: false, message: 'Resume file is required (PDF only, maximum 2 MB)' }, 400);
    }
    if (resumeFiles.length > 1) {
      return c.json({ success: false, message: 'Only one resume file may be attached' }, 400);
    }

    const resumeFile = resumeFiles[0];
    const originalFileName = resumeFile.name || '';

    // Validate filename extension
    if (!originalFileName.toLowerCase().endsWith('.pdf')) {
      return c.json({ success: false, message: 'Only PDF files are supported for resumes (.pdf extension required)' }, 400);
    }

    // Validate size limit (2 MiB)
    if (resumeFile.size > MAX_RESUME_SIZE) {
      return c.json({ success: false, message: 'Resume file size exceeds the 2 MB limit' }, 400);
    }

    const resumeBuffer = await resumeFile.arrayBuffer();
    if (resumeBuffer.byteLength > MAX_RESUME_SIZE) {
      return c.json({ success: false, message: 'Resume file size exceeds the 2 MB limit' }, 400);
    }

    // Validate magic bytes (%PDF-)
    if (!isPdfBuffer(resumeBuffer)) {
      return c.json({ success: false, message: 'Invalid PDF file. The file content is not a genuine PDF document' }, 400);
    }

    const db = getDb(c.env.DB);

    // Verify position exists
    const position = await db.select().from(positions).where(eq(positions.id, positionId)).get();
    if (!position) {
      return c.json({ success: false, message: 'Position not found' }, 404);
    }

    const now = new Date().toISOString();

    // 1. Find or create candidate
    let candidate = await db.select().from(candidates).where(eq(candidates.email, email)).get();
    const candidateId = candidate ? candidate.id : `can-${Date.now().toString(36)}-${Math.random().toString(36).substring(2, 6)}`;

    const candidateData = {
      id: candidateId,
      firstName,
      lastName,
      email,
      phone: body.phone || body.mobile || candidate?.phone || null,
      city: body.city || candidate?.city || null,
      state: body.state || candidate?.state || null,
      dob: body.dob || candidate?.dob || null,
      highestEducation: body.highestEducation || candidate?.highestEducation || null,
      employmentStatus: body.empStatus || body.employmentStatus || candidate?.employmentStatus || null,
      totalExperience: body.totalExp || body.totalExperience || candidate?.totalExperience || null,
      currentCompany: body.currentCompany || candidate?.currentCompany || null,
      currentDesignation: body.currentDesignation || candidate?.currentDesignation || null,
      expectedSalary: body.expectedSalary || candidate?.expectedSalary || null,
      currentSalary: body.currentSalary || candidate?.currentSalary || null,
      noticePeriod: body.noticePeriod || candidate?.noticePeriod || null,
      joiningDate: body.joiningDate || candidate?.joiningDate || null,
      additionalInfo: body.additionalInfo || candidate?.additionalInfo || null,
      updatedAt: now,
    };

    if (candidate) {
      await db.update(candidates).set(candidateData).where(eq(candidates.id, candidate.id)).run();

      // Clean up previous resume in R2 & D1 for this candidate to maintain single resume invariant
      const existingDocs = await db.select().from(candidateDocuments)
        .where(eq(candidateDocuments.candidateId, candidate.id))
        .all();
      for (const oldDoc of existingDocs) {
        if (oldDoc.documentType === 'RESUME') {
          if (oldDoc.storageKey && c.env.RESUMES_BUCKET) {
            try {
              await R2StorageService.delete(c.env.RESUMES_BUCKET, oldDoc.storageKey);
            } catch (r2Err) {
              console.error('Error cleaning up old resume from R2:', r2Err);
            }
          }
          await db.delete(candidateDocuments).where(eq(candidateDocuments.id, oldDoc.id)).run();
        }
      }
    } else {
      await db.insert(candidates).values({ ...candidateData, createdAt: now }).run();
    }

    // 2. Create application record
    const applicationId = `app-${Date.now().toString(36)}-${Math.random().toString(36).substring(2, 6)}`;
    const referenceId = await generateReferenceId(db);

    await db.insert(applications).values({
      id: applicationId,
      referenceId,
      candidateId,
      positionId,
      status: 'APPLIED',
      hasDecision: false,
      isOpened: false,
      createdAt: now,
      updatedAt: now,
    }).run();

    // 3. Upload Resume to R2 & persist metadata in D1
    const cleanFirstName = (firstName || '').trim();
    const cleanLastName = (lastName || '').trim();
    const formattedResumeName = cleanLastName
      ? `${cleanFirstName} ${cleanLastName}_Resume.pdf`
      : `${cleanFirstName}_Resume.pdf`;

    const resumeStorageKey = R2StorageService.buildResumeKey(positionId, candidateId, formattedResumeName);

    if (c.env.RESUMES_BUCKET) {
      await R2StorageService.upload(c.env.RESUMES_BUCKET, resumeStorageKey, resumeBuffer, {
        contentType: 'application/pdf',
        customMetadata: {
          applicationId,
          candidateId,
          originalName: formattedResumeName,
        },
      });
    }

    await db.insert(candidateDocuments).values({
      id: `doc-${Date.now().toString(36)}-res`,
      applicationId,
      candidateId,
      documentType: 'RESUME',
      fileName: formattedResumeName,
      mimeType: 'application/pdf',
      fileSize: resumeBuffer.byteLength,
      storageKey: resumeStorageKey,
      createdAt: now,
    }).run();

    // 4. Create timeline event
    await db.insert(candidateTimeline).values({
      id: `tl-${Date.now().toString(36)}`,
      applicationId,
      eventType: 'APPLICATION_SUBMITTED',
      description: `Application submitted for ${position.title}`,
      createdAt: now,
    }).run();

    return c.json({
      success: true,
      message: 'Application submitted successfully',
      data: {
        applicationId,
        referenceId,
        candidateEmail: email,
        positionTitle: position.title,
        status: 'APPLIED',
        createdAt: now,
      },
    }, 201);
  } catch (error: any) {
    console.error('Application submission error:', error);
    return c.json({ success: false, message: error.message || 'Application submission failed' }, 500);
  }
});

// Admin Candidate lookup by ID / Application ID
applicationsRoute.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const db = getDb(c.env.DB);
    const app = await db.select().from(applications).where(eq(applications.id, id)).get();

    if (!app) {
      return c.json({ success: false, message: 'Application not found' }, 404);
    }

    const candidate = await db.select().from(candidates).where(eq(candidates.id, app.candidateId)).get();
    const position = await db.select().from(positions).where(eq(positions.id, app.positionId)).get();
    const documents = await db.select().from(candidateDocuments).where(eq(candidateDocuments.applicationId, app.id)).all();
    const timeline = await db.select().from(candidateTimeline).where(eq(candidateTimeline.applicationId, app.id)).all();

    return c.json({
      success: true,
      data: {
        ...app,
        candidate,
        position,
        documents,
        timeline,
      },
    });
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Failed to fetch application' }, 500);
  }
});

export default applicationsRoute;
