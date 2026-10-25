

import 'dart:io';

import 'package:dio/dio.dart';

import '../DataClass/MyUser.dart';
import 'RouteFile.dart';

/// URL de base du serveur : le QR code contient "ip:port" ; une URL complète
/// (http(s)://...) est aussi acceptée.
String serverBaseUrl(String serverUri) {
  String uri = serverUri.trim();
  if (uri.endsWith("/")) uri = uri.substring(0, uri.length - 1);
  if (uri.startsWith("http://") || uri.startsWith("https://")) return uri;
  return "$appProtocol://$uri";
}

Dio dioConstructor(baseUrl, {Map<String, dynamic>? extraHeader, bool needAuthorisation = true,
  Duration receiveTimeout = const Duration(seconds: 15)}) {
  Dio dio = Dio();
  Map<String, dynamic> headers = {
    HttpHeaders.userAgentHeader: 'dio',
    HttpHeaders.acceptHeader: 'application/json',
    HttpHeaders.acceptLanguageHeader: 'fr',
  };
  if (needAuthorisation && MyUser.token != null) {
    headers[HttpHeaders.authorizationHeader] = "Token ${MyUser.token}";
  }
  if (extraHeader != null) {
    extraHeader.forEach((key, value) {
      headers[key] = value;
    });
  }
  dio.options
    ..baseUrl = serverBaseUrl(baseUrl.toString())
    ..connectTimeout = const Duration(seconds: 5) //5s
    ..receiveTimeout = receiveTimeout
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
