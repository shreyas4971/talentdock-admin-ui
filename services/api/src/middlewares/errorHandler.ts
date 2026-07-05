import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';
import { DomainError, NotFoundError, ConflictError, BusinessRuleViolation } from '../features/recruitment/domain/errors/DomainErrors';
import { ApiErrorResponse, ErrorCodes } from 'shared_contracts';

export function errorHandler(err: any, req: Request, res: Response, next: NextFunction) {
  logger.error(err);
  
  let statusCode = 500;
  let code: string = ErrorCodes.INTERNAL_ERROR;
  let message = 'Internal Server Error';

  if (err instanceof DomainError) {
    code = err.code;
    message = err.message;
    if (err instanceof NotFoundError) statusCode = 404;
    else if (err instanceof ConflictError) statusCode = 409;
    else if (err instanceof BusinessRuleViolation) statusCode = 400;
    else statusCode = 400;
  }

  const response: ApiErrorResponse = {
    success: false,
    requestId: req.id,
    error: {
      code,
      message,
      details: err.details
    }
  };

  res.status(statusCode).json(response);
}
