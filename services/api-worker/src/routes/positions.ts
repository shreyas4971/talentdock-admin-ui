import { Hono } from 'hono';
import { eq, desc, count, or, sql } from 'drizzle-orm';
import { Env } from '../types';
import { getDb } from '../db/client';
import { positions, applications, candidateDocuments, candidateTimeline } from '../db/schema';
import { authMiddleware } from '../middleware/auth';

const positionsRoute = new Hono<{ Bindings: Env }>();

// Helper to format position for UI consumption
function formatPosition(p: typeof positions.$inferSelect) {
  let responsibilities: string[] = [];
  let requirements: string[] = [];
  let benefits: string[] = [];
  let skills: string[] = [];

  try {
    if (p.responsibilities) responsibilities = JSON.parse(p.responsibilities);
  } catch {}
  try {
    if (p.requirements) requirements = JSON.parse(p.requirements);
  } catch {}
  try {
    if (p.benefits) benefits = JSON.parse(p.benefits);
  } catch {}
  try {
    if (p.skills) skills = JSON.parse(p.skills);
  } catch {}

  const minExp = p.minExperience ?? 0;
  const maxExp = p.maxExperience ?? 5;
  const expDisplay = p.experience && p.experience !== '1-3 Years'
    ? p.experience
    : (minExp || maxExp ? `${minExp}-${maxExp} Years` : '1-3 Years');

  return {
    id: p.id,
    title: p.title,
    department: p.department,
    location: p.location,
    employmentType: p.employmentType,
    type: p.employmentType, // compatibility alias
    experience: expDisplay,
    minExperience: minExp,
    minExp,
    maxExperience: maxExp,
    maxExp,
    relevantExperience: p.relevantExperience ?? 0,
    noticePeriod: p.noticePeriod ?? '30 Days',
    maxNoticePeriod: p.noticePeriod ?? '30 Days',
    immediateJoiner: Boolean(p.immediateJoiner),
    immediateJoinerRequired: Boolean(p.immediateJoiner),
    skills,
    specifications: skills,
    specs: skills,
    status: p.status,
    pinned: p.isPinned,
    isPinned: p.isPinned,
    shortDescription: p.shortDescription || p.description?.substring(0, 120) || '',
    description: p.description || '',
    responsibilities,
    requirements,
    benefits,
    postedDate: p.createdAt,
    createdAt: p.createdAt,
    updatedAt: p.updatedAt,
  };
}

// 1. Public Positions (for Candidate Portal)
positionsRoute.get('/public', async (c) => {
  try {
    const db = getDb(c.env.DB);
    const posList = await db
      .select()
      .from(positions)
      .where(or(eq(positions.status, 'PUBLISHED'), eq(positions.status, 'published'), eq(positions.status, 'Published')))
      .orderBy(desc(positions.createdAt))
      .all();

    return c.json({
      success: true,
      data: posList.map(formatPosition),
    });
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Failed to fetch public positions' }, 500);
  }
});

// 2. Public Position Details by ID
positionsRoute.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const db = getDb(c.env.DB);
    const pos = await db.select().from(positions).where(eq(positions.id, id)).get();

    if (!pos) {
      return c.json({ success: false, message: 'Position not found' }, 404);
    }

    return c.json({
      success: true,
      data: formatPosition(pos),
    });
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Failed to fetch position' }, 500);
  }
});

// 3. Admin: List All Positions (with applicant counts)
positionsRoute.get('/', authMiddleware as any, async (c) => {
  try {
    const db = getDb(c.env.DB);
    const posList = await db.select().from(positions).orderBy(desc(positions.createdAt)).all();

    // Fetch application counts per position
    const appCounts = await db
      .select({
        positionId: applications.positionId,
        count: count(applications.id),
      })
      .from(applications)
      .groupBy(applications.positionId)
      .all();

    const countMap = new Map<string, number>();
    for (const item of appCounts) {
      countMap.set(item.positionId, Number(item.count));
    }

    const result = posList.map((p) => {
      const formatted = formatPosition(p);
      return {
        ...formatted,
        applications: countMap.get(p.id) || 0,
      };
    });

    return c.json({
      success: true,
      data: result,
    });
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Failed to fetch admin positions' }, 500);
  }
});

// 4. Admin: Create Position
positionsRoute.post('/', authMiddleware as any, async (c) => {
  try {
    const body = await c.req.json();
    const now = new Date().toISOString();
    const id = `pos-${Date.now().toString(36)}`;

    const minExp = body.minExperience !== undefined ? Number(body.minExperience) : (body.minExp !== undefined ? Number(body.minExp) : 0);
    const maxExp = body.maxExperience !== undefined ? Number(body.maxExperience) : (body.maxExp !== undefined ? Number(body.maxExp) : 5);
    const expStr = body.experience || (minExp || maxExp ? `${minExp}-${maxExp} Years` : '1-3 Years');

    let skillsStr = '[]';
    if (Array.isArray(body.skills)) {
      skillsStr = JSON.stringify(body.skills);
    } else if (Array.isArray(body.specifications)) {
      skillsStr = JSON.stringify(body.specifications);
    } else if (Array.isArray(body.specs)) {
      skillsStr = JSON.stringify(body.specs);
    } else if (typeof body.skills === 'string') {
      skillsStr = body.skills;
    }

    const newPosition = {
      id,
      title: body.title || 'Untitled Position',
      department: body.department || 'Engineering',
      location: body.location || 'Remote',
      employmentType: body.employmentType || body.type || 'Full-time',
      experience: expStr,
      minExperience: minExp,
      maxExperience: maxExp,
      relevantExperience: body.relevantExperience !== undefined ? Number(body.relevantExperience) : 0,
      noticePeriod: body.noticePeriod || body.maxNoticePeriod || '30 Days',
      immediateJoiner: Boolean(body.immediateJoiner || body.immediateJoinerRequired),
      skills: skillsStr,
      status: (body.status || 'DRAFT').toUpperCase(),
      isPinned: body.pinned ?? body.isPinned ?? false,
      shortDescription: body.shortDescription || '',
      description: body.description || '',
      responsibilities: Array.isArray(body.responsibilities) ? JSON.stringify(body.responsibilities) : (body.responsibilities || '[]'),
      requirements: Array.isArray(body.requirements) ? JSON.stringify(body.requirements) : (body.requirements || '[]'),
      benefits: Array.isArray(body.benefits) ? JSON.stringify(body.benefits) : (body.benefits || '[]'),
      createdAt: now,
      updatedAt: now,
    };

    const db = getDb(c.env.DB);
    await db.insert(positions).values(newPosition).run();

    return c.json({
      success: true,
      data: formatPosition(newPosition as any),
    }, 201);
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Failed to create position' }, 500);
  }
});

