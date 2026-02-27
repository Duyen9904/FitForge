import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Interceptor for error handling
class ErrorInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    // Log error details for debugging
    debugPrint('API Error: ${err.type}');
    debugPrint('URL: ${err.requestOptions.uri}');
    debugPrint('Status: ${err.response?.statusCode}');
    debugPrint('Message: ${err.message}');
    
    handler.next(err);
  }
}
