/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
*/

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
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';

typedef Future<dynamic> ListenerCallback(MethodCall call);

///This type represents a callback, added with [addJavaScriptHandler], that listens to post messages sent from JavaScript.
///
///The Android implementation uses [addJavascriptInterface](https://developer.android.com/reference/android/webkit/WebView#addJavascriptInterface(java.lang.Object,%20java.lang.String)).
///The iOS implementation uses [addScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537172-addscriptmessagehandler?language=objc)
///
///The JavaScript function that can be used to call the handler is `window.flutter_inappbrowser.callHandler(handlerName <String>, ...args);`, where `args` are [rest parameters](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters).
///The `args` will be stringified automatically using `JSON.stringify(args)` method and then they will be decoded on the Dart side.
///
///Also, a [JavaScriptHandlerCallback] can return json data to the JavaScript side.
///In this case, simply return data that you want to send and it will be automatically json encoded using [jsonEncode] from the `dart:convert` library.
typedef dynamic JavaScriptHandlerCallback(List<dynamic> arguments);

var _uuidGenerator = new Uuid();

///
enum ConsoleMessageLevel {
  DEBUG, ERROR, LOG, TIP, WARNING
}

///Public class representing a resource request of the [InAppBrowser] WebView.
///It is used by the method [InAppBrowser.onLoadResource()].
class WebResourceRequest {

  String url;
  Map<String, String> headers;
  String method;

  WebResourceRequest(this.url, this.headers, this.method);

}

///Public class representing a resource response of the [InAppBrowser] WebView.
///It is used by the method [InAppBrowser.onLoadResource()].
class WebResourceResponse {

  String url;
  Map<String, String> headers;
  int statusCode;
  int startTime;
  int duration;
  Uint8List data;

  WebResourceResponse(this.url, this.headers, this.statusCode, this.startTime, this.duration, this.data);

}

///Public class representing a JavaScript console message from WebCore.
///This could be a issued by a call to one of the console logging functions (e.g. console.log('...')) or a JavaScript error on the page.
///
///To receive notifications of these messages, override the [InAppBrowser.onConsoleMessage()] function.
class ConsoleMessage {

  String sourceURL = "";
  int lineNumber = 1;
  String message = "";
  ConsoleMessageLevel messageLevel = ConsoleMessageLevel.LOG;

  ConsoleMessage(this.sourceURL, this.lineNumber, this.message, this.messageLevel);
}

class _ChannelManager {
  static const MethodChannel channel = const MethodChannel('com.pichillilorenzo/flutter_inappbrowser');
  static bool initialized = false;
  static final listeners = HashMap<String, ListenerCallback>();

  static Future<dynamic> _handleMethod(MethodCall call) async {
    String uuid = call.arguments["uuid"];
    return await listeners[uuid](call);
  }

  static void addListener(String key, ListenerCallback callback) {
    if (!initialized)
      init();
    listeners.putIfAbsent(key, () => callback);
  }

