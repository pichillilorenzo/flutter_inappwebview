import 'dart:io';
import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

import 'package:html/parser.dart' show parse;

import 'types.dart';
import 'in_app_browser.dart';
import 'webview_options.dart';

const javaScriptHandlerForbiddenNames = ["onLoadResource", "shouldInterceptAjaxRequest", "onAjaxReadyStateChange", "onAjaxProgress", "shouldInterceptFetchRequest"];

///InAppWebView Widget class.
///
///Flutter Widget for adding an **inline native WebView** integrated in the flutter widget tree.
class InAppWebView extends StatefulWidget {

  ///Event fired when the [InAppWebView] is created.
  final void Function(InAppWebViewController controller) onWebViewCreated;

  ///Event fired when the [InAppWebView] starts to load an [url].
  final void Function(InAppWebViewController controller, String url) onLoadStart;

  ///Event fired when the [InAppWebView] finishes loading an [url].
  final void Function(InAppWebViewController controller, String url) onLoadStop;

  ///Event fired when the [InAppWebView] encounters an error loading an [url].
  final void Function(InAppWebViewController controller, String url, int code, String message) onLoadError;

  ///Event fired when the [InAppWebView] main page receives an HTTP error.
  ///
  ///[url] represents the url of the main page that received the HTTP error.
  ///
  ///[statusCode] represents the status code of the response. HTTP errors have status codes >= 400.
  ///
  ///[description] represents the description of the HTTP error. On iOS, it is always an empty string.
  ///
  ///**NOTE**: available on Android 23+.
  final void Function(InAppWebViewController controller, String url, int statusCode, String description) onLoadHttpError;

  ///Event fired when the current [progress] of loading a page is changed.
  final void Function(InAppWebViewController controller, int progress) onProgressChanged;

  ///Event fired when the [InAppWebView] receives a [ConsoleMessage].
  final void Function(InAppWebViewController controller, ConsoleMessage consoleMessage) onConsoleMessage;

  ///Give the host application a chance to take control when a URL is about to be loaded in the current WebView.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldOverrideUrlLoading] option to `true`.
  final void Function(InAppWebViewController controller, String url) shouldOverrideUrlLoading;

  ///Event fired when the [InAppWebView] loads a resource.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useOnLoadResource] and [InAppWebViewOptions.javaScriptEnabled] options to `true`.
  final void Function(InAppWebViewController controller, LoadedResource resource) onLoadResource;

  ///Event fired when the [InAppWebView] scrolls.
  ///
  ///[x] represents the current horizontal scroll origin in pixels.
  ///
  ///[y] represents the current vertical scroll origin in pixels.
  final void Function(InAppWebViewController controller, int x, int y) onScrollChanged;

  ///Event fired when [InAppWebView] recognizes and starts a downloadable file.
  ///
  ///[url] represents the url of the file.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useOnDownloadStart] option to `true`.
  final void Function(InAppWebViewController controller, String url) onDownloadStart;

  ///Event fired when the [InAppWebView] finds the `custom-scheme` while loading a resource. Here you can handle the url request and return a [CustomSchemeResponse] to load a specific resource encoded to `base64`.
  ///
  ///[scheme] represents the scheme of the url.
  ///
  ///[url] represents the url of the request.
  final Future<CustomSchemeResponse> Function(InAppWebViewController controller, String scheme, String url) onLoadResourceCustomScheme;

  ///Event fired when the [InAppWebView] tries to open a link with `target="_blank"`.
  ///
  ///[url] represents the url of the link.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useOnTargetBlank] option to `true`.
  final void Function(InAppWebViewController controller, String url) onTargetBlank;

  ///Event that notifies the host application that web content from the specified origin is attempting to use the Geolocation API, but no permission state is currently set for that origin.
  ///Note that for applications targeting Android N and later SDKs (API level > `Build.VERSION_CODES.M`) this method is only called for requests originating from secure origins such as https.
  ///On non-secure origins geolocation requests are automatically denied.
  ///
  ///[origin] represents the origin of the web content attempting to use the Geolocation API.
  ///
  ///**NOTE**: available only on Android.
  final Future<GeolocationPermissionShowPromptResponse> Function(InAppWebViewController controller, String origin) onGeolocationPermissionsShowPrompt;

  ///Event fired when javascript calls the `alert()` method to display an alert dialog.
  ///If [JsAlertResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[message] represents the message to be displayed in the alert dialog.
  final Future<JsAlertResponse> Function(InAppWebViewController controller, String message) onJsAlert;

  ///Event fired when javascript calls the `confirm()` method to display a confirm dialog.
  ///If [JsConfirmResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[message] represents the message to be displayed in the alert dialog.
  final Future<JsConfirmResponse> Function(InAppWebViewController controller, String message) onJsConfirm;

  ///Event fired when javascript calls the `prompt()` method to display a prompt dialog.
  ///If [JsPromptResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[message] represents the message to be displayed in the alert dialog.
  ///
  ///[defaultValue] represents the default value displayed in the prompt dialog.
  final Future<JsPromptResponse> Function(InAppWebViewController controller, String message, String defaultValue) onJsPrompt;

  ///Event fired when the webview notifies that a loading URL has been flagged by Safe Browsing.
  ///The default behavior is to show an interstitial to the user, with the reporting checkbox visible.
  ///
  ///[url] represents the url of the request.
  ///
  ///[threatType] represents the reason the resource was caught by Safe Browsing, corresponding to a [SafeBrowsingThreat].
  ///
  ///**NOTE**: available only on Android.
  final Future<SafeBrowsingResponse> Function(InAppWebViewController controller, String url, SafeBrowsingThreat threatType) onSafeBrowsingHit;

  ///Event fired when the WebView received an HTTP authentication request. The default behavior is to cancel the request.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [HttpAuthChallenge].
  final Future<HttpAuthResponse> Function(InAppWebViewController controller, HttpAuthChallenge challenge) onReceivedHttpAuthRequest;

