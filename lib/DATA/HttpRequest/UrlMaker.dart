

Uri urlMaker(String uri, String route, {Map<String, dynamic>? queryParameters}) {
  return Uri.http(uri, route, queryParameters);
}