  static void init () {
    channel.setMethodCallHandler(_handleMethod);
    initialized = true;
  }
}

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
    uuid = _uuidGenerator.v4();
    _ChannelManager.addListener(uuid, _handleMethod);
    _isOpened = false;
    webViewController = new InAppWebViewController.fromInAppBrowser(uuid, _ChannelManager.channel, this);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
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
        return webViewController._handleMethod(call);
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
  Future<void> open({String url = "about:blank", Map<String, String> headers = const {}, Map<String, dynamic> options = const {}}) async {
    assert(url != null && url.isNotEmpty);
    this._throwIsAlreadyOpened(message: 'Cannot open $url!');
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('headers', () => headers);
    args.putIfAbsent('options', () => options);
    args.putIfAbsent('openWithSystemBrowser', () => false);
    args.putIfAbsent('isLocalFile', () => false);
    args.putIfAbsent('isData', () => false);
    args.putIfAbsent('useChromeSafariBrowser', () => false);
    await _ChannelManager.channel.invokeMethod('open', args);
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
  Future<void> openFile(String assetFilePath, {Map<String, String> headers = const {}, Map<String, dynamic> options = const {}}) async {
    assert(assetFilePath != null && assetFilePath.isNotEmpty);
    this._throwIsAlreadyOpened(message: 'Cannot open $assetFilePath!');
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('url', () => assetFilePath);
    args.putIfAbsent('headers', () => headers);
    args.putIfAbsent('options', () => options);
    args.putIfAbsent('openWithSystemBrowser', () => false);
    args.putIfAbsent('isLocalFile', () => true);
    args.putIfAbsent('isData', () => false);
    args.putIfAbsent('useChromeSafariBrowser', () => false);
    await _ChannelManager.channel.invokeMethod('open', args);
  }

  ///Opens a new [InAppBrowser] instance with [data] as a content, using [baseUrl] as the base URL for it.
  ///The [mimeType] parameter specifies the format of the data.
  ///The [encoding] parameter specifies the encoding of the data.
  Future<void> openData(String data, {String mimeType = "text/html", String encoding = "utf8", String baseUrl = "about:blank", Map<String, dynamic> options = const {}}) async {
    assert(data != null);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('options', () => options);
    args.putIfAbsent('data', () => data);
    args.putIfAbsent('mimeType', () => mimeType);
    args.putIfAbsent('encoding', () => encoding);
    args.putIfAbsent('baseUrl', () => baseUrl);
    args.putIfAbsent('openWithSystemBrowser', () => false);
    args.putIfAbsent('isLocalFile', () => false);
    args.putIfAbsent('isData', () => true);
    args.putIfAbsent('useChromeSafariBrowser', () => false);
    await _ChannelManager.channel.invokeMethod('open', args);
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
    return await _ChannelManager.channel.invokeMethod('open', args);
  }

  ///Displays an [InAppBrowser] window that was opened hidden. Calling this has no effect if the [InAppBrowser] was already visible.
  Future<void> show() async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    await _ChannelManager.channel.invokeMethod('show', args);
  }

  ///Hides the [InAppBrowser] window. Calling this has no effect if the [InAppBrowser] was already hidden.
  Future<void> hide() async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    await _ChannelManager.channel.invokeMethod('hide', args);
  }

  ///Closes the [InAppBrowser] window.
  Future<void> close() async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    await _ChannelManager.channel.invokeMethod('close', args);
  }

  ///Check if the Web View of the [InAppBrowser] instance is hidden.
  Future<bool> isHidden() async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    return await _ChannelManager.channel.invokeMethod('isHidden', args);
  }

  ///Sets the [InAppBrowser] options with the new [options] and evaluates them.
  Future<void> setOptions(Map<String, dynamic> options) async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('options', () => options);
    args.putIfAbsent('optionsType', () => "InAppBrowserOptions");
    await _ChannelManager.channel.invokeMethod('setOptions', args);
  }

  ///Gets the current [InAppBrowser] options. Returns `null` if the options are not setted yet.
  Future<Map<String, dynamic>> getOptions() async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('optionsType', () => "InAppBrowserOptions");
    Map<dynamic, dynamic> options = await _ChannelManager.channel.invokeMethod('getOptions', args);
    options = options.cast<String, dynamic>();
    return options;
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
  ///
  ///**NOTE only for iOS**: In some cases, the [response.data] of a [response] with `text/assets` encoding could be empty.
  void onLoadResource(WebResourceResponse response, WebResourceRequest request) {

  }

  ///Event fires when the [InAppBrowser] webview scrolls.
  ///[x] represents the current horizontal scroll origin in pixels.
  ///[y] represents the current vertical scroll origin in pixels.
  void onScrollChanged(int x, int y) {

  }

  void _throwIsAlreadyOpened({String message = ''}) {
    if (this.isOpened()) {
      throw Exception(['Error: ${ (message.isEmpty) ? '' : message + ' '}The browser is already opened.']);
    }
  }

  void _throwIsNotOpened({String message = ''}) {
    if (!this.isOpened()) {
      throw Exception(['Error: ${ (message.isEmpty) ? '' : message + ' '}The browser is not opened.']);
    }
  }
}

///ChromeSafariBrowser class.
///
///This class uses native [Chrome Custom Tabs](https://developer.android.com/reference/android/support/customtabs/package-summary) on Android
///and [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) on iOS.
///
///[browserFallback] represents the [InAppBrowser] instance fallback in case [Chrome Custom Tabs]/[SFSafariViewController] is not available.
class ChromeSafariBrowser {
  String uuid;
  InAppBrowser browserFallback;
  bool _isOpened = false;

