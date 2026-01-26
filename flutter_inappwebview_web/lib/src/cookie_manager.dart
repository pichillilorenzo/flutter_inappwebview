import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'in_app_webview/headless_in_app_webview.dart';
import 'platform_util.dart';

/// Object specifying creation parameters for creating a [WebPlatformCookieManager].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformCookieManagerCreationParams] for
/// more information.
@immutable
class WebPlatformCookieManagerCreationParams
    extends PlatformCookieManagerCreationParams {
  /// Creates a new [WebPlatformCookieManagerCreationParams] instance.
  const WebPlatformCookieManagerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformCookieManagerCreationParams params,
  ) : super();

  /// Creates a [WebPlatformCookieManagerCreationParams] instance based on [PlatformCookieManagerCreationParams].
  factory WebPlatformCookieManagerCreationParams.fromPlatformCookieManagerCreationParams(
    PlatformCookieManagerCreationParams params,
  ) {
    return WebPlatformCookieManagerCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager}
class WebPlatformCookieManager extends PlatformCookieManager
    with ChannelController {
  /// Creates a new [WebPlatformCookieManager].
  WebPlatformCookieManager(PlatformCookieManagerCreationParams params)
    : super.implementation(
        params is WebPlatformCookieManagerCreationParams
            ? params
            : WebPlatformCookieManagerCreationParams.fromPlatformCookieManagerCreationParams(
                params,
              ),
      ) {
    channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_cookiemanager',
    );
    handler = handleMethod;
    initMethodCallHandler();
  }

  static final WebPlatformCookieManager _staticValue = WebPlatformCookieManager(
    WebPlatformCookieManagerCreationParams(
      PlatformCookieManagerCreationParams(),
    ),
  );

  factory WebPlatformCookieManager.static() {
    return _staticValue;
  }

  static WebPlatformCookieManager? _instance;

  ///Gets the [WebPlatformCookieManager] shared instance.
  static WebPlatformCookieManager instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static WebPlatformCookieManager _init() {
    _instance = WebPlatformCookieManager(
      WebPlatformCookieManagerCreationParams(
        const PlatformCookieManagerCreationParams(),
      ),
    );
    return _instance!;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {}

  @override
  Future<bool> setCookie({
    required WebUri url,
    required String name,
    required String value,
    String path = "/",
    String? domain,
    int? expiresDate,
    int? maxAge,
    bool? isSecure,
    bool? isHttpOnly,
    HTTPCookieSameSitePolicy? sameSite,
    @Deprecated("Use webViewController instead")
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    webViewController = webViewController ?? iosBelow11WebViewController;

    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);
    assert(path.isNotEmpty);

    await _setCookieWithJavaScript(
      url: url,
      name: name,
      value: value,
      domain: domain,
      path: path,
      expiresDate: expiresDate,
      maxAge: maxAge,
      isSecure: isSecure,
      sameSite: sameSite,
      webViewController: webViewController,
    );
    return true;
  }

  Future<void> _setCookieWithJavaScript({
    required WebUri url,
    required String name,
    required String value,
    String path = "/",
    String? domain,
    int? expiresDate,
    int? maxAge,
    bool? isSecure,
    HTTPCookieSameSitePolicy? sameSite,
    PlatformInAppWebViewController? webViewController,
  }) async {
    var cookieValue = name + "=" + value + "; Path=" + path;

    if (domain != null) cookieValue += "; Domain=" + domain;

    if (expiresDate != null)
      cookieValue += "; Expires=" + await _getCookieExpirationDate(expiresDate);

    if (maxAge != null) cookieValue += "; Max-Age=" + maxAge.toString();

    if (isSecure != null && isSecure) cookieValue += "; Secure";

    if (sameSite != null && sameSite.isSupported())
      cookieValue += "; SameSite=" + sameSite.toNativeValue()!;

    cookieValue += ";";

    if (webViewController != null) {
      final javaScriptEnabled =
          (await webViewController.getSettings())?.javaScriptEnabled ?? false;
      if (javaScriptEnabled) {
        await webViewController.evaluateJavascript(
          source: 'document.cookie="$cookieValue"',
        );
        return;
      }
    }

    final setCookieCompleter = Completer<void>();
    final headlessWebView = WebPlatformHeadlessInAppWebView(
      WebPlatformHeadlessInAppWebViewCreationParams(
        initialUrlRequest: URLRequest(url: url),
        onLoadStop: (controller, url) async {
          await controller.evaluateJavascript(
            source: 'document.cookie="$cookieValue"',
          );
          setCookieCompleter.complete();
        },
      ),
    );
    await headlessWebView.run();
    await setCookieCompleter.future;
    await headlessWebView.dispose();
  }

  @override
  Future<List<Cookie>> getCookies({
    required WebUri url,
    @Deprecated("Use webViewController instead")
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    assert(url.toString().isNotEmpty);

    webViewController = webViewController ?? iosBelow11WebViewController;

    return await _getCookiesWithJavaScript(
      url: url,
      webViewController: webViewController,
    );
  }

  Future<List<Cookie>> _getCookiesWithJavaScript({
    required WebUri url,
    PlatformInAppWebViewController? webViewController,
  }) async {
    assert(url.toString().isNotEmpty);

    List<Cookie> cookies = [];

    if (webViewController != null) {
      final javaScriptEnabled =
          (await webViewController.getSettings())?.javaScriptEnabled ?? false;
      if (javaScriptEnabled) {
        List<String> documentCookies =
            (await webViewController.evaluateJavascript(
                      source: 'document.cookie',
                    )
                    as String)
                .split(';')
                .map((documentCookie) => documentCookie.trim())
                .toList();
        documentCookies.forEach((documentCookie) {
          List<String> cookie = documentCookie.split('=');
          if (cookie.length > 1) {
            cookies.add(Cookie(name: cookie[0], value: cookie[1]));
          }
        });
        return cookies;
      }
    }

    final pageLoaded = Completer<void>();
    final headlessWebView = WebPlatformHeadlessInAppWebView(
      WebPlatformHeadlessInAppWebViewCreationParams(
        initialUrlRequest: URLRequest(url: url),
        onLoadStop: (controller, url) async {
          pageLoaded.complete();
        },
      ),
    );
    await headlessWebView.run();
    await pageLoaded.future;

    List<String> documentCookies =
        (await headlessWebView.webViewController!.evaluateJavascript(
                  source: 'document.cookie',
                )
                as String)
            .split(';')
            .map((documentCookie) => documentCookie.trim())
            .toList();
    documentCookies.forEach((documentCookie) {
      List<String> cookie = documentCookie.split('=');
      if (cookie.length > 1) {
        cookies.add(Cookie(name: cookie[0], value: cookie[1]));
      }
    });
    await headlessWebView.dispose();
    return cookies;
  }

  @override
  Future<Cookie?> getCookie({
    required WebUri url,
    required String name,
    @Deprecated("Use webViewController instead")
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);

    webViewController = webViewController ?? iosBelow11WebViewController;

    List<Cookie> cookies = await _getCookiesWithJavaScript(
      url: url,
      webViewController: webViewController,
    );
    return cookies.cast<Cookie?>().firstWhere(
      (cookie) => cookie!.name == name,
      orElse: () => null,
    );
  }

  @override
  Future<bool> deleteCookie({
    required WebUri url,
    required String name,
    String path = "/",
    String? domain,
    @Deprecated("Use webViewController instead")
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);

    webViewController = webViewController ?? iosBelow11WebViewController;

    await _setCookieWithJavaScript(
      url: url,
      name: name,
      value: "",
      path: path,
      domain: domain,
      maxAge: -1,
      webViewController: webViewController,
    );
    return true;
  }

  @override
  Future<bool> deleteCookies({
    required WebUri url,
    String path = "/",
    String? domain,
    @Deprecated("Use webViewController instead")
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    assert(url.toString().isNotEmpty);

    webViewController = webViewController ?? iosBelow11WebViewController;

    List<Cookie> cookies = await _getCookiesWithJavaScript(
      url: url,
      webViewController: webViewController,
    );
    for (var i = 0; i < cookies.length; i++) {
      await _setCookieWithJavaScript(
        url: url,
        name: cookies[i].name,
        value: "",
        path: path,
        domain: domain,
        maxAge: -1,
        webViewController: webViewController,
      );
    }
    return true;
  }

  Future<String> _getCookieExpirationDate(int expiresDate) async {
    var platformUtil = PlatformUtil.instance();
    var dateTime = DateTime.fromMillisecondsSinceEpoch(expiresDate).toUtc();
    return await platformUtil.getWebCookieExpirationDate(date: dateTime);
  }

  @override
  void dispose() {
    // empty
  }
}

extension InternalCookieManager on WebPlatformCookieManager {
  get handleMethod => _handleMethod;
}
