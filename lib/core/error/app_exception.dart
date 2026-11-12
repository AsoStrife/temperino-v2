import 'package:dio/dio.dart';

/// Every error that reaches the UI is an [AppException] with an Italian
/// message ready to be shown in a SnackBar or an error state.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  /// Converts any error (dio or otherwise) into an [AppException].
  static AppException from(Object error) {
    if (error is AppException) return error;
    if (error is DioException) return _fromDio(error);
    if (error is FormatException || error is TypeError) {
      return InvalidResponseException(error.toString());
    }
    return UnknownException(error.toString());
  }

  static AppException _fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const RequestTimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        return ServerException(e.response?.statusCode);
      case DioExceptionType.cancel:
        return const UnknownException('Richiesta annullata');
      case DioExceptionType.badCertificate:
        return const NetworkException('Certificato del server non valido');
      case DioExceptionType.unknown:
        if (e.error is FormatException || e.error is TypeError) {
          return InvalidResponseException(e.error.toString());
        }
        return const NetworkException();
    }
  }

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException([
    super.message =
        'Impossibile contattare il server. Controlla la connessione.',
  ]);
}

final class RequestTimeoutException extends AppException {
  const RequestTimeoutException()
    : super('Il server non ha risposto in tempo. Riprova.');
}

final class ServerException extends AppException {
  ServerException(this.statusCode)
    : super('Errore del server${statusCode != null ? ' ($statusCode)' : ''}.');

  final int? statusCode;
}

final class InvalidResponseException extends AppException {
  InvalidResponseException(this.details)
    : super('Risposta del server non valida.');

  final String details;
}

final class UnknownException extends AppException {
  const UnknownException([super.message = 'Si è verificato un errore.']);
}