  ///Initialize the [ChromeSafariBrowser] instance with an [InAppBrowser] fallback instance or `null`.
  ChromeSafariBrowser (bf) {
    uuid = _uuidGenerator.v4();
    browserFallback = bf;
    _ChannelManager.addListener(uuid, _handleMethod);
    _isOpened = false;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {
      case "onChromeSafariBrowserOpened":
        onOpened();
        break;
      case "onChromeSafariBrowserLoaded":
        onLoaded();
        break;
      case "onChromeSafariBrowserClosed":
        onClosed();
        this._isOpened = false;
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
  }

  ///Opens an [url] in a new [ChromeSafariBrowser] instance.
  ///
  ///- [url]: The [url] to load. Call [encodeUriComponent()] on this if the [url] contains Unicode characters.
  ///
  ///- [options]: Options for the [ChromeSafariBrowser].
  ///
  ///- [headersFallback]: The additional header of the [InAppBrowser] instance fallback to be used in the HTTP request for this URL, specified as a map from name to value.
  ///
  ///- [optionsFallback]: Options used by the [InAppBrowser] instance fallback.
  ///
  ///**Android** supports these options:
  ///
  ///- __addShareButton__: Set to `false` if you don't want the default share button. The default value is `true`.
  ///- __showTitle__: Set to `false` if the title shouldn't be shown in the custom tab. The default value is `true`.
  ///- __toolbarBackgroundColor__: Set the custom background color of the toolbar.
  ///- __enableUrlBarHiding__: Set to `true` to enable the url bar to hide as the user scrolls down on the page. The default value is `false`.
  ///- __instantAppsEnabled__: Set to `true` to enable Instant Apps. The default value is `false`.
  ///
  ///**iOS** supports these options:
  ///
  ///- __entersReaderIfAvailable__: Set to `true` if Reader mode should be entered automatically when it is available for the webpage. The default value is `false`.
  ///- __barCollapsingEnabled__: Set to `true` to enable bar collapsing. The default value is `false`.
  ///- __dismissButtonStyle__: Set the custom style for the dismiss button. The default value is `0 //done`. See [SFSafariViewController.DismissButtonStyle](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller/dismissbuttonstyle) for all the available styles.
  ///- __preferredBarTintColor__: Set the custom background color of the navigation bar and the toolbar.
  ///- __preferredControlTintColor__: Set the custom color of the control buttons on the navigation bar and the toolbar.
  ///- __presentationStyle__: Set the custom modal presentation style when presenting the WebView. The default value is `0 //fullscreen`. See [UIModalPresentationStyle](https://developer.apple.com/documentation/uikit/uimodalpresentationstyle) for all the available styles.
  ///- __transitionStyle__: Set to the custom transition style when presenting the WebView. The default value is `0 //crossDissolve`. See [UIModalTransitionStyle](https://developer.apple.com/documentation/uikit/uimodaltransitionStyle) for all the available styles.
  Future<void> open(String url, {Map<String, dynamic> options = const {}, Map<String, String> headersFallback = const {}, Map<String, dynamic> optionsFallback = const {}}) async {
    assert(url != null && url.isNotEmpty);
    this._throwIsAlreadyOpened(message: 'Cannot open $url!');
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('uuidFallback', () => (browserFallback != null) ? browserFallback.uuid : '');
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('headers', () => headersFallback);
    args.putIfAbsent('options', () => options);
    args.putIfAbsent('optionsFallback', () => optionsFallback);
    args.putIfAbsent('isData', () => false);
    args.putIfAbsent('useChromeSafariBrowser', () => true);
    await _ChannelManager.channel.invokeMethod('open', args);
    this._isOpened = true;
  }

  ///Event fires when the [ChromeSafariBrowser] is opened.
  void onOpened() {

  }

  ///Event fires when the [ChromeSafariBrowser] is loaded.
  void onLoaded() {

  }

  ///Event fires when the [ChromeSafariBrowser] is closed.
  void onClosed() {

  }

  bool isOpened() {
    return this._isOpened;
  }

  void _throwIsAlreadyOpened({String message = ''}) {
    if (this.isOpened()) {
      throw Exception(['Error: ${ (message.isEmpty) ? '' : message + ' '}The browser is already opened.']);
    }
  }

  void _throwIsNotOpened({String message = ''}) {
    if (!this.isOpened()) {
      throw Exception(['Error: ${ (message.isEmpty) ? '' : message + ' '}The browser is not opened.']);
    }
  }
}

typedef onWebViewCreatedCallback = void Function(InAppWebViewController controller);
typedef onWebViewLoadStartCallback = void Function(InAppWebViewController controller, String url);
typedef onWebViewLoadStopCallback = void Function(InAppWebViewController controller, String url);
typedef onWebViewLoadErrorCallback = void Function(InAppWebViewController controller, String url, int code, String message);
typedef onWebViewProgressChangedCallback = void Function(InAppWebViewController controller, int progress);
typedef onWebViewConsoleMessageCallback = void Function(InAppWebViewController controller, ConsoleMessage consoleMessage);
typedef shouldOverrideUrlLoadingCallback = void Function(InAppWebViewController controller, String url);
typedef onWebViewLoadResourceCallback = void Function(InAppWebViewController controller, WebResourceResponse response, WebResourceRequest request);
typedef onWebViewScrollChangedCallback = void Function(InAppWebViewController controller, int x, int y);

///Initial [data] as a content for an [InAppWebView] instance, using [baseUrl] as the base URL for it.
///The [mimeType] property specifies the format of the data.
///The [encoding] property specifies the encoding of the data.
class InAppWebViewInitialData {
  String data;
  String mimeType;
  String encoding;
  String baseUrl;

  InAppWebViewInitialData(this.data, {this.mimeType = "text/html", this.encoding = "utf8", this.baseUrl = "about:blank"});

