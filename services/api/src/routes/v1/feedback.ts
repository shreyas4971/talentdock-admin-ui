import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

const requireAuth = (req: any, res: any, next: any) => {
  req.user = { organizationId: 'default-org-id', id: 'admin-user-id' };
  next();
};

router.post('/', requireAuth, async (req: any, res: any) => {
  try {
    const { module, feedbackText } = req.body;
    
    if (!feedbackText) {
      return res.status(400).json({ success: false, message: 'Feedback text is required.' });
    }

    const feedback = await prisma.userFeedback.create({
      data: {
        organizationId: req.user.organizationId,
        module: module || 'Unknown',
        feedbackText,
      }
    });

    await prisma.analyticsEvent.create({
      data: { organizationId: req.user.organizationId, eventName: 'FEEDBACK_SUBMITTED' }
    });

    res.json({ success: true, data: feedback });
  } catch (error: any) {
    res.status(500).json({ success: false, message: 'Failed to submit feedback' });
  }
});

router.get('/', requireAuth, async (req: any, res: any) => {
  try {
    const feedbackList = await prisma.userFeedback.findMany({
      where: { organizationId: req.user.organizationId },
      orderBy: { createdAt: 'desc' }
    });
    res.json({ success: true, data: feedbackList });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch feedback' });
  }
});

router.put('/:id', requireAuth, async (req: any, res: any) => {
  try {
    const { status, priority, internalNotes } = req.body;
    const feedback = await prisma.userFeedback.update({
      where: { id: req.params.id },
      data: { status, priority, internalNotes }
    });
    res.json({ success: true, data: feedback });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to update feedback' });
  }
});

export default router;
