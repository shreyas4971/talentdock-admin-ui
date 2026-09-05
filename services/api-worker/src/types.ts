export interface Env {
  DB: D1Database;
  RESUMES_BUCKET: R2Bucket;
  ENVIRONMENT?: string;
  JWT_SECRET?: string;
  CORS_ORIGINS?: string;
}

export interface ApiResponse<T = any> {
  success: boolean;
  message?: string;
  data?: T;
  error?: string;
}

export interface JwtPayload {
  userId: string;
  email: string;
  role: string;
  exp: number;
}
