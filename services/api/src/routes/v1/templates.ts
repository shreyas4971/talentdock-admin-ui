import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

const requireAuth = (req: any, res: any, next: any) => {
  req.user = { organizationId: 'default-org-id' };
  next();
};

router.get('/', requireAuth, async (req: any, res: any) => {
  const templates = await prisma.emailTemplate.findMany({
    where: { organizationId: req.user.organizationId }
  });
  res.json({ success: true, data: templates });
});

router.post('/', requireAuth, async (req: any, res: any) => {
  const { name, subject, body } = req.body;
  const template = await prisma.emailTemplate.create({
    data: {
      organizationId: req.user.organizationId,
      name,
      subject,
      body
    }
  });
  res.json({ success: true, data: template });
});

router.put('/:id', requireAuth, async (req: any, res: any) => {
  const { subject, body } = req.body;
  const template = await prisma.emailTemplate.update({
    where: { id: req.params.id },
    data: { subject, body }
  });
  res.json({ success: true, data: template });
});

export default router;
