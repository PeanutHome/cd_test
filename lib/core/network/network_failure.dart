import 'package:dio/dio.dart';

class NetworkFailure {
  const NetworkFailure({required this.isOffline, required this.message});

  final bool isOffline;
  final String message;

  static NetworkFailure from(Object error) {
    final offline = _isOffline(error);
    return NetworkFailure(
      isOffline: offline,
      message: offline
          ? 'You are offline. Showing saved movies when available.'
          : 'Unable to load movies. Pull down to try again.',
    );
  }

  static bool _isOffline(Object error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout;
    }
    return false;
  }
}
