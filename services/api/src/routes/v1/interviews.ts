import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

const requireAuth = (req: any, res: any, next: any) => {
  req.user = { organizationId: 'default-org-id' };
  next();
};

router.use(requireAuth);

router.get('/', async (req: any, res: any) => {
  const interviews = await prisma.interview.findMany({
    where: { candidate: { organizationId: req.user.organizationId } },
    include: { candidate: { include: { applications: true } } },
    orderBy: [{ date: 'asc' }, { time: 'asc' }]
  });
  
  const mapped = interviews.map((i: any) => {
    return {
      ...i,
      applicationId: i.candidate.applications.length > 0 ? i.candidate.applications[0].id : null
    };
  });
  
  res.json({ success: true, data: mapped });
});

router.post('/', async (req: any, res: any) => {
  const { candidateId, date, time, interviewer, location, notes } = req.body;
  const interview = await prisma.interview.create({
    data: {
      candidateId,
      date,
      time,
      interviewer,
      location,
      notes
    }
  });

  // Also log to candidate timeline
  const app = await prisma.candidateApplication.findFirst({
    where: { candidateId }
  });
  if (app) {
    await prisma.candidateTimeline.create({
      data: {
        applicationId: app.id,
        eventType: 'INTERVIEW_SCHEDULED',
        description: `Interview scheduled on ${date} at ${time} with ${interviewer}`
      }
    });
  }

  res.status(201).json({ success: true, data: interview });
});

router.delete('/:id', async (req: any, res: any) => {
  await prisma.interview.delete({ where: { id: req.params.id } });
  res.json({ success: true, message: 'Interview deleted' });
});

export default router;