  ///Event fired when the WebView need to perform server trust authentication (certificate validation).
  ///The host application must return either [ServerTrustAuthResponse] instance with [ServerTrustAuthResponseAction.CANCEL] or [ServerTrustAuthResponseAction.PROCEED].
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ServerTrustChallenge].
  final Future<ServerTrustAuthResponse> Function(InAppWebViewController controller, ServerTrustChallenge challenge) onReceivedServerTrustAuthRequest;

  ///Notify the host application to handle a SSL client certificate request.
  ///Webview stores the response in memory (for the life of the application) if [ClientCertResponseAction.PROCEED] or [ClientCertResponseAction.CANCEL]
  ///is called and does not call [onReceivedClientCertRequest] again for the same host and port pair.
  ///Note that, multiple layers in chromium network stack might be caching the responses.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ClientCertChallenge].
  final Future<ClientCertResponse> Function(InAppWebViewController controller, ClientCertChallenge challenge) onReceivedClientCertRequest;

  ///Event fired as find-on-page operations progress.
  ///The listener may be notified multiple times while the operation is underway, and the numberOfMatches value should not be considered final unless [isDoneCounting] is true.
  ///
  ///[activeMatchOrdinal] represents the zero-based ordinal of the currently selected match.
  ///
  ///[numberOfMatches] represents how many matches have been found.
  ///
  ///[isDoneCounting] whether the find operation has actually completed.
  final void Function(InAppWebViewController controller, int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting) onFindResultReceived;

  ///Event fired when an `XMLHttpRequest` is sent to a server.
  ///It gives the host application a chance to take control over the request before sending it.
  ///
  ///[ajaxRequest] represents the `XMLHttpRequest`.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptAjaxRequest] option to `true`.
  ///Also, unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppBrowserPlatformReady")` event, the ajax requests will be intercept for sure.
  final Future<AjaxRequest> Function(InAppWebViewController controller, AjaxRequest ajaxRequest) shouldInterceptAjaxRequest;

  ///Event fired whenever the `readyState` attribute of an `XMLHttpRequest` changes.
  ///It gives the host application a chance to abort the request.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptAjaxRequest] option to `true`.
  ///Also, unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppBrowserPlatformReady")` event, the ajax requests will be intercept for sure.
  final Future<AjaxRequestAction> Function(InAppWebViewController controller, AjaxRequest ajaxRequest) onAjaxReadyStateChange;

  ///Event fired as an `XMLHttpRequest` progress.
  ///It gives the host application a chance to abort the request.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptAjaxRequest] option to `true`.
  ///Also, unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppBrowserPlatformReady")` event, the ajax requests will be intercept for sure.
  final Future<AjaxRequestAction> Function(InAppWebViewController controller, AjaxRequest ajaxRequest) onAjaxProgress;

  ///Event fired when a request is sent to a server through [Fetch API](https://developer.mozilla.org/it/docs/Web/API/Fetch_API).
  ///It gives the host application a chance to take control over the request before sending it.
  ///
  ///[fetchRequest] represents a resource request.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptFetchRequest] option to `true`.
  ///Also, unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept fetch requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppBrowserPlatformReady")` event, the fetch requests will be intercept for sure.
  final Future<FetchRequest> Function(InAppWebViewController controller, FetchRequest fetchRequest) shouldInterceptFetchRequest;

  ///Event fired when the navigation state of the [InAppWebView] changes throught the usage of
  ///javascript **[History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API)** functions (`pushState()`, `replaceState()`) and `onpopstate` event.
  ///
  ///Also, the event is fired when the javascript `window.location` changes without reloading the webview (for example appending or modifying an hash to the url).
  ///
  ///[url] represents the new url.
  final void Function(InAppWebViewController controller, String url) onNavigationStateChange;

  ///Initial url that will be loaded.
  final String initialUrl;
  ///Initial asset file that will be loaded. See [InAppWebView.loadFile()] for explanation.
  final String initialFile;
  ///Initial [InAppWebViewInitialData] that will be loaded.
  final InAppWebViewInitialData initialData;
  ///Initial headers that will be used.
  final Map<String, String> initialHeaders;
  ///Initial options that will be used.
  final InAppWebViewWidgetOptions initialOptions;
  /// `gestureRecognizers` specifies which gestures should be consumed by the web view.
  /// It is possible for other gesture recognizers to be competing with the web view on pointer
  /// events, e.g if the web view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The web view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  /// When `gestureRecognizers` is empty or null, the web view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  const InAppWebView({
    Key key,
    this.initialUrl = "about:blank",
    this.initialFile,
    this.initialData,
    this.initialHeaders = const {},
    this.initialOptions,
    this.onWebViewCreated,
    this.onLoadStart,
    this.onLoadStop,
    this.onLoadError,
    this.onLoadHttpError,
    this.onConsoleMessage,
    this.onProgressChanged,
    this.shouldOverrideUrlLoading,
    this.onLoadResource,
    this.onScrollChanged,
    this.onDownloadStart,
    this.onLoadResourceCustomScheme,
    this.onTargetBlank,
    this.onGeolocationPermissionsShowPrompt,
    this.onJsAlert,
    this.onJsConfirm,
    this.onJsPrompt,
    this.onSafeBrowsingHit,
    this.onReceivedHttpAuthRequest,
    this.onReceivedServerTrustAuthRequest,
    this.onReceivedClientCertRequest,
    this.onFindResultReceived,
    this.shouldInterceptAjaxRequest,
    this.onAjaxReadyStateChange,
    this.onAjaxProgress,
    this.shouldInterceptFetchRequest,
    this.onNavigationStateChange,
    this.gestureRecognizers,
  }) : super(key: key);

  @override
  _InAppWebViewState createState() => _InAppWebViewState();
}

class _InAppWebViewState extends State<InAppWebView> {

