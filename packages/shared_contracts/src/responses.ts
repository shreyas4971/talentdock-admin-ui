export interface ApiSuccessResponse<T> {
  success: true;
  requestId: string;
  message?: string;
  data: T;
  meta?: any;
}

export interface ApiErrorResponse {
  success: false;
  requestId: string;
  error: {
    code: string;
    message: string;
    details?: any;
  };
}

export type ApiResponse<T> = ApiSuccessResponse<T> | ApiErrorResponse;
