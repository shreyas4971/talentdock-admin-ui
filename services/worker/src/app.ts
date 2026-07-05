import express from 'express';
import { createBullBoard } from '@bull-board/api';
import { BullMQAdapter } from '@bull-board/api/bullMQAdapter';
import { ExpressAdapter } from '@bull-board/express';
import { Queue } from 'bullmq';
import Redis from 'ioredis';
import jwt from 'jsonwebtoken';
import { QueueNames } from 'shared_events';
import { ResumeProcessor } from './queues/resumeProcessor';

export const app = express();
const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');

// Start Workers
new ResumeProcessor(redis);

// Bull Board setup
const serverAdapter = new ExpressAdapter();
serverAdapter.setBasePath('/admin/queues');

const resumeQueue = new Queue(QueueNames.RESUME_PROCESSING, { connection: redis });

createBullBoard({
  queues: [new BullMQAdapter(resumeQueue)],
  serverAdapter,
});

// JWT Admin Middleware
const authMiddleware = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  if (process.env.DISABLE_BULL_BOARD_AUTH === 'true') return next();
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ error: 'Unauthorized' });
  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret') as any;
    if (decoded.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};

app.use('/admin/queues', authMiddleware, serverAdapter.getRouter());

app.get('/health', (req, res) => res.json({ status: 'ok' }));
app.get('/ready', async (req, res) => {
  try {
    await redis.ping();
    res.json({ status: 'ready', redis: 'ok' });
  } catch (err) {
    res.status(503).json({ status: 'not_ready', error: String(err) });
  }
});
