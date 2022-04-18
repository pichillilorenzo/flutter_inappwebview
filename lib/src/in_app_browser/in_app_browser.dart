import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview/src/util.dart';

import '../context_menu.dart';
import '../types.dart';

import '../in_app_webview/in_app_webview_controller.dart';
import '../in_app_webview/in_app_webview_options.dart';

import 'in_app_browser_options.dart';

class InAppBrowserAlreadyOpenedException implements Exception {
  final dynamic message;

  InAppBrowserAlreadyOpenedException([this.message]);

  String toString() {
    Object? message = this.message;
    if (message == null) return "InAppBrowserAlreadyOpenedException";
    return "InAppBrowserAlreadyOpenedException: $message";
  }
}

class InAppBrowserNotOpenedException implements Exception {
  final dynamic message;

  InAppBrowserNotOpenedException([this.message]);

  String toString() {
    Object? message = this.message;
    if (message == null) return "InAppBrowserNotOpenedException";
    return "InAppBrowserNotOpenedException: $message";
  }
}

///This class uses the native WebView of the platform.
///The [webViewController] field can be used to access the [InAppWebViewController] API.
class InAppBrowser {
  ///View ID used internally.
  late final String id;

  ///Context menu used by the browser. It should be set before opening the browser.
  ContextMenu? contextMenu;

  ///Represents the pull-to-refresh feature controller.
  PullToRefreshController? pullToRefreshController;

  ///Initial list of user scripts to be loaded at start or end of a page loading.
  final UnmodifiableListView<UserScript>? initialUserScripts;

  bool _isOpened = false;
  late MethodChannel _channel;
  static const MethodChannel _sharedChannel =
      const MethodChannel('com.pichillilorenzo/flutter_inappbrowser');

  /// WebView Controller that can be used to access the [InAppWebViewController] API.
  late final InAppWebViewController webViewController;

  ///The window id of a [CreateWindowAction.windowId].
  final int? windowId;

  ///Represents the WebView native implementation to be used.
  ///The default value is [WebViewImplementation.NATIVE].
  final WebViewImplementation implementation;

