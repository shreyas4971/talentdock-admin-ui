import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

router.get('/counts', async (req: any, res: any) => {
  const orgId = req.headers['x-org-id'] || 'default-org-id';
  
  const [positionsCount, candidatesCount] = await Promise.all([
    prisma.position.count({ where: { organizationId: orgId } }),
    prisma.candidate.count({ where: { organizationId: orgId } })
  ]);
  
  res.json({ success: true, data: { positions: positionsCount, candidates: candidatesCount } });
});

export default router;
