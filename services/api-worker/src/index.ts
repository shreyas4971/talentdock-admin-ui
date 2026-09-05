import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { Env } from './types';
import healthRoute from './routes/health';
import authRoute from './routes/auth';
import positionsRoute from './routes/positions';
import applicationsRoute from './routes/applications';
import candidatesRoute from './routes/candidates';

const app = new Hono<{ Bindings: Env }>();

// Logger
app.use('*', logger());

// CORS Middleware (supports local Flutter web & production origins)
app.use('*', async (c, next) => {
  const allowedOrigins = (c.env.CORS_ORIGINS || '*').split(',').map((o) => o.trim());
  const corsMiddleware = cors({
    origin: (origin) => {
      if (!origin) return '*';
      // Allow localhost on any port (Flutter web debug)
      if (origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:')) {
        return origin;
      }
      if (allowedOrigins.includes('*') || allowedOrigins.includes(origin)) {
        return origin;
      }
      return null;
    },
    allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization', 'x-org-id'],
    exposeHeaders: ['Content-Length', 'Content-Disposition'],
    maxAge: 86400,
    credentials: true,
  });
  return corsMiddleware(c, next);
});

// Global Error Handler
app.onError((err, c) => {
  console.error('[Unhandled Error]:', err);
  return c.json({
    success: false,
    message: err.message || 'Internal Server Error',
  }, 500);
});

// Global 404 Handler
app.notFound((c) => {
  return c.json({
    success: false,
    message: `Route not found: ${c.req.method} ${c.req.path}`,
  }, 404);
});

// Root ping
app.get('/', (c) => {
  return c.json({
    name: 'TalentDock Cloudflare Worker API',
    version: '1.0.0',
    status: 'online',
    docs: '/api/v1/health',
  });
});

// V1 API Routing Mount
const v1 = new Hono<{ Bindings: Env }>();
v1.route('/health', healthRoute);
v1.route('/auth', authRoute);
v1.route('/positions', positionsRoute);
v1.route('/applications', applicationsRoute);
v1.route('/candidates', candidatesRoute);

app.route('/api/v1', v1);

export default app;