  Map<String, String> toMap() {
    return {
      "data": data,
      "mimeType": mimeType,
      "encoding": encoding,
      "baseUrl": baseUrl
    };
  }
}

///InAppWebView Widget class.
///
///Flutter Widget for adding an **inline native WebView** integrated in the flutter widget tree.
///
///All platforms support these options:
///  - __useShouldOverrideUrlLoading__: Set to `true` to be able to listen at the [InAppWebView.shouldOverrideUrlLoading()] event. The default value is `false`.
///  - __useOnLoadResource__: Set to `true` to be able to listen at the [InAppWebView.onLoadResource()] event. The default value is `false`.
///  - __clearCache__: Set to `true` to have all the browser's cache cleared before the new window is opened. The default value is `false`.
///  - __userAgent___: Set the custom WebView's user-agent.
///  - __javaScriptEnabled__: Set to `true` to enable JavaScript. The default value is `true`.
///  - __javaScriptCanOpenWindowsAutomatically__: Set to `true` to allow JavaScript open windows without user interaction. The default value is `false`.
///  - __mediaPlaybackRequiresUserGesture__: Set to `true` to prevent HTML5 audio or video from autoplaying. The default value is `true`.
///  - __transparentBackground__: Set to `true` to make the background of the WebView transparent. If your app has a dark theme, this can prevent a white flash on initialization. The default value is `false`.
///
///  **Android** supports these additional options:
///
///  - __clearSessionCache__: Set to `true` to have the session cookie cache cleared before the new window is opened.
///  - __builtInZoomControls__: Set to `true` if the WebView should use its built-in zoom mechanisms. The default value is `false`.
///  - __displayZoomControls__: Set to `true` if the WebView should display on-screen zoom controls when using the built-in zoom mechanisms. The default value is `false`.
///  - __supportZoom__: Set to `false` if the WebView should not support zooming using its on-screen zoom controls and gestures. The default value is `true`.
///  - __databaseEnabled__: Set to `true` if you want the database storage API is enabled. The default value is `false`.
///  - __domStorageEnabled__: Set to `true` if you want the DOM storage API is enabled. The default value is `false`.
///  - __useWideViewPort__: Set to `true` if the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport. When the value of the setting is false, the layout width is always set to the width of the WebView control in device-independent (CSS) pixels. When the value is true and the page contains the viewport meta tag, the value of the width specified in the tag is used. If the page does not contain the tag or does not provide a width, then a wide viewport will be used. The default value is `true`.
///  - __safeBrowsingEnabled__: Set to `true` if you want the Safe Browsing is enabled. Safe Browsing allows WebView to protect against malware and phishing attacks by verifying the links. The default value is `true`.
///  - __textZoom__: Set text scaling of the WebView. The default value is `100`.
///  - __mixedContentMode__: Configures the WebView's behavior when a secure origin attempts to load a resource from an insecure origin. By default, apps that target `Build.VERSION_CODES.KITKAT` or below default to `MIXED_CONTENT_ALWAYS_ALLOW`. Apps targeting `Build.VERSION_CODES.LOLLIPOP` default to `MIXED_CONTENT_NEVER_ALLOW`. The preferred and most secure mode of operation for the WebView is `MIXED_CONTENT_NEVER_ALLOW` and use of `MIXED_CONTENT_ALWAYS_ALLOW` is strongly discouraged.
///
///  **iOS** supports these additional options:
///
///  - __disallowOverScroll__: Set to `true` to disable the bouncing of the WebView when the scrolling has reached an edge of the content. The default value is `false`.
///  - __enableViewportScale__: Set to `true` to allow a viewport meta tag to either disable or restrict the range of user scaling. The default value is `false`.
///  - __suppressesIncrementalRendering__: Set to `true` if you want the WebView suppresses content rendering until it is fully loaded into memory.. The default value is `false`.
///  - __allowsAirPlayForMediaPlayback__: Set to `true` to allow AirPlay. The default value is `true`.
///  - __allowsBackForwardNavigationGestures__: Set to `true` to allow the horizontal swipe gestures trigger back-forward list navigations. The default value is `true`.
///  - __allowsLinkPreview__: Set to `true` to allow that pressing on a link displays a preview of the destination for the link. The default value is `true`.
///  - __ignoresViewportScaleLimits__: Set to `true` if you want that the WebView should always allow scaling of the webpage, regardless of the author's intent. The ignoresViewportScaleLimits property overrides the `user-scalable` HTML property in a webpage. The default value is `false`.
///  - __allowsInlineMediaPlayback__: Set to `true` to allow HTML5 media playback to appear inline within the screen layout, using browser-supplied controls rather than native controls. For this to work, add the `webkit-playsinline` attribute to any `<video>` elements. The default value is `false`.
///  - __allowsPictureInPictureMediaPlayback__: Set to `true` to allow HTML5 videos play picture-in-picture. The default value is `true`.
class InAppWebView extends StatefulWidget {

  ///Event fires when the [InAppWebView] is created.
  final onWebViewCreatedCallback onWebViewCreated;

  ///Event fires when the [InAppWebView] starts to load an [url].
  final onWebViewLoadStartCallback onLoadStart;

  ///Event fires when the [InAppWebView] finishes loading an [url].
  final onWebViewLoadStopCallback onLoadStop;

  ///Event fires when the [InAppWebView] encounters an error loading an [url].
  final onWebViewLoadErrorCallback onLoadError;

  ///Event fires when the current [progress] of loading a page is changed.
  final onWebViewProgressChangedCallback onProgressChanged;

  ///Event fires when the [InAppWebView] receives a [ConsoleMessage].
  final onWebViewConsoleMessageCallback onConsoleMessage;

  ///Give the host application a chance to take control when a URL is about to be loaded in the current WebView.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set `useShouldOverrideUrlLoading` option to `true`.
  final shouldOverrideUrlLoadingCallback shouldOverrideUrlLoading;

