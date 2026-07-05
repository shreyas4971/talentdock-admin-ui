import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import Redis from 'ioredis';
import { env } from '../config/env';

export const healthRouter = Router();
const prisma = new PrismaClient();
const redis = new Redis(env.REDIS_URL);

/**
 * @openapi
 * /health:
 *   get:
 *     description: Returns 200 if the app is running
 */
healthRouter.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

/**
 * @openapi
 * /ready:
 *   get:
 *     description: Checks DB and Redis connection
 */
healthRouter.get('/ready', async (req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    await redis.ping();
    res.status(200).json({ status: 'ready', db: 'ok', redis: 'ok' });
  } catch (error) {
    res.status(503).json({ status: 'not_ready', error: String(error) });
  }
});
