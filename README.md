# Flutter InAppBrowser Plugin [![Share on Twitter](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=Flutter%20InAppBrowser%20plugin!&url=https://github.com/pichillilorenzo/flutter_inappbrowser&hashtags=flutter,flutterio,dart,dartlang,webview) [![Share on Facebook](https://img.shields.io/badge/share-facebook-blue.svg?longCache=true&style=flat&colorB=%234267b2)](https://www.facebook.com/sharer/sharer.php?u=https%3A//github.com/pichillilorenzo/flutter_inappbrowser)

[![Pub](https://img.shields.io/pub/v/flutter_inappbrowser.svg)](https://pub.dartlang.org/packages/flutter_inappbrowser)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter?sort=votes)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](/LICENSE)

[![Donate to this project using Paypal](https://img.shields.io/badge/paypal-donate-yellow.svg)](https://www.paypal.me/LorenzoPichilli)
[![Donate to this project using Patreon](https://img.shields.io/badge/patreon-donate-yellow.svg)](https://www.patreon.com/bePatron?u=9269604)

A Flutter plugin that allows you to add an inline webview or open an in-app browser window.
This plugin is inspired by the popular [cordova-plugin-inappbrowser](https://github.com/apache/cordova-plugin-inappbrowser)!

### Requirements
- Dart sdk: ">=2.1.0-dev.7.1 <3.0.0"
- Flutter: ">=0.10.1 <2.0.0"
- Android: `minSdkVersion 17`
- iOS: `--ios-language swift`

### Note for Android
During the build, if Android fails with `Error: uses-sdk:minSdkVersion 16 cannot be smaller than version 17 declared in library`, it means that you need to update the `minSdkVersion` of your `build.gradle` file to at least `17`. 

Because of [Flutter AndroidX compatibility](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility), the latest version that doesn't use `AndroidX` is `0.6.0`.

### IMPORTANT Note for iOS
If you are starting a new fresh app, you need to create the Flutter App with `flutter create -i swift` (see [flutter/flutter#13422 (comment)](https://github.com/flutter/flutter/issues/13422#issuecomment-392133780)), otherwise, you will get this message:
```
=== BUILD TARGET flutter_inappbrowser OF PROJECT Pods WITH CONFIGURATION Debug ===
The “Swift Language Version” (SWIFT_VERSION) build setting must be set to a supported value for targets which use Swift. Supported values are: 3.0, 4.0, 4.2. This setting can be set in the build settings editor.
```

If you still have this problem, try to edit iOS `Podfile` like this (see [#15](https://github.com/pichillilorenzo/flutter_inappbrowser/issues/15)):
```
target 'Runner' do
  use_frameworks!  # required by simple_permission
  ...
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.0'  # required by simple_permission
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
```

Instead, if you have already a non-swift project, you can check this issue to solve the problem: [Friction adding swift plugin to objective-c project](https://github.com/flutter/flutter/issues/16049).

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/developing-packages/#edit-plugin-package).

## Installation
First, add `flutter_inappbrowser` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

## Usage
Classes:
- [InAppWebView](#inappwebview-class): Flutter Widget for adding an **inline native WebView** integrated into the flutter widget tree. To use `InAppWebView` class on iOS you need to opt-in for the embedded views preview by adding a boolean property to the app's `Info.plist` file, with the key `io.flutter.embedded_views_preview` and the value `YES`.
- [InAppBrowser](#inappbrowser-class): In-App Browser using native WebView.
- [ChromeSafariBrowser](#chromesafaribrowser-class): In-App Browser using [Chrome Custom Tabs](https://developer.android.com/reference/android/support/customtabs/package-summary) on Android / [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) on iOS.
- [InAppLocalhostServer](#inapplocalhostserver-class): This class allows you to create a simple server on `http://localhost:[port]/`. The default `port` value is `8080`.
- [CookieManager](#cookiemanager-class): Manages the cookies used by WebView instances. **NOTE for iOS**: available from iOS 11.0+.

See the online [docs](https://pub.dartlang.org/documentation/flutter_inappbrowser/latest/) to get the full documentation.

### `InAppWebView` class
Flutter Widget for adding an **inline native WebView** integrated into the flutter widget tree.

[AndroidView](https://docs.flutter.io/flutter/widgets/AndroidView-class.html) and [UiKitView](https://docs.flutter.io/flutter/widgets/UiKitView-class.html) are not officially stable yet!
So, if you want use it, you can but you will have some limitation such as the inability to use the keyboard!

To use `InAppWebView` class on iOS you need to opt-in for the embedded views preview by adding a boolean property to the app's `Info.plist` file, with the key `io.flutter.embedded_views_preview` and the value `YES`.

Use `InAppWebViewController` to control the WebView instance.
Example:
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

Future main() async {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  InAppWebViewController webView;
  String url = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Inline WebView example app'),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: Text("CURRENT URL\n${ (url.length > 50) ? url.substring(0, 50) + "..." : url }"),
              ),
              (progress != 1.0) ? LinearProgressIndicator(value: progress) : null,
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                  ),
                  child: InAppWebView(
                    initialUrl: "https://flutter.io/",
                    initialHeaders: {

                    },
                    initialOptions: {

                    },
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {
                      print("started $url");
                      setState(() {
                        this.url = url;
                      });
                    },
                    onProgressChanged: (InAppWebViewController controller, int progress) {
                      setState(() {
                        this.progress = progress/100;
                      });
                    },
                  ),
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Icon(Icons.arrow_back),
                    onPressed: () {
                      if (webView != null) {
                        webView.goBack();
                      }
                    },
                  ),
                  RaisedButton(
                    child: Icon(Icons.arrow_forward),
                    onPressed: () {
                      if (webView != null) {
                        webView.goForward();
                      }
                    },
                  ),
                  RaisedButton(
                    child: Icon(Icons.refresh),
                    onPressed: () {
                      if (webView != null) {
                        webView.reload();
                      }
                    },
                  ),
                ],
              ),
            ].where((Object o) => o != null).toList(),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mail),
              title: Text('Item 2'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Item 3')
            )
          ],
        ),
      ),
    );
  }
}
```

Screenshots:
- Android:

![android](https://user-images.githubusercontent.com/5956938/47271038-7aebda80-d574-11e8-98fd-41e6bbc9fe2d.gif)

- iOS:

![ios](https://user-images.githubusercontent.com/5956938/54096363-e1e72000-43ab-11e9-85c2-983a830ab7a0.gif)

#### InAppWebView.initialUrl
Initial url that will be loaded.

#### InAppWebView.initialFile
Initial asset file that will be loaded. See `InAppWebView.loadFile()` for explanation.

#### InAppWebView.initialData
Initial `InAppWebViewInitialData` that will be loaded.

#### InAppWebView.initialHeaders
Initial headers that will be used.

#### InAppWebView.initialOptions
Initial options that will be used.

All platforms support:
  - __useShouldOverrideUrlLoading__: Set to `true` to be able to listen at the `shouldOverrideUrlLoading()` event. The default value is `false`.
  - __useOnLoadResource__: Set to `true` to be able to listen at the `onLoadResource()` event. The default value is `false`.
  - __clearCache__: Set to `true` to have all the browser's cache cleared before the new window is opened. The default value is `false`.
  - __userAgent__: Set the custom WebView's user-agent.
  - __javaScriptEnabled__: Set to `true` to enable JavaScript. The default value is `true`.
  - __javaScriptCanOpenWindowsAutomatically__: Set to `true` to allow JavaScript open windows without user interaction. The default value is `false`.
  - __mediaPlaybackRequiresUserGesture__: Set to `true` to prevent HTML5 audio or video from autoplaying. The default value is `true`.
  - __transparentBackground__: Set to `true` to make the background of the WebView transparent. If your app has a dark theme, this can prevent a white flash on initialization. The default value is `false`.

  **Android** supports these additional options:

  - __clearSessionCache__: Set to `true` to have the session cookie cache cleared before the new window is opened.
  - __builtInZoomControls__: Set to `true` if the WebView should use its built-in zoom mechanisms. The default value is `false`.
  - __displayZoomControls__: Set to `true` if the WebView should display on-screen zoom controls when using the built-in zoom mechanisms. The default value is `false`.
  - __supportZoom__: Set to `false` if the WebView should not support zooming using its on-screen zoom controls and gestures. The default value is `true`.
  - __databaseEnabled__: Set to `true` if you want the database storage API is enabled. The default value is `false`.
  - __domStorageEnabled__: Set to `true` if you want the DOM storage API is enabled. The default value is `false`.
  - __useWideViewPort__: Set to `true` if the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport. When the value of the setting is false, the layout width is always set to the width of the WebView control in device-independent (CSS) pixels. When the value is true and the page contains the viewport meta tag, the value of the width specified in the tag is used. If the page does not contain the tag or does not provide a width, then a wide viewport will be used. The default value is `true`.
  - __safeBrowsingEnabled__: Set to `true` if you want the Safe Browsing is enabled. Safe Browsing allows WebView to protect against malware and phishing attacks by verifying the links. The default value is `true`. 
  - __textZoom__: Set text scaling of the WebView. The default value is `100`.
  - __mixedContentMode__: Configures the WebView's behavior when a secure origin attempts to load a resource from an insecure origin. By default, apps that target `Build.VERSION_CODES.KITKAT` or below default to `MIXED_CONTENT_ALWAYS_ALLOW`. Apps targeting `Build.VERSION_CODES.LOLLIPOP` default to `MIXED_CONTENT_NEVER_ALLOW`. The preferred and most secure mode of operation for the WebView is `MIXED_CONTENT_NEVER_ALLOW` and use of `MIXED_CONTENT_ALWAYS_ALLOW` is strongly discouraged.

  **iOS** supports these additional options:

  - __disallowOverScroll__: Set to `true` to disable the bouncing of the WebView when the scrolling has reached an edge of the content. The default value is `false`.
  - __enableViewportScale__: Set to `true` to allow a viewport meta tag to either disable or restrict the range of user scaling. The default value is `false`.
  - __suppressesIncrementalRendering__: Set to `true` if you want the WebView suppresses content rendering until it is fully loaded into memory.. The default value is `false`.
  - __allowsAirPlayForMediaPlayback__: Set to `true` to allow AirPlay. The default value is `true`.
  - __allowsBackForwardNavigationGestures__: Set to `true` to allow the horizontal swipe gestures trigger back-forward list navigations. The default value is `true`.
  - __allowsLinkPreview__: Set to `true` to allow that pressing on a link displays a preview of the destination for the link. The default value is `true`.
  - __ignoresViewportScaleLimits__: Set to `true` if you want that the WebView should always allow scaling of the webpage, regardless of the author's intent. The ignoresViewportScaleLimits property overrides the `user-scalable` HTML property in a webpage. The default value is `false`.
  - __allowsInlineMediaPlayback__: Set to `true` to allow HTML5 media playback to appear inline within the screen layout, using browser-supplied controls rather than native controls. For this to work, add the `webkit-playsinline` attribute to any `<video>` elements. The default value is `false`.
  - __allowsPictureInPictureMediaPlayback__: Set to `true` to allow HTML5 videos play picture-in-picture. The default value is `true`.

#### Events

Event `onWebViewCreated` fires when the `InAppWebView` is created.
```dart
InAppWebView(
    initialUrl: "https://flutter.io/",
    onWebViewCreated: (InAppWebViewController controller) {}
}
```

Event `onLoadStart` fires when the `InAppWebView` starts to load an `url`.
```dart
InAppWebView(
    initialUrl: "https://flutter.io/",
    onLoadStart: (InAppWebViewController controller, String url) {}
}
```

Event `onLoadStop` fires when the `InAppWebView` finishes loading an `url`.
```dart
InAppWebView(
    initialUrl: "https://flutter.io/",
    onLoadStop: (InAppWebViewController controller, String url) {}
}
```

Event `onLoadError` fires when the `InAppWebView` encounters an error loading an `url`.
```dart
InAppWebView(
    initialUrl: "https://flutter.io/",
    onLoadError: (InAppWebViewController controller, String url, int code, String message) {}
}
```

Event `onProgressChanged` fires when the current `progress` (range 0-100) of loading a page is changed.
```dart
InAppWebView(
    initialUrl: "https://flutter.io/",
    onProgressChanged: (InAppWebViewController controller, int progress) {}
}
```

Event `onConsoleMessage` fires when the `InAppWebView` receives a `ConsoleMessage`.
```dart
InAppWebView(
    initialUrl: "https://flutter.io/",
    onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {}
}
```

`shouldOverrideUrlLoading`: Give the host application a chance to take control when a URL is about to be loaded in the current WebView.

**NOTE**: In order to be able to listen this event, you need to set `useShouldOverrideUrlLoading` option to `true`.
```dart
InAppWebView(
    initialUrl: "https://flutter.io/",
    shouldOverrideUrlLoading: (InAppWebViewController controller, String url) {}
}
```

Event `onLoadResource` fires when the `InAppWebView` webview loads a resource.

**NOTE**: In order to be able to listen this event, you need to set `useOnLoadResource` option to `true`.

**NOTE only for iOS**: In some cases, the `response.data` of a `response` with `text/html` encoding could be empty.
```dart
InAppWebView(
    initialUrl: "https://flutter.io/",
    onLoadResource: (InAppWebViewController controller, WebResourceResponse response, WebResourceRequest request) {}
}
```

Event `onScrollChanged` fires when the `InAppWebView` scrolls.
`x` represents the current horizontal scroll origin in pixels.
`y` represents the current vertical scroll origin in pixels.
```dart
InAppWebView(
    initialUrl: "https://flutter.io/",
    onScrollChanged: (InAppWebViewController controller, int x, int y) {}
}
```

#### Future\<String\> InAppWebViewController.getUrl

Gets the URL for the current page.
This is not always the same as the URL passed to `InAppWebView.onLoadStarted` because although the load for that URL has begun, the current page may not have changed.

```dart
inAppWebViewController.getUrl();
```

#### Future\<String\> InAppWebViewController.getTitle

Gets the title for the current page.

```dart
inAppWebViewController.getTitle();
```

#### Future\<int\> InAppWebViewController.getProgress

Gets the progress for the current page. The progress value is between 0 and 100.

```dart
inAppWebViewController.getProgress();
```

#### Future\<List\<int\>\> InAppWebViewController.getFavicon

Gets the favicon for the current page.

```dart
inAppWebViewController.getFavicon();
```

#### Future\<void\> InAppWebViewController.loadUrl

Loads the given `url` with optional `headers` specified as a map from name to value.

```dart
inAppWebViewController.loadUrl(String url, {Map<String, String> headers = const {}});
```

#### Future\<void\> InAppWebViewController.postUrl

Loads the given `url` with `postData` using `POST` method into this WebView.

```dart
inAppWebViewController.postUrl(String url, Uint8List postData);
```

#### Future\<void\> InAppWebViewController.loadData

Loads the given `data` into this WebView, using `baseUrl` as the base URL for the content.
The `mimeType` parameter specifies the format of the data.
The `encoding` parameter specifies the encoding of the data.

```dart
inAppWebViewController.loadData(String data, {String mimeType = "text/html", String encoding = "utf8", String baseUrl = "about:blank"});
```

#### Future\<void\> InAppWebViewController.loadFile

Loads the given `assetFilePath` with optional `headers` specified as a map from name to value.

To be able to load your local files (html, js, css, etc.), you need to add them in the `assets` section of the `pubspec.yaml` file, otherwise they cannot be found!

Example of a `pubspec.yaml` file:
```yaml
...

# The following section is specific to Flutter.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  assets:
    - assets/index.html
    - assets/css/
    - assets/images/

...
```
Example of a `main.dart` file:
```dart
...
inAppWebViewController.loadFile("assets/index.html");
...
```

```dart
inAppWebViewController.loadFile(String assetFilePath, {Map<String, String> headers = const {}});
```

#### Future\<void\> InAppWebViewController.reload

Reloads the `InAppWebView` window.

```dart
inAppWebViewController.reload();
```

#### Future\<void\> InAppWebViewController.goBack

Goes back in the history of the `InAppWebView` window.

```dart
inAppWebViewController.goBack();
```

#### Future\<bool\> InAppWebViewController.canGoBack

Returns a boolean value indicating whether the `InAppWebView` can move backward.

```dart
inAppWebViewController.canGoBack();
```

#### Future\<void\> InAppWebViewController.goForward

Goes forward in the history of the `InAppWebView` window.

```dart
inAppWebViewController.goForward();
```

#### Future\<bool\> InAppWebViewController.canGoForward

Returns a boolean value indicating whether the `InAppWebView` can move forward.

```dart
inAppWebViewController.canGoForward();
```

#### Future\<void\> InAppWebViewController.goBackOrForward

Goes to the history item that is the number of steps away from the current item. Steps is negative if backward and positive if forward.

```dart
inAppWebViewController.goBackOrForward(int steps);
```

#### Future\<bool\> InAppWebViewController.canGoBackOrForward

Returns a boolean value indicating whether the `InAppWebView` can go back or forward the given number of steps. Steps is negative if backward and positive if forward.

```dart
inAppWebViewController.canGoBackOrForward(int steps);
```

#### Future\<void\> InAppWebViewController.goTo

Navigates to a `WebHistoryItem` from the back-forward `WebHistory.list` and sets it as the current item.

```dart
inAppWebViewController.goTo(WebHistoryItem historyItem);
```

#### Future\<bool\> InAppWebViewController.isLoading

Check if the Web View of the `InAppWebView` instance is in a loading state.

```dart
inAppWebViewController.isLoading();
```

#### Future\<void\> InAppWebViewController.stopLoading

Stops the Web View of the `InAppWebView` instance from loading.

```dart
inAppWebViewController.stopLoading();
```

#### Future\<String\> InAppWebViewController.injectScriptCode

Injects JavaScript code into the `InAppWebView` window and returns the result of the evaluation.

```dart
inAppWebViewController.injectScriptCode(String source);
```

#### Future\<void\> InAppWebViewController.injectScriptFile

Injects a JavaScript file into the `InAppWebView` window.

```dart
inAppWebViewController.injectScriptFile(String urlFile);
```

#### Future\<void\> InAppWebViewController.injectStyleCode

Injects CSS into the `InAppWebView` window.

```dart
inAppWebViewController.injectStyleCode(String source);
```

#### Future\<void\> InAppWebViewController.injectStyleFile

Injects a CSS file into the `InAppWebView` window.

```dart
inAppWebViewController.injectStyleFile(String urlFile);
```

#### void InAppWebViewController.addJavaScriptHandler

Adds a JavaScript message handler `callback` (`JavaScriptHandlerCallback`) that listen to post messages sent from JavaScript by the handler with name `handlerName`.

The Android implementation uses [addJavascriptInterface](https://developer.android.com/reference/android/webkit/WebView#addJavascriptInterface(java.lang.Object,%20java.lang.String)).
The iOS implementation uses [addScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537172-addscriptmessagehandler?language=objc)

The JavaScript function that can be used to call the handler is `window.flutter_inappbrowser.callHandler(handlerName <String>, ...args);`, where `args` are [rest parameters](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters).
The `args` will be stringified automatically using `JSON.stringify(args)` method and then they will be decoded on the Dart side.

In order to call `window.flutter_inappbrowser.callHandler(handlerName <String>, ...args)` properly, you need to wait and listen the JavaScript event `flutterInAppBrowserPlatformReady`.
This event will be dispatch as soon as the platform (Android or iOS) is ready to handle the `callHandler` method.
```javascript
window.addEventListener("flutterInAppBrowserPlatformReady", function(event) {
    console.log("ready");
});
```

`window.flutter_inappbrowser.callHandler` returns a JavaScript [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)
that can be used to get the json result returned by `JavaScriptHandlerCallback`.
In this case, simply return data that you want to send and it will be automatically json encoded using `jsonEncode` from the `dart:convert` library.

So, on the JavaScript side, to get data coming from the Dart side, you will use:
```html
<script>
    window.addEventListener("flutterInAppBrowserPlatformReady", function(event) {
        window.flutter_inappbrowser.callHandler('handlerFoo').then(function(result) {
            console.log(result, typeof result);
            console.log(JSON.stringify(result));
        });
    
        window.flutter_inappbrowser.callHandler('handlerFooWithArgs', 1, true, ['bar', 5], {foo: 'baz'}).then(function(result) {
            console.log(result, typeof result);
            console.log(JSON.stringify(result));
        });
    });
</script>
```

Instead, on the `onLoadStop` WebView event, you can use `callHandler` directly:
```dart
// Inject JavaScript that will receive data back from Flutter
inAppWebViewController.injectScriptCode("""
  window.flutter_inappbrowser.callHandler('test', 'Text from Javascript').then(function(result) {
    console.log(result);
  });
""");
```

```dart
inAppWebViewController.addJavaScriptHandler(String handlerName, JavaScriptHandlerCallback callback);
```

#### JavaScriptHandlerCallback InAppWebViewController.removeJavaScriptHandler

Removes a JavaScript message handler previously added with the `addJavaScriptHandler()` associated to `handlerName` key.
Returns the value associated with `handlerName` before it was removed.
Returns `null` if `handlerName` was not found.
```dart
inAppWebViewController.removeJavaScriptHandler(String handlerName);
```

#### Future\<Uint8List\> InAppWebViewController.takeScreenshot

Takes a screenshot (in PNG format) of the WebView's visible viewport and returns a `Uint8List`. Returns `null` if it wasn't be able to take it.

**NOTE for iOS**: available from iOS 11.0+.
```dart
inAppWebViewController.takeScreenshot();
```

#### Future\<void\> InAppWebViewController.setOptions

Sets the `InAppWebView` options with the new `options` and evaluates them.
```dart
inAppWebViewController.setOptions(Map<String, dynamic> options);
```

#### Future\<Map\<String, dynamic\>\> InAppWebViewController.getOptions

Gets the current `InAppWebView` options. Returns `null` if the options are not setted yet.
```dart
inAppWebViewController.getOptions();
```

#### Future\<WebHistory\> InAppWebViewController.getCopyBackForwardList

Gets the WebHistory for this WebView. This contains the back/forward list for use in querying each item in the history stack.
This contains only a snapshot of the current state.
Multiple calls to this method may return different objects.
The object returned from this method will not be updated to reflect any new state.
```dart
inAppWebViewController.getCopyBackForwardList();
```

### `InAppBrowser` class
In-App Browser using native WebView.

`inAppBrowser.webViewController` can be used to access the `InAppWebView` API.

Create a Class that extends the `InAppBrowser` Class in order to override the callbacks to manage the browser events.
Example:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class MyInAppBrowser extends InAppBrowser {
  
  @override
  void onBrowserCreated() async {
    print("\n\nBrowser Ready!\n\n");
  }
  
  @override
  void onLoadStart(String url) {
    print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(String url) async {
    print("\n\nStopped $url\n\n");

    // call a javascript message handler
    await this.webViewController.injectScriptCode("window.flutter_inappbrowser.callHandler('handlerNameTest', 1, 5,'string', {'key': 5}, [4,6,8]);");

    // print body html
    print(await this.webViewController.injectScriptCode("document.body.innerHTML"));

    // console messages
    await this.webViewController.injectScriptCode("console.log({'testObject': 5});"); // the message will be: [object Object]
    await this.webViewController.injectScriptCode("console.log('testObjectStringify', JSON.stringify({'testObject': 5}));"); // the message will be: testObjectStringify {"testObject": 5}
    await this.webViewController.injectScriptCode("console.error('testError', false);"); // the message will be: testError false

    // add jquery library and custom javascript
    await this.webViewController.injectScriptFile("https://code.jquery.com/jquery-3.3.1.min.js");
    this.webViewController.injectScriptCode("""
      \$( "body" ).html( "Next Step..." )
    """);

    // add custom css
    this.webViewController.injectStyleCode("""
    body {
      background-color: #3c3c3c !important;
    }
    """);
    this.webViewController.injectStyleFile("https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css");
  }

  @override
  void onLoadError(String url, int code, String message) {
    print("\n\nCan't load $url.. Error: $message\n\n");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }

  @override
  void shouldOverrideUrlLoading(String url) {
    print("\n\n override $url\n\n");
    this.webViewController.loadUrl(url);
  }

  @override
  void onLoadResource(WebResourceResponse response, WebResourceRequest request) {
    print("Started at: " + response.startTime.toString() + "ms ---> duration: " + response.duration.toString() + "ms " + response.url);
  }

  @override
  void onConsoleMessage(ConsoleMessage consoleMessage) {
    print("""
    console output:
      sourceURL: ${consoleMessage.sourceURL}
      lineNumber: ${consoleMessage.lineNumber}
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel}
    """);
  }

}

MyInAppBrowser inAppBrowser = new MyInAppBrowser();

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    // listen for post messages coming from the JavaScript side
    inAppBrowser.webViewController.addJavaScriptHandler("handlerNameTest", (arguments) async {
      print("handlerNameTest arguments");
      print(arguments); // it prints: [1, 5, string, {key: 5}, [4, 6, 8]]
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Flutter InAppBrowser Plugin example app'),
        ),
        body: new Center(
          child: new RaisedButton(onPressed: () async {
            await inAppBrowser.open(url: "https://flutter.io/", options: {
              "useShouldOverrideUrlLoading": true,
              "useOnLoadResource": true
            });
          },
              child: Text("Open InAppBrowser")
          ),
        ),
      ),
    );
  }
}
```

Screenshots:
- iOS:

![ios](https://user-images.githubusercontent.com/5956938/45934084-2a935400-bf99-11e8-9d71-9e1758b5b8c6.gif)

- Android:

![android](https://user-images.githubusercontent.com/5956938/45934080-26ffcd00-bf99-11e8-8136-d39a81bd83e7.gif)

#### Future\<void\> InAppBrowser.open

Opens an `url` in a new `InAppBrowser` instance.

- `url`: The `url` to load. Call `encodeUriComponent()` on this if the `url` contains Unicode characters. The default value is `about:blank`.

- `headers`: The additional headers to be used in the HTTP request for this URL, specified as a map from name to value.

- `options`: Options for the `InAppBrowser`.

  All platforms support:
  - __useShouldOverrideUrlLoading__: Set to `true` to be able to listen at the `shouldOverrideUrlLoading()` event. The default value is `false`.
  - __useOnLoadResource__: Set to `true` to be able to listen at the `onLoadResource()` event. The default value is `false`.
  - __clearCache__: Set to `true` to have all the browser's cache cleared before the new window is opened. The default value is `false`.
  - __userAgent__: Set the custom WebView's user-agent.
  - __javaScriptEnabled__: Set to `true` to enable JavaScript. The default value is `true`.
  - __javaScriptCanOpenWindowsAutomatically__: Set to `true` to allow JavaScript open windows without user interaction. The default value is `false`.
  - __hidden__: Set to `true` to create the browser and load the page, but not show it. The `onLoadStop` event fires when loading is complete. Omit or set to `false` (default) to have the browser open and load normally.
  - __toolbarTop__: Set to `false` to hide the toolbar at the top of the WebView. The default value is `true`.
  - __toolbarTopBackgroundColor__: Set the custom background color of the toolbar at the top.
  - __hideUrlBar__: Set to `true` to hide the url bar on the toolbar at the top. The default value is `false`.
  - __mediaPlaybackRequiresUserGesture__: Set to `true` to prevent HTML5 audio or video from autoplaying. The default value is `true`.

  **Android** supports these additional options:

  - __hideTitleBar__: Set to `true` if you want the title should be displayed. The default value is `false`.
  - __closeOnCannotGoBack__: Set to `false` to not close the InAppBrowser when the user click on the back button and the WebView cannot go back to the history. The default value is `true`.
  - __clearSessionCache__: Set to `true` to have the session cookie cache cleared before the new window is opened.
  - __builtInZoomControls__: Set to `true` if the WebView should use its built-in zoom mechanisms. The default value is `false`.
  - __displayZoomControls__: Set to `true` if the WebView should display on-screen zoom controls when using the built-in zoom mechanisms. The default value is `false`.
  - __supportZoom__: Set to `false` if the WebView should not support zooming using its on-screen zoom controls and gestures. The default value is `true`.
  - __databaseEnabled__: Set to `true` if you want the database storage API is enabled. The default value is `false`.
  - __domStorageEnabled__: Set to `true` if you want the DOM storage API is enabled. The default value is `false`.
  - __useWideViewPort__: Set to `true` if the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport. When the value of the setting is false, the layout width is always set to the width of the WebView control in device-independent (CSS) pixels. When the value is true and the page contains the viewport meta tag, the value of the width specified in the tag is used. If the page does not contain the tag or does not provide a width, then a wide viewport will be used. The default value is `true`.
  - __safeBrowsingEnabled__: Set to `true` if you want the Safe Browsing is enabled. Safe Browsing allows WebView to protect against malware and phishing attacks by verifying the links. The default value is `true`.
  - __progressBar__: Set to `false` to hide the progress bar at the bottom of the toolbar at the top. The default value is `true`.
  - __textZoom__: Set text scaling of the WebView. The default value is `100`.
  - __mixedContentMode__: Configures the WebView's behavior when a secure origin attempts to load a resource from an insecure origin. By default, apps that target `Build.VERSION_CODES.KITKAT` or below default to `MIXED_CONTENT_ALWAYS_ALLOW`. Apps targeting `Build.VERSION_CODES.LOLLIPOP` default to `MIXED_CONTENT_NEVER_ALLOW`. The preferred and most secure mode of operation for the WebView is `MIXED_CONTENT_NEVER_ALLOW` and use of `MIXED_CONTENT_ALWAYS_ALLOW` is strongly discouraged.

  **iOS** supports these additional options:

  - __disallowOverScroll__: Set to `true` to disable the bouncing of the WebView when the scrolling has reached an edge of the content. The default value is `false`.
  - __toolbarBottom__: Set to `false` to hide the toolbar at the bottom of the WebView. The default value is `true`.
  - __toolbarBottomBackgroundColor__: Set the custom background color of the toolbar at the bottom.
  - __toolbarBottomTranslucent__: Set to `true` to set the toolbar at the bottom translucent. The default value is `true`.
  - __closeButtonCaption__: Set the custom text for the close button.
  - __closeButtonColor__: Set the custom color for the close button.
  - __presentationStyle__: Set the custom modal presentation style when presenting the WebView. The default value is `0 //fullscreen`. See [UIModalPresentationStyle](https://developer.apple.com/documentation/uikit/uimodalpresentationstyle) for all the available styles.
  - __transitionStyle__: Set to the custom transition style when presenting the WebView. The default value is `0 //crossDissolve`. See [UIModalTransitionStyle](https://developer.apple.com/documentation/uikit/uimodaltransitionStyle) for all the available styles.
  - __enableViewportScale__: Set to `true` to allow a viewport meta tag to either disable or restrict the range of user scaling. The default value is `false`.
  - __suppressesIncrementalRendering__: Set to `true` if you want the WebView suppresses content rendering until it is fully loaded into memory.. The default value is `false`.
  - __allowsAirPlayForMediaPlayback__: Set to `true` to allow AirPlay. The default value is `true`.
  - __allowsBackForwardNavigationGestures__: Set to `true` to allow the horizontal swipe gestures trigger back-forward list navigations. The default value is `true`.
  - __allowsLinkPreview__: Set to `true` to allow that pressing on a link displays a preview of the destination for the link. The default value is `true`.
  - __ignoresViewportScaleLimits__: Set to `true` if you want that the WebView should always allow scaling of the webpage, regardless of the author's intent. The ignoresViewportScaleLimits property overrides the `user-scalable` HTML property in a webpage. The default value is `false`.
  - __allowsInlineMediaPlayback__: Set to `true` to allow HTML5 media playback to appear inline within the screen layout, using browser-supplied controls rather than native controls. For this to work, add the `webkit-playsinline` attribute to any `<video>` elements. The default value is `false`.
  - __allowsPictureInPictureMediaPlayback__: Set to `true` to allow HTML5 videos play picture-in-picture. The default value is `true`.
  - __spinner__: Set to `false` to hide the spinner when the WebView is loading a page. The default value is `true`.

Example:
```dart
inAppBrowser.open('https://flutter.io/', options: {
  "useShouldOverrideUrlLoading": true,
  "useOnLoadResource": true,
  "clearCache": true,
  "disallowOverScroll": true,
  "domStorageEnabled": true,
  "supportZoom": false,
  "toolbarBottomTranslucent": false,
  "allowsLinkPreview": false
});
```

```dart
inAppBrowser.open({String url = "about:blank", Map<String, String> headers = const {}, Map<String, dynamic> options = const {}});
```

#### Future\<void\> InAppBrowser.openFile

Opens the given `assetFilePath` file in a new `InAppBrowser` instance. The other arguments are the same of `InAppBrowser.open()`.

To be able to load your local files (assets, js, css, etc.), you need to add them in the `assets` section of the `pubspec.yaml` file, otherwise they cannot be found!

Example of a `pubspec.yaml` file:
```yaml
...

# The following section is specific to Flutter.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  assets:
    - assets/index.html
    - assets/css/
    - assets/images/

...
```
Example of a `main.dart` file:
```dart
...
inAppBrowser.openFile("assets/index.html");
...
```

```dart
inAppBrowser.openFile(String assetFilePath, {Map<String, String> headers = const {}, Map<String, dynamic> options = const {}});
```

#### static Future\<void\> InAppBrowser.openData

Opens a new `InAppBrowser` instance with `data` as a content, using `baseUrl` as the base URL for it.
The `mimeType` parameter specifies the format of the data.
The `encoding` parameter specifies the encoding of the data.

```dart
InAppBrowser.openData(String data, {String mimeType = "text/html", String encoding = "utf8", String baseUrl = "about:blank", Map<String, dynamic> options = const {}});
```

#### static Future\<void\> InAppBrowser.openWithSystemBrowser

This is a static method that opens an `url` in the system browser. You wont be able to use the `InAppBrowser` methods here!

```dart
InAppBrowser.openWithSystemBrowser(String url);
```

#### Future\<void\> InAppBrowser.show

Displays an `InAppBrowser` window that was opened hidden. Calling this has no effect if the `InAppBrowser` was already visible.

```dart
inAppBrowser.show();
```

#### Future\<void\> InAppBrowser.hide

Hides the `InAppBrowser` window. Calling this has no effect if the `InAppBrowser` was already hidden.

```dart
inAppBrowser.hide();
```

#### Future\<void\> InAppBrowser.close

Closes the `InAppBrowser` window.

```dart
inAppBrowser.close();
```

#### Future\<bool\> InAppBrowser.isHidden

Check if the Web View of the `InAppBrowser` instance is hidden.

```dart
inAppBrowser.isHidden();
```

#### Future\<void\> InAppBrowser.setOptions

Sets the `InAppBrowser` options and the `InAppWebView` options with the new `options` and evaluates them.
```dart
inAppBrowser.setOptions(Map<String, dynamic> options);
```

#### Future\<Map\<String, dynamic\>\> InAppBrowser.getOptions

Gets the current `InAppBrowser` options and the current `InAppWebView` options merged together. Returns `null` if the options are not setted yet.
```dart
inAppBrowser.getOptions();
```

#### bool InAppBrowser.isOpened

Returns `true` if the `InAppBrowser` instance is opened, otherwise `false`.
```dart
inAppBrowser.isOpened();
```

#### Events

Event `onBrowserCreated` fires when the `InAppBrowser` is created.
```dart
  @override
  void onBrowserCreated() {

  }
```

Event `onLoadStart` fires when the `InAppBrowser` starts to load an `url`.
```dart
  @override
  void onLoadStart(String url) {

  }
```

Event `onLoadStop` fires when the `InAppBrowser` finishes loading an `url`.
```dart
  @override
  void onLoadStop(String url) {

  }
```

Event `onLoadError` fires when the `InAppBrowser` encounters an error loading an `url`.
```dart
  @override
  void onLoadError(String url, int code, String message) {

  }
```

Event `onProgressChanged` fires when the current `progress` (range 0-100) of loading a page is changed.
```dart
  @override
  void onProgressChanged(int progress) {

  }
```

Event `onExit` fires when the `InAppBrowser` window is closed.
```dart
  @override
  void onExit() {

  }
```

Event `onConsoleMessage` fires when the `InAppBrowser` webview receives a `ConsoleMessage`.
```dart
  @override
  void onConsoleMessage(ConsoleMessage consoleMessage) {

  }
```

`shouldOverrideUrlLoading`: Give the host application a chance to take control when a URL is about to be loaded in the current WebView.

**NOTE**: In order to be able to listen this event, you need to set `useShouldOverrideUrlLoading` option to `true`.
```dart
  @override
  void shouldOverrideUrlLoading(String url) {

  }
```

Event `onLoadResource` fires when the `InAppBrowser` webview loads a resource.

**NOTE**: In order to be able to listen this event, you need to set `useOnLoadResource` option to `true`.

**NOTE only for iOS**: In some cases, the `response.data` of a `response` with `text/html` encoding could be empty.
```dart
  @override
  void onLoadResource(WebResourceResponse response, WebResourceRequest request) {

  }
```

Event `onScrollChanged` fires when the `InAppBrowser` webview scrolls.
`x` represents the current horizontal scroll origin in pixels.
`y` represents the current vertical scroll origin in pixels.
```dart
  @override
  void onScrollChanged(int x, int y) {
                                                                         
  }

```

### `ChromeSafariBrowser` class
[Chrome Custom Tabs](https://developer.android.com/reference/android/support/customtabs/package-summary) on Android / [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) on iOS.

You can initialize the `ChromeSafariBrowser` instance with an `InAppBrowser` fallback instance.

Create a Class that extends the `ChromeSafariBrowser` Class in order to override the callbacks to manage the browser events. Example:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class MyInAppBrowser extends InAppBrowser {

  @override
  Future onLoadStart(String url) async {
    print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(String url) async {
    print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(String url, int code, String message) {
    print("\n\nCan't load $url.. Error: $message\n\n");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }

}

MyInAppBrowser inAppBrowserFallback = new MyInAppBrowser();

class MyChromeSafariBrowser extends ChromeSafariBrowser {

  MyChromeSafariBrowser(browserFallback) : super(browserFallback);

  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onLoaded() {
    print("ChromeSafari browser loaded");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}

MyChromeSafariBrowser chromeSafariBrowser = new MyChromeSafariBrowser(inAppBrowserFallback);


void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Flutter InAppBrowser Plugin example app'),
        ),
        body: new Center(
          child: new RaisedButton(onPressed: () {
            chromeSafariBrowser.open("https://flutter.io/", options: {
                  "addShareButton": false,
                  "toolbarBackgroundColor": "#000000",
                  "dismissButtonStyle": 1,
                  "preferredBarTintColor": "#000000",
                },
              optionsFallback: {
                "toolbarTopBackgroundColor": "#000000",
                "closeButtonCaption": "Close"
              });
          },
          child: Text("Open ChromeSafariBrowser")
          ),
        ),
      ),
    );
  }
}

```

Screenshots:
- iOS:

![ios](https://user-images.githubusercontent.com/5956938/46532148-0c362e00-c8a0-11e8-9a0e-343e049dcf35.gif)

- Android:

![android](https://user-images.githubusercontent.com/5956938/46532149-0c362e00-c8a0-11e8-8134-9af18f38a746.gif)

#### Future\<void\> ChromeSafariBrowser.open
Opens an `url` in a new `ChromeSafariBrowser` instance.

- `url`: The `url` to load. Call `encodeUriComponent()` on this if the `url` contains Unicode characters.

- `options`: Options for the `ChromeSafariBrowser`.

- `headersFallback`: The additional header of the `InAppBrowser` instance fallback to be used in the HTTP request for this URL, specified as a map from name to value.

- `optionsFallback`: Options used by the `InAppBrowser` instance fallback.

**Android** supports these options:

- __addShareButton__: Set to `false` if you don't want the default share button. The default value is `true`.
- __showTitle__: Set to `false` if the title shouldn't be shown in the custom tab. The default value is `true`.
- __toolbarBackgroundColor__: Set the custom background color of the toolbar.
- __enableUrlBarHiding__: Set to `true` to enable the url bar to hide as the user scrolls down on the page. The default value is `false`.
- __instantAppsEnabled__: Set to `true` to enable Instant Apps. The default value is `false`.

**iOS** supports these options:

- __entersReaderIfAvailable__: Set to `true` if Reader mode should be entered automatically when it is available for the webpage. The default value is `false`.
- __barCollapsingEnabled__: Set to `true` to enable bar collapsing. The default value is `false`.
- __dismissButtonStyle__: Set the custom style for the dismiss button. The default value is `0 //done`. See [SFSafariViewController.DismissButtonStyle](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller/dismissbuttonstyle) for all the available styles.
- __preferredBarTintColor__: Set the custom background color of the navigation bar and the toolbar.
- __preferredControlTintColor__: Set the custom color of the control buttons on the navigation bar and the toolbar.
- __presentationStyle__: Set the custom modal presentation style when presenting the WebView. The default value is `0 //fullscreen`. See [UIModalPresentationStyle](https://developer.apple.com/documentation/uikit/uimodalpresentationstyle) for all the available styles.
- __transitionStyle__: Set to the custom transition style when presenting the WebView. The default value is `0 //crossDissolve`. See [UIModalTransitionStyle](https://developer.apple.com/documentation/uikit/uimodaltransitionStyle) for all the available styles.

Example:
```dart
chromeSafariBrowser.open("https://flutter.io/", options: {
  "addShareButton": false,
  "toolbarBackgroundColor": "#000000",
  "dismissButtonStyle": 1,
  "preferredBarTintColor": "#000000",
});
```

#### Events

Event `onOpened` fires when the `ChromeSafariBrowser` is opened.
```dart
  @override
  void onOpened() {

  }
```

Event `onLoaded` fires when the `ChromeSafariBrowser` is loaded.
```dart
  @override
  void onLoaded() {

  }
```

Event `onClosed` fires when the `ChromeSafariBrowser` is closed.
```dart
  @override
  void onClosed() {

  }
```

### `InAppLocalhostServer` class
This class allows you to create a simple server on `http://localhost:[port]/` in order to be able to load your assets file on a server. The default `port` value is `8080`.

Example:
```dart
// ...

InAppLocalhostServer localhostServer = new InAppLocalhostServer();

Future main() async {
  await localhostServer.start();
  runApp(new MyApp());
}

// ...

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Flutter InAppBrowser Plugin example app'),
        ),
        body: new Center(
          child: new RaisedButton(
            onPressed: () async {
              await inAppBrowser.open(
                  url: "http://localhost:8080/assets/index.html",
                  options: {});
            },
            child: Text("Open InAppBrowser")
          ),
        ),
      ),
    );
  }

// ...

```

#### Future\<void\> InAppLocalhostServer.start
Starts a server on `http://localhost:[port]/`.

**NOTE for iOS**: For the iOS Platform, you need to add the `NSAllowsLocalNetworking` key with `true` in the `Info.plist` file (See [ATS Configuration Basics](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW35)):
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```
The `NSAllowsLocalNetworking` key is available since **iOS 10**.

```dart
localhostServer.start();
```

#### Future\<void\> InAppLocalhostServer.close
Closes the server.

```dart
localhostServer.close();
```

### `CookieManager` class
Manages the cookies used by WebView instances.

**NOTE for iOS**: available from iOS 11.0+.

Example:
```dart
var url = "https://flutter.io/";
await CookieManager.setCookie(url, "myCookie", "cookieValue", domain: "flutter.io", expiresDate: 1540838864611);
print(await CookieManager.getCookies(url));
print(await CookieManager.getCookie(url, "myCookie"));
await CookieManager.deleteCookie(url, "myCookie");
await CookieManager.deleteCookie(url, "_gid", domain: ".googleblog.com");
await CookieManager.deleteCookies(url);
await CookieManager.deleteAllCookies();
```

#### static Future\<void\> CookieManager.setCookie

Sets a cookie for the given `url`. Any existing cookie with the same `host`, `path` and `name` will be replaced with the new cookie. 
The cookie being set will be ignored if it is expired.

The default value of `path` is `"/"`.
If `domain` is `null`, its default value will be the domain name of `url`.
```dart
CookieManager.setCookie(String url, String name, String value, { String domain, String path = "/", int expiresDate, int maxAge, bool isSecure });
```

#### static Future\<void\> CookieManager.getCookies

Gets all the cookies for the given `url`.
```dart
CookieManager.getCookies(String url);
```

#### static Future\<void\> CookieManager.getCookie

Gets a cookie by its `name` for the given `url`.
```dart
CookieManager.getCookie(String url, String name);
```

#### static Future\<void\> CookieManager.deleteCookie

Removes a cookie by its `name` for the given `url`, `domain` and `path`.

The default value of `path` is `"/"`.
If `domain` is `null` or empty, its default value will be the domain name of `url`.
```dart
CookieManager.deleteCookie(String url, String name, {String domain = "", String path = "/"});
```

#### static Future\<void\> CookieManager.deleteCookies

Removes all cookies for the given `url`, `domain` and `path`.

The default value of `path` is `"/"`.
If `domain` is `null` or empty, its default value will be the domain name of `url`.
```dart
CookieManager.deleteCookies(String url, {String domain = "", String path = "/"});
```

#### static Future\<void\> CookieManager.deleteAllCookies

Removes all cookies.
```dart
CookieManager.deleteAllCookies();
```
