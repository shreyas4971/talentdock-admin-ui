import { ErrorCodes } from 'shared_contracts';

export class DomainError extends Error {
  constructor(public code: ErrorCodes, message: string, public details?: any) {
    super(message);
    this.name = 'DomainError';
  }
}

export class NotFoundError extends DomainError {
  constructor(message: string) {
    super(ErrorCodes.NOT_FOUND, message);
  }
}

export class ConflictError extends DomainError {
  constructor(message: string) {
    super(ErrorCodes.CONFLICT, message);
  }
}

export class BusinessRuleViolation extends DomainError {
  constructor(message: string) {
    super(ErrorCodes.BUSINESS_RULE_VIOLATION, message);
  }
}
