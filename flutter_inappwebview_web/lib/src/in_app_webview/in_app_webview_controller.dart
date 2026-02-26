import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../web_storage/web_storage.dart';
import '_static_channel.dart';
import 'headless_in_app_webview.dart';

/// Object specifying creation parameters for creating a [WebPlatformInAppWebViewController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformInAppWebViewControllerCreationParams] for
/// more information.
@immutable
class WebPlatformInAppWebViewControllerCreationParams
    extends PlatformInAppWebViewControllerCreationParams {
  /// Creates a new [WebPlatformInAppWebViewControllerCreationParams] instance.
  const WebPlatformInAppWebViewControllerCreationParams({
    required super.id,
    super.webviewParams,
  });

  /// Creates a [WebPlatformInAppWebViewControllerCreationParams] instance based on [PlatformInAppWebViewControllerCreationParams].
  factory WebPlatformInAppWebViewControllerCreationParams.fromPlatformInAppWebViewControllerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformInAppWebViewControllerCreationParams params,
  ) {
    return WebPlatformInAppWebViewControllerCreationParams(
      id: params.id,
      webviewParams: params.webviewParams,
    );
  }
}

///Controls a WebView, such as an [InAppWebView] widget instance, a [WebPlatformHeadlessInAppWebView] instance or [WebPlatformInAppBrowser] WebView instance.
///
///If you are using the [InAppWebView] widget, an [InAppWebViewController] instance can be obtained by setting the [InAppWebView.onWebViewCreated]
///callback. Instead, if you are using an [WebPlatformInAppBrowser] instance, you can get it through the [WebPlatformInAppBrowser.webViewController] attribute.
class WebPlatformInAppWebViewController extends PlatformInAppWebViewController
    with ChannelController {
  // ignore: unused_field
  static final MethodChannel _staticChannel = IN_APP_WEBVIEW_STATIC_CHANNEL;

  Map<UserScriptInjectionTime, List<UserScript>> _userScripts = {
    UserScriptInjectionTime.AT_DOCUMENT_START: <UserScript>[],
    UserScriptInjectionTime.AT_DOCUMENT_END: <UserScript>[],
  };
  Map<String, Function> _javaScriptHandlersMap = HashMap<String, Function>();
  Map<String, ScriptHtmlTagAttributes> _injectedScriptsFromURL = {};

  dynamic _controllerFromPlatform;

  @override
  late WebPlatformWebStorage webStorage;

  WebPlatformInAppWebViewController(
    PlatformInAppWebViewControllerCreationParams params,
  ) : super.implementation(
        params is WebPlatformInAppWebViewControllerCreationParams
            ? params
            : WebPlatformInAppWebViewControllerCreationParams.fromPlatformInAppWebViewControllerCreationParams(
                params,
              ),
      ) {
    channel = MethodChannel('com.pichillilorenzo/flutter_inappwebview_$id');
    handler = handleMethod;
    initMethodCallHandler();

    this._init(params);
  }

  static final WebPlatformInAppWebViewController _staticValue =
      WebPlatformInAppWebViewController(
        WebPlatformInAppWebViewControllerCreationParams(id: null),
      );

  factory WebPlatformInAppWebViewController.static() {
    return _staticValue;
  }

  void _init(PlatformInAppWebViewControllerCreationParams params) {
    _controllerFromPlatform =
        params.webviewParams?.controllerFromPlatform?.call(this) ?? this;

    webStorage = WebPlatformWebStorage(
      WebPlatformWebStorageCreationParams(
        localStorage: WebPlatformLocalStorage.defaultStorage(controller: this),
        sessionStorage: WebPlatformSessionStorage.defaultStorage(
          controller: this,
        ),
      ),
    );
  }

  _debugLog(String method, dynamic args) {
    debugLog(
      className: this.runtimeType.toString(),
      name: "WebView",
      id: getViewId().toString(),
      debugLoggingSettings: PlatformInAppWebViewController.debugLoggingSettings,
      method: method,
      args: args,
    );
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    if (PlatformInAppWebViewController.debugLoggingSettings.enabled &&
        call.method != "onCallJsHandler") {
      _debugLog(call.method, call.arguments);
    }

    switch (call.method) {
      case "onLoadStart":
        _injectedScriptsFromURL.clear();
        if ((webviewParams != null && webviewParams!.onLoadStart != null)) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;
          webviewParams!.onLoadStart!(_controllerFromPlatform, uri);
        }
        break;
      case "onLoadStop":
        if ((webviewParams != null && webviewParams!.onLoadStop != null)) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;
          webviewParams!.onLoadStop!(_controllerFromPlatform, uri);
        }
        break;
      case "onConsoleMessage":
        if ((webviewParams != null &&
            webviewParams!.onConsoleMessage != null)) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          ConsoleMessage consoleMessage = ConsoleMessage.fromMap(arguments)!;
          webviewParams!.onConsoleMessage!(
            _controllerFromPlatform,
            consoleMessage,
          );
        }
        break;
      case "onScrollChanged":
        if ((webviewParams != null && webviewParams!.onScrollChanged != null)) {
          int x = call.arguments["x"];
          int y = call.arguments["y"];
          webviewParams!.onScrollChanged!(_controllerFromPlatform, x, y);
        }
        break;
      case "onCreateWindow":
        if ((webviewParams != null && webviewParams!.onCreateWindow != null)) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          CreateWindowAction createWindowAction = CreateWindowAction.fromMap(
            arguments,
          )!;

          return await webviewParams!.onCreateWindow!(
            _controllerFromPlatform,
            createWindowAction,
          );
        }
        break;
      case "onCloseWindow":
        if ((webviewParams != null && webviewParams!.onCloseWindow != null)) {
          webviewParams!.onCloseWindow!(_controllerFromPlatform);
        }
        break;
      case "onTitleChanged":
        if ((webviewParams != null && webviewParams!.onTitleChanged != null)) {
          String? title = call.arguments["title"];
          webviewParams!.onTitleChanged!(_controllerFromPlatform, title);
        }
        break;
      case "onZoomScaleChanged":
        if ((webviewParams != null &&
            // ignore: deprecated_member_use_from_same_package
            (webviewParams!.androidOnScaleChanged != null ||
                webviewParams!.onZoomScaleChanged != null))) {
          double oldScale = call.arguments["oldScale"];
          double newScale = call.arguments["newScale"];

          if (webviewParams!.onZoomScaleChanged != null)
            webviewParams!.onZoomScaleChanged!(
              _controllerFromPlatform,
              oldScale,
              newScale,
            );
          else {
            // ignore: deprecated_member_use_from_same_package
            webviewParams!.androidOnScaleChanged!(
              _controllerFromPlatform,
              oldScale,
              newScale,
            );
          }
        }
        break;
      case "onUpdateVisitedHistory":
        if ((webviewParams != null &&
            webviewParams!.onUpdateVisitedHistory != null)) {
          String? url = call.arguments["url"];
          bool? isReload = call.arguments["isReload"];
          WebUri? uri = url != null ? WebUri(url) : null;
          webviewParams!.onUpdateVisitedHistory!(
            _controllerFromPlatform,
            uri,
            isReload,
          );
        }
        break;
      case "onEnterFullscreen":
        if (webviewParams != null && webviewParams!.onEnterFullscreen != null)
          webviewParams!.onEnterFullscreen!(_controllerFromPlatform);
        break;
      case "onExitFullscreen":
        if (webviewParams != null && webviewParams!.onExitFullscreen != null)
          webviewParams!.onExitFullscreen!(_controllerFromPlatform);
        break;
      case "onWindowFocus":
        if (webviewParams != null && webviewParams!.onWindowFocus != null)
          webviewParams!.onWindowFocus!(_controllerFromPlatform);
        break;
      case "onWindowBlur":
        if (webviewParams != null && webviewParams!.onWindowBlur != null)
          webviewParams!.onWindowBlur!(_controllerFromPlatform);
        break;
      case "onPrintRequest":
        if ((webviewParams != null &&
            (webviewParams!.onPrintRequest != null ||
                // ignore: deprecated_member_use_from_same_package
                webviewParams!.onPrint != null))) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;

          if (webviewParams!.onPrintRequest != null)
            return await webviewParams!.onPrintRequest!(
              _controllerFromPlatform,
              uri,
              null,
            );
          else {
            // ignore: deprecated_member_use_from_same_package
            webviewParams!.onPrint!(_controllerFromPlatform, uri);
            return false;
          }
        }
        break;
      case "onInjectedScriptLoaded":
        String id = call.arguments[0];
        var onLoadCallback = _injectedScriptsFromURL[id]?.onLoad;
        if ((webviewParams != null) && onLoadCallback != null) {
          onLoadCallback();
        }
        break;
      case "onInjectedScriptError":
        String id = call.arguments[0];
        var onErrorCallback = _injectedScriptsFromURL[id]?.onError;
        if ((webviewParams != null) && onErrorCallback != null) {
          onErrorCallback();
        }
        break;
      case "onCallJsHandler":
        String handlerName = call.arguments["handlerName"];
        Map<String, dynamic> handlerDataMap = call.arguments["data"]
            .cast<String, dynamic>();
        // decode args to json
        handlerDataMap["args"] = jsonDecode(handlerDataMap["args"]);
        final handlerData = JavaScriptHandlerFunctionData.fromMap(
          handlerDataMap,
        )!;

        _debugLog(handlerName, handlerData);

        if (_javaScriptHandlersMap.containsKey(handlerName)) {
          // convert result to json
          try {
            var jsHandlerResult = null;
            if (_javaScriptHandlersMap[handlerName]
                is JavaScriptHandlerCallback) {
              jsHandlerResult =
                  await (_javaScriptHandlersMap[handlerName]
                      as JavaScriptHandlerCallback)(handlerData.args);
            } else if (_javaScriptHandlersMap[handlerName]
                is JavaScriptHandlerFunction) {
              jsHandlerResult =
                  await (_javaScriptHandlersMap[handlerName]
                      as JavaScriptHandlerFunction)(handlerData);
            } else {
              jsHandlerResult = await _javaScriptHandlersMap[handlerName]!();
            }
            return jsonEncode(jsHandlerResult);
          } catch (error, stacktrace) {
            developer.log(
              error.toString() + '\n' + stacktrace.toString(),
              name: 'JavaScript Handler "$handlerName"',
            );
            throw Exception(error.toString().replaceFirst('Exception: ', ''));
          }
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  @override
  Future<WebUri?> getUrl() async {
    Map<String, dynamic> args = <String, dynamic>{};
    String? url = await channel?.invokeMethod<String?>('getUrl', args);
    return url != null ? WebUri(url) : null;
  }

  @override
  Future<String?> getTitle() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<String?>('getTitle', args);
  }

  @override
  Future<String?> getHtml() async {
    String? html;

    InAppWebViewSettings? settings = await getSettings();
    if (settings != null && settings.javaScriptEnabled == true) {
      html = await evaluateJavascript(
        source: "window.document.getElementsByTagName('html')[0].outerHTML;",
      );
      if (html != null && html.isNotEmpty) return html;
    }

    var webviewUrl = await getUrl();
    if (webviewUrl == null) {
      return html;
    }

    if (webviewUrl.isScheme("file")) {
      var assetPathSplit = webviewUrl.toString().split("/flutter_assets/");
      var assetPath = assetPathSplit[assetPathSplit.length - 1];
      try {
        var bytes = await rootBundle.load(assetPath);
        html = utf8.decode(bytes.buffer.asUint8List());
      } catch (e) {}
    }

    return html;
  }

  @override
  Future<List<Favicon>> getFavicons() async {
    List<Favicon> favicons = [];

    var webviewUrl = await getUrl();

    if (webviewUrl == null) {
      return favicons;
    }

    String? manifestUrl;

    var html = await getHtml();
    if (html == null || html.isEmpty) {
      return favicons;
    }
    var assetPathBase;

    if (webviewUrl.isScheme("file")) {
      var assetPathSplit = webviewUrl.toString().split("/flutter_assets/");
      assetPathBase = assetPathSplit[0] + "/flutter_assets/";
    }

    InAppWebViewSettings? settings = await getSettings();
    if (settings != null && settings.javaScriptEnabled == true) {
      List<Map<dynamic, dynamic>> links =
          (await evaluateJavascript(
            source: """
(function() {
  var linkNodes = document.head.getElementsByTagName("link");
  var links = [];
  for (var i = 0; i < linkNodes.length; i++) {
    var linkNode = linkNodes[i];
    if (linkNode.rel === 'manifest') {
      links.push(
        {
          rel: linkNode.rel,
          href: linkNode.href,
          sizes: null
        }
      );
    } else if (linkNode.rel != null && linkNode.rel.indexOf('icon') >= 0) {
      links.push(
        {
          rel: linkNode.rel,
          href: linkNode.href,
          sizes: linkNode.sizes != null && linkNode.sizes.value != "" ? linkNode.sizes.value : null
        }
      );
    }
  }
  return links;
})();
""",
          ))?.cast<Map<dynamic, dynamic>>() ??
          [];
      for (var link in links) {
        if (link["rel"] == "manifest") {
          manifestUrl = link["href"];
          if (!_isUrlAbsolute(manifestUrl!)) {
            if (manifestUrl.startsWith("/")) {
              manifestUrl = manifestUrl.substring(1);
            }
            manifestUrl =
                ((assetPathBase == null)
                    ? webviewUrl.scheme + "://" + webviewUrl.host + "/"
                    : assetPathBase) +
                manifestUrl;
          }
          continue;
        }
        favicons.addAll(
          _createFavicons(
            webviewUrl,
            assetPathBase,
            link["href"],
            link["rel"],
            link["sizes"],
            false,
          ),
        );
      }
    }

    return favicons;
  }

  bool _isUrlAbsolute(String url) {
    return url.startsWith("http://") || url.startsWith("https://");
  }

  List<Favicon> _createFavicons(
    WebUri url,
    String? assetPathBase,
    String urlIcon,
    String? rel,
    String? sizes,
    bool isManifest,
  ) {
    List<Favicon> favicons = [];

    List<String> urlSplit = urlIcon.split("/");
    if (!_isUrlAbsolute(urlIcon)) {
      if (urlIcon.startsWith("/")) {
        urlIcon = urlIcon.substring(1);
      }
      urlIcon =
          ((assetPathBase == null)
              ? url.scheme + "://" + url.host + "/"
              : assetPathBase) +
          urlIcon;
    }
    if (isManifest) {
      rel = (sizes != null)
          ? urlSplit[urlSplit.length - 1]
                .replaceFirst("-" + sizes, "")
                .split(" ")[0]
                .split(".")[0]
          : null;
    }
    if (sizes != null && sizes.isNotEmpty && sizes != "any") {
      List<String> sizesSplit = sizes.split(" ");
      for (String size in sizesSplit) {
        int width = int.parse(size.split("x")[0]);
        int height = int.parse(size.split("x")[1]);
        favicons.add(
          Favicon(url: WebUri(urlIcon), rel: rel, width: width, height: height),
        );
      }
    } else {
      favicons.add(
        Favicon(url: WebUri(urlIcon), rel: rel, width: null, height: null),
      );
    }

    return favicons;
  }

  @override
  Future<void> loadUrl({
    required URLRequest urlRequest,
    @Deprecated('Use allowingReadAccessTo instead')
    Uri? iosAllowingReadAccessTo,
    WebUri? allowingReadAccessTo,
  }) async {
    assert(urlRequest.url != null && urlRequest.url.toString().isNotEmpty);
    assert(
      allowingReadAccessTo == null || allowingReadAccessTo.isScheme("file"),
    );
    assert(
      iosAllowingReadAccessTo == null ||
          iosAllowingReadAccessTo.isScheme("file"),
    );

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlRequest', () => urlRequest.toMap());
    args.putIfAbsent(
      'allowingReadAccessTo',
      () =>
          allowingReadAccessTo?.toString() ??
          iosAllowingReadAccessTo?.toString(),
    );
    await channel?.invokeMethod('loadUrl', args);
  }

  @override
  Future<void> postUrl({
    required WebUri url,
    required Uint8List postData,
  }) async {
    assert(url.toString().isNotEmpty);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    args.putIfAbsent('postData', () => postData);
    await channel?.invokeMethod('postUrl', args);
  }

  @override
  Future<void> loadData({
    required String data,
    String mimeType = "text/html",
    String encoding = "utf8",
    WebUri? baseUrl,
    @Deprecated('Use historyUrl instead') Uri? androidHistoryUrl,
    WebUri? historyUrl,
    @Deprecated('Use allowingReadAccessTo instead')
    Uri? iosAllowingReadAccessTo,
    WebUri? allowingReadAccessTo,
  }) async {
    assert(
      allowingReadAccessTo == null || allowingReadAccessTo.isScheme("file"),
    );
    assert(
      iosAllowingReadAccessTo == null ||
          iosAllowingReadAccessTo.isScheme("file"),
    );

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('data', () => data);
    args.putIfAbsent('mimeType', () => mimeType);
    args.putIfAbsent('encoding', () => encoding);
    args.putIfAbsent('baseUrl', () => baseUrl?.toString() ?? "about:blank");
    args.putIfAbsent(
      'historyUrl',
      () =>
          historyUrl?.toString() ??
          androidHistoryUrl?.toString() ??
          "about:blank",
    );
    args.putIfAbsent(
      'allowingReadAccessTo',
      () =>
          allowingReadAccessTo?.toString() ??
          iosAllowingReadAccessTo?.toString(),
    );
    await channel?.invokeMethod('loadData', args);
  }

  @override
  Future<void> loadFile({required String assetFilePath}) async {
    assert(assetFilePath.isNotEmpty);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('assetFilePath', () => assetFilePath);
    await channel?.invokeMethod('loadFile', args);
  }

  @override
  Future<void> reload() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('reload', args);
  }

  @override
  Future<void> goBack() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('goBack', args);
  }

  @override
  Future<void> goForward() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('goForward', args);
  }

  @override
  Future<void> goBackOrForward({required int steps}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('steps', () => steps);
    await channel?.invokeMethod('goBackOrForward', args);
  }

  @override
  Future<bool> isLoading() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('isLoading', args) ?? false;
  }

  @override
  Future<void> stopLoading() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('stopLoading', args);
  }

  @override
  Future<dynamic> evaluateJavascript({
    required String source,
    ContentWorld? contentWorld,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('source', () => source);
    args.putIfAbsent('contentWorld', () => contentWorld?.toMap());
    var data = await channel?.invokeMethod('evaluateJavascript', args);
    if (data != null) {
      try {
        // try to json decode the data coming from JavaScript
        // otherwise return it as it is.
        data = json.decode(data);
      } catch (e) {}
    }
    return data;
  }

  @override
  Future<void> injectJavascriptFileFromUrl({
    required WebUri urlFile,
    ScriptHtmlTagAttributes? scriptHtmlTagAttributes,
  }) async {
    assert(urlFile.toString().isNotEmpty);
    var id = scriptHtmlTagAttributes?.id;
    if (scriptHtmlTagAttributes != null && id != null) {
      _injectedScriptsFromURL[id] = scriptHtmlTagAttributes;
    }
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlFile', () => urlFile.toString());
    args.putIfAbsent(
      'scriptHtmlTagAttributes',
      () => scriptHtmlTagAttributes?.toMap(),
    );
    await channel?.invokeMethod('injectJavascriptFileFromUrl', args);
  }

  @override
  Future<dynamic> injectJavascriptFileFromAsset({
    required String assetFilePath,
  }) async {
    String source = await rootBundle.loadString(assetFilePath);
    return await evaluateJavascript(source: source);
  }

  @override
  Future<void> injectCSSCode({required String source}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('source', () => source);
    await channel?.invokeMethod('injectCSSCode', args);
  }

  @override
  Future<void> injectCSSFileFromUrl({
    required WebUri urlFile,
    CSSLinkHtmlTagAttributes? cssLinkHtmlTagAttributes,
  }) async {
    assert(urlFile.toString().isNotEmpty);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlFile', () => urlFile.toString());
    args.putIfAbsent(
      'cssLinkHtmlTagAttributes',
      () => cssLinkHtmlTagAttributes?.toMap(),
    );
    await channel?.invokeMethod('injectCSSFileFromUrl', args);
  }

  @override
  Future<void> injectCSSFileFromAsset({required String assetFilePath}) async {
    String source = await rootBundle.loadString(assetFilePath);
    await injectCSSCode(source: source);
  }

  @override
  @Deprecated('Use setSettings instead')
  Future<void> setOptions({required InAppWebViewGroupOptions options}) async {
    InAppWebViewSettings settings =
        InAppWebViewSettings.fromMap(options.toMap()) ?? InAppWebViewSettings();
    await setSettings(settings: settings);
  }

  @override
  @Deprecated('Use getSettings instead')
  Future<InAppWebViewGroupOptions?> getOptions() async {
    InAppWebViewSettings? settings = await getSettings();

    Map<dynamic, dynamic>? options = settings?.toMap();
    if (options != null) {
      options = options.cast<String, dynamic>();
      return InAppWebViewGroupOptions.fromMap(options as Map<String, dynamic>);
    }

    return null;
  }

  @override
  Future<void> setSettings({required InAppWebViewSettings settings}) async {
    Map<String, dynamic> args = <String, dynamic>{};

    args.putIfAbsent('settings', () => settings.toMap());
    await channel?.invokeMethod('setSettings', args);
  }

  @override
  Future<InAppWebViewSettings?> getSettings() async {
    Map<String, dynamic> args = <String, dynamic>{};

    Map<dynamic, dynamic>? settings = await channel?.invokeMethod(
      'getSettings',
      args,
    );
    if (settings != null) {
      settings = settings.cast<String, dynamic>();
      return InAppWebViewSettings.fromMap(settings as Map<String, dynamic>);
    }

    return null;
  }

  @override
  @Deprecated("Use tRexRunnerHtml instead")
  Future<String> getTRexRunnerHtml() async {
    return await tRexRunnerHtml;
  }

  @override
  @Deprecated("Use tRexRunnerCss instead")
  Future<String> getTRexRunnerCss() async {
    return await tRexRunnerCss;
  }

  @override
  Future<void> scrollTo({
    required int x,
    required int y,
    bool animated = false,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('x', () => x);
    args.putIfAbsent('y', () => y);
    args.putIfAbsent('animated', () => animated);
    await channel?.invokeMethod('scrollTo', args);
  }

  @override
  Future<void> scrollBy({
    required int x,
    required int y,
    bool animated = false,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('x', () => x);
    args.putIfAbsent('y', () => y);
    args.putIfAbsent('animated', () => animated);
    await channel?.invokeMethod('scrollBy', args);
  }

  @override
  Future<PlatformPrintJobController?> printCurrentPage({
    PrintJobSettings? settings,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("settings", () => settings?.toMap());
    await channel?.invokeMethod<String?>('printCurrentPage', args);
    return null;
  }

  @override
  Future<int?> getContentHeight() async {
    Map<String, dynamic> args = <String, dynamic>{};
    var height = await channel?.invokeMethod('getContentHeight', args);
    if (height == null || height == 0) {
      // try to use javascript
      var scrollHeight = await evaluateJavascript(
        source: "document.documentElement.scrollHeight;",
      );
      if (scrollHeight != null && scrollHeight is num) {
        height = scrollHeight.toInt();
      }
    }
    return height;
  }

  @override
  Future<int?> getContentWidth() async {
    Map<String, dynamic> args = <String, dynamic>{};
    var width = await channel?.invokeMethod('getContentWidth', args);
    if (width == null || width == 0) {
      // try to use javascript
      var scrollHeight = await evaluateJavascript(
        source: "document.documentElement.scrollWidth;",
      );
      if (scrollHeight != null && scrollHeight is num) {
        width = scrollHeight.toInt();
      }
    }
    return width;
  }

  @override
  Future<WebUri?> getOriginalUrl() async {
    Map<String, dynamic> args = <String, dynamic>{};
    String? url = await channel?.invokeMethod<String?>('getOriginalUrl', args);
    return url != null ? WebUri(url) : null;
  }

  @override
  Future<String?> getSelectedText() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<String?>('getSelectedText', args);
  }

  @override
  Future<List<MetaTag>> getMetaTags() async {
    List<MetaTag> metaTags = [];

    List<Map<dynamic, dynamic>>? metaTagList = (await evaluateJavascript(
      source: """
(function() {
  var metaTags = [];
  var metaTagNodes = document.head.getElementsByTagName('meta');
  for (var i = 0; i < metaTagNodes.length; i++) {
    var metaTagNode = metaTagNodes[i];
    
    var otherAttributes = metaTagNode.getAttributeNames();
    var nameIndex = otherAttributes.indexOf("name");
    if (nameIndex !== -1) otherAttributes.splice(nameIndex, 1);
    var contentIndex = otherAttributes.indexOf("content");
    if (contentIndex !== -1) otherAttributes.splice(contentIndex, 1);
    
    var attrs = [];
    for (var j = 0; j < otherAttributes.length; j++) {
      var otherAttribute = otherAttributes[j];
      attrs.push(
        {
          name: otherAttribute,
          value: metaTagNode.getAttribute(otherAttribute)
        }
      );
    }

    metaTags.push(
      {
        name: metaTagNode.name,
        content: metaTagNode.content,
        attrs: attrs
      }
    );
  }
  return metaTags;
})();
    """,
    ))?.cast<Map<dynamic, dynamic>>();

    if (metaTagList == null) {
      return metaTags;
    }

    for (var metaTag in metaTagList) {
      var attrs = <MetaTagAttribute>[];

      for (var metaTagAttr in metaTag["attrs"]) {
        attrs.add(
          MetaTagAttribute(
            name: metaTagAttr["name"],
            value: metaTagAttr["value"],
          ),
        );
      }

      metaTags.add(
        MetaTag(
          name: metaTag["name"],
          content: metaTag["content"],
          attrs: attrs,
        ),
      );
    }

    return metaTags;
  }

  @override
  Future<Color?> getMetaThemeColor() async {
    Color? themeColor;

    try {
      Map<String, dynamic> args = <String, dynamic>{};
      themeColor = UtilColor.fromStringRepresentation(
        await channel?.invokeMethod('getMetaThemeColor', args),
      );
      return themeColor;
    } catch (e) {
      // not implemented
    }

    // try using javascript
    var metaTags = await getMetaTags();
    MetaTag? metaTagThemeColor;

    for (var metaTag in metaTags) {
      if (metaTag.name == "theme-color") {
        metaTagThemeColor = metaTag;
        break;
      }
    }

    if (metaTagThemeColor == null) {
      return null;
    }

    var colorValue = metaTagThemeColor.content;

    themeColor = colorValue != null
        ? UtilColor.fromStringRepresentation(colorValue)
        : null;

    return themeColor;
  }

  @override
  Future<int?> getScrollX() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<int?>('getScrollX', args);
  }

  @override
  Future<int?> getScrollY() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<int?>('getScrollY', args);
  }

  @override
  Future<bool> isSecureContext() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('isSecureContext', args) ?? false;
  }

  @override
  Future<bool> canScrollVertically() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('canScrollVertically', args) ??
        false;
  }

  @override
  Future<bool> canScrollHorizontally() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('canScrollHorizontally', args) ??
        false;
  }

  @override
  void addJavaScriptHandler({
    required String handlerName,
    required Function callback,
  }) {
    assert(
      !kJavaScriptHandlerForbiddenNames.contains(handlerName),
      '"$handlerName" is a forbidden name!',
    );
    this._javaScriptHandlersMap[handlerName] = (callback);
  }

  @override
  Function? removeJavaScriptHandler({required String handlerName}) {
    return this._javaScriptHandlersMap.remove(handlerName);
  }

  @override
  bool hasJavaScriptHandler({required String handlerName}) {
    return this._javaScriptHandlersMap.containsKey(handlerName);
  }

  @override
  Future<void> addUserScript({required UserScript userScript}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('userScript', () => userScript.toMap());
    if (!(_userScripts[userScript.injectionTime]?.contains(userScript) ??
        false)) {
      _userScripts[userScript.injectionTime]?.add(userScript);
      await channel?.invokeMethod('addUserScript', args);
    }
  }

  @override
  Future<void> addUserScripts({required List<UserScript> userScripts}) async {
    for (var i = 0; i < userScripts.length; i++) {
      await addUserScript(userScript: userScripts[i]);
    }
  }

  @override
  Future<bool> removeUserScript({required UserScript userScript}) async {
    var index = _userScripts[userScript.injectionTime]?.indexOf(userScript);
    if (index == null || index == -1) {
      return false;
    }

    _userScripts[userScript.injectionTime]?.remove(userScript);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('userScript', () => userScript.toMap());
    args.putIfAbsent('index', () => index);
    await channel?.invokeMethod('removeUserScript', args);

    return true;
  }

  @override
  Future<void> removeUserScriptsByGroupName({required String groupName}) async {
    final List<UserScript> userScriptsAtDocumentStart = List.from(
      _userScripts[UserScriptInjectionTime.AT_DOCUMENT_START] ?? [],
    );
    for (final userScript in userScriptsAtDocumentStart) {
      if (userScript.groupName == groupName) {
        _userScripts[userScript.injectionTime]?.remove(userScript);
      }
    }

    final List<UserScript> userScriptsAtDocumentEnd = List.from(
      _userScripts[UserScriptInjectionTime.AT_DOCUMENT_END] ?? [],
    );
    for (final userScript in userScriptsAtDocumentEnd) {
      if (userScript.groupName == groupName) {
        _userScripts[userScript.injectionTime]?.remove(userScript);
      }
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('groupName', () => groupName);
    await channel?.invokeMethod('removeUserScriptsByGroupName', args);
  }

  @override
  Future<void> removeUserScripts({
    required List<UserScript> userScripts,
  }) async {
    for (final userScript in userScripts) {
      await removeUserScript(userScript: userScript);
    }
  }

  @override
  Future<void> removeAllUserScripts() async {
    _userScripts[UserScriptInjectionTime.AT_DOCUMENT_START]?.clear();
    _userScripts[UserScriptInjectionTime.AT_DOCUMENT_END]?.clear();

    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('removeAllUserScripts', args);
  }

  @override
  bool hasUserScript({required UserScript userScript}) {
    return _userScripts[userScript.injectionTime]?.contains(userScript) ??
        false;
  }

  @override
  Future<void> setJavaScriptBridgeName(String bridgeName) async {
    assert(
      RegExp(r'^[a-zA-Z_]\w*$').hasMatch(bridgeName),
      'bridgeName must be a non-empty string with only alphanumeric and underscore characters. It can\'t start with a number.',
    );
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('bridgeName', () => bridgeName);
    await _staticChannel.invokeMethod('setJavaScriptBridgeName', args);
  }

  @override
  Future<String> getJavaScriptBridgeName() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _staticChannel.invokeMethod<String>(
          'getJavaScriptBridgeName',
          args,
        ) ??
        '';
  }

  @override
  Future<String> getDefaultUserAgent() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _staticChannel.invokeMethod<String>(
          'getDefaultUserAgent',
          args,
        ) ??
        '';
  }

  @override
  Future<String> get tRexRunnerHtml async => await rootBundle.loadString(
    'packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html',
  );

  @override
  Future<String> get tRexRunnerCss async => await rootBundle.loadString(
    'packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css',
  );

  @override
  Future<String?> getIFrameId() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<String?>('getIFrameId', args);
  }

  @override
  dynamic getViewId() {
    return id;
  }

  @override
  void dispose({bool isKeepAlive = false}) {
    disposeChannel(removeMethodCallHandler: true);
    webStorage.dispose();
    _controllerFromPlatform = null;
    _injectedScriptsFromURL.clear();
  }
}

extension InternalInAppWebViewController on WebPlatformInAppWebViewController {
  get handleMethod => _handleMethod;
}