  ///Event fires when the [InAppWebView] loads a resource.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set `useOnLoadResource` option to `true`.
  ///
  ///**NOTE only for iOS**: In some cases, the [response.data] of a [response] with `text/assets` encoding could be empty.
  final onWebViewLoadResourceCallback onLoadResource;

  ///Event fires when the [InAppWebView] scrolls.
  ///[x] represents the current horizontal scroll origin in pixels.
  ///[y] represents the current vertical scroll origin in pixels.
  final onWebViewScrollChangedCallback onScrollChanged;

  ///Initial url that will be loaded.
  final String initialUrl;
  ///Initial asset file that will be loaded. See [InAppWebView.loadFile()] for explanation.
  final String initialFile;
  ///Initial [InAppWebViewInitialData] that will be loaded.
  final InAppWebViewInitialData initialData;
  ///Initial headers that will be used.
  final Map<String, String> initialHeaders;
  ///Initial options that will be used.
  final Map<String, dynamic> initialOptions;
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
    this.initialOptions = const {},
    this.onWebViewCreated,
    this.onLoadStart,
    this.onLoadStop,
    this.onLoadError,
    this.onConsoleMessage,
    this.onProgressChanged,
    this.shouldOverrideUrlLoading,
    this.onLoadResource,
    this.onScrollChanged,
    this.gestureRecognizers,
  }) : super(key: key);

  @override
  _InAppWebViewState createState() => _InAppWebViewState();
}

class _InAppWebViewState extends State<InAppWebView> {

