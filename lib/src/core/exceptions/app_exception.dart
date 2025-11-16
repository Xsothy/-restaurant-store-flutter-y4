enum AppExceptionType {
  network,
  unauthorized,
  validation,
  server,
  cache,
  unknown,
}

class AppException implements Exception {
  const AppException({
    required this.message,
    this.type = AppExceptionType.unknown,
    this.statusCode,
    this.cause,
  });

  final String message;
  final AppExceptionType type;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() {
    final buffer = StringBuffer('AppException(message: $message, type: $type');
    if (statusCode != null) {
      buffer.write(', statusCode: $statusCode');
    }
    if (cause != null) {
      buffer.write(', cause: $cause');
    }
    buffer.write(')');
    return buffer.toString();
  }
}
