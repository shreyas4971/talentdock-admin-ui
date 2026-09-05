import { Hono } from 'hono';
import { eq, desc, or, like } from 'drizzle-orm';
import { Env } from '../types';
import { getDb } from '../db/client';
import { candidates, applications, positions, candidateNotes, candidateDocuments, candidateTimeline } from '../db/schema';
import { authMiddleware } from '../middleware/auth';
import { R2StorageService } from '../storage/r2';

const candidatesRoute = new Hono<{ Bindings: Env }>();

// 1. List / Search Candidates (Admin)
candidatesRoute.get('/', authMiddleware as any, async (c) => {
  try {
    const search = c.req.query('search') || '';
    const statusFilter = c.req.query('status');
    const positionIdFilter = c.req.query('positionId');

    const db = getDb(c.env.DB);
    const appList = await db
      .select({
        application: applications,
        candidate: candidates,
        position: positions,
      })
      .from(applications)
      .innerJoin(candidates, eq(applications.candidateId, candidates.id))
      .innerJoin(positions, eq(applications.positionId, positions.id))
      .orderBy(desc(applications.createdAt))
      .all();

    const formatted = appList
      .filter((row) => {
        if (statusFilter && row.application.status.toUpperCase() !== statusFilter.toUpperCase()) {
          return false;
        }
        if (positionIdFilter && row.position.id !== positionIdFilter) {
          return false;
        }
        if (search) {
          const s = search.toLowerCase();
          const fullName = `${row.candidate.firstName} ${row.candidate.lastName}`.toLowerCase();
          const email = row.candidate.email.toLowerCase();
          const posTitle = row.position.title.toLowerCase();
          const ref = row.application.referenceId.toLowerCase();
          return fullName.includes(s) || email.includes(s) || posTitle.includes(s) || ref.includes(s);
        }
        return true;
      })
      .map((row) => ({
        id: row.application.id,
        candidateId: row.candidate.id,
        referenceId: row.application.referenceId,
        name: `${row.candidate.firstName} ${row.candidate.lastName}`,
        firstName: row.candidate.firstName,
        lastName: row.candidate.lastName,
        email: row.candidate.email,
        phone: row.candidate.phone,
        position: row.position.title,
        positionId: row.position.id,
        location: row.candidate.city ? `${row.candidate.city}, ${row.candidate.state || ''}` : row.position.location,
        experience: row.candidate.totalExperience || '1 Year',
        notice: row.candidate.noticePeriod || '30 Days',
        status: row.application.status,
        date: row.application.createdAt,
        isOpened: row.application.isOpened,
        hasDecision: row.application.hasDecision,
      }));

    return c.json({
      success: true,
      data: formatted,
    });
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Failed to list candidates' }, 500);
  }
});

// 2. Candidate Details
candidatesRoute.get('/:id', authMiddleware as any, async (c) => {
  try {
    const id = c.req.param('id');
    const db = getDb(c.env.DB);

    // Can be application ID or candidate ID
    let app = await db.select().from(applications).where(eq(applications.id, id)).get();
    let candidateId = app ? app.candidateId : id;

    const candidate = await db.select().from(candidates).where(eq(candidates.id, candidateId)).get();
    if (!candidate) {
      return c.json({ success: false, message: 'Candidate not found' }, 404);
    }

    if (!app) {
      app = await db.select().from(applications).where(eq(applications.candidateId, candidate.id)).get();
    }

    const position = app ? await db.select().from(positions).where(eq(positions.id, app.positionId)).get() : null;
    const notes = await db.select().from(candidateNotes).where(eq(candidateNotes.candidateId, candidate.id)).orderBy(desc(candidateNotes.createdAt)).all();
    const docs = app ? await db.select().from(candidateDocuments).where(eq(candidateDocuments.applicationId, app.id)).all() : [];
    const timeline = app ? await db.select().from(candidateTimeline).where(eq(candidateTimeline.applicationId, app.id)).orderBy(desc(candidateTimeline.createdAt)).all() : [];

    return c.json({
      success: true,
      data: {
        candidate,
        application: app,
        position,
        notes,
        documents: docs,
        timeline,
      },
    });
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Failed to fetch candidate details' }, 500);
  }
});

// 3. Update Status
candidatesRoute.put('/:id/status', authMiddleware as any, async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();
    const { status } = body;
    const now = new Date().toISOString();

    const db = getDb(c.env.DB);
    let app = await db.select().from(applications).where(eq(applications.id, id)).get();
    if (!app) {
      app = await db.select().from(applications).where(eq(applications.candidateId, id)).get();
    }

    if (!app) {
      return c.json({ success: false, message: 'Application not found' }, 404);
    }

    await db.update(applications).set({ status, updatedAt: now }).where(eq(applications.id, app.id)).run();

    await db.insert(candidateTimeline).values({
      id: `tl-${Date.now().toString(36)}`,
      applicationId: app.id,
      eventType: 'STATUS_CHANGED',
      description: `Status changed to ${status}`,
      createdAt: now,
    }).run();

    return c.json({ success: true, message: 'Status updated' });
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Failed to update status' }, 500);
  }
});

// 4. Add Candidate Note
candidatesRoute.post('/:id/notes', authMiddleware as any, async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();
    const { content } = body;
    const now = new Date().toISOString();

    if (!content) {
      return c.json({ success: false, message: 'Note content is required' }, 400);
    }

    const db = getDb(c.env.DB);
    let candidate = await db.select().from(candidates).where(eq(candidates.id, id)).get();
    if (!candidate) {
      const app = await db.select().from(applications).where(eq(applications.id, id)).get();
      if (app) {
        candidate = await db.select().from(candidates).where(eq(candidates.id, app.candidateId)).get();
      }
    }

    if (!candidate) {
      return c.json({ success: false, message: 'Candidate not found' }, 404);
    }

    const noteId = `note-${Date.now().toString(36)}`;
    await db.insert(candidateNotes).values({
      id: noteId,
      candidateId: candidate.id,
      content,
      createdAt: now,
      updatedAt: now,
    }).run();

    return c.json({ success: true, data: { id: noteId, candidateId: candidate.id, content, createdAt: now } }, 201);
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Failed to add note' }, 500);
  }
});

// 5. Resume Download / Stream from R2
candidatesRoute.get('/:id/resume', authMiddleware as any, async (c) => {
  try {
    const id = c.req.param('id');
    const db = getDb(c.env.DB);

    const doc = await db
      .select()
      .from(candidateDocuments)
      .where(or(eq(candidateDocuments.applicationId, id), eq(candidateDocuments.candidateId, id)))
      .get();

    if (!doc || !c.env.RESUMES_BUCKET) {
      return c.json({ success: false, message: 'Resume document not found' }, 404);
    }

    const object = await R2StorageService.get(c.env.RESUMES_BUCKET, doc.storageKey);
    if (!object) {
      return c.json({ success: false, message: 'File not found in storage' }, 404);
    }

    const headers = new Headers();
    headers.set('Content-Type', doc.mimeType || 'application/pdf');
    headers.set('Content-Disposition', `inline; filename="${doc.fileName}"`);

    return new Response(object.body as any, { headers });
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Failed to retrieve resume' }, 500);
  }
});

export default candidatesRoute;
