import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

const requireAuth = (req: any, res: any, next: any) => {
  req.user = { organizationId: 'default-org-id' };
  next();
};

router.get('/', requireAuth, async (req: any, res: any) => {
  const orgId = req.user.organizationId;
  const openPositions = await prisma.position.count({
    where: { organizationId: orgId, status: 'PUBLISHED' }
  });
  
  const totalApplications = await prisma.candidateApplication.count({
    where: { candidate: { organizationId: orgId } }
  });

  const today = new Date();
  today.setHours(0,0,0,0);
  const applicationsToday = await prisma.candidateApplication.count({
    where: {
      candidate: { organizationId: orgId },
      createdAt: { gte: today }
    }
  });

  const shortlisted = await prisma.candidateApplication.count({
    where: { candidate: { organizationId: orgId }, status: { in: ['INTERVIEW', 'OFFER'] } }
  });

  const positionsCreated = await prisma.analyticsEvent.count({ where: { organizationId: orgId, eventName: 'POSITION_CREATED' } });
  const applicationsSubmitted = await prisma.analyticsEvent.count({ where: { organizationId: orgId, eventName: 'APPLICATION_SUBMITTED' } });
  const statusChanges = await prisma.analyticsEvent.count({ where: { organizationId: orgId, eventName: 'STATUS_CHANGE' } });
  const excelExports = await prisma.analyticsEvent.count({ where: { organizationId: orgId, eventName: 'EXPORT_EXCEL' } });
  const feedbacksSubmitted = await prisma.analyticsEvent.count({ where: { organizationId: orgId, eventName: 'FEEDBACK_SUBMITTED' } });

  res.json({
    success: true,
    data: {
      openPositions,
      totalApplications,
      applicationsToday,
      shortlisted,
      analytics: {
        positionsCreated,
        applicationsSubmitted,
        statusChanges,
        excelExports,
        feedbacksSubmitted
      }
    }
  });
});

export default router;