  InAppWebViewController _controller;

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) {
      _controller._dispose();
      _controller = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return GestureDetector(
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
              'initialOptions': widget.initialOptions
            },
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
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
          'initialOptions': widget.initialOptions
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
  bool _isOpened = false;
  // ignore: unused_field
  int _id;
  String _inAppBrowserUuid;
  InAppBrowser _inAppBrowser;


  InAppWebViewController(int id, InAppWebView widget) {
    _id = id;
    _channel = MethodChannel('com.pichillilorenzo/flutter_inappwebview_$id');
    _channel.setMethodCallHandler(_handleMethod);
    _widget = widget;
  }

  InAppWebViewController.fromInAppBrowser(String uuid, MethodChannel channel, InAppBrowser inAppBrowser) {
    _inAppBrowserUuid = uuid;
    _channel = channel;
    _inAppBrowser = inAppBrowser;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
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
      case "onLoadResource":
        Map<dynamic, dynamic> rawResponse = call.arguments["response"];
        rawResponse = rawResponse.cast<String, dynamic>();
        Map<dynamic, dynamic> rawRequest = call.arguments["request"];
        rawRequest = rawRequest.cast<String, dynamic>();

        String urlResponse = rawResponse["url"];
        Map<dynamic, dynamic> headersResponse = rawResponse["headers"];
        headersResponse = headersResponse.cast<String, String>();
        int statusCode = rawResponse["statusCode"];
        int startTime = rawResponse["startTime"];
        int duration = rawResponse["duration"];
        Uint8List data = rawResponse["data"];

        String urlRequest = rawRequest["url"];
        Map<dynamic, dynamic> headersRequest = rawRequest["headers"];
        headersRequest = headersResponse.cast<String, String>();
        String method = rawRequest["method"];

        var response = new WebResourceResponse(urlResponse, headersResponse, statusCode, startTime, duration, data);
        var request = new WebResourceRequest(urlRequest, headersRequest, method);

        if (_widget != null && _widget.onLoadResource != null)
          _widget.onLoadResource(this, response, request);
        else if (_inAppBrowser != null)
          _inAppBrowser.onLoadResource(response, request);
        break;
      case "onConsoleMessage":
        String sourceURL = call.arguments["sourceURL"];
        int lineNumber = call.arguments["lineNumber"];
        String message = call.arguments["message"];
        ConsoleMessageLevel messageLevel;
        ConsoleMessageLevel.values.forEach((element) {
          if ("ConsoleMessageLevel." + call.arguments["messageLevel"] == element.toString()) {
            messageLevel = element;
            return;
          }
        });
        if (_widget != null && _widget.onConsoleMessage != null)
          _widget.onConsoleMessage(this, ConsoleMessage(sourceURL, lineNumber, message, messageLevel));
        else if (_inAppBrowser != null)
          _inAppBrowser.onConsoleMessage(ConsoleMessage(sourceURL, lineNumber, message, messageLevel));
        break;
      case "onScrollChanged":
        int x = call.arguments["x"];
        int y = call.arguments["y"];
        if (_widget != null && _widget.onScrollChanged != null)
          _widget.onScrollChanged(this, x, y);
        else if (_inAppBrowser != null)
          _inAppBrowser.onScrollChanged(x, y);
        break;
      case "onCallJsHandler":
        String handlerName = call.arguments["handlerName"];
        // decode args to json
        List<dynamic> args = jsonDecode(call.arguments["args"]);
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
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('getUrl', args);
  }

  ///Gets the title for the current page.
  Future<String> getTitle() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('getTitle', args);
  }

  ///Gets the progress for the current page. The progress value is between 0 and 100.
  Future<int> getProgress() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('getProgress', args);
  }

  ///Gets the favicon for the current page.
  Future<List<int>> getFavicon() async {
    var completer = new Completer<List<int>>();
    var faviconData = new List<int>();
    HttpClient client = new HttpClient();
    var url = Uri.parse(await getUrl());
    // solution found here: https://stackoverflow.com/a/15750809/4637638
    var faviconUrl = Uri.parse("https://plus.google.com/_/favicon?domain_url=" + url.scheme + "://" + url.host);

    client.getUrl(faviconUrl).then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) {
      response.listen((List<int> data) {
        faviconData = data;
      }, onDone: () => completer.complete(faviconData));
    });

    return completer.future;
  }

  ///Loads the given [url] with optional [headers] specified as a map from name to value.
  Future<void> loadUrl(String url, {Map<String, String> headers = const {}}) async {
    assert(url != null && url.isNotEmpty);
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened(message: 'Cannot laod $url!');
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('headers', () => headers);
    await _channel.invokeMethod('loadUrl', args);
  }

  ///Loads the given [url] with [postData] using `POST` method into this WebView.
  Future<void> postUrl(String url, Uint8List postData) async {
    assert(url != null && url.isNotEmpty);
    assert(postData != null);
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened(message: 'Cannot laod $url!');
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('postData', () => postData);
    await _channel.invokeMethod('postUrl', args);
  }

  ///Loads the given [data] into this WebView, using [baseUrl] as the base URL for the content.
  ///The [mimeType] parameter specifies the format of the data.
  ///The [encoding] parameter specifies the encoding of the data.
  Future<void> loadData(String data, {String mimeType = "text/html", String encoding = "utf8", String baseUrl = "about:blank"}) async {
    assert(data != null);
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
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
  Future<void> loadFile(String assetFilePath, {Map<String, String> headers = const {}}) async {
    assert(assetFilePath != null && assetFilePath.isNotEmpty);
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened(message: 'Cannot laod $assetFilePath!');
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('url', () => assetFilePath);
    args.putIfAbsent('headers', () => headers);
    await _channel.invokeMethod('loadFile', args);
  }

  ///Reloads the [InAppWebView] window.
  Future<void> reload() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('reload', args);
  }

  ///Goes back in the history of the [InAppWebView] window.
  Future<void> goBack() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('goBack', args);
  }

  ///Returns a boolean value indicating whether the [InAppWebView] can move backward.
  Future<bool> canGoBack() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('canGoBack', args);
  }

  ///Goes forward in the history of the [InAppWebView] window.
  Future<void> goForward() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('goForward', args);
  }

  ///Returns a boolean value indicating whether the [InAppWebView] can move forward.
  Future<bool> canGoForward() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('canGoForward', args);
  }

  ///Goes to the history item that is the number of steps away from the current item. Steps is negative if backward and positive if forward.
  Future<void> goBackOrForward(int steps) async {
    assert(steps != null);

    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('steps', () => steps);
    await _channel.invokeMethod('goBackOrForward', args);
  }

  ///Returns a boolean value indicating whether the [InAppWebView] can go back or forward the given number of steps. Steps is negative if backward and positive if forward.
  Future<bool> canGoBackOrForward(int steps) async {
    assert(steps != null);

    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('steps', () => steps);
    return await _channel.invokeMethod('canGoBackOrForward', args);
  }

  ///Navigates to a [WebHistoryItem] from the back-forward [WebHistory.list] and sets it as the current item.
  Future<void> goTo(WebHistoryItem historyItem) async {
    await goBackOrForward(historyItem.offset);
  }

  ///Check if the Web View of the [InAppWebView] instance is in a loading state.
  Future<bool> isLoading() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('isLoading', args);
  }

  ///Stops the Web View of the [InAppWebView] instance from loading.
  Future<void> stopLoading() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('stopLoading', args);
  }

  ///Injects JavaScript code into the [InAppWebView] window and returns the result of the evaluation.
  Future<String> injectScriptCode(String source) async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('source', () => source);
    return await _channel.invokeMethod('injectScriptCode', args);
  }

  ///Injects a JavaScript file into the [InAppWebView] window.
  Future<void> injectScriptFile(String urlFile) async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('urlFile', () => urlFile);
    await _channel.invokeMethod('injectScriptFile', args);
  }

  ///Injects CSS into the [InAppWebView] window.
  Future<void> injectStyleCode(String source) async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('source', () => source);
    await _channel.invokeMethod('injectStyleCode', args);
  }

  ///Injects a CSS file into the [InAppWebView] window.
  Future<void> injectStyleFile(String urlFile) async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('urlFile', () => urlFile);
    await _channel.invokeMethod('injectStyleFile', args);
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
  ///This event will be dispatch as soon as the platform (Android or iOS) is ready to handle the `callHandler` method.
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
  ///       console.log(result, typeof result);
  ///       console.log(JSON.stringify(result));
  ///     });
  ///
  ///     window.flutter_inappbrowser.callHandler('handlerFooWithArgs', 1, true, ['bar', 5], {foo: 'baz'}).then(function(result) {
  ///       console.log(result, typeof result);
  ///       console.log(JSON.stringify(result));
  ///     });
  ///   });
  ///</script>
  ///```
  ///
  ///Instead, on the `onLoadStop` WebView event, you can use `callHandler` directly:
  ///```dart
  ///  // Inject JavaScript that will receive data back from Flutter
  ///  inAppWebViewController.injectScriptCode("""
  ///    window.flutter_inappbrowser.callHandler('test', 'Text from Javascript').then(function(result) {
  ///      console.log(result);
  ///    });
  ///  """);
  ///```
  void addJavaScriptHandler(String handlerName, JavaScriptHandlerCallback callback) {
    this.javaScriptHandlersMap[handlerName] = (callback);
  }

  ///Removes a JavaScript message handler previously added with the [addJavaScriptHandler()] associated to [handlerName] key.
  ///Returns the value associated with [handlerName] before it was removed.
  ///Returns `null` if [handlerName] was not found.
  JavaScriptHandlerCallback removeJavaScriptHandler(String handlerName) {
    return this.javaScriptHandlersMap.remove(handlerName);
  }

  ///Takes a screenshot (in PNG format) of the WebView's visible viewport and returns a `Uint8List`. Returns `null` if it wasn't be able to take it.
  ///__safeBrowsingEnabled__
  ///**NOTE for iOS**: available from iOS 11.0+.
  Future<Uint8List> takeScreenshot() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('takeScreenshot', args);
  }

  ///Sets the [InAppWebView] options with the new [options] and evaluates them.
  Future<void> setOptions(Map<String, dynamic> options) async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('options', () => options);
    args.putIfAbsent('optionsType', () => "InAppBrowserOptions");
    await _channel.invokeMethod('setOptions', args);
  }

  ///Gets the current [InAppWebView] options. Returns `null` if the options are not setted yet.
  Future<Map<String, dynamic>> getOptions() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('optionsType', () => "InAppBrowserOptions");
    Map<dynamic, dynamic> options = await _ChannelManager.channel.invokeMethod('getOptions', args);
    options = options.cast<String, dynamic>();
    return options;
  }

  ///Gets the WebHistory for this WebView. This contains the back/forward list for use in querying each item in the history stack.
  ///This contains only a snapshot of the current state.
  ///Multiple calls to this method may return different objects.
  ///The object returned from this method will not be updated to reflect any new state.
  Future<WebHistory> getCopyBackForwardList() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser._throwIsNotOpened();
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
      historyList.add(WebHistoryItem(historyItem["originalUrl"], historyItem["title"], historyItem["url"], i, i - currentIndex));
    }
    return WebHistory(historyList, currentIndex);
  }
  ///Dispose/Destroy the WebView.
  Future<void> _dispose() async {
    await _channel.invokeMethod('dispose');
  }

}

