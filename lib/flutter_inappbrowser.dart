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

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';

typedef Future<dynamic> ListenerCallback(MethodCall call);
typedef Future<void> JavaScriptHandlerCallback(List<dynamic> arguments);

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
  static final initialized = false;
  static final listeners = HashMap<String, ListenerCallback>();

  static Future<dynamic> _handleMethod(MethodCall call) async {
    String uuid = call.arguments["uuid"];
    return await listeners[uuid](call);
  }

  static void addListener (String key, ListenerCallback callback) {
    if (!initialized)
      init();
    listeners.putIfAbsent(key, () => callback);
  }

  static void init () {
    channel.setMethodCallHandler(_handleMethod);
  }
}

///InAppBrowser class.
///
///This class uses the native WebView of the platform.
class InAppBrowser {

  String uuid;
  Map<String, List<JavaScriptHandlerCallback>> javaScriptHandlersMap = HashMap<String, List<JavaScriptHandlerCallback>>();
  HttpServer _server;
  bool _isOpened = false;

  ///
  InAppBrowser () {
    uuid = _uuidGenerator.v4();
    _ChannelManager.addListener(uuid, _handleMethod);
    _isOpened = false;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {
      case "onLoadStart":
        String url = call.arguments["url"];
        onLoadStart(url);
        break;
      case "onLoadStop":
        String url = call.arguments["url"];
        onLoadStop(url);
        break;
      case "onLoadError":
        String url = call.arguments["url"];
        int code = call.arguments["code"];
        String message = call.arguments["message"];
        onLoadError(url, code, message);
        break;
      case "onExit":
        this._closeServer();
        this._isOpened = false;
        onExit();
        break;
      case "shouldOverrideUrlLoading":
        String url = call.arguments["url"];
        shouldOverrideUrlLoading(url);
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

        onLoadResource(response, request);
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
        onConsoleMessage(ConsoleMessage(sourceURL, lineNumber, message, messageLevel));
        break;
      case "onCallJsHandler":
        String handlerName = call.arguments["handlerName"];
        List<dynamic> args = jsonDecode(call.arguments["args"]);
        if (javaScriptHandlersMap.containsKey(handlerName)) {
          for (var handler in javaScriptHandlersMap[handlerName]) {
            handler(args);
          }
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
  }

  ///Opens an [url] in a new [InAppBrowser] instance or in the system browser (`openWithSystemBrowser: true`).
  ///
  ///**NOTE**: If you open the given [url] with the system browser (`openWithSystemBrowser: true`), you wont be able to use the [InAppBrowser] methods!
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
  ///    - __openWithSystemBrowser__: Set to `true` to open the given `url` with the system browser. The default value is `false`.
  ///    - __isLocalFile__: Set to `true` if the [url] is pointing to a local file (the file must be addded in the `assets` section of your `pubspec.yaml`. See [loadFile()] explanation). The default value is `false`.
  ///    - __clearCache__: Set to `true` to have all the browser's cache cleared before the new window is opened. The default value is `false`.
  ///    - __userAgent___: Set the custom WebView's user-agent.
  ///    - __javaScriptEnabled__: Set to `true` to enable JavaScript. The default value is `true`.
  ///    - __javaScriptCanOpenWindowsAutomatically__: Set to `true` to allow JavaScript open windows without user interaction. The default value is `false`.
  ///    - __hidden__: Set to `true` to create the browser and load the page, but not show it. The `onLoadStop` event fires when loading is complete. Omit or set to `false` (default) to have the browser open and load normally.
  ///    - __toolbarTop__: Set to `false` to hide the toolbar at the top of the WebView. The default value is `true`.
  ///    - __toolbarTopBackgroundColor__: Set the custom background color of the toolbat at the top.
  ///    - __hideUrlBar__: Set to `true` to hide the url bar on the toolbar at the top. The default value is `false`.
  ///    - __mediaPlaybackRequiresUserGesture__: Set to `true` to prevent HTML5 audio or video from autoplaying. The default value is `true`.
  ///
  ///  - **Android** supports these additional options:
  ///
  ///    - __hideTitleBar__: Set to `true` if you want the title should be displayed. The default value is `false`.
  ///    - __closeOnCannotGoBack__: Set to `false` to not close the InAppBrowser when the user click on the back button and the WebView cannot go back to the history. The default value is `true`.
  ///    - __clearSessionCache__: Set to `true` to have the session cookie cache cleared before the new window is opened.
  ///    - __builtInZoomControls__: Set to `true` if the WebView should use its built-in zoom mechanisms. The default value is `false`.
  ///    - __supportZoom__: Set to `false` if the WebView should not support zooming using its on-screen zoom controls and gestures. The default value is `true`.
  ///    - __databaseEnabled__: Set to `true` if you want the database storage API is enabled. The default value is `false`.
  ///    - __domStorageEnabled__: Set to `true` if you want the DOM storage API is enabled. The default value is `false`.
  ///    - __useWideViewPort__: Set to `true` if the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport. When the value of the setting is false, the layout width is always set to the width of the WebView control in device-independent (CSS) pixels. When the value is true and the page contains the viewport meta tag, the value of the width specified in the tag is used. If the page does not contain the tag or does not provide a width, then a wide viewport will be used. The default value is `true`.
  ///    - __safeBrowsingEnabled__: Set to `true` if you want the Safe Browsing is enabled. Safe Browsing allows WebView to protect against malware and phishing attacks by verifying the links. The default value is `true`.
  ///    - __progressBar__: Set to `false` to hide the progress bar at the bottom of the toolbar at the top. The default value is `true`.
  ///
  ///  - **iOS** supports these additional options:
  ///
  ///    - __disallowOverScroll__: Set to `true` to disable the bouncing of the WebView when the scrolling has reached an edge of the content. The default value is `false`.
  ///    - __toolbarBottom__: Set to `false` to hide the toolbar at the bottom of the WebView. The default value is `true`.
  ///    - __toolbarBottomBackgroundColor__: Set the custom background color of the toolbat at the bottom.
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
    this._throwIsAlreadyOpened(message: 'Cannot open $url!');
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('headers', () => headers);
    args.putIfAbsent('options', () => options);
    args.putIfAbsent('useChromeSafariBrowser', () => false);
    await _ChannelManager.channel.invokeMethod('open', args);
    this._isOpened = true;
  }

  ///This is a static method that opens an [url] in the system browser.
  ///This has the same behaviour of an [InAppBrowser] instance calling the [open()] method with option `openWithSystemBrowser: true`.
  static Future<void> openWithSystemBrowser(String url) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => "");
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('headers', () => {});
    args.putIfAbsent('options', () => {"openWithSystemBrowser": true});
    args.putIfAbsent('useChromeSafariBrowser', () => false);
    return await _ChannelManager.channel.invokeMethod('open', args);
  }

  Future<void> _startServer({int port = 8080}) async {

    this._closeServer();
    var completer = new Completer();

    runZoned(() {
      HttpServer.bind('127.0.0.1', port).then((server) {
        print('Server running at http://127.0.0.1:' + port.toString());

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

  Future<void> _closeServer() async {
    if (this._server != null) {
      final port = this._server.port;
      await this._server.close(force: true);
      print('Server running at http://127.0.0.1:$port closed');
      this._server = null;
    }
  }

  ///Serve the [assetFilePath] from Flutter assets on http://localhost:[port]/. It is similar to [InAppBrowser.open()] with option `isLocalFile: true`, but it starts a server.
  ///
  ///**NOTE for iOS**: For the iOS Platform, you need to add the `NSAllowsLocalNetworking` key with `true` in the `Info.plist` file (See [ATS Configuration Basics](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW35):
  ///```xml
  ///<key>NSAppTransportSecurity</key>
  ///<dict>
  ///    <key>NSAllowsLocalNetworking</key>
  ///    <true/>
  ///</dict>
  ///```
  ///The `NSAllowsLocalNetworking` key is available since **iOS 10**.
  Future<void> openOnLocalhost(String assetFilePath, {int port = 8080, Map<String, String> headers = const {}, Map<String, dynamic> options = const {}}) async {
    this._throwIsAlreadyOpened(message: 'Cannot open $assetFilePath!');
    await this._startServer(port: port);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('url', () => 'http://localhost:${this._server.port}/' + assetFilePath);
    args.putIfAbsent('headers', () => headers);
    options["isLocalFile"] = false;
    args.putIfAbsent('options', () => options);
    args.putIfAbsent('useChromeSafariBrowser', () => false);
    await _ChannelManager.channel.invokeMethod('open', args);
    this._isOpened = true;
  }

  ///Loads the given [url] with optional [headers] specified as a map from name to value.
  Future<void> loadUrl(String url, {Map<String, String> headers = const {}}) async {
    this._throwIsNotOpened(message: 'Cannot laod $url!');
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('headers', () => headers);
    await _ChannelManager.channel.invokeMethod('loadUrl', args);
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
    this._throwIsNotOpened(message: 'Cannot laod $assetFilePath!');
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('url', () => assetFilePath);
    args.putIfAbsent('headers', () => headers);
    await _ChannelManager.channel.invokeMethod('loadFile', args);
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

  ///Reloads the [InAppBrowser] window.
  Future<void> reload() async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    await _ChannelManager.channel.invokeMethod('reload', args);
  }

  ///Goes back in the history of the [InAppBrowser] window.
  Future<void> goBack() async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    await _ChannelManager.channel.invokeMethod('goBack', args);
  }

  ///Goes forward in the history of the [InAppBrowser] window.
  Future<void> goForward() async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    await _ChannelManager.channel.invokeMethod('goForward', args);
  }

  ///Check if the Web View of the [InAppBrowser] instance is in a loading state.
  Future<bool> isLoading() async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    return await _ChannelManager.channel.invokeMethod('isLoading', args);
  }

  ///Stops the Web View of the [InAppBrowser] instance from loading.
  Future<void> stopLoading() async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    await _ChannelManager.channel.invokeMethod('stopLoading', args);
  }

  ///Check if the Web View of the [InAppBrowser] instance is hidden.
  Future<bool> isHidden() async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    return await _ChannelManager.channel.invokeMethod('isHidden', args);
  }

  ///Injects JavaScript code into the [InAppBrowser] window and returns the result of the evaluation.
  Future<String> injectScriptCode(String source) async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('source', () => source);
    return await _ChannelManager.channel.invokeMethod('injectScriptCode', args);
  }

  ///Injects a JavaScript file into the [InAppBrowser] window.
  Future<void> injectScriptFile(String urlFile) async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('urlFile', () => urlFile);
    await _ChannelManager.channel.invokeMethod('injectScriptFile', args);
  }

  ///Injects CSS into the [InAppBrowser] window.
  Future<void> injectStyleCode(String source) async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('source', () => source);
    await _ChannelManager.channel.invokeMethod('injectStyleCode', args);
  }

  ///Injects a CSS file into the [InAppBrowser] window.
  Future<void> injectStyleFile(String urlFile) async {
    this._throwIsNotOpened();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('urlFile', () => urlFile);
    await _ChannelManager.channel.invokeMethod('injectStyleFile', args);
  }

  ///Adds/Appends a JavaScript message handler [callback] ([JavaScriptHandlerCallback]) that listen to post messages sent from JavaScript by the handler with name [handlerName].
  ///Returns the position `index` of the handler that can be used to remove it with the [removeJavaScriptHandler()] method.
  ///
  ///The Android implementation uses [addJavascriptInterface](https://developer.android.com/reference/android/webkit/WebView#addJavascriptInterface(java.lang.Object,%20java.lang.String)).
  ///The iOS implementation uses [addScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537172-addscriptmessagehandler?language=objc)
  ///
  ///The JavaScript function that can be used to call the handler is `window.flutter_inappbrowser.callHandler(handlerName <String>, ...args);`, where `args` are [rest parameters](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters).
  ///The `args` will be stringified automatically using `JSON.stringify(args)` method and then they will be decoded on the Dart side.
  int addJavaScriptHandler(String handlerName, JavaScriptHandlerCallback callback) {
    this.javaScriptHandlersMap.putIfAbsent(handlerName, () => List<JavaScriptHandlerCallback>());
    this.javaScriptHandlersMap[handlerName].add(callback);
    return this.javaScriptHandlersMap[handlerName].indexOf(callback);
  }

  ///Removes a JavaScript message handler previously added with the [addJavaScriptHandler()] method in the [handlerName] list by its position [index].
  ///Returns `true` if the callback is removed, otherwise `false`.
  bool removeJavaScriptHandler(String handlerName, int index) {
    try {
      this.javaScriptHandlersMap[handlerName].removeAt(index);
      return true;
    }
    on RangeError catch(e) {
      print(e);
    }
    return false;
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

  ///Event fires when the [InAppBrowser] window is closed.
  void onExit() {

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

  ///Event fires when the [InAppBrowser] webview receives a [ConsoleMessage].
  void onConsoleMessage(ConsoleMessage consoleMessage) {

  }

  ///Returns `true` if the browser is opened, otherwise `false`.
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

  ///Initialize the [ChromeSafariBrowser] instance with a [InAppBrowser] fallback instance or `null`.
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

  ///Opens an [url] in a new [ChromeSafariBrowser] instance or the system browser.
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
    this._throwIsAlreadyOpened(message: 'Cannot open $url!');
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('uuidFallback', () => (browserFallback != null) ? browserFallback.uuid : '');
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('headers', () => headersFallback);
    args.putIfAbsent('options', () => options);
    args.putIfAbsent('optionsFallback', () => optionsFallback);
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