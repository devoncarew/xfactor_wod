import 'dart:developer' as developer;
import 'dart:io';

import 'logging.dart';

Log _log = new Log('http');

final _HttpOverrides _httpOverrides = new _HttpOverrides();

void installHttpLogger() {
  //if (!_log.isEnabled) {
  _log.enable();
  //}

  HttpOverrides.global = _httpOverrides;
}

class _HttpOverrides extends HttpOverrides {
  HttpClient createHttpClient(SecurityContext context) {
    return new LoggingHttpClient(context: context);
  }
}

class LoggingHttpClient implements HttpClient {
  HttpClient proxy;

  LoggingHttpClient({SecurityContext context}) {
    HttpOverrides.global = null;
    proxy = new HttpClient(context: context);
    HttpOverrides.global = _httpOverrides;
  }

  @override
  bool get autoUncompress => proxy.autoUncompress;

  set autoUncompress(bool value) {
    proxy.autoUncompress = value;
  }

  // TODO:
  @override
  Duration connectionTimeout;

  // TODO:
  @override
  Duration idleTimeout;

  // TODO:
  @override
  int maxConnectionsPerHost;

  // TODO:
  @override
  String userAgent;

  @override
  void addCredentials(
      Uri url, String realm, HttpClientCredentials credentials) {
    print('addCredentials');
    proxy.addCredentials(url, realm, credentials);
  }

  @override
  void addProxyCredentials(
      String host, int port, String realm, HttpClientCredentials credentials) {
    print('addProxyCredentials');
    proxy.addProxyCredentials(host, port, realm, credentials);
  }

  @override
  set authenticate(
      Future<bool> Function(Uri url, String scheme, String realm) f) {
    print('authenticate');
    proxy.authenticate = f;
  }

  @override
  set authenticateProxy(
      Future<bool> Function(String host, int port, String scheme, String realm)
          f) {
    print('authenticateProxy');
    proxy.authenticateProxy = f;
  }

  @override
  set badCertificateCallback(
      bool Function(X509Certificate cert, String host, int port) callback) {
    print('badCertificateCallback');
    proxy.badCertificateCallback = callback;
  }

  @override
  void close({bool force = false}) {
    print('close');
    proxy.close(force: force);
  }

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) {
    print('delete');
    return proxy.delete(host, port, path);
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) {
    print('deleteUrl');
    return proxy.deleteUrl(url);
  }

  @override
  set findProxy(String Function(Uri url) f) {
    print('findProxy');
    proxy.findProxy = f;
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) {
    print('get');
    _log.log('getUrl: $host');
    return proxy.get(host, port, path);
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    print('getUrl');
    _log.log('getUrl: $url');
    return proxy.getUrl(url);
  }

  @override
  Future<HttpClientRequest> head(String host, int port, String path) {
    print('head');
    return proxy.head(host, port, path);
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) {
    print('headUrl');
    return proxy.headUrl(url);
  }

  @override
  Future<HttpClientRequest> open(
      String method, String host, int port, String path) {
    print('open');
    return proxy.open(method, host, port, path);
  }

  int count = 1;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    final int id = count++;

    // http.open #123 uri GET
    developer.log('#$id $url open', name: 'http.${method.toLowerCase()}');
    //_log.log('openUrl: $url $method');

    Future<HttpClientRequest> request = proxy.openUrl(method, url);
    return request.then((HttpClientRequest req) {
      //_log.log('openUrl: $url request ready');
      developer.log('#$id $url ready', name: 'http.${method.toLowerCase()}');

      req.done.then((HttpClientResponse response) {
        developer.log(
            '#$id $url ${response.statusCode} ${response.reasonPhrase} ${response.contentLength} bytes',
            name: 'http.${method.toLowerCase()}');
      });

      return req;
    });
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) {
    print('patch');
    return proxy.patch(host, port, path);
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) {
    print('patchUrl');
    return proxy.patchUrl(url);
  }

  @override
  Future<HttpClientRequest> post(String host, int port, String path) {
    print('post');
    return proxy.post(host, port, path);
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    print('postUrl');
    return proxy.postUrl(url);
  }

  @override
  Future<HttpClientRequest> put(String host, int port, String path) {
    print('put');
    return proxy.put(host, port, path);
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) {
    print('putUrl');
    return proxy.putUrl(url);
  }
}
