import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Max length for request/response body in logs to avoid flooding the console.
const int _maxBodyLogLength = 1000;

/// Header keys whose values are redacted in logs.
const _sensitiveHeaders = ['authorization', 'cookie'];

/// Interceptor for logging requests and responses.
/// In debug mode logs full request/response (URI, headers, body).
/// In release mode logs only method, URI, and status.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({this.verbose = true});

  /// When true (and in debug mode), logs headers and body. When false, logs only method + URI + status.
  final bool verbose;

  static Map<String, String> _redactHeaders(dynamic headers) {
    if (headers == null || headers is! Map || headers.isEmpty) {
      return {};
    }
    final redacted = <String, String>{};
    for (final e in headers.entries) {
      final key = e.key.toString();
      final keyLower = key.toLowerCase();
      final value = e.value;
      final valueStr =
          value is List ? value.join(', ') : value?.toString() ?? '';
      redacted[key] =
          _sensitiveHeaders.any((h) => keyLower == h) ? '***' : valueStr;
    }
    return redacted;
  }

  static String _stringifyBody(dynamic data, {int maxLength = _maxBodyLogLength}) {
    if (data == null) return '';
    if (data is List<int>) return '<binary>';
    final str = data is Map || data is List ? data.toString() : data.toString();
    if (str.length <= maxLength) return str;
    return '${str.substring(0, maxLength)}... (truncated, total ${str.length} chars)';
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final isVerbose = kDebugMode && verbose;
    developer.log(
      '→ ${options.method} ${options.uri}',
      name: 'API',
    );
    if (isVerbose) {
      final headers = _redactHeaders(options.headers);
      if (headers.isNotEmpty) {
        developer.log('  Headers: $headers', name: 'API');
      }
      if (options.data != null) {
        developer.log(
          '  Body: ${_stringifyBody(options.data)}',
          name: 'API',
        );
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    final isVerbose = kDebugMode && verbose;
    developer.log(
      '← ${response.statusCode} ${response.requestOptions.uri}',
      name: 'API',
    );
    if (isVerbose) {
      final headers = _redactHeaders(response.headers.map);
      if (headers.isNotEmpty) {
        developer.log('  Headers: $headers', name: 'API');
      }
      final data = response.data;
      if (data != null) {
        if (data is List<int>) {
          developer.log('  Body: <binary>', name: 'API');
        } else {
          developer.log(
            '  Body: ${_stringifyBody(data)}',
            name: 'API',
          );
        }
      }
    }
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    final isVerbose = kDebugMode && verbose;
    developer.log(
      '✗ ${err.response?.statusCode ?? 'ERROR'} ${err.requestOptions.uri}',
      name: 'API',
      error: err.message,
    );
    if (isVerbose && err.response?.data != null) {
      developer.log(
        '  Response data: ${_stringifyBody(err.response!.data)}',
        name: 'API',
      );
    }
    handler.next(err);
  }
}
