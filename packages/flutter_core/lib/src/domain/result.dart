sealed class Result<T> {}

class Success<T> extends Result<T> {
  final T data;
  Success(this.data);
}

class Failure<T> extends Result<T> {
  final DomainError error;
  Failure(this.error);
}

abstract class DomainError {
  final String message;
  final String code;
  DomainError(this.message, this.code);
}

class NetworkError extends DomainError {
  NetworkError(super.message, {super.code = 'NETWORK_ERROR'});
}

class UnauthorizedError extends DomainError {
  UnauthorizedError(super.message, {super.code = 'UNAUTHORIZED'});
}

class BusinessRuleError extends DomainError {
  BusinessRuleError(super.message, {super.code = 'BUSINESS_RULE_VIOLATION'});
}
