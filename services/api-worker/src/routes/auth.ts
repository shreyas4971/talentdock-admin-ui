import { Hono } from 'hono';
import { eq } from 'drizzle-orm';
import { Env } from '../types';
import { getDb } from '../db/client';
import { users } from '../db/schema';
import { signJwt, verifyPassword, hashPassword, authMiddleware } from '../middleware/auth';

const auth = new Hono<{ Bindings: Env }>();

/**
 * Admin Login
 */
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

/**
 * Get Authenticated User Profile (Protected)
 */
auth.get('/me', authMiddleware as any, async (c) => {
  try {
    const userPayload = c.get('user' as any) as any;
    if (!userPayload?.userId) {
      return c.json({ success: false, message: 'Unauthorized' }, 401);
    }

    const db = getDb(c.env.DB);
    const user = await db.select().from(users).where(eq(users.id, userPayload.userId)).get();

    if (!user) {
      return c.json({ success: false, message: 'User not found' }, 404);
    }

    return c.json({
      success: true,
      data: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        createdAt: user.createdAt,
      },
    });
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Failed to fetch user profile' }, 500);
  }
});

/**
 * Change Admin Password (Protected)
 */
auth.post('/change-password', authMiddleware as any, async (c) => {
  try {
    const userPayload = c.get('user' as any) as any;
    if (!userPayload?.userId) {
      return c.json({ success: false, message: 'Unauthorized' }, 401);
    }

    const body = await c.req.json().catch(() => ({}));
    const { currentPassword, newPassword, confirmPassword } = body;

    if (!currentPassword || !newPassword || !confirmPassword) {
      return c.json({ success: false, message: 'All password fields are required' }, 400);
    }

    if (newPassword !== confirmPassword) {
      return c.json({ success: false, message: 'New password and confirmation do not match' }, 400);
    }

    if (newPassword.length < 6) {
      return c.json({ success: false, message: 'New password must be at least 6 characters long' }, 400);
    }

    const db = getDb(c.env.DB);
    const existingUser = await db.select().from(users).where(eq(users.id, userPayload.userId)).get();

    if (!existingUser) {
      return c.json({ success: false, message: 'User not found' }, 404);
    }

    // Verify current password against stored hash
    const isValidCurrent = await verifyPassword(currentPassword, existingUser.passwordHash);
    if (!isValidCurrent) {
      return c.json({ success: false, message: 'Current password is incorrect' }, 400);
    }

    // Hash new password using PBKDF2 Web Crypto standard
    const newPasswordHash = await hashPassword(newPassword);
    const now = new Date().toISOString();

    await db.update(users)
      .set({
        passwordHash: newPasswordHash,
        updatedAt: now,
      })
      .where(eq(users.id, existingUser.id))
      .run();

    return c.json({
      success: true,
      message: 'Password changed successfully',
    });
  } catch (error: any) {
    return c.json({ success: false, message: error.message || 'Failed to change password' }, 500);
  }
});

export default auth;