///WebHistory class.
///
///This class contains a snapshot of the current back/forward list for a WebView.
class WebHistory {
  List<WebHistoryItem> _list;
  ///List of all [WebHistoryItem]s.
  List<WebHistoryItem> get list => _list;
  ///Index of the current [WebHistoryItem].
  int currentIndex;

  WebHistory(this._list, this.currentIndex);
}

///WebHistoryItem class.
///
///A convenience class for accessing fields in an entry in the back/forward list of a WebView. Each WebHistoryItem is a snapshot of the requested history item.
class WebHistoryItem {
  ///Original url of this history item.
  String originalUrl;
  ///Document title of this history item.
  String title;
  ///Url of this history item.
  String url;
  ///0-based position index in the back-forward [WebHistory.list].
  int index;
  ///Position offset respect to the currentIndex of the back-forward [WebHistory.list].
  int offset;

  WebHistoryItem(this.originalUrl, this.title, this.url, this.index, this.offset);
}

///InAppLocalhostServer class.
///
///This class allows you to create a simple server on `http://localhost:[port]/` in order to be able to load your assets file on a server. The default [port] value is `8080`.
class InAppLocalhostServer {

  HttpServer _server;
  int _port = 8080;

  InAppLocalhostServer({int port = 8080}) {
    this._port = port;
  }

  ///Starts a server on http://localhost:[port]/.
  ///
  ///**NOTE for iOS**: For the iOS Platform, you need to add the `NSAllowsLocalNetworking` key with `true` in the `Info.plist` file (See [ATS Configuration Basics](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW35)):
  ///```xml
  ///<key>NSAppTransportSecurity</key>
  ///<dict>
  ///    <key>NSAllowsLocalNetworking</key>
  ///    <true/>
  ///</dict>
  ///```
  ///The `NSAllowsLocalNetworking` key is available since **iOS 10**.
  Future<void> start() async {

    if (this._server != null) {
      throw Exception('Server already started on http://localhost:$_port');
    }

    var completer = new Completer();

    runZoned(() {
      HttpServer.bind('127.0.0.1', _port).then((server) {
        print('Server running on http://localhost:' + _port.toString());

        this._server = server;

        server.listen((HttpRequest request) async {
          var body = List<int>();
          var path = request.requestedUri.path;
          path = (path.startsWith('/')) ? path.substring(1) : path;
          path += (path.endsWith('/')) ? 'index.html' : '';

          try {
            body = (await rootBundle.load(path))
                .buffer.asUint8List();
          } catch (e) {
            print(e.toString());
            request.response.close();
            return;
          }

          var contentType = ['text', 'html'];
          if (!request.requestedUri.path.endsWith('/') && request.requestedUri.pathSegments.isNotEmpty) {
            var mimeType = lookupMimeType(request.requestedUri.path, headerBytes: body);
            if (mimeType != null) {
              contentType = mimeType.split('/');
            }
          }

          request.response.headers.contentType = new ContentType(contentType[0], contentType[1], charset: 'utf-8');
          request.response.add(body);
          request.response.close();
        });

        completer.complete();
      });
    }, onError: (e, stackTrace) => print('Error: $e $stackTrace'));

    return completer.future;
  }

