import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import ExcelJS from 'exceljs';

const router = Router();
const prisma = new PrismaClient();

const requireAuth = (req: any, res: any, next: any) => {
  req.user = { organizationId: 'default-org-id' };
  next();
};

const buildWhereClause = (orgId: string, q: any) => {
  const where: any = { candidate: { organizationId: orgId } };
  
  if (q.positionId) where.positionId = q.positionId;
  if (q.status) where.status = q.status;
  
  if (q.search) {
    const term = String(q.search);
    where.OR = [
      { referenceId: { contains: term, mode: 'insensitive' } },
      { candidate: { firstName: { contains: term, mode: 'insensitive' } } },
      { candidate: { lastName: { contains: term, mode: 'insensitive' } } },
      { candidate: { email: { contains: term, mode: 'insensitive' } } },
      { candidate: { phone: { contains: term, mode: 'insensitive' } } },
      { position: { title: { contains: term, mode: 'insensitive' } } },
      { candidate: { notes: { some: { content: { contains: term, mode: 'insensitive' } } } } }
    ];
  }
  return where;
};

router.get('/export', requireAuth, async (req: any, res: any) => {
  try {
    const applications = await prisma.candidateApplication.findMany({
      where: buildWhereClause(req.user.organizationId, req.query),
      include: { candidate: true, position: true },
      orderBy: { createdAt: 'desc' }
    });

    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet('Candidates');
    
    sheet.columns = [
      { header: 'Reference ID', key: 'ref', width: 20 },
      { header: 'Applied Date', key: 'date', width: 15 },
      { header: 'Position', key: 'pos', width: 30 },
      { header: 'First Name', key: 'fn', width: 20 },
      { header: 'Last Name', key: 'ln', width: 20 },
      { header: 'Email', key: 'email', width: 30 },
      { header: 'Phone', key: 'phone', width: 20 },
      { header: 'Experience (Yrs)', key: 'exp', width: 15 },
      { header: 'Status', key: 'status', width: 15 },
    ];

    sheet.getRow(1).font = { bold: true };

    applications.forEach(app => {
      sheet.addRow({
        ref: app.referenceId,
        date: app.createdAt.toISOString().split('T')[0],
        pos: app.position.title,
        fn: app.candidate.firstName,
        ln: app.candidate.lastName,
        email: app.candidate.email,
        phone: app.candidate.phone || '',
        exp: app.experienceYears || 0,
        status: app.status
      });
    });

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', 'attachment; filename=CandidatesExport.xlsx');

    await workbook.xlsx.write(res);
    
    await prisma.analyticsEvent.create({
      data: { organizationId: req.user.organizationId, eventName: 'EXPORT_EXCEL' }
    });

    res.end();
  } catch (error) {
    res.status(500).json({ success: false, message: 'Export failed' });
  }
});

router.get('/', requireAuth, async (req: any, res: any) => {
  const applications = await prisma.candidateApplication.findMany({
    where: buildWhereClause(req.user.organizationId, req.query),
    include: { candidate: true, position: true },
    orderBy: { createdAt: 'desc' }
  });
  res.json({ success: true, data: applications });
});

router.get('/:id', requireAuth, async (req: any, res: any) => {
  const application = await prisma.candidateApplication.findUnique({
    where: { id: req.params.id },
    include: {
      position: true,
      documents: true,
      timeline: { orderBy: { createdAt: 'desc' } },
      candidate: { include: { notes: { orderBy: { createdAt: 'desc' } }, interviews: true } }
    }
  });
  res.json({ success: true, data: application });
});

router.put('/:id/status', requireAuth, async (req: any, res: any) => {
  const { status } = req.body;
  const application = await prisma.candidateApplication.update({
    where: { id: req.params.id },
    data: { status }
  });
  
  await prisma.candidateTimeline.create({
    data: {
      applicationId: req.params.id,
      eventType: 'STATUS_CHANGE',
      description: `Status changed to ${status}`
    }
  });
  
  await prisma.analyticsEvent.create({
    data: { organizationId: req.user.organizationId, eventName: 'STATUS_CHANGE' }
  });

  res.json({ success: true, data: application });
});

router.post('/:id/notes', requireAuth, async (req: any, res: any) => {
  const application = await prisma.candidateApplication.findUnique({ where: { id: req.params.id } });
  if (!application) return res.status(404).json({ success: false });

  const note = await prisma.candidateNote.create({
    data: {
      candidateId: application.candidateId,
      content: req.body.content
    }
  });

  await prisma.candidateTimeline.create({
    data: {
      applicationId: req.params.id,
      eventType: 'NOTE_ADDED',
      description: 'A note was added to the candidate profile.'
    }
  });

  await prisma.activityFeed.create({
    data: { organizationId: req.user.organizationId, action: 'NOTE_ADDED', entityType: 'CANDIDATE', entityId: application.candidateId }
  });

  res.json({ success: true, data: note });
});

router.delete('/:id/notes/:noteId', requireAuth, async (req: any, res: any) => {
  await prisma.candidateNote.delete({ where: { id: req.params.noteId } });
  res.json({ success: true });
});

router.put('/:id/tags', requireAuth, async (req: any, res: any) => {
  const application = await prisma.candidateApplication.findUnique({ where: { id: req.params.id } });
  if (!application) return res.status(404).json({ success: false });

  await prisma.candidate.update({
    where: { id: application.candidateId },
    data: { tags: req.body.tags || [] }
  });

  res.json({ success: true });
});

router.post('/bulk', requireAuth, async (req: any, res: any) => {
  const { action, ids, status } = req.body;
  
  if (!ids || !ids.length) return res.status(400).json({ success: false });

  if (action === 'delete') {
    await prisma.candidateApplication.deleteMany({ where: { id: { in: ids } } });
  } else if (action === 'updateStatus' && status) {
    await prisma.candidateApplication.updateMany({
      where: { id: { in: ids } },
      data: { status }
    });
    
    // Log timeline events
    for (const id of ids) {
      await prisma.candidateTimeline.create({
        data: {
          applicationId: id,
          eventType: 'STATUS_CHANGE',
          description: `Bulk status changed to ${status}`
        }
      });
    }
  }

  res.json({ success: true });
});

export default router;