// 5. Admin: Update Position
positionsRoute.put('/:id', authMiddleware as any, async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();
    const now = new Date().toISOString();

    const db = getDb(c.env.DB);
    const existing = await db.select().from(positions).where(eq(positions.id, id)).get();
    if (!existing) {
      return c.json({ success: false, message: 'Position not found' }, 404);
    }

    const updates: Partial<typeof positions.$inferInsert> = {
      updatedAt: now,
    };

    if (body.title !== undefined) updates.title = body.title;
    if (body.department !== undefined) updates.department = body.department;
    if (body.location !== undefined) updates.location = body.location;
    if (body.employmentType !== undefined) updates.employmentType = body.employmentType;
    if (body.type !== undefined) updates.employmentType = body.type;
    if (body.status !== undefined) updates.status = body.status.toUpperCase();
    if (body.pinned !== undefined) updates.isPinned = body.pinned;
    if (body.isPinned !== undefined) updates.isPinned = body.isPinned;
    if (body.shortDescription !== undefined) updates.shortDescription = body.shortDescription;
    if (body.description !== undefined) updates.description = body.description;
    
    if (body.minExperience !== undefined) updates.minExperience = Number(body.minExperience);
    else if (body.minExp !== undefined) updates.minExperience = Number(body.minExp);
    
    if (body.maxExperience !== undefined) updates.maxExperience = Number(body.maxExperience);
    else if (body.maxExp !== undefined) updates.maxExperience = Number(body.maxExp);
    
    if (body.relevantExperience !== undefined) updates.relevantExperience = Number(body.relevantExperience);
    if (body.noticePeriod !== undefined) updates.noticePeriod = String(body.noticePeriod);
    else if (body.maxNoticePeriod !== undefined) updates.noticePeriod = String(body.maxNoticePeriod);
    
    if (body.immediateJoiner !== undefined) updates.immediateJoiner = Boolean(body.immediateJoiner);
    else if (body.immediateJoinerRequired !== undefined) updates.immediateJoiner = Boolean(body.immediateJoinerRequired);

    if (body.skills !== undefined) {
      updates.skills = Array.isArray(body.skills) ? JSON.stringify(body.skills) : String(body.skills);
    } else if (body.specifications !== undefined) {
      updates.skills = Array.isArray(body.specifications) ? JSON.stringify(body.specifications) : String(body.specifications);
    } else if (body.specs !== undefined) {
      updates.skills = Array.isArray(body.specs) ? JSON.stringify(body.specs) : String(body.specs);
    }

    if (body.experience !== undefined) {
      updates.experience = body.experience;
    } else if (body.minExperience !== undefined || body.maxExperience !== undefined || body.minExp !== undefined || body.maxExp !== undefined) {
      const minE = updates.minExperience ?? existing.minExperience ?? 0;
      const maxE = updates.maxExperience ?? existing.maxExperience ?? 5;
      updates.experience = `${minE}-${maxE} Years`;
    }

    if (body.responsibilities !== undefined) {
      updates.responsibilities = Array.isArray(body.responsibilities) ? JSON.stringify(body.responsibilities) : body.responsibilities;
    }
    if (body.requirements !== undefined) {
      updates.requirements = Array.isArray(body.requirements) ? JSON.stringify(body.requirements) : body.requirements;
    }
    if (body.benefits !== undefined) {
      updates.benefits = Array.isArray(body.benefits) ? JSON.stringify(body.benefits) : body.benefits;
    }

    await db.update(positions).set(updates).where(eq(positions.id, id)).run();
    const updated = await db.select().from(positions).where(eq(positions.id, id)).get();

    return c.json({
      success: true,
      data: formatPosition(updated!),
    });
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Failed to update position' }, 500);
  }
});

// 6. Admin: Delete / Remove Position
positionsRoute.delete('/:id', authMiddleware as any, async (c) => {
  try {
    const id = c.req.param('id');
    const db = getDb(c.env.DB);
    const existing = await db.select().from(positions).where(eq(positions.id, id)).get();
    if (!existing) {
      return c.json({ success: false, message: 'Position not found' }, 404);
    }

    const apps = await db.select().from(applications).where(eq(applications.positionId, id)).all();
    for (const app of apps) {
      await db.delete(candidateDocuments).where(eq(candidateDocuments.applicationId, app.id)).run();
      await db.delete(candidateTimeline).where(eq(candidateTimeline.applicationId, app.id)).run();
    }
    if (apps.length > 0) {
      await db.delete(applications).where(eq(applications.positionId, id)).run();
    }
    await db.delete(positions).where(eq(positions.id, id)).run();

    return c.json({ success: true, message: 'Position deleted successfully' });
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Failed to delete position' }, 500);
  }
});

export default positionsRoute;
