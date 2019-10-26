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

import 'types.dart';
import 'in_app_browser.dart';
import 'channel_manager.dart';
import 'webview_options.dart';


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
///  - __useOnDownloadStart__: Set to `true` to be able to listen at the [InAppWebView.onDownloadStart()] event. The default value is `false`.
///  - __useOnTargetBlank__: Set to `true` to be able to listen at the [InAppWebView.onTargetBlank()] event. The default value is `false`.
///  - __clearCache__: Set to `true` to have all the browser's cache cleared before the new window is opened. The default value is `false`.
///  - __userAgent___: Set the custom WebView's user-agent.
///  - __javaScriptEnabled__: Set to `true` to enable JavaScript. The default value is `true`.
///  - __javaScriptCanOpenWindowsAutomatically__: Set to `true` to allow JavaScript open windows without user interaction. The default value is `false`.
///  - __mediaPlaybackRequiresUserGesture__: Set to `true` to prevent HTML5 audio or video from autoplaying. The default value is `true`.
///  - __transparentBackground__: Set to `true` to make the background of the WebView transparent. If your app has a dark theme, this can prevent a white flash on initialization. The default value is `false`.
///  - __resourceCustomSchemes__: List of custom schemes that [InAppWebView] must handle. Use the [InAppWebView.onLoadResourceCustomScheme()] event to intercept resource requests with custom scheme.
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

  ///Event fires when [InAppWebView] recognizes and starts a downloadable file.
  ///[url] represents the url of the file.
  final onDownloadStartCallback onDownloadStart;

  ///Event fires when the [InAppWebView] finds the `custom-scheme` while loading a resource. Here you can handle the url request and return a [CustomSchemeResponse] to load a specific resource encoded to `base64`.
  ///[scheme] represents the scheme of the url.
  ///[url] represents the url of the request.
  final onLoadResourceCustomSchemeCallback onLoadResourceCustomScheme;

  ///Event fires when the [InAppWebView] tries to open a link with `target="_blank"`.
  ///[url] represents the url of the link.
  final onTargetBlankCallback onTargetBlank;

  ///Initial url that will be loaded.
  final String initialUrl;
  ///Initial asset file that will be loaded. See [InAppWebView.loadFile()] for explanation.
  final String initialFile;
  ///Initial [InAppWebViewInitialData] that will be loaded.
  final InAppWebViewInitialData initialData;
  ///Initial headers that will be used.
  final Map<String, String> initialHeaders;
  ///Initial options that will be used.
  final List<WebViewOptions> initialOptions;
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
    this.initialOptions = const [],
    this.onWebViewCreated,
    this.onLoadStart,
    this.onLoadStop,
    this.onLoadError,
    this.onConsoleMessage,
    this.onProgressChanged,
    this.shouldOverrideUrlLoading,
    this.onLoadResource,
    this.onScrollChanged,
    this.onDownloadStart,
    this.onLoadResourceCustomScheme,
    this.onTargetBlank,
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
    Map<String, dynamic> initialOptions = {};
    widget.initialOptions.forEach((webViewOption) {
      initialOptions.addAll(webViewOption.toMap());
    });

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
            'initialOptions': initialOptions
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
    _channel.setMethodCallHandler(handleMethod);
    _widget = widget;
  }

  InAppWebViewController.fromInAppBrowser(String uuid, MethodChannel channel, InAppBrowser inAppBrowser) {
    _inAppBrowserUuid = uuid;
    _channel = channel;
    _inAppBrowser = inAppBrowser;
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
        String initiatorType = call.arguments["initiatorType"];
        String url = call.arguments["url"];
        double startTime = call.arguments["startTime"];
        double duration = call.arguments["duration"];

        var response = new WebResourceResponse(initiatorType, url, startTime, duration);

        if (_widget != null && _widget.onLoadResource != null)
          _widget.onLoadResource(this, response);
        else if (_inAppBrowser != null)
          _inAppBrowser.onLoadResource(response);
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
      _inAppBrowser.throwIsNotOpened(message: 'Cannot laod $url!');
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
  Future<void> loadData(String data, {String mimeType = "text/html", String encoding = "utf8", String baseUrl = "about:blank"}) async {
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
  Future<void> loadFile(String assetFilePath, {Map<String, String> headers = const {}}) async {
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

  ///Reloads the [InAppWebView] window.
  Future<void> reload() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('reload', args);
  }

  ///Goes back in the history of the [InAppWebView] window.
  Future<void> goBack() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('goBack', args);
  }

  ///Returns a boolean value indicating whether the [InAppWebView] can move backward.
  Future<bool> canGoBack() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('canGoBack', args);
  }

  ///Goes forward in the history of the [InAppWebView] window.
  Future<void> goForward() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('goForward', args);
  }

  ///Returns a boolean value indicating whether the [InAppWebView] can move forward.
  Future<bool> canGoForward() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('canGoForward', args);
  }

  ///Goes to the history item that is the number of steps away from the current item. Steps is negative if backward and positive if forward.
  Future<void> goBackOrForward(int steps) async {
    assert(steps != null);

    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
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
      _inAppBrowser.throwIsNotOpened();
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
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('isLoading', args);
  }

  ///Stops the Web View of the [InAppWebView] instance from loading.
  Future<void> stopLoading() async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    await _channel.invokeMethod('stopLoading', args);
  }

  ///Injects JavaScript code into the [InAppWebView] window and returns the result of the evaluation.
  Future<String> injectScriptCode(String source) async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('source', () => source);
    return await _channel.invokeMethod('injectScriptCode', args);
  }

  ///Injects a JavaScript file into the [InAppWebView] window.
  Future<void> injectScriptFile(String urlFile) async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('urlFile', () => urlFile);
    await _channel.invokeMethod('injectScriptFile', args);
  }

  ///Injects CSS into the [InAppWebView] window.
  Future<void> injectStyleCode(String source) async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('source', () => source);
    await _channel.invokeMethod('injectStyleCode', args);
  }

  ///Injects a CSS file into the [InAppWebView] window.
  Future<void> injectStyleFile(String urlFile) async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
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
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    return await _channel.invokeMethod('takeScreenshot', args);
  }

  ///Sets the [InAppWebView] options with the new [options] and evaluates them.
  Future<void> setOptions(Map<String, dynamic> options) async {
    Map<String, dynamic> args = <String, dynamic>{};
    if (_inAppBrowserUuid != null && _inAppBrowser != null) {
      _inAppBrowser.throwIsNotOpened();
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
      _inAppBrowser.throwIsNotOpened();
      args.putIfAbsent('uuid', () => _inAppBrowserUuid);
    }
    args.putIfAbsent('optionsType', () => "InAppBrowserOptions");
    Map<dynamic, dynamic> options = await ChannelManager.channel.invokeMethod('getOptions', args);
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
      historyList.add(WebHistoryItem(historyItem["originalUrl"], historyItem["title"], historyItem["url"], i, i - currentIndex));
    }
    return WebHistory(historyList, currentIndex);
  }
  ///Dispose/Destroy the WebView.
  Future<void> _dispose() async {
    await _channel.invokeMethod('dispose');
  }

}