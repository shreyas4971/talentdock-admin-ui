import { Hono } from 'hono';
import { eq, desc } from 'drizzle-orm';
import { Env } from '../types';
import { getDb } from '../db/client';
import { candidates, applications, positions } from '../db/schema';
import { authMiddleware } from '../middleware/auth';

const searchRoute = new Hono<{ Bindings: Env }>();

/**
 * Global Search for Candidates and Positions (Authenticated Admin)
 */
searchRoute.get('/', authMiddleware as any, async (c) => {
  try {
    const query = (c.req.query('q') || '').trim();

    if (!query) {
      return c.json({
        success: true,
        data: {
          candidates: [],
          positions: [],
        },
      });
    }

    const s = query.toLowerCase();
    const db = getDb(c.env.DB);

    // 1. Search Candidates & Applications
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

    const matchedCandidates = appList
      .filter((row) => {
        const fullName = `${row.candidate.firstName} ${row.candidate.lastName}`.toLowerCase();
        const email = (row.candidate.email || '').toLowerCase();
        const phone = (row.candidate.phone || '').toLowerCase();
        const refId = (row.application.referenceId || '').toLowerCase();
        const appId = (row.application.id || '').toLowerCase();
        const candId = (row.candidate.id || '').toLowerCase();

        return (
          fullName.includes(s) ||
          email.includes(s) ||
          phone.includes(s) ||
          refId.includes(s) ||
          appId.includes(s) ||
          candId.includes(s)
        );
      })
      .slice(0, 10)
      .map((row) => ({
        id: row.application.id,
        candidateId: row.candidate.id,
        name: `${row.candidate.firstName} ${row.candidate.lastName}`,
        positionTitle: row.position.title,
        referenceId: row.application.referenceId,
        status: row.application.status,
      }));

    // 2. Search Positions
    const posList = await db
      .select()
      .from(positions)
      .orderBy(desc(positions.createdAt))
      .all();

    const matchedPositions = posList
      .filter((pos) => {
        const title = (pos.title || '').toLowerCase();
        const dept = (pos.department || '').toLowerCase();
        const id = (pos.id || '').toLowerCase();

        return title.includes(s) || dept.includes(s) || id.includes(s);
      })
      .slice(0, 10)
      .map((pos) => ({
        id: pos.id,
        title: pos.title,
        department: pos.department,
        location: pos.location,
        status: pos.status,
      }));

    return c.json({
      success: true,
      data: {
        candidates: matchedCandidates,
        positions: matchedPositions,
      },
    });
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Search failed' }, 500);
  }
});

export default searchRoute;
