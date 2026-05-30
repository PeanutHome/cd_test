import 'package:dio/dio.dart';

import '../config/app_config.dart';

class ApiKeyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters['api_key'] = AppConfig.apiKey;
    handler.next(options);
  }
}
