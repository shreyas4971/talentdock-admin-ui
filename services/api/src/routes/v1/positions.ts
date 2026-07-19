import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// MVP Mock Auth Middleware
const requireAuth = (req: any, res: any, next: any) => {
  req.user = { organizationId: 'default-org-id' };
  next();
};

router.get('/public', async (req: any, res: any) => {
  const orgId = req.headers['x-org-id'] || 'default-org-id';
  const positions = await prisma.position.findMany({
    where: { organizationId: orgId, status: { in: ['PUBLISHED', 'OPEN'] } }
  });
  res.json({ success: true, data: positions });
});

router.get('/', async (req: any, res: any) => {
  const positions = await prisma.position.findMany({
    where: { organizationId: req.user?.organizationId || 'default-org-id' }
  });
  res.json({ success: true, data: positions });
});

router.post('/', requireAuth, async (req: any, res: any) => {
  const { title, description, department, location, status } = req.body;
    const newPosition = await prisma.position.create({
      data: {
        organizationId: req.user?.organizationId || 'default-org-id',
        title,
        description,
        department,
        location,
        status: status || 'DRAFT'
      }
    });
    await prisma.analyticsEvent.create({
      data: { organizationId: req.user?.organizationId || 'default-org-id', eventName: 'POSITION_CREATED' }
    });
    res.json({ success: true, data: newPosition });
});

router.put('/:id', requireAuth, async (req: any, res: any) => {
  const { id } = req.params;
  const position = await prisma.position.update({
    where: { id },
    data: req.body
  });
  res.json({ success: true, data: position });
});

router.get('/:id', async (req: any, res: any) => {
  const position = await prisma.position.findUnique({ where: { id: req.params.id } });
  res.json({ success: true, data: position });
});

router.post('/:id/duplicate', requireAuth, async (req: any, res: any) => {
  const existing = await prisma.position.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ success: false });

  const duplicated = await prisma.position.create({
    data: {
      organizationId: existing.organizationId,
      title: `${existing.title} (Copy)`,
      description: existing.description,
      department: existing.department,
      location: existing.location,
      status: 'DRAFT'
    }
  });

  await prisma.activityFeed.create({
    data: { organizationId: existing.organizationId, action: 'POSITION_DUPLICATED', entityType: 'POSITION', entityId: duplicated.id }
  });

  res.json({ success: true, data: duplicated });
});

export default router;