  InAppWebViewController _controller;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> initialOptions = {};
    initialOptions.addAll(widget.initialOptions.inAppWebViewOptions?.toMap() ?? {});
    if (Platform.isAndroid)
      initialOptions.addAll(widget.initialOptions.androidInAppWebViewOptions?.toMap() ?? {});
    else if (Platform.isIOS)
      initialOptions.addAll(widget.initialOptions.iosInAppWebViewOptions?.toMap() ?? {});

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'com.pichillilorenzo/flutter_inappwebview',
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        layoutDirection: TextDirection.rtl,
        creationParams: <String, dynamic>{
          'initialUrl': widget.initialUrl,
          'initialFile': widget.initialFile,
          'initialData': widget.initialData?.toMap(),
          'initialHeaders': widget.initialHeaders,
          'initialOptions': initialOptions
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
      // onLongPress issue: https://github.com/flutter/plugins/blob/f31d16a6ca0c4bd6849cff925a00b6823973696b/packages/webview_flutter/lib/src/webview_android.dart#L31
      /*return GestureDetector(
        onLongPress: () {},
        excludeFromSemantics: true,
        child: AndroidView(
          viewType: 'com.pichillilorenzo/flutter_inappwebview',
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: widget.gestureRecognizers,
          layoutDirection: TextDirection.rtl,
          creationParams: <String, dynamic>{
            'initialUrl': widget.initialUrl,
            'initialFile': widget.initialFile,
            'initialData': widget.initialData?.toMap(),
            'initialHeaders': widget.initialHeaders,
            'initialOptions': initialOptions
          },
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );*/
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'com.pichillilorenzo/flutter_inappwebview',
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: <String, dynamic>{
          'initialUrl': widget.initialUrl,
          'initialFile': widget.initialFile,
          'initialData': widget.initialData?.toMap(),
          'initialHeaders': widget.initialHeaders,
          'initialOptions': initialOptions
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the flutter_inappbrowser plugin');
  }

  @override
  void didUpdateWidget(InAppWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose(){
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    _controller = InAppWebViewController(id, widget);
    if (widget.onWebViewCreated != null) {
      widget.onWebViewCreated(_controller);
    }
  }
}

/// Controls an [InAppWebView] widget instance.
///
/// An [InAppWebViewController] instance can be obtained by setting the [InAppWebView.onWebViewCreated]
/// callback for an [InAppWebView] widget.
class InAppWebViewController {

  InAppWebView _widget;
  MethodChannel _channel;
  Map<String, JavaScriptHandlerCallback> javaScriptHandlersMap = HashMap<String, JavaScriptHandlerCallback>();
  // ignore: unused_field
  bool _isOpened = false;
  // ignore: unused_field
  int _id;
  String _inAppBrowserUuid;
  InAppBrowser _inAppBrowser;


  InAppWebViewController(int id, InAppWebView widget) {
    this._id = id;
    this._channel = MethodChannel('com.pichillilorenzo/flutter_inappwebview_$id');
    this._channel.setMethodCallHandler(handleMethod);
    this._widget = widget;
  }

  InAppWebViewController.fromInAppBrowser(String uuid, MethodChannel channel, InAppBrowser inAppBrowser) {
    this._inAppBrowserUuid = uuid;
    this._channel = channel;
    this._inAppBrowser = inAppBrowser;
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch(call.method) {
      case "onLoadStart":
        String url = call.arguments["url"];
        if (_widget != null && _widget.onLoadStart != null)
          _widget.onLoadStart(this, url);
        else if (_inAppBrowser != null)
          _inAppBrowser.onLoadStart(url);
        break;
      case "onLoadStop":
        String url = call.arguments["url"];
        if (_widget != null && _widget.onLoadStop != null)
          _widget.onLoadStop(this, url);
        else if (_inAppBrowser != null)
          _inAppBrowser.onLoadStop(url);
        break;
      case "onLoadError":
        String url = call.arguments["url"];
        int code = call.arguments["code"];
        String message = call.arguments["message"];
        if (_widget != null && _widget.onLoadError != null)
          _widget.onLoadError(this, url, code, message);
        else if (_inAppBrowser != null)
          _inAppBrowser.onLoadError(url, code, message);
        break;
      case "onLoadHttpError":
        String url = call.arguments["url"];
        int statusCode = call.arguments["statusCode"];
        String description = call.arguments["description"];
        if (_widget != null && _widget.onLoadHttpError != null)
          _widget.onLoadHttpError(this, url, statusCode, description);
        else if (_inAppBrowser != null)
          _inAppBrowser.onLoadHttpError(url, statusCode, description);
        break;
      case "onProgressChanged":
        int progress = call.arguments["progress"];
        if (_widget != null && _widget.onProgressChanged != null)
          _widget.onProgressChanged(this, progress);
        else if (_inAppBrowser != null)
          _inAppBrowser.onProgressChanged(progress);
        break;
      case "shouldOverrideUrlLoading":
        String url = call.arguments["url"];
        if (_widget != null && _widget.shouldOverrideUrlLoading != null)
          _widget.shouldOverrideUrlLoading(this, url);
        else if (_inAppBrowser != null)
          _inAppBrowser.shouldOverrideUrlLoading(url);
        break;
      case "onConsoleMessage":
        String message = call.arguments["message"];
        ConsoleMessageLevel messageLevel = ConsoleMessageLevel.fromValue(call.arguments["messageLevel"]);
        ConsoleMessage consoleMessage = ConsoleMessage(message: message, messageLevel: messageLevel);
        if (_widget != null && _widget.onConsoleMessage != null)
          _widget.onConsoleMessage(this, consoleMessage);
        else if (_inAppBrowser != null)
          _inAppBrowser.onConsoleMessage(consoleMessage);
        break;
      case "onScrollChanged":
        int x = call.arguments["x"];
        int y = call.arguments["y"];
        if (_widget != null && _widget.onScrollChanged != null)
          _widget.onScrollChanged(this, x, y);
        else if (_inAppBrowser != null)
          _inAppBrowser.onScrollChanged(x, y);
        break;
      case "onDownloadStart":
        String url = call.arguments["url"];
        if (_widget != null && _widget.onDownloadStart != null)
          _widget.onDownloadStart(this, url);
        else if (_inAppBrowser != null)
          _inAppBrowser.onDownloadStart(url);
        break;
      case "onLoadResourceCustomScheme":
        String scheme = call.arguments["scheme"];
        String url = call.arguments["url"];
        if (_widget != null && _widget.onLoadResourceCustomScheme != null) {
          try {
            var response = await _widget.onLoadResourceCustomScheme(this, scheme, url);
            return (response != null) ? response.toJson(): null;
          } catch (error) {
            print(error);
            return null;
          }
        } else if (_inAppBrowser != null) {
          try {
            var response = await _inAppBrowser.onLoadResourceCustomScheme(scheme, url);
            return (response != null) ? response.toJson(): null;
          } catch (error) {
            print(error);
            return null;
          }
        }
        break;
      case "onTargetBlank":
        String url = call.arguments["url"];
        if (_widget != null && _widget.onTargetBlank != null)
          _widget.onTargetBlank(this, url);
        else if (_inAppBrowser != null)
          _inAppBrowser.onTargetBlank(url);
        break;
      case "onGeolocationPermissionsShowPrompt":
        String origin = call.arguments["origin"];
        if (_widget != null && _widget.onGeolocationPermissionsShowPrompt != null)
          return (await _widget.onGeolocationPermissionsShowPrompt(this, origin))?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser.onGeolocationPermissionsShowPrompt(origin))?.toMap();
        break;
      case "onJsAlert":
        String message = call.arguments["message"];
        if (_widget != null && _widget.onJsAlert != null)
          return (await _widget.onJsAlert(this, message))?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser.onJsAlert(message))?.toMap();
        break;
      case "onJsConfirm":
        String message = call.arguments["message"];
        if (_widget != null && _widget.onJsConfirm != null)
          return (await _widget.onJsConfirm(this, message))?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser.onJsConfirm(message))?.toMap();
        break;
      case "onJsPrompt":
        String message = call.arguments["message"];
        String defaultValue = call.arguments["defaultValue"];
        if (_widget != null && _widget.onJsPrompt != null)
          return (await _widget.onJsPrompt(this, message, defaultValue))?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser.onJsPrompt(message, defaultValue))?.toMap();
        break;
      case "onSafeBrowsingHit":
        String url = call.arguments["url"];
        SafeBrowsingThreat threatType = SafeBrowsingThreat.fromValue(call.arguments["threatType"]);
        if (_widget != null && _widget.onSafeBrowsingHit != null)
          return (await _widget.onSafeBrowsingHit(this, url, threatType))?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser.onSafeBrowsingHit(url, threatType))?.toMap();
        break;
      case "onReceivedHttpAuthRequest":
        String host = call.arguments["host"];
        String protocol = call.arguments["protocol"];
        String realm = call.arguments["realm"];
        int port = call.arguments["port"];
        int previousFailureCount = call.arguments["previousFailureCount"];
        var protectionSpace = ProtectionSpace(host: host, protocol: protocol, realm: realm, port: port);
        var challenge = HttpAuthChallenge(previousFailureCount: previousFailureCount, protectionSpace: protectionSpace);
        if (_widget != null && _widget.onReceivedHttpAuthRequest != null)
          return (await _widget.onReceivedHttpAuthRequest(this, challenge))?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser.onReceivedHttpAuthRequest(challenge))?.toMap();
        break;
      case "onReceivedServerTrustAuthRequest":
        String host = call.arguments["host"];
        String protocol = call.arguments["protocol"];
        String realm = call.arguments["realm"];
        int port = call.arguments["port"];
        int error = call.arguments["error"];
        String message = call.arguments["message"];
        Uint8List serverCertificate = call.arguments["serverCertificate"];
        var protectionSpace = ProtectionSpace(host: host, protocol: protocol, realm: realm, port: port);
        var challenge = ServerTrustChallenge(protectionSpace: protectionSpace, error: error, message: message, serverCertificate: serverCertificate);
        if (_widget != null && _widget.onReceivedServerTrustAuthRequest != null)
          return (await _widget.onReceivedServerTrustAuthRequest(this, challenge))?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser.onReceivedServerTrustAuthRequest(challenge))?.toMap();
        break;
      case "onReceivedClientCertRequest":
        String host = call.arguments["host"];
        String protocol = call.arguments["protocol"];
        String realm = call.arguments["realm"];
        int port = call.arguments["port"];
        var protectionSpace = ProtectionSpace(host: host, protocol: protocol, realm: realm, port: port);
        var challenge = ClientCertChallenge(protectionSpace: protectionSpace);
        if (_widget != null && _widget.onReceivedClientCertRequest != null)
          return (await _widget.onReceivedClientCertRequest(this, challenge))?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser.onReceivedClientCertRequest(challenge))?.toMap();
        break;
      case "onFindResultReceived":
        int activeMatchOrdinal = call.arguments["activeMatchOrdinal"];
        int numberOfMatches = call.arguments["numberOfMatches"];
        bool isDoneCounting = call.arguments["isDoneCounting"];
        if (_widget != null && _widget.onFindResultReceived != null)
          _widget.onFindResultReceived(this, activeMatchOrdinal, numberOfMatches, isDoneCounting);
        else if (_inAppBrowser != null)
          _inAppBrowser.onFindResultReceived(activeMatchOrdinal, numberOfMatches, isDoneCounting);
        break;
      case "onNavigationStateChange":
        String url = call.arguments["url"];
        if (_widget != null && _widget.onNavigationStateChange != null)
          _widget.onNavigationStateChange(this, url);
        else if (_inAppBrowser != null)
          _inAppBrowser.onNavigationStateChange(url);
        break;
      case "onCallJsHandler":
        String handlerName = call.arguments["handlerName"];
        // decode args to json
        List<dynamic> args = jsonDecode(call.arguments["args"]);

        switch(handlerName) {
          case "onLoadResource":
            Map<dynamic, dynamic> argMap = args[0];
            String initiatorType = argMap["initiatorType"];
            String url = argMap["name"];
            double startTime = argMap["startTime"] is int ? argMap["startTime"].toDouble() : argMap["startTime"];
            double duration = argMap["duration"] is int ? argMap["duration"].toDouble() : argMap["duration"];

            var response = new LoadedResource(initiatorType: initiatorType, url: url, startTime: startTime, duration: duration);

            if (_widget != null && _widget.onLoadResource != null)
              _widget.onLoadResource(this, response);
            else if (_inAppBrowser != null)
              _inAppBrowser.onLoadResource(response);
            return null;
          case "shouldInterceptAjaxRequest":
            Map<dynamic, dynamic> argMap = args[0];
            dynamic data = argMap["data"];
            String method = argMap["method"];
            String url = argMap["url"];
            bool isAsync = argMap["isAsync"];
            String user = argMap["user"];
            String password = argMap["password"];
            bool withCredentials = argMap["withCredentials"];
            AjaxRequestHeaders headers = AjaxRequestHeaders(argMap["headers"]);
            String responseType = argMap["responseType"];

            var request = new AjaxRequest(data: data, method: method, url: url, isAsync: isAsync, user: user, password: password, withCredentials: withCredentials, headers: headers, responseType: responseType);

            if (_widget != null && _widget.shouldInterceptAjaxRequest != null)
              return jsonEncode(await _widget.shouldInterceptAjaxRequest(this, request));
            else if (_inAppBrowser != null)
              return jsonEncode(await _inAppBrowser.shouldInterceptAjaxRequest(request));
            return null;
          case "onAjaxReadyStateChange":
            Map<dynamic, dynamic> argMap = args[0];
            dynamic data = argMap["data"];
            String method = argMap["method"];
            String url = argMap["url"];
            bool isAsync = argMap["isAsync"];
            String user = argMap["user"];
            String password = argMap["password"];
            bool withCredentials = argMap["withCredentials"];
            AjaxRequestHeaders headers = AjaxRequestHeaders(argMap["headers"]);
            int readyState = argMap["readyState"];
            int status = argMap["status"];
            String responseURL = argMap["responseURL"];
            String responseType = argMap["responseType"];
            dynamic response = argMap["response"];
            String responseText = argMap["responseText"];
            String responseXML = argMap["responseXML"];
            String statusText = argMap["statusText"];
            Map<dynamic, dynamic> responseHeaders = argMap["responseHeaders"];

            var request = new AjaxRequest(data: data, method: method, url: url, isAsync: isAsync, user: user, password: password,
                withCredentials: withCredentials, headers: headers, readyState: AjaxRequestReadyState.fromValue(readyState), status: status, responseURL: responseURL,
                responseType: responseType, response: response, responseText: responseText, responseXML: responseXML, statusText: statusText, responseHeaders: responseHeaders);

            if (_widget != null && _widget.onAjaxReadyStateChange != null)
              return jsonEncode(await _widget.onAjaxReadyStateChange(this, request));
            else if (_inAppBrowser != null)
              return jsonEncode(await _inAppBrowser.onAjaxReadyStateChange(request));
            return null;
          case "onAjaxProgress":
            Map<dynamic, dynamic> argMap = args[0];
            dynamic data = argMap["data"];
            String method = argMap["method"];
            String url = argMap["url"];
            bool isAsync = argMap["isAsync"];
            String user = argMap["user"];
            String password = argMap["password"];
            bool withCredentials = argMap["withCredentials"];
            AjaxRequestHeaders headers = AjaxRequestHeaders(argMap["headers"]);
            int readyState = argMap["readyState"];
            int status = argMap["status"];
            String responseURL = argMap["responseURL"];
            String responseType = argMap["responseType"];
            dynamic response = argMap["response"];
            String responseText = argMap["responseText"];
            String responseXML = argMap["responseXML"];
            String statusText = argMap["statusText"];
            Map<dynamic, dynamic> responseHeaders = argMap["responseHeaders"];
            Map<dynamic, dynamic> eventMap = argMap["event"];

            AjaxRequestEvent event = AjaxRequestEvent(lengthComputable: eventMap["lengthComputable"], loaded: eventMap["loaded"], total: eventMap["total"], type: AjaxRequestEventType.fromValue(eventMap["type"]));

            var request = new AjaxRequest(data: data, method: method, url: url, isAsync: isAsync, user: user, password: password,
                withCredentials: withCredentials, headers: headers, readyState: AjaxRequestReadyState.fromValue(readyState), status: status, responseURL: responseURL,
                responseType: responseType, response: response, responseText: responseText, responseXML: responseXML, statusText: statusText, responseHeaders: responseHeaders, event: event);

            if (_widget != null && _widget.onAjaxProgress != null)
              return jsonEncode(await _widget.onAjaxProgress(this, request));
            else if (_inAppBrowser != null)
              return jsonEncode(await _inAppBrowser.onAjaxProgress(request));
            return null;
          case "shouldInterceptFetchRequest":
            Map<dynamic, dynamic> argMap = args[0];
            String url = argMap["url"];
            String method = argMap["method"];
            Map<dynamic, dynamic> headers = argMap["headers"];
            Uint8List body = Uint8List.fromList(argMap["body"].cast<int>());
            String mode = argMap["mode"];
            FetchRequestCredential credentials = FetchRequest.createFetchRequestCredentialFromMap(argMap["credentials"]);
            String cache = argMap["cache"];
            String redirect = argMap["redirect"];
            String referrer = argMap["referrer"];
            String referrerPolicy = argMap["referrerPolicy"];
            String integrity = argMap["integrity"];
            bool keepalive = argMap["keepalive"];

            var request = new FetchRequest(url: url, method: method, headers: headers, body: body, mode: mode, credentials: credentials,
                cache: cache, redirect: redirect, referrer: referrer, referrerPolicy: referrerPolicy, integrity: integrity, keepalive: keepalive);

            if (_widget != null && _widget.shouldInterceptFetchRequest != null)
              return jsonEncode(await _widget.shouldInterceptFetchRequest(this, request));
            else if (_inAppBrowser != null)
              return jsonEncode(await _inAppBrowser.shouldInterceptFetchRequest(request));
            return null;
        }

        if (javaScriptHandlersMap.containsKey(handlerName)) {
          // convert result to json
          try {
            return jsonEncode(await javaScriptHandlersMap[handlerName](args));
          } catch (error) {
            print(error);
            return null;
          }
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
  }

  ///Gets the URL for the current page.
  ///This is not always the same as the URL passed to [InAppWebView.onLoadStarted] because although the load for that URL has begun, the current page may not have changed.
  Future<String> getUrl() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('getUrl', args);
  }

  ///Gets the title for the current page.
  Future<String> getTitle() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('getTitle', args);
  }

  ///Gets the progress for the current page. The progress value is between 0 and 100.
  Future<int> getProgress() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('getProgress', args);
  }

  ///Gets the content html of the page. It first tries to get the content through javascript.
  ///If this doesn't work, it tries to get the content reading the file:
  ///- checking if it is an asset (`file:///`) or
  ///- downloading it using an `HttpClient` through the WebView's current url.
  Future<String> getHtml() async {
    var html = "";
    InAppWebViewWidgetOptions options = await getOptions();
    if (options != null && options.inAppWebViewOptions.javaScriptEnabled == true) {
      html = await evaluateJavascript(source: "window.document.getElementsByTagName('html')[0].outerHTML;");
      if (html != null && html.isNotEmpty)
        return html;
    }

    var webviewUrl = await getUrl();
    if (webviewUrl.startsWith("file:///")) {
      var assetPathSplitted = webviewUrl.split("/flutter_assets/");
      var assetPath = assetPathSplitted[assetPathSplitted.length - 1];
      var bytes = await rootBundle.load(assetPath);
      html = utf8.decode(bytes.buffer.asUint8List());
    }
    else {
      HttpClient client = new HttpClient();
      var url = Uri.parse(webviewUrl);
      try {
        var htmlRequest = await client.getUrl(url);
        html = await (await htmlRequest.close()).transform(Utf8Decoder()).join();
      } catch (e) {
        print(e);
      }
    }
    return html;
  }

  ///Gets the list of all favicons for the current page.
  Future<List<Favicon>> getFavicons() async {
    List<Favicon> favicons = [];

    HttpClient client = new HttpClient();
    var webviewUrl = await getUrl();
    var url = (webviewUrl.startsWith("file:///")) ? Uri.file(webviewUrl) : Uri.parse(webviewUrl);
    String manifestUrl;

    var html = await getHtml();
    if (html.isEmpty) {
        return favicons;
    }

    var assetPathBase;

    if (webviewUrl.startsWith("file:///")) {
      var assetPathSplitted = webviewUrl.split("/flutter_assets/");
      assetPathBase = assetPathSplitted[0] + "/flutter_assets/";
    }

    // get all link html elements
    var document = parse(html);
    var links = document.getElementsByTagName('link');
    for (var link in links) {
      var attributes = link.attributes;
      if (attributes["rel"] == "manifest") {
        manifestUrl = attributes["href"];
        if (!_isUrlAbsolute(manifestUrl)) {
          if (manifestUrl.startsWith("/")) {
            manifestUrl = manifestUrl.substring(1);
          }
          manifestUrl = ((assetPathBase == null) ? url.scheme + "://" + url.host + "/" : assetPathBase) + manifestUrl;
        }
        continue;
      }
      if (!attributes["rel"].contains("icon")) {
        continue;
      }
      favicons.addAll(_createFavicons(url, assetPathBase, attributes["href"], attributes["rel"], attributes["sizes"], false));
    }

    // try to get /favicon.ico
    try {
      var faviconUrl = url.scheme + "://" + url.host + "/favicon.ico";
      await client.headUrl(Uri.parse(faviconUrl));
      favicons.add(Favicon(url: faviconUrl, rel: "shortcut icon"));
    } catch(e) {
      print("/favicon.ico file not found: " + e.toString());
    }

    // try to get the manifest file
    HttpClientRequest manifestRequest;
    HttpClientResponse manifestResponse;
    bool manifestFound = false;
    if (manifestUrl == null) {
      manifestUrl = url.scheme + "://" + url.host + "/manifest.json";
    }
    try {
      manifestRequest = await client.getUrl(Uri.parse(manifestUrl));
      manifestResponse = await manifestRequest.close();
      manifestFound = manifestResponse.statusCode == 200 && manifestResponse.headers.contentType?.mimeType == "application/json";
    } catch(e) {
      print("Manifest file not found: " + e.toString());
    }

    if (manifestFound) {
      Map<String, dynamic> manifest = json.decode(await manifestResponse.transform(Utf8Decoder()).join());
      if (manifest.containsKey("icons")) {
        for(Map<String, dynamic> icon in manifest["icons"]) {
          favicons.addAll(_createFavicons(url, assetPathBase, icon["src"], icon["rel"], icon["sizes"], true));
        }
      }
    }

    return favicons;
  }

  bool _isUrlAbsolute(String url) {
    return url.startsWith("http://") || url.startsWith("https://");
  }

  List<Favicon> _createFavicons(Uri url, String assetPathBase, String urlIcon, String rel, String sizes, bool isManifest) {
    List<Favicon> favicons = [];

    List<String> urlSplitted = urlIcon.split("/");
    if (!_isUrlAbsolute(urlIcon)) {
      if (urlIcon.startsWith("/")) {
        urlIcon = urlIcon.substring(1);
      }
      urlIcon = ((assetPathBase == null) ? url.scheme + "://" + url.host + "/" : assetPathBase) + urlIcon;
    }
    if (isManifest) {
      rel = (sizes != null) ? urlSplitted[urlSplitted.length - 1].replaceFirst("-" + sizes, "").split(" ")[0].split(".")[0] : null;
    }
    if (sizes != null && sizes.isNotEmpty && sizes != "any") {
      List<String> sizesSplitted = sizes.split(" ");
      for (String size in sizesSplitted) {
        int width = int.parse(size.split("x")[0]);
        int height = int.parse(size.split("x")[1]);
        favicons.add(Favicon(url: urlIcon, rel: rel, width: width, height: height));
      }
    } else {
      favicons.add(Favicon(url: urlIcon, rel: rel, width: null, height: null));
    }

    return favicons;
  }

  ///Loads the given [url] with optional [headers] specified as a map from name to value.
  Future<void> loadUrl({@required String url, Map<String, String> headers = const {}}) async {
    assert(url != null && url.isNotEmpty);
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened(message: 'Cannot laod $url!');
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('headers', () => headers);
    await _channel.invokeMethod('loadUrl', args);
  }

  ///Loads the given [url] with [postData] using `POST` method into this WebView.
  Future<void> postUrl({@required String url, @required Uint8List postData}) async {
    assert(url != null && url.isNotEmpty);
    assert(postData != null);
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened(message: 'Cannot laod $url!');
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('postData', () => postData);
    await _channel.invokeMethod('postUrl', args);
  }

  ///Loads the given [data] into this WebView, using [baseUrl] as the base URL for the content.
  ///The [mimeType] parameter specifies the format of the data.
  ///The [encoding] parameter specifies the encoding of the data.
  Future<void> loadData({@required String data, String mimeType = "text/html", String encoding = "utf8", String baseUrl = "about:blank"}) async {
    assert(data != null);
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('data', () => data);
    args.putIfAbsent('mimeType', () => mimeType);
    args.putIfAbsent('encoding', () => encoding);
    args.putIfAbsent('baseUrl', () => baseUrl);
    await _channel.invokeMethod('loadData', args);
  }

  ///Loads the given [assetFilePath] with optional [headers] specified as a map from name to value.
  ///
  ///To be able to load your local files (assets, js, css, etc.), you need to add them in the `assets` section of the `pubspec.yaml` file, otherwise they cannot be found!
  ///
  ///Example of a `pubspec.yaml` file:
  ///```yaml
  ///...
  ///
  ///# The following section is specific to Flutter.
  ///flutter:
  ///
  ///  # The following line ensures that the Material Icons font is
  ///  # included with your application, so that you can use the icons in
  ///  # the material Icons class.
  ///  uses-material-design: true
  ///
  ///  assets:
  ///    - assets/index.html
  ///    - assets/css/
  ///    - assets/images/
  ///
  ///...
  ///```
  ///Example of a `main.dart` file:
  ///```dart
  ///...
  ///inAppBrowser.loadFile("assets/index.html");
  ///...
  ///```
  Future<void> loadFile({@required String assetFilePath, Map<String, String> headers = const {}}) async {
    assert(assetFilePath != null && assetFilePath.isNotEmpty);
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened(message: 'Cannot laod $assetFilePath!');
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('url', () => assetFilePath);
    args.putIfAbsent('headers', () => headers);
    await _channel.invokeMethod('loadFile', args);
  }

  ///Reloads the WebView.
  Future<void> reload() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('reload', args);
  }

  ///Goes back in the history of the WebView.
  Future<void> goBack() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('goBack', args);
  }

  ///Returns a boolean value indicating whether the WebView can move backward.
  Future<bool> canGoBack() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('canGoBack', args);
  }

  ///Goes forward in the history of the WebView.
  Future<void> goForward() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('goForward', args);
  }

  ///Returns a boolean value indicating whether the WebView can move forward.
  Future<bool> canGoForward() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('canGoForward', args);
  }

  ///Goes to the history item that is the number of steps away from the current item. Steps is negative if backward and positive if forward.
  Future<void> goBackOrForward({@required int steps}) async {
    assert(steps != null);

    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('steps', () => steps);
    await _channel.invokeMethod('goBackOrForward', args);
  }

  ///Returns a boolean value indicating whether the WebView can go back or forward the given number of steps. Steps is negative if backward and positive if forward.
  Future<bool> canGoBackOrForward({@required int steps}) async {
    assert(steps != null);

    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('steps', () => steps);
    return await _channel.invokeMethod('canGoBackOrForward', args);
  }

  ///Navigates to a [WebHistoryItem] from the back-forward [WebHistory.list] and sets it as the current item.
  Future<void> goTo({@required WebHistoryItem historyItem}) async {
    await goBackOrForward(steps: historyItem.offset);
  }

  ///Check if the WebView instance is in a loading state.
  Future<bool> isLoading() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('isLoading', args);
  }

  ///Stops the WebView from loading.
  Future<void> stopLoading() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('stopLoading', args);
  }

  ///Evaluates JavaScript code into the WebView and returns the result of the evaluation.
  Future<dynamic> evaluateJavascript({@required String source}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('source', () => source);
    var data = await _channel.invokeMethod('evaluateJavascript', args);
    if (data != null && Platform.isAndroid)
      data = json.decode(data);
    return data;
  }

  ///Injects an external JavaScript file into the WebView from a defined url.
  Future<void> injectJavascriptFileFromUrl({@required String urlFile}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('urlFile', () => urlFile);
    await _channel.invokeMethod('injectJavascriptFileFromUrl', args);
  }
  
  ///Injects a JavaScript file into the WebView from the flutter assets directory.
  Future<void> injectJavascriptFileFromAsset({@required String assetFilePath}) async {
    String source = await rootBundle.loadString(assetFilePath);
    await evaluateJavascript(source: source);
  }

  ///Injects CSS into the WebView.
  Future<void> injectCSSCode({@required String source}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('source', () => source);
    await _channel.invokeMethod('injectCSSCode', args);
  }

  ///Injects an external CSS file into the WebView from a defined url.
  Future<void> injectCSSFileFromUrl({@required String urlFile}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('urlFile', () => urlFile);
    await _channel.invokeMethod('injectStyleFile', args);
  }

  ///Injects a CSS file into the WebView from the flutter assets directory.
  Future<void> injectCSSFileFromAsset({@required String assetFilePath}) async {
    String source = await rootBundle.loadString(assetFilePath);
    await injectCSSCode(source: source);
  }

  ///Adds a JavaScript message handler [callback] ([JavaScriptHandlerCallback]) that listen to post messages sent from JavaScript by the handler with name [handlerName].
  ///
  ///The Android implementation uses [addJavascriptInterface](https://developer.android.com/reference/android/webkit/WebView#addJavascriptInterface(java.lang.Object,%20java.lang.String)).
  ///The iOS implementation uses [addScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537172-addscriptmessagehandler?language=objc)
  ///
  ///The JavaScript function that can be used to call the handler is `window.flutter_inappbrowser.callHandler(handlerName <String>, ...args)`, where `args` are [rest parameters](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters).
  ///The `args` will be stringified automatically using `JSON.stringify(args)` method and then they will be decoded on the Dart side.
  ///
  ///In order to call `window.flutter_inappbrowser.callHandler(handlerName <String>, ...args)` properly, you need to wait and listen the JavaScript event `flutterInAppBrowserPlatformReady`.
  ///This event will be dispatched as soon as the platform (Android or iOS) is ready to handle the `callHandler` method.
  ///```javascript
  ///   window.addEventListener("flutterInAppBrowserPlatformReady", function(event) {
  ///     console.log("ready");
  ///   });
  ///```
  ///
  ///`window.flutter_inappbrowser.callHandler` returns a JavaScript [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)
  ///that can be used to get the json result returned by [JavaScriptHandlerCallback].
  ///In this case, simply return data that you want to send and it will be automatically json encoded using [jsonEncode] from the `dart:convert` library.
  ///
  ///So, on the JavaScript side, to get data coming from the Dart side, you will use:
  ///```html
  ///<script>
  ///   window.addEventListener("flutterInAppBrowserPlatformReady", function(event) {
  ///     window.flutter_inappbrowser.callHandler('handlerFoo').then(function(result) {
  ///       console.log(result);
  ///     });
  ///
  ///     window.flutter_inappbrowser.callHandler('handlerFooWithArgs', 1, true, ['bar', 5], {foo: 'baz'}).then(function(result) {
  ///       console.log(result);
  ///     });
  ///   });
  ///</script>
  ///```
  ///
  ///Instead, on the `onLoadStop` WebView event, you can use `callHandler` directly:
  ///```dart
  ///  // Inject JavaScript that will receive data back from Flutter
  ///  inAppWebViewController.evaluateJavascript(source: """
  ///    window.flutter_inappbrowser.callHandler('test', 'Text from Javascript').then(function(result) {
  ///      console.log(result);
  ///    });
  ///  """);
  ///```
  void addJavaScriptHandler({@required String handlerName, @required JavaScriptHandlerCallback callback}) {
    assert(!javaScriptHandlerForbiddenNames.contains(handlerName));
    this.javaScriptHandlersMap[handlerName] = (callback);
  }

  ///Removes a JavaScript message handler previously added with the [addJavaScriptHandler()] associated to [handlerName] key.
  ///Returns the value associated with [handlerName] before it was removed.
  ///Returns `null` if [handlerName] was not found.
  JavaScriptHandlerCallback removeJavaScriptHandler({@required String handlerName}) {
    return this.javaScriptHandlersMap.remove(handlerName);
  }

  ///Takes a screenshot (in PNG format) of the WebView's visible viewport and returns a `Uint8List`. Returns `null` if it wasn't be able to take it.
  ///
  ///**NOTE for iOS**: available from iOS 11.0+.
  Future<Uint8List> takeScreenshot() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('takeScreenshot', args);
  }

  ///Sets the WebView options with the new [options] and evaluates them.
  Future<void> setOptions({@required InAppWebViewWidgetOptions options}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }

    Map<String, dynamic> optionsMap = {};
    optionsMap.addAll(options.inAppWebViewOptions?.toMap() ?? {});
    if (Platform.isAndroid)
      optionsMap.addAll(options.androidInAppWebViewOptions?.toMap() ?? {});
    else if (Platform.isIOS)
      optionsMap.addAll(options.iosInAppWebViewOptions?.toMap() ?? {});

    args.putIfAbsent('options', () => optionsMap);
    await _channel.invokeMethod('setOptions', args);
  }

  ///Gets the current WebView options. Returns the options with `null` value if they are not set yet.
  Future<InAppWebViewWidgetOptions> getOptions() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }

    InAppWebViewWidgetOptions inAppWebViewWidgetOptions = InAppWebViewWidgetOptions();
    Map<dynamic, dynamic> options = await _channel.invokeMethod('getOptions', args);
    if (options != null) {
      options = options.cast<String, dynamic>();
      inAppWebViewWidgetOptions.inAppWebViewOptions = InAppWebViewOptions.fromMap(options);
      if (Platform.isAndroid)
        inAppWebViewWidgetOptions.androidInAppWebViewOptions = AndroidInAppWebViewOptions.fromMap(options);
      else if (Platform.isIOS)
        inAppWebViewWidgetOptions.iosInAppWebViewOptions = IosInAppWebViewOptions.fromMap(options);
    }

    return inAppWebViewWidgetOptions;
  }

  ///Gets the WebHistory for this WebView. This contains the back/forward list for use in querying each item in the history stack.
  ///This contains only a snapshot of the current state.
  ///Multiple calls to this method may return different objects.
  ///The object returned from this method will not be updated to reflect any new state.
  Future<WebHistory> getCopyBackForwardList() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    Map<dynamic, dynamic> result = await _channel.invokeMethod('getCopyBackForwardList', args);
    result = result.cast<String, dynamic>();

    List<dynamic> historyListMap = result["history"];
    historyListMap = historyListMap.cast<LinkedHashMap<dynamic, dynamic>>();

    int currentIndex = result["currentIndex"];

    List<WebHistoryItem> historyList = List();
    for(var i = 0; i < historyListMap.length; i++) {
      LinkedHashMap<dynamic, dynamic> historyItem = historyListMap[i];
      historyList.add(WebHistoryItem(originalUrl: historyItem["originalUrl"], title: historyItem["title"], url: historyItem["url"], index: i, offset: i - currentIndex));
    }
    return WebHistory(list: historyList, currentIndex: currentIndex);
  }

  ///Starts Safe Browsing initialization.
  ///
  ///URL loads are not guaranteed to be protected by Safe Browsing until after the this method returns true.
  ///Safe Browsing is not fully supported on all devices. For those devices this method will returns false.
  ///
  ///This should not be called if Safe Browsing has been disabled by manifest tag
  ///or [AndroidInAppWebViewOptions.safeBrowsingEnabled]. This prepares resources used for Safe Browsing.
  ///
  ///**NOTE**: available only on Android 27+.
  Future<bool> startSafeBrowsing() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('startSafeBrowsing', args);
  }

  ///Sets the list of hosts (domain names/IP addresses) that are exempt from SafeBrowsing checks. The list is global for all the WebViews.
  ///
  /// Each rule should take one of these:
  ///| Rule | Example | Matches Subdomain |
  ///| -- | -- | -- |
  ///| HOSTNAME | example.com | Yes |
  ///| .HOSTNAME | .example.com | No |
  ///| IPV4_LITERAL | 192.168.1.1 | No |
  ///| IPV6_LITERAL_WITH_BRACKETS | [10:20:30:40:50:60:70:80] | No |
  ///
  ///All other rules, including wildcards, are invalid. The correct syntax for hosts is defined by [RFC 3986](https://tools.ietf.org/html/rfc3986#section-3.2.2).
  ///
  ///[hosts] represents the list of hosts. This value must never be null.
  ///
  ///**NOTE**: available only on Android 27+.
  Future<bool> setSafeBrowsingWhitelist({@required List<String> hosts}) async {
    assert(hosts != null);
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('hosts', () => hosts);
    return await _channel.invokeMethod('setSafeBrowsingWhitelist', args);
  }

  ///Returns a URL pointing to the privacy policy for Safe Browsing reporting. This value will never be `null`.
  ///
  ///**NOTE**: available only on Android 27+.
  Future<String> getSafeBrowsingPrivacyPolicyUrl() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('getSafeBrowsingPrivacyPolicyUrl', args);
  }

  ///Clears all the webview's cache.
  Future<void> clearCache() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('clearCache', args);
  }

  ///Clears the SSL preferences table stored in response to proceeding with SSL certificate errors.
  ///
  ///**NOTE**: available only on Android.
  Future<void> clearSslPreferences() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('clearSslPreferences', args);
  }

  ///Clears the client certificate preferences stored in response to proceeding/cancelling client cert requests.
  ///Note that WebView automatically clears these preferences when the system keychain is updated.
  ///The preferences are shared by all the WebViews that are created by the embedder application.
  ///
  ///**NOTE**: On iOS certificate-based credentials are never stored permanently.
  ///
  ///**NOTE**: available on Android 21+.
  Future<void> clearClientCertPreferences() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('clearClientCertPreferences', args);
  }

  ///Finds all instances of find on the page and highlights them. Notifies [onFindResultReceived] listener.
  ///
  ///[find] represents the string to find.
  ///
  ///**NOTE**: on Android, it finds all instances asynchronously. Successive calls to this will cancel any pending searches.
  ///
  ///**NOTE**: on iOS, this is implemented using CSS and Javascript.
  Future<void> findAllAsync({@required String find}) async {
    assert(find != null);
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('find', () => find);
    await _channel.invokeMethod('findAllAsync', args);
  }

  ///Highlights and scrolls to the next match found by [findAllAsync()]. Notifies [onFindResultReceived] listener.
  ///
  ///[forward] represents the direction to search.
  ///
  ///**NOTE**: on iOS, this is implemented using CSS and Javascript.
  Future<void> findNext({@required bool forward}) async {
    assert(forward != null);
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('forward', () => forward);
    await _channel.invokeMethod('findNext', args);
  }

  ///Clears the highlighting surrounding text matches created by [findAllAsync()].
  ///
  ///**NOTE**: on iOS, this is implemented using CSS and Javascript.
  Future<void> clearMatches() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('clearMatches', args);
  }

  ///Gets the html (with javascript) of the Chromium's t-rex runner game. Used in combination with [getTRexRunnerCss()].
  Future<String> getTRexRunnerHtml() async {
    return await rootBundle.loadString("packages/flutter_inappbrowser/t_rex_runner/t-rex.html");
  }

  ///Gets the css of the Chromium's t-rex runner game. Used in combination with [getTRexRunnerHtml()].
  Future<String> getTRexRunnerCss() async {
    return await rootBundle.loadString("packages/flutter_inappbrowser/t_rex_runner/t-rex.css");
  }

  ///Scrolls the WebView to the position.
  ///
  ///[x] represents the x position to scroll to.
  ///
  ///[y] represents the y position to scroll to.
  Future<void> scrollTo({@required int x, @required int y}) async {
    assert(x != null && y != null);
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('x', () => x);
    args.putIfAbsent('y', () => y);
    await _channel.invokeMethod('scrollTo', args);
  }

  ///Moves the scrolled position of the WebView.
  ///
  ///[x] represents the amount of pixels to scroll by horizontally.
  ///
  ///[y] represents the amount of pixels to scroll by vertically.
  Future<void> scrollBy({@required int x, @required int y}) async {
    assert(x != null && y != null);
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('x', () => x);
    args.putIfAbsent('y', () => y);
    await _channel.invokeMethod('scrollBy', args);
  }

  /*Future<void> dispose() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (Platform.isIOS)
      await _channel.invokeMethod('removeFromSuperview', args);
  }*/
}
