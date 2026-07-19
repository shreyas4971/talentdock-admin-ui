import { Router } from 'express';
import authRoutes from './auth';
import positionRoutes from './positions';
import applicationRoutes from './applications';
import candidateRoutes from './candidates';
import dashboardRoutes from './dashboard';
import feedbackRouter from './feedback';
import templatesRouter from './templates';
import interviewsRouter from './interviews';
import savedFiltersRouter from './savedFilters';

const router = Router();

router.use('/auth', authRoutes);
router.use('/positions', positionRoutes);
router.use('/applications', applicationRoutes);
router.use('/candidates', candidateRoutes);
router.use('/dashboard', dashboardRoutes);
router.use('/feedback', feedbackRouter);
router.use('/templates', templatesRouter);
router.use('/interviews', interviewsRouter);
router.use('/saved-filters', savedFiltersRouter);

export default router;
