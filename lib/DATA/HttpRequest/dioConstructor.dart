

import 'dart:io';

import 'package:dio/dio.dart';

import '../DataClass/MyUser.dart';
import 'RouteFile.dart';

Dio dioConstructor(baseUrl, {Map<String, dynamic>? extraHeader, bool needAuthorisation = true, }) {
  Dio dio = Dio();
  Map<String, dynamic> headers = {
    HttpHeaders.userAgentHeader: 'dio',
    'common-header': 'xx',
  };
  if (needAuthorisation) {
    headers["authorization"] = "Bearer $testToken";
  }
  headers["userId"] = MyUser.currentUser.id;
  if (extraHeader != null) {
    extraHeader.forEach((key, value) {
      headers[key] = value;
    });
  }
  dio.options
    ..baseUrl = "$appProtocol://$baseUrl"
    ..connectTimeout = const Duration(seconds: 5) //5s
    ..receiveTimeout = const Duration(seconds: 5)
    ..validateStatus = (int? status) {
      return status != null && status > 0;
    }
    ..headers = headers;
  dio.interceptors
    ..add(InterceptorsWrapper(
      onRequest: (options, handler) {
        return handler.next(options);
      },
    ))
    ..add(LogInterceptor(responseBody: false));
  return dio;
}