  ///
  InAppBrowser(
      {this.windowId,
      this.initialUserScripts,
      this.implementation = WebViewImplementation.NATIVE}) {
    id = IdGenerator.generate();
    this._channel =
        MethodChannel('com.pichillilorenzo/flutter_inappbrowser_$id');
    this._channel.setMethodCallHandler(handleMethod);
    _isOpened = false;
    webViewController = new InAppWebViewController.fromInAppBrowser(
        this._channel, this, this.initialUserScripts);
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onBrowserCreated":
        this._isOpened = true;
        this.pullToRefreshController?.initMethodChannel(id);
        onBrowserCreated();
        break;
      case "onExit":
        this._isOpened = false;
        onExit();
        break;
      default:
        return webViewController.handleMethod(call);
    }
  }

  ///Opens the [InAppBrowser] instance with an [urlRequest].
  ///
  ///[urlRequest]: The [urlRequest] to load.
  ///
  ///[options]: Options for the [InAppBrowser].
  Future<void> openUrlRequest(
      {required URLRequest urlRequest,
      InAppBrowserClassOptions? options}) async {
    this.throwIfAlreadyOpened(message: 'Cannot open $urlRequest!');
    assert(urlRequest.url != null && urlRequest.url.toString().isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('id', () => id);
    args.putIfAbsent('urlRequest', () => urlRequest.toMap());
    args.putIfAbsent('options',
        () => options?.toMap() ?? InAppBrowserClassOptions().toMap());
    args.putIfAbsent('contextMenu', () => contextMenu?.toMap() ?? {});
    args.putIfAbsent('windowId', () => windowId);
    args.putIfAbsent('implementation', () => implementation.toValue());
    args.putIfAbsent('initialUserScripts',
        () => initialUserScripts?.map((e) => e.toMap()).toList() ?? []);
    args.putIfAbsent(
        'pullToRefreshOptions',
        () =>
            pullToRefreshController?.options.toMap() ??
            PullToRefreshOptions(enabled: false).toMap());
    await _sharedChannel.invokeMethod('open', args);
  }

  ///Opens the [InAppBrowser] instance with the given [assetFilePath] file.
  ///
  ///[options]: Options for the [InAppBrowser].
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
  ///inAppBrowser.openFile(assetFilePath: "assets/index.html");
  ///...
  ///```
  ///
  ///[headers]: The additional headers to be used in the HTTP request for this URL, specified as a map from name to value.
  ///
  ///[options]: Options for the [InAppBrowser].
  Future<void> openFile(
      {required String assetFilePath,
      InAppBrowserClassOptions? options}) async {
    this.throwIfAlreadyOpened(message: 'Cannot open $assetFilePath!');
    assert(assetFilePath.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('id', () => id);
    args.putIfAbsent('assetFilePath', () => assetFilePath);
    args.putIfAbsent('options',
        () => options?.toMap() ?? InAppBrowserClassOptions().toMap());
    args.putIfAbsent('contextMenu', () => contextMenu?.toMap() ?? {});
    args.putIfAbsent('windowId', () => windowId);
    args.putIfAbsent('implementation', () => implementation.toValue());
    args.putIfAbsent('initialUserScripts',
        () => initialUserScripts?.map((e) => e.toMap()).toList() ?? []);
    args.putIfAbsent(
        'pullToRefreshOptions',
        () =>
            pullToRefreshController?.options.toMap() ??
            PullToRefreshOptions(enabled: false).toMap());
    await _sharedChannel.invokeMethod('open', args);
  }

  ///Opens the [InAppBrowser] instance with [data] as a content, using [baseUrl] as the base URL for it.
  ///
  ///The [mimeType] parameter specifies the format of the data. The default value is `"text/html"`.
  ///
  ///The [encoding] parameter specifies the encoding of the data. The default value is `"utf8"`.
  ///
  ///The [androidHistoryUrl] parameter is the URL to use as the history entry. The default value is `about:blank`. If non-null, this must be a valid URL. This parameter is used only on Android.
  ///
  ///The [options] parameter specifies the options for the [InAppBrowser].
  Future<void> openData(
      {required String data,
      String mimeType = "text/html",
      String encoding = "utf8",
      Uri? baseUrl,
      Uri? androidHistoryUrl,
      InAppBrowserClassOptions? options}) async {
    this.throwIfAlreadyOpened(message: 'Cannot open data!');

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('id', () => id);
    args.putIfAbsent('options',
        () => options?.toMap() ?? InAppBrowserClassOptions().toMap());
    args.putIfAbsent('data', () => data);
    args.putIfAbsent('mimeType', () => mimeType);
    args.putIfAbsent('encoding', () => encoding);
    args.putIfAbsent('baseUrl', () => baseUrl?.toString() ?? "about:blank");
    args.putIfAbsent(
        'historyUrl', () => androidHistoryUrl?.toString() ?? "about:blank");
    args.putIfAbsent('contextMenu', () => contextMenu?.toMap() ?? {});
    args.putIfAbsent('windowId', () => windowId);
    args.putIfAbsent('implementation', () => implementation.toValue());
    args.putIfAbsent('initialUserScripts',
        () => initialUserScripts?.map((e) => e.toMap()).toList() ?? []);
    args.putIfAbsent(
        'pullToRefreshOptions',
        () =>
            pullToRefreshController?.options.toMap() ??
            PullToRefreshOptions(enabled: false).toMap());
    await _sharedChannel.invokeMethod('open', args);
  }

  ///This is a static method that opens an [url] in the system browser. You wont be able to use the [InAppBrowser] methods here!
  static Future<void> openWithSystemBrowser({required Uri url}) async {
    assert(url.toString().isNotEmpty);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    return await _sharedChannel.invokeMethod('openWithSystemBrowser', args);
  }

  ///Displays an [InAppBrowser] window that was opened hidden. Calling this has no effect if the [InAppBrowser] was already visible.
  Future<void> show() async {
    this.throwIfNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('show', args);
  }

  ///Hides the [InAppBrowser] window. Calling this has no effect if the [InAppBrowser] was already hidden.
  Future<void> hide() async {
    this.throwIfNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('hide', args);
  }

  ///Closes the [InAppBrowser] window.
  Future<void> close() async {
    this.throwIfNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('close', args);
  }

  ///Check if the Web View of the [InAppBrowser] instance is hidden.
  Future<bool> isHidden() async {
    this.throwIfNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('isHidden', args);
  }

  ///Sets the [InAppBrowser] options with the new [options] and evaluates them.
  Future<void> setOptions({required InAppBrowserClassOptions options}) async {
    this.throwIfNotOpened();

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('options', () => options.toMap());
    await _channel.invokeMethod('setOptions', args);
  }

  ///Gets the current [InAppBrowser] options. Returns `null` if it wasn't able to get them.
  Future<InAppBrowserClassOptions?> getOptions() async {
    this.throwIfNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};

    Map<dynamic, dynamic>? options =
        await _channel.invokeMethod('getOptions', args);
    if (options != null) {
      options = options.cast<String, dynamic>();
      return InAppBrowserClassOptions.fromMap(options as Map<String, dynamic>);
    }

    return null;
  }

  ///Returns `true` if the [InAppBrowser] instance is opened, otherwise `false`.
  bool isOpened() {
    return this._isOpened;
  }

  ///Event fired when the [InAppBrowser] is created.
  void onBrowserCreated() {}

  ///Event fired when the [InAppBrowser] window is closed.
  void onExit() {}

  ///Event fired when the [InAppBrowser] starts to load an [url].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onPageStarted](https://developer.android.com/reference/android/webkit/WebViewClient#onPageStarted(android.webkit.WebView,%20java.lang.String,%20android.graphics.Bitmap)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455621-webview))
  void onLoadStart(Uri? url) {}

  ///Event fired when the [InAppBrowser] finishes loading an [url].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onPageFinished](https://developer.android.com/reference/android/webkit/WebViewClient#onPageFinished(android.webkit.WebView,%20java.lang.String)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455629-webview))
  void onLoadStop(Uri? url) {}

  ///Event fired when the [InAppBrowser] encounters an error loading an [url].
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedError(android.webkit.WebView,%20int,%20java.lang.String,%20java.lang.String)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455623-webview
  void onLoadError(Uri? url, int code, String message) {}

  ///Event fired when the [InAppBrowser] main page receives an HTTP error.
  ///
  ///[url] represents the url of the main page that received the HTTP error.
  ///
  ///[statusCode] represents the status code of the response. HTTP errors have status codes >= 400.
  ///
  ///[description] represents the description of the HTTP error. On iOS, it is always an empty string.
  ///
  ///**NOTE**: available on Android 23+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpError(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20android.webkit.WebResourceResponse)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview
  void onLoadHttpError(Uri? url, int statusCode, String description) {}

  ///Event fired when the current [progress] (range 0-100) of loading a page is changed.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onProgressChanged](https://developer.android.com/reference/android/webkit/WebChromeClient#onProgressChanged(android.webkit.WebView,%20int)))
  ///- iOS
  void onProgressChanged(int progress) {}

  ///Event fired when the [InAppBrowser] webview receives a [ConsoleMessage].
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onConsoleMessage(android.webkit.ConsoleMessage)
  void onConsoleMessage(ConsoleMessage consoleMessage) {}

  ///Give the host application a chance to take control when a URL is about to be loaded in the current WebView. This event is not called on the initial load of the WebView.
  ///
  ///Note that on Android there isn't any way to load an URL for a frame that is not the main frame, so if the request is not for the main frame, the navigation is allowed by default.
  ///However, if you want to cancel requests for subframes, you can use the [AndroidInAppWebViewOptions.regexToCancelSubFramesLoading] option
  ///to write a Regular Expression that, if the url request of a subframe matches, then the request of that subframe is canceled.
  ///
  ///Also, on Android, this method is not called for POST requests.
  ///
  ///[navigationAction] represents an object that contains information about an action that causes navigation to occur.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldOverrideUrlLoading] option to `true`.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#shouldOverrideUrlLoading(android.webkit.WebView,%20java.lang.String)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455641-webview
  Future<NavigationActionPolicy?>? shouldOverrideUrlLoading(
      NavigationAction navigationAction) {}

  ///Event fired when the [InAppBrowser] webview loads a resource.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useOnLoadResource] and [InAppWebViewOptions.javaScriptEnabled] options to `true`.
  void onLoadResource(LoadedResource resource) {}

  ///Event fired when the [InAppBrowser] webview scrolls.
  ///
  ///[x] represents the current horizontal scroll origin in pixels.
  ///
  ///[y] represents the current vertical scroll origin in pixels.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#onScrollChanged(int,%20int,%20int,%20int)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619392-scrollviewdidscroll
  void onScrollChanged(int x, int y) {}

  ///Use [onDownloadStartRequest] instead
  @Deprecated('Use `onDownloadStartRequest` instead')
  void onDownloadStart(Uri url) {}

  ///Event fired when [WebView] recognizes a downloadable file.
  ///To download the file, you can use the [flutter_downloader](https://pub.dev/packages/flutter_downloader) plugin.
  ///
  ///[downloadStartRequest] represents the request of the file to download.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useOnDownloadStart] option to `true`.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#setDownloadListener(android.webkit.DownloadListener)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview
  void onDownloadStartRequest(DownloadStartRequest downloadStartRequest) {}

  ///Event fired when the [InAppBrowser] webview finds the `custom-scheme` while loading a resource. Here you can handle the url request and return a [CustomSchemeResponse] to load a specific resource encoded to `base64`.
  ///
  ///[scheme] represents the scheme of the url.
  ///
  ///[url] represents the url of the request.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkurlschemehandler
  Future<CustomSchemeResponse?>? onLoadResourceCustomScheme(Uri url) {}

  ///Event fired when the [InAppBrowser] webview requests the host application to create a new window,
  ///for example when trying to open a link with `target="_blank"` or when `window.open()` is called by JavaScript side.
  ///If the host application chooses to honor this request, it should return `true` from this method, create a new WebView to host the window.
  ///If the host application chooses not to honor the request, it should return `false` from this method.
  ///The default implementation of this method does nothing and hence returns `false`.
  ///
  ///[createWindowAction] represents the request.
  ///
  ///**NOTE**: to allow JavaScript to open windows, you need to set [InAppWebViewOptions.javaScriptCanOpenWindowsAutomatically] option to `true`.
  ///
  ///**NOTE**: on Android you need to set [AndroidInAppWebViewOptions.supportMultipleWindows] option to `true`.
  ///
  ///**NOTE**: on iOS, setting these initial options: [InAppWebViewOptions.supportZoom], [InAppWebViewOptions.useOnLoadResource], [InAppWebViewOptions.useShouldInterceptAjaxRequest],
  ///[InAppWebViewOptions.useShouldInterceptFetchRequest], [InAppWebViewOptions.applicationNameForUserAgent], [InAppWebViewOptions.javaScriptCanOpenWindowsAutomatically],
  ///[InAppWebViewOptions.javaScriptEnabled], [InAppWebViewOptions.minimumFontSize], [InAppWebViewOptions.preferredContentMode], [InAppWebViewOptions.incognito],
  ///[InAppWebViewOptions.cacheEnabled], [InAppWebViewOptions.mediaPlaybackRequiresUserGesture],
  ///[InAppWebViewOptions.resourceCustomSchemes], [IOSInAppWebViewOptions.sharedCookiesEnabled],
  ///[IOSInAppWebViewOptions.enableViewportScale], [IOSInAppWebViewOptions.allowsAirPlayForMediaPlayback],
  ///[IOSInAppWebViewOptions.allowsPictureInPictureMediaPlayback], [IOSInAppWebViewOptions.isFraudulentWebsiteWarningEnabled],
  ///[IOSInAppWebViewOptions.allowsInlineMediaPlayback], [IOSInAppWebViewOptions.suppressesIncrementalRendering], [IOSInAppWebViewOptions.selectionGranularity],
  ///[IOSInAppWebViewOptions.ignoresViewportScaleLimits],
  ///will have no effect due to a `WKWebView` limitation when creating a new window WebView: it's impossible to return a new `WKWebView`
  ///with a different `WKWebViewConfiguration` instance (see https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview).
  ///So, these options will be inherited from the caller WebView.
  ///Also, note that calling [InAppWebViewController.setOptions] method using the controller of the new created WebView,
  ///it will update also the WebView options of the caller WebView.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onCreateWindow(android.webkit.WebView,%20boolean,%20boolean,%20android.os.Message)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview
  Future<bool?>? onCreateWindow(CreateWindowAction createWindowAction) {}

  ///Event fired when the host application should close the given WebView and remove it from the view system if necessary.
  ///At this point, WebCore has stopped any loading in this window and has removed any cross-scripting ability in javascript.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onCloseWindow(android.webkit.WebView)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkuidelegate/1537390-webviewdidclose
  void onCloseWindow() {}

  ///Event fired when the JavaScript `window` object of the WebView has received focus.
  ///This is the result of the `focus` javascript event applied to the `window` object.
  void onWindowFocus() {}

  ///Event fired when the JavaScript `window` object of the WebView has lost focus.
  ///This is the result of the `blur` javascript event applied to the `window` object.
  void onWindowBlur() {}

  ///Event fired when javascript calls the `alert()` method to display an alert dialog.
  ///If [JsAlertResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsAlertRequest] contains the message to be displayed in the alert dialog and the of the page requesting the dialog.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onJsAlert(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkuidelegate/1537406-webview
  Future<JsAlertResponse?>? onJsAlert(JsAlertRequest jsAlertRequest) {}

  ///Event fired when javascript calls the `confirm()` method to display a confirm dialog.
  ///If [JsConfirmResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsConfirmRequest] contains the message to be displayed in the confirm dialog and the of the page requesting the dialog.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onJsConfirm(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkuidelegate/1536489-webview
  Future<JsConfirmResponse?>? onJsConfirm(JsConfirmRequest jsConfirmRequest) {}

  ///Event fired when javascript calls the `prompt()` method to display a prompt dialog.
  ///If [JsPromptResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsPromptRequest] contains the message to be displayed in the prompt dialog, the default value displayed in the prompt dialog, and the of the page requesting the dialog.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onJsPrompt(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String,%20android.webkit.JsPromptResult)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkuidelegate/1538086-webview
  Future<JsPromptResponse?>? onJsPrompt(JsPromptRequest jsPromptRequest) {}

  ///Event fired when the WebView received an HTTP authentication request. The default behavior is to cancel the request.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [URLAuthenticationChallenge].
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpAuthRequest(android.webkit.WebView,%20android.webkit.HttpAuthHandler,%20java.lang.String,%20java.lang.String)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview
  Future<HttpAuthResponse?>? onReceivedHttpAuthRequest(
      URLAuthenticationChallenge challenge) {}

  ///Event fired when the WebView need to perform server trust authentication (certificate validation).
  ///The host application must return either [ServerTrustAuthResponse] instance with [ServerTrustAuthResponseAction.CANCEL] or [ServerTrustAuthResponseAction.PROCEED].
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ServerTrustChallenge].
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedSslError(android.webkit.WebView,%20android.webkit.SslErrorHandler,%20android.net.http.SslError)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview
  Future<ServerTrustAuthResponse?>? onReceivedServerTrustAuthRequest(
      URLAuthenticationChallenge challenge) {}

  ///Notify the host application to handle an SSL client certificate request.
  ///Webview stores the response in memory (for the life of the application) if [ClientCertResponseAction.PROCEED] or [ClientCertResponseAction.CANCEL]
  ///is called and does not call [onReceivedClientCertRequest] again for the same host and port pair.
  ///Note that, multiple layers in chromium network stack might be caching the responses.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ClientCertChallenge].
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedClientCertRequest(android.webkit.WebView,%20android.webkit.ClientCertRequest)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview
  Future<ClientCertResponse?>? onReceivedClientCertRequest(
      URLAuthenticationChallenge challenge) {}

  ///Event fired as find-on-page operations progress.
  ///The listener may be notified multiple times while the operation is underway, and the [numberOfMatches] value should not be considered final unless [isDoneCounting] is true.
  ///
  ///[activeMatchOrdinal] represents the zero-based ordinal of the currently selected match.
  ///
  ///[numberOfMatches] represents how many matches have been found.
  ///
  ///[isDoneCounting] whether the find operation has actually completed.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.FindListener.onFindResultReceived](https://developer.android.com/reference/android/webkit/WebView.FindListener#onFindResultReceived(int,%20int,%20boolean)))
  ///- iOS
  void onFindResultReceived(
      int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting) {}

  ///Event fired when an `XMLHttpRequest` is sent to a server.
  ///It gives the host application a chance to take control over the request before sending it.
  ///
  ///[ajaxRequest] represents the `XMLHttpRequest`.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptAjaxRequest] option to `true`.
  Future<AjaxRequest?>? shouldInterceptAjaxRequest(AjaxRequest ajaxRequest) {}

  ///Event fired whenever the `readyState` attribute of an `XMLHttpRequest` changes.
  ///It gives the host application a chance to abort the request.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptAjaxRequest] option to `true`.
  Future<AjaxRequestAction?>? onAjaxReadyStateChange(AjaxRequest ajaxRequest) {}

  ///Event fired as an `XMLHttpRequest` progress.
  ///It gives the host application a chance to abort the request.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptAjaxRequest] option to `true`.
  Future<AjaxRequestAction?>? onAjaxProgress(AjaxRequest ajaxRequest) {}

  ///Event fired when a request is sent to a server through [Fetch API](https://developer.mozilla.org/it/docs/Web/API/Fetch_API).
  ///It gives the host application a chance to take control over the request before sending it.
  ///
  ///[fetchRequest] represents a resource request.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptFetchRequest] option to `true`.
  Future<FetchRequest?>? shouldInterceptFetchRequest(
      FetchRequest fetchRequest) {}

  ///Event fired when the host application updates its visited links database.
  ///This event is also fired when the navigation state of the [InAppWebView] changes through the usage of
  ///javascript **[History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API)** functions (`pushState()`, `replaceState()`) and `onpopstate` event
  ///or, also, when the javascript `window.location` changes without reloading the webview (for example appending or modifying an hash to the url).
  ///
  ///[url] represents the url being visited.
  ///
  ///[androidIsReload] indicates if this url is being reloaded. Available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#doUpdateVisitedHistory(android.webkit.WebView,%20java.lang.String,%20boolean)
  void onUpdateVisitedHistory(Uri? url, bool? androidIsReload) {}

  ///Event fired when `window.print()` is called from JavaScript side.
  ///
  ///[url] represents the url on which is called.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  void onPrint(Uri? url) {}

  ///Event fired when an HTML element of the webview has been clicked and held.
  ///
  ///[hitTestResult] represents the hit result for hitting an HTML elements.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/view/View#setOnLongClickListener(android.view.View.OnLongClickListener)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/uikit/uilongpressgesturerecognizer
  void onLongPressHitTestResult(InAppWebViewHitTestResult hitTestResult) {}

  ///Event fired when the current page has entered full screen mode.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onShowCustomView(android.view.View,%20android.webkit.WebChromeClient.CustomViewCallback)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/uikit/uiwindow/1621621-didbecomevisiblenotification
  void onEnterFullscreen() {}

  ///Event fired when the current page has exited full screen mode.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onHideCustomView()
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/uikit/uiwindow/1621617-didbecomehiddennotification
  void onExitFullscreen() {}

  ///Called when the web view begins to receive web content.
  ///
  ///This event occurs early in the document loading process, and as such
  ///you should expect that linked resources (for example, CSS and images) may not be available.
  ///
  ///[url] represents the URL corresponding to the page navigation that triggered this callback.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onPageCommitVisible(android.webkit.WebView,%20java.lang.String)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455635-webview
  void onPageCommitVisible(Uri? url) {}

  ///Event fired when a change in the document title occurred.
  ///
  ///[title] represents the string containing the new title of the document.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTitle(android.webkit.WebView,%20java.lang.String)
  void onTitleChanged(String? title) {}

  ///Event fired to respond to the results of an over-scroll operation.
  ///
  ///[x] represents the new X scroll value in pixels.
  ///
  ///[y] represents the new Y scroll value in pixels.
  ///
  ///[clampedX] is `true` if [x] was clamped to an over-scroll boundary.
  ///
  ///[clampedY] is `true` if [y] was clamped to an over-scroll boundary.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#onOverScrolled(int,%20int,%20boolean,%20boolean)
  void onOverScrolled(int x, int y, bool clampedX, bool clampedY) {}

  ///Event fired when the zoom scale of the WebView has changed.
  ///
  ///[oldScale] The old zoom scale factor.
  ///
  ///[newScale] The new zoom scale factor.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onScaleChanged(android.webkit.WebView,%20float,%20float)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619409-scrollviewdidzoom
  void onZoomScaleChanged(double oldScale, double newScale) {}

  ///Event fired when the WebView notifies that a loading URL has been flagged by Safe Browsing.
  ///The default behavior is to show an interstitial to the user, with the reporting checkbox visible.
  ///
  ///[url] represents the url of the request.
  ///
  ///[threatType] represents the reason the resource was caught by Safe Browsing, corresponding to a [SafeBrowsingThreat].
  ///
  ///**NOTE**: available only on Android 27+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onSafeBrowsingHit(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20int,%20android.webkit.SafeBrowsingResponse)
  Future<SafeBrowsingResponse?>? androidOnSafeBrowsingHit(
      Uri url, SafeBrowsingThreat? threatType) {}

  ///Event fired when the WebView is requesting permission to access the specified resources and the permission currently isn't granted or denied.
  ///
  ///[origin] represents the origin of the web page which is trying to access the restricted resources.
  ///
  ///[resources] represents the array of resources the web content wants to access.
  ///
  ///**NOTE**: available only on Android 23+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequest(android.webkit.PermissionRequest)
  Future<PermissionRequestResponse?>? androidOnPermissionRequest(
      String origin, List<String> resources) {}

  ///Event that notifies the host application that web content from the specified origin is attempting to use the Geolocation API, but no permission state is currently set for that origin.
  ///Note that for applications targeting Android N and later SDKs (API level > `Build.VERSION_CODES.M`) this method is only called for requests originating from secure origins such as https.
  ///On non-secure origins geolocation requests are automatically denied.
  ///
  ///[origin] represents the origin of the web content attempting to use the Geolocation API.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsShowPrompt(java.lang.String,%20android.webkit.GeolocationPermissions.Callback)
  Future<GeolocationPermissionShowPromptResponse?>?
      androidOnGeolocationPermissionsShowPrompt(String origin) {}

  ///Notify the host application that a request for Geolocation permissions, made with a previous call to [androidOnGeolocationPermissionsShowPrompt] has been canceled.
  ///Any related UI should therefore be hidden.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsHidePrompt()
  void androidOnGeolocationPermissionsHidePrompt() {}

  ///Notify the host application of a resource request and allow the application to return the data.
  ///If the return value is `null`, the WebView will continue to load the resource as usual.
  ///Otherwise, the return response and data will be used.
  ///
  ///This callback is invoked for a variety of URL schemes (e.g., `http(s):`, `data:`, `file:`, etc.),
  ///not only those schemes which send requests over the network.
  ///This is not called for `javascript:` URLs, `blob:` URLs, or for assets accessed via `file:///android_asset/` or `file:///android_res/` URLs.
  ///
  ///In the case of redirects, this is only called for the initial resource URL, not any subsequent redirect URLs.
  ///
  ///[request] Object containing the details of the request.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**:
  ///- https://developer.android.com/reference/android/webkit/WebViewClient#shouldInterceptRequest(android.webkit.WebView,%20android.webkit.WebResourceRequest)
  ///- https://developer.android.com/reference/android/webkit/WebViewClient#shouldInterceptRequest(android.webkit.WebView,%20java.lang.String)
  Future<WebResourceResponse?>? androidShouldInterceptRequest(
      WebResourceRequest request) {}

  ///Event called when the renderer currently associated with the WebView becomes unresponsive as a result of a long running blocking task such as the execution of JavaScript.
  ///
  ///If a WebView fails to process an input event, or successfully navigate to a new URL within a reasonable time frame, the renderer is considered to be unresponsive, and this callback will be called.
  ///
  ///This callback will continue to be called at regular intervals as long as the renderer remains unresponsive.
  ///If the renderer becomes responsive again, [androidOnRenderProcessResponsive] will be called once,
  ///and this method will not subsequently be called unless another period of unresponsiveness is detected.
  ///
  ///The minimum interval between successive calls to `androidOnRenderProcessUnresponsive` is 5 seconds.
  ///
  ///No action is taken by WebView as a result of this method call.
  ///Applications may choose to terminate the associated renderer via the object that is passed to this callback,
  ///if in multiprocess mode, however this must be accompanied by correctly handling [androidOnRenderProcessGone] for this WebView,
  ///and all other WebViews associated with the same renderer. Failure to do so will result in application termination.
  ///
  ///**NOTE**: available only on Android 29+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessUnresponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)
  Future<WebViewRenderProcessAction?>? androidOnRenderProcessUnresponsive(
      Uri? url) {}

  ///Event called once when an unresponsive renderer currently associated with the WebView becomes responsive.
  ///
  ///After a WebView renderer becomes unresponsive, which is notified to the application by [androidOnRenderProcessUnresponsive],
  ///it is possible for the blocking renderer task to complete, returning the renderer to a responsive state.
  ///In that case, this method is called once to indicate responsiveness.
  ///
  ///No action is taken by WebView as a result of this method call.
  ///
  ///**NOTE**: available only on Android 29+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessResponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)
  Future<WebViewRenderProcessAction?>? androidOnRenderProcessResponsive(
      Uri? url) {}

  ///Event fired when the given WebView's render process has exited.
  ///The application's implementation of this callback should only attempt to clean up the WebView.
  ///The WebView should be removed from the view hierarchy, all references to it should be cleaned up.
  ///
  ///[detail] the reason why it exited.
  ///
  ///**NOTE**: available only on Android 26+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onRenderProcessGone(android.webkit.WebView,%20android.webkit.RenderProcessGoneDetail)
  void androidOnRenderProcessGone(RenderProcessGoneDetail detail) {}

  ///As the host application if the browser should resend data as the requested page was a result of a POST. The default is to not resend the data.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onFormResubmission(android.webkit.WebView,%20android.os.Message,%20android.os.Message)
  Future<FormResubmissionAction?>? androidOnFormResubmission(Uri? url) {}

  ///Use [onZoomScaleChanged] instead.
  @Deprecated('Use `onZoomScaleChanged` instead')
  void androidOnScaleChanged(double oldScale, double newScale) {}

  ///Event fired when there is new favicon for the current page.
  ///
  ///[icon] represents the favicon for the current page.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedIcon(android.webkit.WebView,%20android.graphics.Bitmap)
  void androidOnReceivedIcon(Uint8List icon) {}

  ///Event fired when there is an url for an apple-touch-icon.
  ///
  ///[url] represents the icon url.
  ///
  ///[precomposed] is `true` if the url is for a precomposed touch icon.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTouchIconUrl(android.webkit.WebView,%20java.lang.String,%20boolean)
  void androidOnReceivedTouchIconUrl(Uri url, bool precomposed) {}

  ///Event fired when the client should display a dialog to confirm navigation away from the current page.
  ///This is the result of the `onbeforeunload` javascript event.
  ///If [JsBeforeUnloadResponse.handledByClient] is `true`, WebView will assume that the client will handle the confirm dialog.
  ///If [JsBeforeUnloadResponse.handledByClient] is `false`, a default value of `true` will be returned to javascript to accept navigation away from the current page.
  ///The default behavior is to return `false`.
  ///Setting the [JsBeforeUnloadResponse.action] to [JsBeforeUnloadResponseAction.CONFIRM] will navigate away from the current page,
  ///[JsBeforeUnloadResponseAction.CANCEL] will cancel the navigation.
  ///
  ///[jsBeforeUnloadRequest] contains the message to be displayed in the alert dialog and the of the page requesting the dialog.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onJsBeforeUnload(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)
  Future<JsBeforeUnloadResponse?>? androidOnJsBeforeUnload(
      JsBeforeUnloadRequest jsBeforeUnloadRequest) {}

  ///Event fired when a request to automatically log in the user has been processed.
  ///
  ///[loginRequest] contains the realm, account and args of the login request.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedLoginRequest(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String)
  void androidOnReceivedLoginRequest(LoginRequest loginRequest) {}

  ///Invoked when the web view's web content process is terminated.
  ///
  ///**NOTE**: available only on iOS.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455639-webviewwebcontentprocessdidtermi
  void iosOnWebContentProcessDidTerminate() {}

  ///Called when a web view receives a server redirect.
  ///
  ///**NOTE**: available only on iOS.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455627-webview
  void iosOnDidReceiveServerRedirectForProvisionalNavigation() {}

  ///Called when a web view asks for permission to navigate to new content after the response to the navigation request is known.
  ///
  ///[navigationResponse] represents the navigation response.
  ///
  ///**NOTE**: available only on iOS.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview
  Future<IOSNavigationResponseAction?>? iosOnNavigationResponse(
      IOSWKNavigationResponse navigationResponse) {}

  ///Called when a web view asks whether to continue with a connection that uses a deprecated version of TLS (v1.0 and v1.1).
  ///
  ///[challenge] represents the authentication challenge.
  ///
  ///**NOTE**: available only on iOS 14.0+.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/3601237-webview
  Future<IOSShouldAllowDeprecatedTLSAction?>? iosShouldAllowDeprecatedTLS(
      URLAuthenticationChallenge challenge) {}

  void throwIfAlreadyOpened({String message = ''}) {
    if (this.isOpened()) {
      throw InAppBrowserAlreadyOpenedException([
        'Error: ${(message.isEmpty) ? '' : message + ' '}The browser is already opened.'
      ]);
    }
  }

  void throwIfNotOpened({String message = ''}) {
    if (!this.isOpened()) {
      throw InAppBrowserNotOpenedException([
        'Error: ${(message.isEmpty) ? '' : message + ' '}The browser is not opened.'
      ]);
    }
  }
}
