import { Hono } from 'hono';
import { eq } from 'drizzle-orm';
import { Env } from '../types';
import { getDb } from '../db/client';
import { users } from '../db/schema';
import { signJwt, verifyPassword } from '../middleware/auth';

const auth = new Hono<{ Bindings: Env }>();

auth.post('/login', async (c) => {
  try {
    const body = await c.req.json().catch(() => ({}));
    const { email, password } = body;

    if (!email || !password) {
      return c.json({ success: false, message: 'Email and password are required' }, 400);
    }

    const normalizedEmail = email.toLowerCase().trim();
    const db = getDb(c.env.DB);
    const existingUser = await db.select().from(users).where(eq(users.email, normalizedEmail)).get();

    if (!existingUser) {
      return c.json({ success: false, message: 'Invalid email or password' }, 401);
    }

    const isValidPassword = await verifyPassword(password, existingUser.passwordHash);
    if (!isValidPassword) {
      return c.json({ success: false, message: 'Invalid email or password' }, 401);
    }

    const secret = c.env.JWT_SECRET || 'talentdock-dev-secret-key-2026';
    const token = await signJwt({
      userId: existingUser.id,
      email: existingUser.email,
      role: existingUser.role,
    }, secret);

    return c.json({
      success: true,
      data: {
        token,
        user: {
          id: existingUser.id,
          email: existingUser.email,
          name: existingUser.name,
          role: existingUser.role,
        },
      },
    });
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Login failed' }, 500);
  }
});

export default auth;
