import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_inappbrowser/src/webview_options.dart';

import 'types.dart';
import 'channel_manager.dart';
import 'in_app_webview.dart' show InAppWebViewController;

///InAppBrowser class. [webViewController] can be used to access the [InAppWebView] API.
///
///This class uses the native WebView of the platform.
class InAppBrowser {

  String uuid;
  Map<String, JavaScriptHandlerCallback> javaScriptHandlersMap = HashMap<String, JavaScriptHandlerCallback>();
  bool _isOpened = false;
  /// WebView Controller that can be used to access the [InAppWebView] API.
  InAppWebViewController webViewController;

  ///
  InAppBrowser () {
    uuid = uuidGenerator.v4();
    ChannelManager.addListener(uuid, handleMethod);
    _isOpened = false;
    webViewController = new InAppWebViewController.fromInAppBrowser(uuid, ChannelManager.channel, this);
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch(call.method) {
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
  ///- [url]: The [url] to load. Call [encodeUriComponent()] on this if the [url] contains Unicode characters. The default value is `about:blank`.
  ///
  ///- [headers]: The additional headers to be used in the HTTP request for this URL, specified as a map from name to value.
  ///
  ///- [options]: Options for the [InAppBrowser].
  ///
  ///  - All platforms support:
  ///    - __useShouldOverrideUrlLoading__: Set to `true` to be able to listen at the [shouldOverrideUrlLoading()] event. The default value is `false`.
  ///    - __useOnLoadResource__: Set to `true` to be able to listen at the [onLoadResource()] event. The default value is `false`.
  ///    - __useOnDownloadStart__: Set to `true` to be able to listen at the [onDownloadStart()] event. The default value is `false`.
  ///    - __useOnTargetBlank__: Set to `true` to be able to listen at the [onTargetBlank()] event. The default value is `false`.
  ///    - __clearCache__: Set to `true` to have all the browser's cache cleared before the new window is opened. The default value is `false`.
  ///    - __userAgent__: Set the custom WebView's user-agent.
  ///    - __javaScriptEnabled__: Set to `true` to enable JavaScript. The default value is `true`.
  ///    - __javaScriptCanOpenWindowsAutomatically__: Set to `true` to allow JavaScript open windows without user interaction. The default value is `false`.
  ///    - __hidden__: Set to `true` to create the browser and load the page, but not show it. The `onLoadStop` event fires when loading is complete. Omit or set to `false` (default) to have the browser open and load normally.
  ///    - __toolbarTop__: Set to `false` to hide the toolbar at the top of the WebView. The default value is `true`.
  ///    - __toolbarTopBackgroundColor__: Set the custom background color of the toolbar at the top.
  ///    - __hideUrlBar__: Set to `true` to hide the url bar on the toolbar at the top. The default value is `false`.
  ///    - __mediaPlaybackRequiresUserGesture__: Set to `true` to prevent HTML5 audio or video from autoplaying. The default value is `true`.
  ///    - __transparentBackground__: Set to `true` to make the background of the WebView transparent. If your app has a dark theme, this can prevent a white flash on initialization. The default value is `false`.
  ///    - __resourceCustomSchemes__: List of custom schemes that [InAppBrowser] must handle. Use the [onLoadResourceCustomScheme()] event to intercept resource requests with custom scheme.
  ///
  ///  - **Android** supports these additional options:
  ///
  ///    - __hideTitleBar__: Set to `true` if you want the title should be displayed. The default value is `false`.
  ///    - __closeOnCannotGoBack__: Set to `false` to not close the InAppBrowser when the user click on the back button and the WebView cannot go back to the history. The default value is `true`.
  ///    - __clearSessionCache__: Set to `true` to have the session cookie cache cleared before the new window is opened.
  ///    - __builtInZoomControls__: Set to `true` if the WebView should use its built-in zoom mechanisms. The default value is `false`.
  ///    - __displayZoomControls__: Set to `true` if the WebView should display on-screen zoom controls when using the built-in zoom mechanisms. The default value is `false`.
  ///    - __supportZoom__: Set to `false` if the WebView should not support zooming using its on-screen zoom controls and gestures. The default value is `true`.
  ///    - __databaseEnabled__: Set to `true` if you want the database storage API is enabled. The default value is `false`.
  ///    - __domStorageEnabled__: Set to `true` if you want the DOM storage API is enabled. The default value is `false`.
  ///    - __useWideViewPort__: Set to `true` if the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport. When the value of the setting is false, the layout width is always set to the width of the WebView control in device-independent (CSS) pixels. When the value is true and the page contains the viewport meta tag, the value of the width specified in the tag is used. If the page does not contain the tag or does not provide a width, then a wide viewport will be used. The default value is `true`.
  ///    - __safeBrowsingEnabled__: Set to `true` if you want the Safe Browsing is enabled. Safe Browsing allows WebView to protect against malware and phishing attacks by verifying the links. The default value is `true`.
  ///    - __progressBar__: Set to `false` to hide the progress bar at the bottom of the toolbar at the top. The default value is `true`.
  ///    - __textZoom__: Set text scaling of the WebView. The default value is `100`.
  ///    - __mixedContentMode__: Configures the WebView's behavior when a secure origin attempts to load a resource from an insecure origin. By default, apps that target `Build.VERSION_CODES.KITKAT` or below default to `MIXED_CONTENT_ALWAYS_ALLOW`. Apps targeting `Build.VERSION_CODES.LOLLIPOP` default to `MIXED_CONTENT_NEVER_ALLOW`. The preferred and most secure mode of operation for the WebView is `MIXED_CONTENT_NEVER_ALLOW` and use of `MIXED_CONTENT_ALWAYS_ALLOW` is strongly discouraged.
  ///
  ///  - **iOS** supports these additional options:
  ///
  ///    - __disallowOverScroll__: Set to `true` to disable the bouncing of the WebView when the scrolling has reached an edge of the content. The default value is `false`.
  ///    - __toolbarBottom__: Set to `false` to hide the toolbar at the bottom of the WebView. The default value is `true`.
  ///    - __toolbarBottomBackgroundColor__: Set the custom background color of the toolbar at the bottom.
  ///    - __toolbarBottomTranslucent__: Set to `true` to set the toolbar at the bottom translucent. The default value is `true`.
  ///    - __closeButtonCaption__: Set the custom text for the close button.
  ///    - __closeButtonColor__: Set the custom color for the close button.
  ///    - __presentationStyle__: Set the custom modal presentation style when presenting the WebView. The default value is `0 //fullscreen`. See [UIModalPresentationStyle](https://developer.apple.com/documentation/uikit/uimodalpresentationstyle) for all the available styles.
  ///    - __transitionStyle__: Set to the custom transition style when presenting the WebView. The default value is `0 //crossDissolve`. See [UIModalTransitionStyle](https://developer.apple.com/documentation/uikit/uimodaltransitionStyle) for all the available styles.
  ///    - __enableViewportScale__: Set to `true` to allow a viewport meta tag to either disable or restrict the range of user scaling. The default value is `false`.
  ///    - __suppressesIncrementalRendering__: Set to `true` if you want the WebView suppresses content rendering until it is fully loaded into memory.. The default value is `false`.
  ///    - __allowsAirPlayForMediaPlayback__: Set to `true` to allow AirPlay. The default value is `true`.
  ///    - __allowsBackForwardNavigationGestures__: Set to `true` to allow the horizontal swipe gestures trigger back-forward list navigations. The default value is `true`.
  ///    - __allowsLinkPreview__: Set to `true` to allow that pressing on a link displays a preview of the destination for the link. The default value is `true`.
  ///    - __ignoresViewportScaleLimits__: Set to `true` if you want that the WebView should always allow scaling of the webpage, regardless of the author's intent. The ignoresViewportScaleLimits property overrides the `user-scalable` HTML property in a webpage. The default value is `false`.
  ///    - __allowsInlineMediaPlayback__: Set to `true` to allow HTML5 media playback to appear inline within the screen layout, using browser-supplied controls rather than native controls. For this to work, add the `webkit-playsinline` attribute to any `<video>` elements. The default value is `false`.
  ///    - __allowsPictureInPictureMediaPlayback__: Set to `true` to allow HTML5 videos play picture-in-picture. The default value is `true`.
  ///    - __spinner__: Set to `false` to hide the spinner when the WebView is loading a page. The default value is `true`.
  Future<void> open({String url = "about:blank", Map<String, String> headers = const {}, InAppBrowserClassOptions options}) async {
    assert(url != null && url.isNotEmpty);
    this.throwIsAlreadyOpened(message: 'Cannot open $url!');

    Map<String, dynamic> optionsMap = {};

    optionsMap.addAll(options.inAppBrowserOptions?.toMap() ?? {});
    optionsMap.addAll(options.inAppWebViewWidgetOptions?.inAppWebViewOptions?.toMap() ?? {});
    if (Platform.isAndroid) {
      optionsMap.addAll(options.androidInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(options.inAppWebViewWidgetOptions?.androidInAppWebViewOptions?.toMap() ?? {});
    }
    else if (Platform.isIOS) {
      optionsMap.addAll(options.iosInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(options.inAppWebViewWidgetOptions?.iosInAppWebViewOptions?.toMap() ?? {});
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

  ///Opens the given [assetFilePath] file in a new [InAppBrowser] instance. The other arguments are the same of [InAppBrowser.open()].
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
  ///    - assets/t-rex.html
  ///    - assets/css/
  ///    - assets/images/
  ///
  ///...
  ///```
  ///Example of a `main.dart` file:
  ///```dart
  ///...
  ///inAppBrowser.openFile("assets/t-rex.html");
  ///...
  ///```
  Future<void> openFile(String assetFilePath, {Map<String, String> headers = const {}, InAppBrowserClassOptions options}) async {
    assert(assetFilePath != null && assetFilePath.isNotEmpty);
    this.throwIsAlreadyOpened(message: 'Cannot open $assetFilePath!');

    Map<String, dynamic> optionsMap = {};

    optionsMap.addAll(options.inAppBrowserOptions?.toMap() ?? {});
    optionsMap.addAll(options.inAppWebViewWidgetOptions?.inAppWebViewOptions?.toMap() ?? {});
    if (Platform.isAndroid) {
      optionsMap.addAll(options.androidInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(options.inAppWebViewWidgetOptions?.androidInAppWebViewOptions?.toMap() ?? {});
    }
    else if (Platform.isIOS) {
      optionsMap.addAll(options.iosInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(options.inAppWebViewWidgetOptions?.iosInAppWebViewOptions?.toMap() ?? {});
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
  ///The [mimeType] parameter specifies the format of the data.
  ///The [encoding] parameter specifies the encoding of the data.
  Future<void> openData(String data, {String mimeType = "text/html", String encoding = "utf8", String baseUrl = "about:blank", InAppBrowserClassOptions options}) async {
    assert(data != null);

    Map<String, dynamic> optionsMap = {};

    optionsMap.addAll(options.inAppBrowserOptions?.toMap() ?? {});
    optionsMap.addAll(options.inAppWebViewWidgetOptions?.inAppWebViewOptions?.toMap() ?? {});
    if (Platform.isAndroid) {
      optionsMap.addAll(options.androidInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(options.inAppWebViewWidgetOptions?.androidInAppWebViewOptions?.toMap() ?? {});
    }
    else if (Platform.isIOS) {
      optionsMap.addAll(options.iosInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(options.inAppWebViewWidgetOptions?.iosInAppWebViewOptions?.toMap() ?? {});
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
  static Future<void> openWithSystemBrowser(String url) async {
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
  Future<void> setOptions(InAppBrowserClassOptions options) async {
    this.throwIsNotOpened();

    Map<String, dynamic> optionsMap = {};

    optionsMap.addAll(options.inAppBrowserOptions?.toMap() ?? {});
    optionsMap.addAll(options.inAppWebViewWidgetOptions?.inAppWebViewOptions?.toMap() ?? {});
    if (Platform.isAndroid) {
      optionsMap.addAll(options.androidInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(options.inAppWebViewWidgetOptions?.androidInAppWebViewOptions?.toMap() ?? {});
    }
    else if (Platform.isIOS) {
      optionsMap.addAll(options.iosInAppBrowserOptions?.toMap() ?? {});
      optionsMap.addAll(options.inAppWebViewWidgetOptions?.iosInAppWebViewOptions?.toMap() ?? {});
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

    InAppBrowserClassOptions inAppBrowserClassOptions = InAppBrowserClassOptions();
    Map<dynamic, dynamic> options = await ChannelManager.channel.invokeMethod('getOptions', args);
    if (options != null) {
      options = options.cast<String, dynamic>();
      inAppBrowserClassOptions.inAppBrowserOptions = InAppBrowserOptions.fromMap(options);
      inAppBrowserClassOptions.inAppWebViewWidgetOptions.inAppWebViewOptions = InAppWebViewOptions.fromMap(options);
      if (Platform.isAndroid) {
        inAppBrowserClassOptions.androidInAppBrowserOptions = AndroidInAppBrowserOptions.fromMap(options);
        inAppBrowserClassOptions.inAppWebViewWidgetOptions.androidInAppWebViewOptions = AndroidInAppWebViewOptions.fromMap(options);
      }
      else if (Platform.isIOS) {
        inAppBrowserClassOptions.iosInAppBrowserOptions = IosInAppBrowserOptions.fromMap(options);
        inAppBrowserClassOptions.inAppWebViewWidgetOptions.iosInAppWebViewOptions = IosInAppWebViewOptions.fromMap(options);
      }
    }

    return inAppBrowserClassOptions;
  }

  ///Returns `true` if the [InAppBrowser] instance is opened, otherwise `false`.
  bool isOpened() {
    return this._isOpened;
  }

  ///Event fires when the [InAppBrowser] is created.
  void onBrowserCreated() {

  }

  ///Event fires when the [InAppBrowser] starts to load an [url].
  void onLoadStart(String url) {

  }

  ///Event fires when the [InAppBrowser] finishes loading an [url].
  void onLoadStop(String url) {

  }

  ///Event fires when the [InAppBrowser] encounters an error loading an [url].
  void onLoadError(String url, int code, String message) {

  }

  ///Event fires when the current [progress] (range 0-100) of loading a page is changed.
  void onProgressChanged(int progress) {

  }

  ///Event fires when the [InAppBrowser] window is closed.
  void onExit() {

  }

  ///Event fires when the [InAppBrowser] webview receives a [ConsoleMessage].
  void onConsoleMessage(ConsoleMessage consoleMessage) {

  }

  ///Give the host application a chance to take control when a URL is about to be loaded in the current WebView.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set `useShouldOverrideUrlLoading` option to `true`.
  void shouldOverrideUrlLoading(String url) {

  }

  ///Event fires when the [InAppBrowser] webview loads a resource.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set `useOnLoadResource` option to `true`.
  void onLoadResource(LoadedResource resource) {

  }

  ///Event fires when the [InAppBrowser] webview scrolls.
  ///
  ///[x] represents the current horizontal scroll origin in pixels.
  ///
  ///[y] represents the current vertical scroll origin in pixels.
  void onScrollChanged(int x, int y) {

  }

  ///Event fires when [InAppBrowser] recognizes and starts a downloadable file.
  ///
  ///[url] represents the url of the file.
  void onDownloadStart(String url) {

  }

  ///Event fires when the [InAppBrowser] webview finds the `custom-scheme` while loading a resource. Here you can handle the url request and return a [CustomSchemeResponse] to load a specific resource encoded to `base64`.
  ///
  ///[scheme] represents the scheme of the url.
  ///
  ///[url] represents the url of the request.
  Future<CustomSchemeResponse> onLoadResourceCustomScheme(String scheme, String url) {

  }

  ///Event fires when the [InAppBrowser] webview tries to open a link with `target="_blank"`.
  ///
  ///[url] represents the url of the link.
  void onTargetBlank(String url) {

  }

  ///Event that notifies the host application that web content from the specified origin is attempting to use the Geolocation API, but no permission state is currently set for that origin.
  ///Note that for applications targeting Android N and later SDKs (API level > `Build.VERSION_CODES.M`) this method is only called for requests originating from secure origins such as https.
  ///On non-secure origins geolocation requests are automatically denied.
  ///
  ///[origin] represents the origin of the web content attempting to use the Geolocation API.
  ///
  ///**NOTE**: available only for Android.
  Future<GeolocationPermissionShowPromptResponse> onGeolocationPermissionsShowPrompt (String origin) {

  }

  ///Event fires when javascript calls the `alert()` method to display an alert dialog.
  ///If [JsAlertResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[message] represents the message to be displayed in the alert dialog.
  Future<JsAlertResponse> onJsAlert(String message) {

  }

  ///Event fires when javascript calls the `confirm()` method to display a confirm dialog.
  ///If [JsConfirmResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[message] represents the message to be displayed in the alert dialog.
  Future<JsConfirmResponse> onJsConfirm(String message) {

  }

  ///Event fires when javascript calls the `prompt()` method to display a prompt dialog.
  ///If [JsPromptResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[message] represents the message to be displayed in the alert dialog.
  ///[defaultValue] represents the default value displayed in the prompt dialog.
  Future<JsPromptResponse> onJsPrompt(String message, String defaultValue) {

  }

  ///Event fires when the webview notifies that a loading URL has been flagged by Safe Browsing.
  ///The default behavior is to show an interstitial to the user, with the reporting checkbox visible.
  ///
  ///[url] represents the url of the request.
  ///
  ///[threatType] represents the reason the resource was caught by Safe Browsing, corresponding to a [SafeBrowsingThreat].
  ///
  ///**NOTE**: available only for Android.
  Future<SafeBrowsingResponse> onSafeBrowsingHit(String url, SafeBrowsingThreat threatType) {

  }

  ///Event fires when a WebView received an HTTP authentication request. The default behavior is to cancel the request.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the auth challenge.
  Future<HttpAuthResponse> onReceivedHttpAuthRequest(HttpAuthChallenge challenge) {

  }

  ///
  Future<ServerTrustAuthResponse> onReceivedServerTrustAuthRequest(ServerTrustChallenge challenge) {

  }

  ///
  Future<ClientCertResponse> onReceivedClientCertRequest(ClientCertChallenge challenge) {

  }

  ///Event fired as find-on-page operations progress.
  ///The listener may be notified multiple times while the operation is underway, and the numberOfMatches value should not be considered final unless [isDoneCounting] is true.
  ///
  ///[activeMatchOrdinal] represents the zero-based ordinal of the currently selected match.
  ///
  ///[numberOfMatches] represents how many matches have been found.
  ///
  ///[isDoneCounting] whether the find operation has actually completed.
  void onFindResultReceived(int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting) {

  }

  void throwIsAlreadyOpened({String message = ''}) {
    if (this.isOpened()) {
      throw Exception(['Error: ${ (message.isEmpty) ? '' : message + ' '}The browser is already opened.']);
    }
  }

  void throwIsNotOpened({String message = ''}) {
    if (!this.isOpened()) {
      throw Exception(['Error: ${ (message.isEmpty) ? '' : message + ' '}The browser is not opened.']);
    }
  }

}
