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
  const filters = await prisma.savedFilter.findMany({
    where: { organizationId: req.user.organizationId },
    orderBy: { createdAt: 'desc' }
  });
  res.json({ success: true, data: filters });
});

router.post('/', async (req: any, res: any) => {
  const { name, query } = req.body;
  const filter = await prisma.savedFilter.create({
    data: {
      organizationId: req.user.organizationId,
      name,
      query
    }
  });
  res.status(201).json({ success: true, data: filter });
});

router.delete('/:id', async (req: any, res: any) => {
  await prisma.savedFilter.delete({ where: { id: req.params.id } });
  res.json({ success: true, message: 'Saved filter deleted' });
});

export default router;
