class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException(this.message, [this.prefix]);

  @override
  String toString() {
    // Only show prefix if it adds value, but for UI we want clean messages
    // return '${prefix ?? ""}$message';
    return message;
  }
}

class NetworkException extends AppException {
  NetworkException([String message = 'No Internet Connection'])
      : super(message, 'Network Error: ');
}

class ServerException extends AppException {
  ServerException([String message = 'Server Error'])
      : super(message, 'Server Error: ');
}

class AuthException extends AppException {
  AuthException([String message = 'Authentication Failed'])
      : super(message, 'Auth Error: ');
}

class ValidationException extends AppException {
  ValidationException([String message = 'Invalid Request'])
      : super(message, 'Validation Error: ');
}

class TimeoutException extends AppException {
  TimeoutException([String message = 'Connection Timed Out'])
      : super(message, 'Timeout Error: ');
}

class UnauthorisedException extends AppException {
  UnauthorisedException([String message = 'Unauthorised Request'])
      : super(message, 'Unauthorised: ');
}
