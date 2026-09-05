import { Hono } from 'hono';
import { Env } from '../types';

const health = new Hono<{ Bindings: Env }>();

health.get('/', (c) => {
  return c.json({
    success: true,
    data: {
      status: 'healthy',
      service: 'talentdock-api-worker',
      environment: c.env.ENVIRONMENT || 'development',
      version: '1.0.0',
      timestamp: new Date().toISOString(),
    },
  });
});

export default health;
