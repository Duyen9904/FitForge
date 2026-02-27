/// API exception types
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException({super.message = 'Network connection error'});
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message = 'Unauthorized access'})
      : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException({super.message = 'Access forbidden'})
      : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException({super.message = 'Resource not found'})
      : super(statusCode: 404);
}

class ServerException extends ApiException {
  ServerException({super.message = 'Server error'})
      : super(statusCode: 500);
}

class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  ValidationException({
    super.message = 'Validation failed',
    this.errors,
  }) : super(statusCode: 400);
}

class TimeoutException extends ApiException {
  TimeoutException({super.message = 'Request timeout'});
}
