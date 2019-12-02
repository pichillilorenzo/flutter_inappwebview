import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'webview_options.dart';

import 'types.dart';
import 'channel_manager.dart';
import 'in_app_webview.dart' show InAppWebViewController;

///InAppBrowser class. [webViewController] can be used to access the [InAppWebView] API.
///
///This class uses the native WebView of the platform.
class InAppBrowser {
  String uuid;
  Map<String, JavaScriptHandlerCallback> javaScriptHandlersMap =
      HashMap<String, JavaScriptHandlerCallback>();
  bool _isOpened = false;

  /// WebView Controller that can be used to access the [InAppWebView] API.
  InAppWebViewController webViewController;

  ///
  InAppBrowser() {
    uuid = uuidGenerator.v4();
    ChannelManager.addListener(uuid, handleMethod);
    _isOpened = false;
    webViewController = new InAppWebViewController.fromInAppBrowser(
        uuid, ChannelManager.channel, this);
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onBrowserCreated":
        this._isOpened = true;
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

  ///Opens an [url] in a new [InAppBrowser] instance.
  ///
  ///[url]: The [url] to load. Call `encodeUriComponent()` on this if the [url] contains Unicode characters. The default value is `about:blank`.
  ///
  ///[headers]: The additional headers to be used in the HTTP request for this URL, specified as a map from name to value.
  ///
  ///[options]: Options for the [InAppBrowser].
  Future<void> open(
      {String url = "about:blank",
      Map<String, String> headers = const {},
      InAppBrowserClassOptions options}) async {
    assert(url != null && url.isNotEmpty);
    this.throwIsAlreadyOpened(message: 'Cannot open $url!');

    Map<String, dynamic> optionsMap = {};

    optionsMap.addAll(options.inAppBrowserOptions?.toMap() ?? {});
    optionsMap.addAll(
        options.inAppWebViewWidgetOptions?.inAppWebViewOptions?.toMap() ?? {});
    if (Platform.isAndroid) {
      optionsMap.addAll(options.androidInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(options
              .inAppWebViewWidgetOptions?.androidInAppWebViewOptions
              ?.toMap() ??
          {});
    } else if (Platform.isIOS) {
      optionsMap.addAll(options.iosInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(
          options.inAppWebViewWidgetOptions?.iosInAppWebViewOptions?.toMap() ??
              {});
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('headers', () => headers);
    args.putIfAbsent('options', () => optionsMap);
    args.putIfAbsent('openWithSystemBrowser', () => false);
    args.putIfAbsent('isLocalFile', () => false);
    args.putIfAbsent('isData', () => false);
    args.putIfAbsent('useChromeSafariBrowser', () => false);
    await ChannelManager.channel.invokeMethod('open', args);
  }

  ///Opens the given [assetFilePath] file in a new [InAppBrowser] instance. The other arguments are the same of [InAppBrowser.open].
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
  ///inAppBrowser.openFile("assets/index.html");
  ///...
  ///```
  ///
  ///[headers]: The additional headers to be used in the HTTP request for this URL, specified as a map from name to value.
  ///
  ///[options]: Options for the [InAppBrowser].
  Future<void> openFile(
      {@required String assetFilePath,
      Map<String, String> headers = const {},
      InAppBrowserClassOptions options}) async {
    assert(assetFilePath != null && assetFilePath.isNotEmpty);
    this.throwIsAlreadyOpened(message: 'Cannot open $assetFilePath!');

    Map<String, dynamic> optionsMap = {};

    optionsMap.addAll(options.inAppBrowserOptions?.toMap() ?? {});
    optionsMap.addAll(
        options.inAppWebViewWidgetOptions?.inAppWebViewOptions?.toMap() ?? {});
    if (Platform.isAndroid) {
      optionsMap.addAll(options.androidInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(options
              .inAppWebViewWidgetOptions?.androidInAppWebViewOptions
              ?.toMap() ??
          {});
    } else if (Platform.isIOS) {
      optionsMap.addAll(options.iosInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(
          options.inAppWebViewWidgetOptions?.iosInAppWebViewOptions?.toMap() ??
              {});
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('url', () => assetFilePath);
    args.putIfAbsent('headers', () => headers);
    args.putIfAbsent('options', () => optionsMap);
    args.putIfAbsent('openWithSystemBrowser', () => false);
    args.putIfAbsent('isLocalFile', () => true);
    args.putIfAbsent('isData', () => false);
    args.putIfAbsent('useChromeSafariBrowser', () => false);
    await ChannelManager.channel.invokeMethod('open', args);
  }

  ///Opens a new [InAppBrowser] instance with [data] as a content, using [baseUrl] as the base URL for it.
  ///
  ///The [mimeType] parameter specifies the format of the data. The default value is `"text/html"`.
  ///
  ///The [encoding] parameter specifies the encoding of the data. The default value is `"utf8"`.
  ///
  ///The [historyUrl] parameter is the URL to use as the history entry. The default value is `about:blank`. If non-null, this must be a valid URL. This parameter is used only on Android.
  ///
  ///The [options] parameter specifies the options for the [InAppBrowser].
  Future<void> openData(
      {@required String data,
      String mimeType = "text/html",
      String encoding = "utf8",
      String baseUrl = "about:blank",
      String historyUrl = "about:blank",
      InAppBrowserClassOptions options}) async {
    assert(data != null);

    Map<String, dynamic> optionsMap = {};

    optionsMap.addAll(options.inAppBrowserOptions?.toMap() ?? {});
    optionsMap.addAll(
        options.inAppWebViewWidgetOptions?.inAppWebViewOptions?.toMap() ?? {});
    if (Platform.isAndroid) {
      optionsMap.addAll(options.androidInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(options
              .inAppWebViewWidgetOptions?.androidInAppWebViewOptions
              ?.toMap() ??
          {});
    } else if (Platform.isIOS) {
      optionsMap.addAll(options.iosInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(
          options.inAppWebViewWidgetOptions?.iosInAppWebViewOptions?.toMap() ??
              {});
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('options', () => optionsMap);
    args.putIfAbsent('data', () => data);
    args.putIfAbsent('mimeType', () => mimeType);
    args.putIfAbsent('encoding', () => encoding);
    args.putIfAbsent('baseUrl', () => baseUrl);
    args.putIfAbsent('openWithSystemBrowser', () => false);
    args.putIfAbsent('isLocalFile', () => false);
    args.putIfAbsent('isData', () => true);
    args.putIfAbsent('useChromeSafariBrowser', () => false);
    await ChannelManager.channel.invokeMethod('open', args);
  }

  ///This is a static method that opens an [url] in the system browser. You wont be able to use the [InAppBrowser] methods here!
  static Future<void> openWithSystemBrowser({@required String url}) async {
    assert(url != null && url.isNotEmpty);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => "");
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('headers', () => {});
    args.putIfAbsent('isLocalFile', () => false);
    args.putIfAbsent('isData', () => false);
    args.putIfAbsent('openWithSystemBrowser', () => true);
    args.putIfAbsent('useChromeSafariBrowser', () => false);
    args.putIfAbsent('options', () => {});
    return await ChannelManager.channel.invokeMethod('open', args);
  }

  ///Displays an [InAppBrowser] window that was opened hidden. Calling this has no effect if the [InAppBrowser] was already visible.
  Future<void> show() async {
    this.throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    await ChannelManager.channel.invokeMethod('show', args);
  }

  ///Hides the [InAppBrowser] window. Calling this has no effect if the [InAppBrowser] was already hidden.
  Future<void> hide() async {
    this.throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    await ChannelManager.channel.invokeMethod('hide', args);
  }

  ///Closes the [InAppBrowser] window.
  Future<void> close() async {
    this.throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    await ChannelManager.channel.invokeMethod('close', args);
  }

  ///Check if the Web View of the [InAppBrowser] instance is hidden.
  Future<bool> isHidden() async {
    this.throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    return await ChannelManager.channel.invokeMethod('isHidden', args);
  }

  ///Sets the [InAppBrowser] options with the new [options] and evaluates them.
  Future<void> setOptions({@required InAppBrowserClassOptions options}) async {
    this.throwIsNotOpened();

    Map<String, dynamic> optionsMap = {};

    optionsMap.addAll(options.inAppBrowserOptions?.toMap() ?? {});
    optionsMap.addAll(
        options.inAppWebViewWidgetOptions?.inAppWebViewOptions?.toMap() ?? {});
    if (Platform.isAndroid) {
      optionsMap.addAll(options.androidInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(options
              .inAppWebViewWidgetOptions?.androidInAppWebViewOptions
              ?.toMap() ??
          {});
    } else if (Platform.isIOS) {
      optionsMap.addAll(options.iosInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(
          options.inAppWebViewWidgetOptions?.iosInAppWebViewOptions?.toMap() ??
              {});
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('options', () => optionsMap);
    args.putIfAbsent('optionsType', () => "InAppBrowserOptions");
    await ChannelManager.channel.invokeMethod('setOptions', args);
  }

  ///Gets the current [InAppBrowser] options as a `Map`. Returns `null` if the options are not setted yet.
  Future<InAppBrowserClassOptions> getOptions() async {
    this.throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('optionsType', () => "InAppBrowserOptions");

    InAppBrowserClassOptions inAppBrowserClassOptions =
        InAppBrowserClassOptions();
    Map<dynamic, dynamic> options =
        await ChannelManager.channel.invokeMethod('getOptions', args);
    if (options != null) {
      options = options.cast<String, dynamic>();
      inAppBrowserClassOptions.inAppBrowserOptions =
          InAppBrowserOptions.fromMap(options);
      inAppBrowserClassOptions.inAppWebViewWidgetOptions.inAppWebViewOptions =
          InAppWebViewOptions.fromMap(options);
      if (Platform.isAndroid) {
        inAppBrowserClassOptions.androidInAppBrowserOptions =
            AndroidInAppBrowserOptions.fromMap(options);
        inAppBrowserClassOptions
                .inAppWebViewWidgetOptions.androidInAppWebViewOptions =
            AndroidInAppWebViewOptions.fromMap(options);
      } else if (Platform.isIOS) {
        inAppBrowserClassOptions.iosInAppBrowserOptions =
            IosInAppBrowserOptions.fromMap(options);
        inAppBrowserClassOptions.inAppWebViewWidgetOptions
            .iosInAppWebViewOptions = IosInAppWebViewOptions.fromMap(options);
      }
    }

    return inAppBrowserClassOptions;
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
  void onLoadStart(String url) {}

  ///Event fired when the [InAppBrowser] finishes loading an [url].
  void onLoadStop(String url) {}

  ///Event fired when the [InAppBrowser] encounters an error loading an [url].
  void onLoadError(String url, int code, String message) {}

  ///Event fired when the [InAppBrowser] main page receives an HTTP error.
  ///
  ///[url] represents the url of the main page that received the HTTP error.
  ///
  ///[statusCode] represents the status code of the response. HTTP errors have status codes >= 400.
  ///
  ///[description] represents the description of the HTTP error. On iOS, it is always an empty string.
  ///
  ///**NOTE**: available on Android 23+.
  void onLoadHttpError(String url, int statusCode, String description) {}

  ///Event fired when the current [progress] (range 0-100) of loading a page is changed.
  void onProgressChanged(int progress) {}

  ///Event fired when the [InAppBrowser] webview receives a [ConsoleMessage].
  void onConsoleMessage(ConsoleMessage consoleMessage) {}

  ///Give the host application a chance to take control when a URL is about to be loaded in the current WebView.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldOverrideUrlLoading] option to `true`.
  void shouldOverrideUrlLoading(String url) {}

  ///Event fired when the [InAppBrowser] webview loads a resource.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useOnLoadResource] and [InAppWebViewOptions.javaScriptEnabled] options to `true`.
  void onLoadResource(LoadedResource resource) {}

  ///Event fired when the [InAppBrowser] webview scrolls.
  ///
  ///[x] represents the current horizontal scroll origin in pixels.
  ///
  ///[y] represents the current vertical scroll origin in pixels.
  void onScrollChanged(int x, int y) {}

  ///Event fired when [InAppBrowser] recognizes and starts a downloadable file.
  ///
  ///[url] represents the url of the file.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useOnDownloadStart] option to `true`.
  void onDownloadStart(String url) {}

  ///Event fired when the [InAppBrowser] webview finds the `custom-scheme` while loading a resource. Here you can handle the url request and return a [CustomSchemeResponse] to load a specific resource encoded to `base64`.
  ///
  ///[scheme] represents the scheme of the url.
  ///
  ///[url] represents the url of the request.
  // ignore: missing_return
  Future<CustomSchemeResponse> onLoadResourceCustomScheme(
      String scheme, String url) {}

  ///Event fired when the [InAppBrowser] webview tries to open a link with `target="_blank"`.
  ///
  ///[url] represents the url of the link.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useOnTargetBlank] option to `true`.
  void onTargetBlank(String url) {}

  ///Event that notifies the host application that web content from the specified origin is attempting to use the Geolocation API, but no permission state is currently set for that origin.
  ///Note that for applications targeting Android N and later SDKs (API level > `Build.VERSION_CODES.M`) this method is only called for requests originating from secure origins such as https.
  ///On non-secure origins geolocation requests are automatically denied.
  ///
  ///[origin] represents the origin of the web content attempting to use the Geolocation API.
  ///
  ///**NOTE**: available only on Android.
  // ignore: missing_return
  Future<GeolocationPermissionShowPromptResponse>
      onGeolocationPermissionsShowPrompt(String origin) {}

  ///Event fired when javascript calls the `alert()` method to display an alert dialog.
  ///If [JsAlertResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[message] represents the message to be displayed in the alert dialog.
  // ignore: missing_return
  Future<JsAlertResponse> onJsAlert(String message) {}

  ///Event fired when javascript calls the `confirm()` method to display a confirm dialog.
  ///If [JsConfirmResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[message] represents the message to be displayed in the alert dialog.
  // ignore: missing_return
  Future<JsConfirmResponse> onJsConfirm(String message) {}

  ///Event fired when javascript calls the `prompt()` method to display a prompt dialog.
  ///If [JsPromptResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[message] represents the message to be displayed in the alert dialog.
  ///[defaultValue] represents the default value displayed in the prompt dialog.
  // ignore: missing_return
  Future<JsPromptResponse> onJsPrompt(String message, String defaultValue) {}

  ///Event fired when the WebView notifies that a loading URL has been flagged by Safe Browsing.
  ///The default behavior is to show an interstitial to the user, with the reporting checkbox visible.
  ///
  ///[url] represents the url of the request.
  ///
  ///[threatType] represents the reason the resource was caught by Safe Browsing, corresponding to a [SafeBrowsingThreat].
  ///
  ///**NOTE**: available only on Android.
  // ignore: missing_return
  Future<SafeBrowsingResponse> onSafeBrowsingHit(
      String url, SafeBrowsingThreat threatType) {}

  ///Event fired when the WebView received an HTTP authentication request. The default behavior is to cancel the request.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [HttpAuthChallenge].
  // ignore: missing_return
  Future<HttpAuthResponse> onReceivedHttpAuthRequest(
      HttpAuthChallenge challenge) {}

  ///Event fired when the WebView need to perform server trust authentication (certificate validation).
  ///The host application must return either [ServerTrustAuthResponse] instance with [ServerTrustAuthResponseAction.CANCEL] or [ServerTrustAuthResponseAction.PROCEED].
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ServerTrustChallenge].
  // ignore: missing_return
  Future<ServerTrustAuthResponse> onReceivedServerTrustAuthRequest(
      ServerTrustChallenge challenge) {}

  ///Notify the host application to handle an SSL client certificate request.
  ///Webview stores the response in memory (for the life of the application) if [ClientCertResponseAction.PROCEED] or [ClientCertResponseAction.CANCEL]
  ///is called and does not call [onReceivedClientCertRequest] again for the same host and port pair.
  ///Note that, multiple layers in chromium network stack might be caching the responses.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ClientCertChallenge].
  // ignore: missing_return
  Future<ClientCertResponse> onReceivedClientCertRequest(
      ClientCertChallenge challenge) {}

  ///Event fired as find-on-page operations progress.
  ///The listener may be notified multiple times while the operation is underway, and the numberOfMatches value should not be considered final unless [isDoneCounting] is true.
  ///
  ///[activeMatchOrdinal] represents the zero-based ordinal of the currently selected match.
  ///
  ///[numberOfMatches] represents how many matches have been found.
  ///
  ///[isDoneCounting] whether the find operation has actually completed.
  void onFindResultReceived(
      int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting) {}

  ///Event fired when an `XMLHttpRequest` is sent to a server.
  ///It gives the host application a chance to take control over the request before sending it.
  ///
  ///[ajaxRequest] represents the `XMLHttpRequest`.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptAjaxRequest] option to `true`.
  // ignore: missing_return
  Future<AjaxRequest> shouldInterceptAjaxRequest(AjaxRequest ajaxRequest) {}

  ///Event fired whenever the `readyState` attribute of an `XMLHttpRequest` changes.
  ///It gives the host application a chance to abort the request.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptAjaxRequest] option to `true`.
  // ignore: missing_return
  Future<AjaxRequestAction> onAjaxReadyStateChange(AjaxRequest ajaxRequest) {}

  ///Event fired as an `XMLHttpRequest` progress.
  ///It gives the host application a chance to abort the request.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptAjaxRequest] option to `true`.
  // ignore: missing_return
  Future<AjaxRequestAction> onAjaxProgress(AjaxRequest ajaxRequest) {}

  ///Event fired when a request is sent to a server through [Fetch API](https://developer.mozilla.org/it/docs/Web/API/Fetch_API).
  ///It gives the host application a chance to take control over the request before sending it.
  ///
  ///[fetchRequest] represents a resource request.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptFetchRequest] option to `true`.
  // ignore: missing_return
  Future<FetchRequest> shouldInterceptFetchRequest(FetchRequest fetchRequest) {}

  ///Event fired when the navigation state of the WebView changes throught the usage of
  ///javascript **[History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API)** functions (`pushState()`, `replaceState()`) and `onpopstate` event.
  ///
  ///Also, the event is fired when the javascript `window.location` changes without reloading the webview (for example appending or modifying an hash to the url).
  ///
  ///[url] represents the new url.
  void onNavigationStateChange(String url) {}

  ///Event fired when the WebView is requesting permission to access the specified resources and the permission currently isn't granted or denied.
  ///
  ///[origin] represents the origin of the web page which is trying to access the restricted resources.
  ///
  ///[resources] represents the array of resources the web content wants to access.
  ///
  ///**NOTE**: available only on Android 23+.
  // ignore: missing_return
  Future<PermissionRequestResponse> onPermissionRequest(
      String origin, List<String> resources) {}

  void throwIsAlreadyOpened({String message = ''}) {
    if (this.isOpened()) {
      throw Exception([
        'Error: ${(message.isEmpty) ? '' : message + ' '}The browser is already opened.'
      ]);
    }
  }

  void throwIsNotOpened({String message = ''}) {
    if (!this.isOpened()) {
      throw Exception([
        'Error: ${(message.isEmpty) ? '' : message + ' '}The browser is not opened.'
      ]);
    }
  }
}
