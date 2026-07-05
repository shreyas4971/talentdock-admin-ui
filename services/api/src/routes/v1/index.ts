import { Router } from 'express';
import authRoutes from './auth';
import positionRoutes from './positions';
import applicationRoutes from './applications';
import candidateRoutes from './candidates';

const router = Router();

router.use('/auth', authRoutes);
router.use('/positions', positionRoutes);
router.use('/applications', applicationRoutes);
router.use('/candidates', candidateRoutes);
router.use('/dashboard', dashboardRoutes);

export default router;