  ///Closes the server.
  Future<void> close() async {
    if (this._server != null) {
      await this._server.close(force: true);
      print('Server running on http://localhost:$_port closed');
      this._server = null;
    }
  }

}

///Manages the cookies used by WebView instances.
///
///**NOTE for iOS**: available from iOS 11.0+.
class CookieManager {
  static bool _initialized = false;
  static const MethodChannel _channel = const MethodChannel('com.pichillilorenzo/flutter_inappbrowser_cookiemanager');

  static void _init () {
    _channel.setMethodCallHandler(_handleMethod);
    _initialized = true;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
  }

  ///Sets a cookie for the given [url]. Any existing cookie with the same [host], [path] and [name] will be replaced with the new cookie. The cookie being set will be ignored if it is expired.
  ///
  ///The default value of [path] is `"/"`.
  ///If [domain] is `null`, its default value will be the domain name of [url].
  static Future<void> setCookie(String url, String name, String value,
      { String domain,
        String path = "/",
        int expiresDate,
        int maxAge,
        bool isSecure }) async {
    if (!_initialized)
      _init();

    if (domain == null)
      domain = _getDomainName(url);

    assert(url != null && url.isNotEmpty);
    assert(name != null && name.isNotEmpty);
    assert(value != null && value.isNotEmpty);
    assert(domain != null && domain.isNotEmpty);
    assert(path != null && path.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('name', () => name);
    args.putIfAbsent('value', () => value);
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    args.putIfAbsent('expiresDate', () => expiresDate?.toString());
    args.putIfAbsent('maxAge', () => maxAge);
    args.putIfAbsent('isSecure', () => isSecure);

    await _channel.invokeMethod('setCookie', args);
  }

  ///Gets all the cookies for the given [url].
  static Future<List<Map<String, dynamic>>> getCookies(String url) async {
    if (!_initialized)
      _init();

    assert(url != null && url.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    List<dynamic> cookies = await _channel.invokeMethod('getCookies', args);
    cookies = cookies.cast<Map<dynamic, dynamic>>();
    for(var i = 0; i < cookies.length; i++) {
      cookies[i] = cookies[i].cast<String, dynamic>();
    }
    cookies = cookies.cast<Map<String, dynamic>>();
    return cookies;
  }

  ///Gets a cookie by its [name] for the given [url].
  static Future<Map<String, dynamic>> getCookie(String url, String name) async {
    if (!_initialized)
      _init();

    assert(url != null && url.isNotEmpty);
    assert(name != null && name.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    List<dynamic> cookies = await _channel.invokeMethod('getCookies', args);
    cookies = cookies.cast<Map<dynamic, dynamic>>();
    for(var i = 0; i < cookies.length; i++) {
      cookies[i] = cookies[i].cast<String, dynamic>();
      if (cookies[i]["name"] == name)
        return cookies[i];
    }
    return null;
  }

  ///Removes a cookie by its [name] for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///If [domain] is `null` or empty, its default value will be the domain name of [url].
  static Future<void> deleteCookie(String url, String name, {String domain = "", String path = "/"}) async {
    if (!_initialized)
      _init();

    if (domain == null || domain.isEmpty)
      domain = _getDomainName(url);

    assert(url != null && url.isNotEmpty);
    assert(name != null && name.isNotEmpty);
    assert(domain != null && url.isNotEmpty);
    assert(path != null && url.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('name', () => name);
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    await _channel.invokeMethod('deleteCookie', args);
  }

  ///Removes all cookies for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///If [domain] is `null` or empty, its default value will be the domain name of [url].
  static Future<void> deleteCookies(String url, {String domain = "", String path = "/"}) async {
    if (!_initialized)
      _init();

    if (domain == null || domain.isEmpty)
      domain = _getDomainName(url);

    assert(url != null && url.isNotEmpty);
    assert(domain != null && url.isNotEmpty);
    assert(path != null && url.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    await _channel.invokeMethod('deleteCookies', args);
  }

  ///Removes all cookies.
  static Future<void> deleteAllCookies() async {
    if (!_initialized)
      _init();

    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('deleteAllCookies', args);
  }

  static String _getDomainName(String url) {
    Uri uri = Uri.parse(url);
    String domain = uri.host;
    if (domain == null)
      return "";
    return domain.startsWith("www.") ? domain.substring(4) : domain;
  }
}
