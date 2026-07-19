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
  
  const thisWeek = new Date();
  thisWeek.setDate(thisWeek.getDate() - 7);
  
  const thisMonth = new Date();
  thisMonth.setMonth(thisMonth.getMonth() - 1);

  const applicationsToday = await prisma.candidateApplication.count({
    where: { candidate: { organizationId: orgId }, createdAt: { gte: today } }
  });
  
  const applicationsThisWeek = await prisma.candidateApplication.count({
    where: { candidate: { organizationId: orgId }, createdAt: { gte: thisWeek } }
  });
  
  const applicationsThisMonth = await prisma.candidateApplication.count({
    where: { candidate: { organizationId: orgId }, createdAt: { gte: thisMonth } }
  });

  const shortlisted = await prisma.candidateApplication.count({
    where: { candidate: { organizationId: orgId }, status: { in: ['INTERVIEW', 'OFFER'] } }
  });

  const recentApplications = await prisma.candidateApplication.findMany({
    where: { candidate: { organizationId: orgId } },
    include: { candidate: true, position: true },
    orderBy: { createdAt: 'desc' },
    take: 5
  });

  const recentActivity = await prisma.activityFeed.findMany({
    where: { organizationId: orgId },
    orderBy: { createdAt: 'desc' },
    take: 10
  });

  const upcomingInterviews = await prisma.interview.findMany({
    where: { candidate: { organizationId: orgId } },
    include: { candidate: true },
    orderBy: [{ date: 'asc' }, { time: 'asc' }],
    take: 5
  });

  const recentlyUpdatedCandidates = await prisma.candidate.findMany({
    where: { organizationId: orgId },
    include: { applications: { include: { position: true } } },
    orderBy: { updatedAt: 'desc' },
    take: 5
  });

  const recentlyCreatedPositions = await prisma.position.findMany({
    where: { organizationId: orgId },
    orderBy: { createdAt: 'desc' },
    take: 5
  });

  res.json({
    success: true,
    data: {
      openPositions,
      totalApplications,
      applicationsToday,
      applicationsThisWeek,
      applicationsThisMonth,
      shortlisted,
      recentApplications,
      recentActivity,
      upcomingInterviews,
      recentlyUpdatedCandidates,
      recentlyCreatedPositions
    }
  });
});

export default router;
