# Flutter InAppWebView Plugin [![Share on Twitter](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=Flutter%20InAppBrowser%20plugin!&url=https://github.com/pichillilorenzo/flutter_inappwebview&hashtags=flutter,flutterio,dart,dartlang,webview) [![Share on Facebook](https://img.shields.io/badge/share-facebook-blue.svg?longCache=true&style=flat&colorB=%234267b2)](https://www.facebook.com/sharer/sharer.php?u=https%3A//github.com/pichillilorenzo/flutter_inappwebview)

[![Pub](https://img.shields.io/pub/v/flutter_inappwebview.svg)](https://pub.dartlang.org/packages/flutter_inappwebview)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter?sort=votes)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](/LICENSE)

[![Donate to this project using Paypal](https://img.shields.io/badge/paypal-donate-yellow.svg)](https://www.paypal.me/LorenzoPichilli)
[![GitHub contributors](https://img.shields.io/github/contributors/pichillilorenzo/flutter_inappwebview)](https://github.com/pichillilorenzo/flutter_inappwebview/graphs/contributors)
[![GitHub forks](https://img.shields.io/github/forks/pichillilorenzo/flutter_inappwebview?style=social)](https://github.com/pichillilorenzo/flutter_inappwebview)
[![GitHub stars](https://img.shields.io/github/stars/pichillilorenzo/flutter_inappwebview?style=social)](https://github.com/pichillilorenzo/flutter_inappwebview)


![InAppWebView-logo](https://user-images.githubusercontent.com/5956938/86118415-0ac78300-bad1-11ea-9933-31dc65744f38.png)

A Flutter plugin that allows you to add an inline webview, to use an headless webview, and to open an in-app browser window.

## Articles/Resources

- [InAppWebView: The Real Power of WebViews in Flutter](https://medium.com/flutter-community/inappwebview-the-real-power-of-webviews-in-flutter-c6d52374209d?source=friends_link&sk=cb74487219bcd85e610a670ee0b447d0)

## Requirements

- Dart sdk: ">=2.7.0 <3.0.0"
- Flutter: ">=1.12.13+hotfix.5"
- Android: `minSdkVersion 17` and add support for `androidx` (see [AndroidX Migration](https://flutter.dev/docs/development/androidx-migration) to migrate an existing app)
- iOS: `--ios-language swift`, Xcode version `>= 11`

### IMPORTANT Note for Android and iOS

If you're running an application and need to access the binary messenger before `runApp()` has been called
(for example, during plugin initialization), then you need to explicitly call the `WidgetsFlutterBinding.ensureInitialized()` first.

An example:
```dart
void main() {
  // it should be the first line in main method
  WidgetsFlutterBinding.ensureInitialized();

  // rest of your app code
  runApp(MyApp());
}
```

### IMPORTANT Note for Android

If you are starting a new fresh app, you need to create the Flutter App with `flutter create --androidx -i swift`
to add support for `androidx`, otherwise it won't work (see [AndroidX Migration](https://flutter.dev/docs/development/androidx-migration) to migrate an existing app).

During the build, if Android fails with `Error: uses-sdk:minSdkVersion 16 cannot be smaller than version 17 declared in library`,
it means that you need to update the `minSdkVersion` of your `android/app/build.gradle` file to at least `17`.

Also, you need to add `<uses-permission android:name="android.permission.INTERNET"/>` in the `android/app/src/main/AndroidManifest.xml`
file in order to give minimum permission to perform network operations in your application.

If you `flutter create`d your project prior to version `1.12`, you need to make sure to update your project in order to use the new **Java Embedding API**!
Take a look at the official Flutter wiki: [Upgrading pre 1.12 Android projects](https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects).
Also, you can refer to the [#343](https://github.com/pichillilorenzo/flutter_inappwebview/issues/343) issue.
Remember to add `<meta-data>` tag inside the `<application>` tag of your `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
  android:name="flutterEmbedding"
  android:value="2" />
```
as mentioned in the 6th step of [Full-Flutter app migration](https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects#full-flutter-app-migration) guide.
**Without this, the plugin will NOT work!!!**

Because of [Flutter AndroidX compatibility](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility), the latest version that doesn't use `AndroidX` is `0.6.0`.

Also, note that to use the `InAppWebView` widget on Android, it requires **Android API 20+** (see [AndroidView](https://api.flutter.dev/flutter/widgets/AndroidView-class.html)).

**Support HTTP request**: Starting with Android 9 (API level 28), cleartext support is disabled by default:
- Check the official [Network security configuration - "Opt out of cleartext traffic"](https://developer.android.com/training/articles/security-config#CleartextTrafficPermitted) section.
- Also, check this StackOverflow issue answer: [Cleartext HTTP traffic not permitted](https://stackoverflow.com/a/50834600/4637638).

### IMPORTANT Note for iOS

If you are starting a new fresh app, you need to create the Flutter App with `flutter create --androidx -i swift`
(see [flutter/flutter#13422 (comment)](https://github.com/flutter/flutter/issues/13422#issuecomment-392133780)), otherwise, you will get this message:
```
=== BUILD TARGET flutter_inappwebview OF PROJECT Pods WITH CONFIGURATION Debug ===
The “Swift Language Version” (SWIFT_VERSION) build setting must be set to a supported value for targets which use Swift. Supported values are: 3.0, 4.0, 4.2, 5.0. This setting can be set in the build settings editor.
```

If you still have this problem, try to edit iOS `Podfile` like this (see [#15](https://github.com/pichillilorenzo/flutter_inappwebview/issues/15)):
```
target 'Runner' do
  use_frameworks!  # required by simple_permission
  ...
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.0'  # required by simple_permission
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
```

Instead, if you have already a non-swift project, you can check this issue to solve the problem: [Friction adding swift plugin to objective-c project](https://github.com/flutter/flutter/issues/16049).

**Support HTTP request**: you need to disable Apple Transport Security (ATS) feature. There're two options:
1. Disable ATS for a specific domain only ([Official wiki](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity/nsexceptiondomains)): (add following codes to your `Info.plist` file)
```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSExceptionDomains</key>
  <dict>
    <key>www.yourserver.com</key>
    <dict>
      <!-- add this key to enable subdomains such as sub.yourserver.com -->
      <key>NSIncludesSubdomains</key>
      <true/>
      <!-- add this key to allow standard HTTP requests, thus negating the ATS -->
      <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
      <true/>
      <!-- add this key to specify the minimum TLS version to accept -->
      <key>NSTemporaryExceptionMinimumTLSVersion</key>
      <string>TLSv1.1</string>
    </dict>
  </dict>
</dict>
```
2. Completely disable ATS ([Official wiki](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity/nsallowsarbitraryloads)): (add following codes to your `Info.plist` file)
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key><true/>
</dict>
```

Other useful `Info.plist` properties are:
* `NSAllowsLocalNetworking`: A Boolean value indicating whether to allow loading of local resources ([Official wiki](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity/nsallowslocalnetworking));
* `NSAllowsArbitraryLoadsInWebContent`: A Boolean value indicating whether all App Transport Security restrictions are disabled for requests made from web views ([Official wiki](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity/nsallowsarbitraryloadsinwebcontent)).

### How to enable the usage of camera for HTML inputs such as `<input type="file" accept="image/*" capture>`

In order to be able to use camera, for example, for taking images through `<input type="file" accept="image/*" capture>` HTML tag, you need to ask camera permission.
To ask camera permission, you can simply use the [permission_handler](https://pub.dev/packages/permission_handler) plugin!

Example:
```dart
import 'package:permission_handler/permission_handler.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();

  runApp(MyApp());
}
```

On **Android**, you need to add some additional configurations.
Add the following codes inside the `<application>` tag of your `android/app/src/main/AndroidManifest.xml`:
```xml
<provider
    android:name="com.pichillilorenzo.flutter_inappwebview.InAppWebViewFileProvider"
    android:authorities="${applicationId}.flutter_inappwebview.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/provider_paths" />
</provider>
```

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/developing-packages/#edit-plugin-package).

## Installation

First, add `flutter_inappwebview` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

## Usage

Classes:
- [InAppWebView](#inappwebview-class): Flutter Widget for adding an **inline native WebView** integrated into the flutter widget tree. To use `InAppWebView` class on iOS you need to opt-in for the embedded views preview by adding a boolean property to the app's `Info.plist` file, with the key `io.flutter.embedded_views_preview` and the value `YES`. Also, note that on Android it requires **Android API 20+** (see [AndroidView](https://api.flutter.dev/flutter/widgets/AndroidView-class.html)).
- [ContextMenu](#contextmenu-class): This class represents the WebView context menu.
- [HeadlessInAppWebView](#headlessinappwebview-class): Class that represents a WebView in headless mode. It can be used to run a WebView in background without attaching an `InAppWebView` to the widget tree.
- [InAppBrowser](#inappbrowser-class): In-App Browser using native WebView.
- [ChromeSafariBrowser](#chromesafaribrowser-class): In-App Browser using [Chrome Custom Tabs](https://developer.android.com/reference/android/support/customtabs/package-summary) on Android / [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) on iOS.
- [InAppLocalhostServer](#inapplocalhostserver-class): This class allows you to create a simple server on `http://localhost:[port]/`. The default `port` value is `8080`.
- [CookieManager](#cookiemanager-class): This class implements a singleton object (shared instance) which manages the cookies used by WebView instances. **NOTE for iOS**: available from iOS 11.0+.
- [HttpAuthCredentialDatabase](#httpauthcredentialdatabase-class): This class implements a singleton object (shared instance) which manages the shared HTTP auth credentials cache.
- [WebStorageManager](#webstoragemanager-class): This class implements a singleton object (shared instance) which manages the web storage used by WebView instances.

## API Reference

See the online [API Reference](https://pub.dartlang.org/documentation/flutter_inappwebview/latest/) to get the full documentation.

The API showed in this `README.md` file shows only a part of the documentation that conforms to the master branch only. 
So, here you could have methods, options, and events that aren't published yet.
If you need a specific version, change the **GitHub branch** to your version or use the **online API Reference** (recommended).

### Load a file inside `assets` folder

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

### `InAppWebView` class

Flutter Widget for adding an **inline native WebView** integrated into the flutter widget tree.

The plugin relies on Flutter's mechanism (in developers preview) for embedding Android and iOS native views: [AndroidView](https://docs.flutter.io/flutter/widgets/AndroidView-class.html) and [UiKitView](https://docs.flutter.io/flutter/widgets/UiKitView-class.html).
Known issues are tagged with the [platform-views](https://github.com/flutter/flutter/labels/a%3A%20platform-views) label in the [Flutter official repo](https://github.com/flutter/flutter).
Keyboard support within webviews is also experimental.

To use `InAppWebView` class on iOS you need to opt-in for the embedded views preview by adding a boolean property to the app's `Info.plist` file, with the key `io.flutter.embedded_views_preview` and the value `YES`.

Also, note that on Android it requires **Android API 20+** (see [AndroidView](https://api.flutter.dev/flutter/widgets/AndroidView-class.html)).

Use `InAppWebViewController` to control the WebView instance.
Example:
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          title: const Text('InAppWebView Example'),
        ),
        body: Container(
          child: Column(children: <Widget>[
            Container(
              padding: EdgeInsets.all(20.0),
              child: Text(
                  "CURRENT URL\n${(url.length > 50) ? url.substring(0, 50) + "..." : url}"),
            ),
            Container(
                padding: EdgeInsets.all(10.0),
                child: progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container()),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                child: InAppWebView(
                  initialUrl: "https://flutter.dev/",
                  initialHeaders: {},
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        debuggingEnabled: true,
                    )
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                    webView = controller;
                  },
                  onLoadStart: (InAppWebViewController controller, String url) {
                    setState(() {
                      this.url = url;
                    });
                  },
                  onLoadStop: (InAppWebViewController controller, String url) async {
                    setState(() {
                      this.url = url;
                    });
                  },
                  onProgressChanged: (InAppWebViewController controller, int progress) {
                    setState(() {
                      this.progress = progress / 100;
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
        ])),
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

#### `InAppWebViewController` Methods

##### `InAppWebViewController` Cross-platform methods

* `getUrl`: Gets the URL for the current page.
* `getTitle`: Gets the title for the current page.
* `getProgress`: Gets the progress for the current page. The progress value is between 0 and 100.
* `getHtml`: Gets the content html of the page.
* `getFavicons`: Gets the list of all favicons for the current page.
* `loadUrl({@required String url, Map<String, String> headers = const {}})`: Loads the given url with optional headers specified as a map from name to value.
* `postUrl({@required String url, @required Uint8List postData})`: Loads the given url with postData using `POST` method into this WebView.
* `loadData({@required String data, String mimeType = "text/html", String encoding = "utf8", String baseUrl = "about:blank", String androidHistoryUrl = "about:blank"})`: Loads the given data into this WebView.
* `loadFile({@required String assetFilePath, Map<String, String> headers = const {}})`: Loads the given `assetFilePath` with optional headers specified as a map from name to value.
* `reload`: Reloads the WebView.
* `goBack`: Goes back in the history of the WebView.
* `canGoBack`: Returns a boolean value indicating whether the WebView can move backward.
* `goForward`: Goes forward in the history of the WebView.
* `canGoForward`: Returns a boolean value indicating whether the WebView can move forward.
* `goBackOrForward({@required int steps})`: Goes to the history item that is the number of steps away from the current item. Steps is negative if backward and positive if forward.
* `canGoBackOrForward({@required int steps})`: Returns a boolean value indicating whether the WebView can go back or forward the given number of steps. Steps is negative if backward and positive if forward.
* `goTo({@required WebHistoryItem historyItem})`: Navigates to a `WebHistoryItem` from the back-forward `WebHistory.list` and sets it as the current item.
* `isLoading`: Check if the WebView instance is in a loading state.
* `stopLoading`: Stops the WebView from loading.
* `evaluateJavascript({@required String source})`: Evaluates JavaScript code into the WebView and returns the result of the evaluation.
* `injectJavascriptFileFromUrl({@required String urlFile})`: Injects an external JavaScript file into the WebView from a defined url.
* `injectJavascriptFileFromAsset({@required String assetFilePath})`: Injects a JavaScript file into the WebView from the flutter assets directory.
* `injectCSSCode({@required String source})`: Injects CSS into the WebView.
* `injectCSSFileFromUrl({@required String urlFile})`: Injects an external CSS file into the WebView from a defined url.
* `injectCSSFileFromAsset({@required String assetFilePath})`: Injects a CSS file into the WebView from the flutter assets directory.
* `addJavaScriptHandler({@required String handlerName, @required JavaScriptHandlerCallback callback})`: Adds a JavaScript message handler callback that listen to post messages sent from JavaScript by the handler with name `handlerName`.
* `removeJavaScriptHandler({@required String handlerName})`: Removes a JavaScript message handler previously added with the `addJavaScriptHandler()` associated to `handlerName` key.
* `takeScreenshot`: Takes a screenshot (in PNG format) of the WebView's visible viewport and returns a `Uint8List`. Returns `null` if it wasn't be able to take it.
* `setOptions({@required InAppWebViewGroupOptions options})`: Sets the WebView options with the new options and evaluates them.
* `getOptions`: Gets the current WebView options. Returns the options with `null` value if they are not set yet.
* `getCopyBackForwardList`: Gets the `WebHistory` for this WebView. This contains the back/forward list for use in querying each item in the history stack.
* `clearCache`: Clears all the webview's cache.
* `findAllAsync({@required String find})`: Finds all instances of find on the page and highlights them. Notifies `onFindResultReceived` listener.
* `findNext({@required bool forward})`: Highlights and scrolls to the next match found by `findAllAsync()`. Notifies `onFindResultReceived` listener.
* `clearMatches`: Clears the highlighting surrounding text matches created by `findAllAsync()`.
* `getTRexRunnerHtml`: Gets the html (with javascript) of the Chromium's t-rex runner game. Used in combination with `getTRexRunnerCss()`.
* `getTRexRunnerCss`: Gets the css of the Chromium's t-rex runner game. Used in combination with `getTRexRunnerHtml()`.
* `scrollTo({@required int x, @required int y, bool animated = false})`: Scrolls the WebView to the position.
* `scrollBy({@required int x, @required int y, bool animated = false})`: Moves the scrolled position of the WebView.
* `pauseTimers`: On Android, it pauses all layout, parsing, and JavaScript timers for all WebViews. This is a global requests, not restricted to just this WebView. This can be useful if the application has been paused. On iOS, it is restricted to just this WebView.
* `resumeTimers`: On Android, it resumes all layout, parsing, and JavaScript timers for all WebViews. This will resume dispatching all timers. On iOS, it resumes all layout, parsing, and JavaScript timers to just this WebView.
* `printCurrentPage`: Prints the current page.
* `getScale`: Gets the current scale of this WebView.
* `getSelectedText`: Gets the selected text.
* `getHitTestResult`: Gets the hit result for hitting an HTML elements.
* `clearFocus`: Clears the current focus. It will clear also, for example, the current text selection.
* `setContextMenu(ContextMenu contextMenu)`: Sets or updates the WebView context menu to be used next time it will appear.
* `requestFocusNodeHref`: Requests the anchor or image element URL at the last tapped point.
* `requestImageRef`: Requests the URL of the image last touched by the user.
* `getMetaTags`: Returns the list of `<meta>` tags of the current WebView.
* `getMetaThemeColor`: Returns an instance of `Color` representing the `content` value of the `<meta name="theme-color" content="">` tag of the current WebView, if available, otherwise `null`.
* `getScrollX`: Returns the scrolled left position of the current WebView.
* `getScrollY`: Returns the scrolled top position of the current WebView.
* `getCertificate`: Gets the SSL certificate for the main top-level page or null if there is no certificate (the site is not secure).
* `static getDefaultUserAgent`: Gets the default user agent.

##### `InAppWebViewController.webStorage`

`InAppWebViewController.webStorage` provides access to the JavaScript [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API):
* `WebStorage.localStorage`: provides access to `window.localStorage`;
* `WebStorage.sessionStorage`: provides access to `window.sessionStorage`.

Methods available:
* `length`: Returns an integer representing the number of data items stored in the Storage object.
* `setItem({@required String key, @required dynamic value})`: When passed a `key` name and `value`, will add that key to the storage, or update that key's value if it already exists.
* `getItem({@required String key})`: When passed a `key` name, will return that key's value, or `null` if the key does not exist, in the given Storage object.
* `removeItem({@required String key})`: When passed a `key` name, will remove that key from the given Storage object if it exists.
* `getItems`: Returns the list of all items from the given Storage object.
* `clear`: Clears all keys stored in a given Storage object.
* `key({@required int index})`: When passed a number `index`, returns the name of the nth key in a given Storage object.

##### `InAppWebViewController` Android-specific methods

Android-specific methods can be called using the `InAppWebViewController.android` attribute.

* `startSafeBrowsing`: Starts Safe Browsing initialization.
* `clearSslPreferences`: Clears the SSL preferences table stored in response to proceeding with SSL certificate errors.
* `pause`: Does a best-effort attempt to pause any processing that can be paused safely, such as animations and geolocation. Note that this call does not pause JavaScript.
* `resume`: Resumes a WebView after a previous call to `pause()`.
* `getOriginalUrl`: Gets the URL that was originally requested for the current page.
* `pageDown({@required bool bottom})`: Scrolls the contents of this WebView down by half the page size.
* `pageUp({@required bool top})`: Scrolls the contents of this WebView up by half the view size.
* `saveWebArchive({@required String basename, @required bool autoname})`: Saves the current view as a web archive.
* `zoomIn`: Performs zoom in in this WebView.
* `zoomOut`: Performs zoom out in this WebView.
* `clearHistory`: Clears the internal back/forward list.
* `static clearClientCertPreferences`: Clears the client certificate preferences stored in response to proceeding/cancelling client cert requests.
* `static getSafeBrowsingPrivacyPolicyUrl`: Returns a URL pointing to the privacy policy for Safe Browsing reporting. This value will never be `null`.
* `static setSafeBrowsingWhitelist({@required List<String> hosts})`: Sets the list of hosts (domain names/IP addresses) that are exempt from SafeBrowsing checks. The list is global for all the WebViews.
* `static getCurrentWebViewPackage`: Gets the current Android WebView package info.

##### `InAppWebViewController` iOS-specific methods

iOS-specific methods can be called using the `InAppWebViewController.ios` attribute.

* `hasOnlySecureContent`: A Boolean value indicating whether all resources on the page have been loaded over securely encrypted connections.
* `reloadFromOrigin`: Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible.

##### About the JavaScript handler

The Android implementation uses [addJavascriptInterface](https://developer.android.com/reference/android/webkit/WebView#addJavascriptInterface(java.lang.Object,%20java.lang.String)).
The iOS implementation uses [addScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537172-addscriptmessagehandler?language=objc)

The JavaScript function that can be used to call the handler is `window.flutter_inappwebview.callHandler(handlerName <String>, ...args)`, where `args` are [rest parameters](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters).
The `args` will be stringified automatically using `JSON.stringify(args)` method and then they will be decoded on the Dart side.

In order to call `window.flutter_inappwebview.callHandler(handlerName <String>, ...args)` properly, you need to wait and listen the JavaScript event `flutterInAppWebViewPlatformReady`.
This event will be dispatched as soon as the platform (Android or iOS) is ready to handle the `callHandler` method.
```javascript
   window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
     console.log("ready");
   });
```

`window.flutter_inappwebview.callHandler` returns a JavaScript [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)
that can be used to get the json result returned by `JavaScriptHandlerCallback`.
In this case, simply return data that you want to send and it will be automatically json encoded using `jsonEncode` from the `dart:convert` library.

So, on the JavaScript side, to get data coming from the Dart side, you will use:
```html
<script>
   window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
     window.flutter_inappwebview.callHandler('handlerFoo').then(function(result) {
       console.log(result);
     });

     window.flutter_inappwebview.callHandler('handlerFooWithArgs', 1, true, ['bar', 5], {foo: 'baz'}).then(function(result) {
       console.log(result);
     });
   });
</script>
```

Instead, on the `onLoadStop` WebView event, you can use `callHandler` directly:
```dart
  // Inject JavaScript that will receive data back from Flutter
  inAppWebViewController.evaluateJavascript(source: """
    window.flutter_inappwebview.callHandler('test', 'Text from Javascript').then(function(result) {
      console.log(result);
    });
  """);
```

#### `InAppWebView` options

##### `InAppWebView` Cross-platform options

* `useShouldOverrideUrlLoading`: Set to `true` to be able to listen at the `shouldOverrideUrlLoading` event. The default value is `false`.
* `useOnLoadResource`: Set to `true` to be able to listen at the `onLoadResource` event. The default value is `false`.
* `useOnDownloadStart`: Set to `true` to be able to listen at the `onDownloadStart` event. The default value is `false`.
* `useShouldInterceptAjaxRequest`: Set to `true` to be able to listen at the `shouldInterceptAjaxRequest` event. The default value is `false`.
* `useShouldInterceptFetchRequest`: Set to `true` to be able to listen at the `shouldInterceptFetchRequest` event. The default value is `false`.
* `clearCache`: Set to `true` to have all the browser's cache cleared before the new WebView is opened. The default value is `false`.
* `userAgent`: Sets the user-agent for the WebView.
* `applicationNameForUserAgent`: Append to the existing user-agent. Setting userAgent will override this.
* `javaScriptEnabled`: Set to `true` to enable JavaScript. The default value is `true`.
* `debuggingEnabled`: Enables debugging of web contents (HTML / CSS / JavaScript) loaded into any WebViews of this application.
* `javaScriptCanOpenWindowsAutomatically`: Set to `true` to allow JavaScript open windows without user interaction. The default value is `false`.
* `mediaPlaybackRequiresUserGesture`: Set to `true` to prevent HTML5 audio or video from autoplaying. The default value is `true`.
* `minimumFontSize`: Sets the minimum font size. The default value is `8` for Android, `0` for iOS.
* `verticalScrollBarEnabled`: Define whether the vertical scrollbar should be drawn or not. The default value is `true`.
* `horizontalScrollBarEnabled`: Define whether the horizontal scrollbar should be drawn or not. The default value is `true`.
* `resourceCustomSchemes`: List of custom schemes that the WebView must handle. Use the `onLoadResourceCustomScheme` event to intercept resource requests with custom scheme.
* `contentBlockers`: List of `ContentBlocker` that are a set of rules used to block content in the browser window.
* `preferredContentMode`: Sets the content mode that the WebView needs to use when loading and rendering a webpage. The default value is `InAppWebViewUserPreferredContentMode.RECOMMENDED`.
* `incognito`: Set to `true` to open a browser window with incognito mode. The default value is `false`.
* `cacheEnabled`: Sets whether WebView should use browser caching. The default value is `true`.
* `transparentBackground`: Set to `true` to make the background of the WebView transparent. If your app has a dark theme, this can prevent a white flash on initialization. The default value is `false`.
* `disableVerticalScroll`: Set to `true` to disable vertical scroll. The default value is `false`.
* `disableHorizontalScroll`: Set to `true` to disable horizontal scroll. The default value is `false`.
* `disableContextMenu`: Set to `true` to disable context menu. The default value is `false`.
* `supportZoom`: Set to `false` if the WebView should not support zooming using its on-screen zoom controls and gestures. The default value is `true`.

##### `InAppWebView` Android-specific options

* `useShouldInterceptRequest`: Set to `true` to be able to listen at the `androidShouldInterceptRequest` event. The default value is `false`.
* `useOnRenderProcessGone`: Set to `true` to be able to listen at the `androidOnRenderProcessGone` event. The default value is `false`.
* `textZoom`: Sets the text zoom of the page in percent. The default value is `100`.
* `clearSessionCache`: Set to `true` to have the session cookie cache cleared before the new window is opened.
* `builtInZoomControls`: Set to `true` if the WebView should use its built-in zoom mechanisms. The default value is `true`.
* `displayZoomControls`: Set to `true` if the WebView should display on-screen zoom controls when using the built-in zoom mechanisms. The default value is `false`.
* `databaseEnabled`: Set to `true` if you want the database storage API is enabled. The default value is `true`.
* `domStorageEnabled`: Set to `true` if you want the DOM storage API is enabled. The default value is `true`.
* `useWideViewPort`: Set to `true` if the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport.
* `safeBrowsingEnabled`: Sets whether Safe Browsing is enabled. Safe Browsing allows WebView to protect against malware and phishing attacks by verifying the links.
* `mixedContentMode`: Configures the WebView's behavior when a secure origin attempts to load a resource from an insecure origin.
* `allowContentAccess`: Enables or disables content URL access within WebView. Content URL access allows WebView to load content from a content provider installed in the system. The default value is `true`.
* `allowFileAccess`: Enables or disables file access within WebView. Note that this enables or disables file system access only.
* `allowFileAccessFromFileURLs`: Sets whether JavaScript running in the context of a file scheme URL should be allowed to access content from other file scheme URLs.
* `allowUniversalAccessFromFileURLs`: Sets whether JavaScript running in the context of a file scheme URL should be allowed to access content from any origin.
* `appCachePath`: Sets the path to the Application Caches files. In order for the Application Caches API to be enabled, this option must be set a path to which the application can write.
* `blockNetworkImage`: Sets whether the WebView should not load image resources from the network (resources accessed via http and https URI schemes). The default value is `false`.
* `blockNetworkLoads`: Sets whether the WebView should not load resources from the network. The default value is `false`.
* `cacheMode`: Overrides the way the cache is used. The way the cache is used is based on the navigation type. For a normal page load, the cache is checked and content is re-validated as needed.
* `cursiveFontFamily`: Sets the cursive font family name. The default value is `"cursive"`.
* `defaultFixedFontSize`: Sets the default fixed font size. The default value is `16`.
* `defaultFontSize`: Sets the default font size. The default value is `16`.
* `defaultTextEncodingName`: Sets the default text encoding name to use when decoding html pages. The default value is `"UTF-8"`.
* `disabledActionModeMenuItems`: Disables the action mode menu items according to menuItems flag.
* `fantasyFontFamily`: Sets the fantasy font family name. The default value is `"fantasy"`.
* `fixedFontFamily`: Sets the fixed font family name. The default value is `"monospace"`.
* `forceDark`: Set the force dark mode for this WebView. The default value is `AndroidInAppWebViewForceDark.FORCE_DARK_OFF`.
* `geolocationEnabled`: Sets whether Geolocation API is enabled. The default value is `true`.
* `layoutAlgorithm`: Sets the underlying layout algorithm. This will cause a re-layout of the WebView.
* `loadWithOverviewMode`: Sets whether the WebView loads pages in overview mode, that is, zooms out the content to fit on screen by width.
* `loadsImagesAutomatically`: Sets whether the WebView should load image resources. Note that this method controls loading of all images, including those embedded using the data URI scheme.
* `minimumLogicalFontSize`: Sets the minimum logical font size. The default is `8`.
* `initialScale`: Sets the initial scale for this WebView. 0 means default. The behavior for the default scale depends on the state of `useWideViewPort` and `loadWithOverviewMode`.
* `needInitialFocus`: Tells the WebView whether it needs to set a node. The default value is `true`.
* `offscreenPreRaster`: Sets whether this WebView should raster tiles when it is offscreen but attached to a window.
* `sansSerifFontFamily`: Sets the sans-serif font family name. The default value is `"sans-serif"`.
* `serifFontFamily`: Sets the serif font family name. The default value is `"sans-serif"`.
* `standardFontFamily`: Sets the standard font family name. The default value is `"sans-serif"`.
* `saveFormData`: Sets whether the WebView should save form data. In Android O, the platform has implemented a fully functional Autofill feature to store form data.
* `thirdPartyCookiesEnabled`: Boolean value to enable third party cookies in the WebView.
* `hardwareAcceleration`: Boolean value to enable Hardware Acceleration in the WebView.
* `supportMultipleWindows`: Sets whether the WebView whether supports multiple windows.
* `regexToCancelSubFramesLoading`: Regular expression used by `shouldOverrideUrlLoading` event to cancel navigation for frames that are not the main frame. If the url request of a subframe matches the regular expression, then the request of that subframe is canceled.
* `overScrollMode`: Sets the WebView's over-scroll mode. The default value is `AndroidOverScrollMode.OVER_SCROLL_IF_CONTENT_SCROLLS`.
* `scrollBarStyle`: Specify the style of the scrollbars. The scrollbars can be overlaid or inset. The default value is `AndroidScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY`.
* `verticalScrollbarPosition`: Set the position of the vertical scroll bar. The default value is `AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT`.
* `scrollBarDefaultDelayBeforeFade`: Defines the delay in milliseconds that a scrollbar waits before fade out.
* `scrollbarFadingEnabled`: Define whether scrollbars will fade when the view is not scrolling. The default value is `true`.
* `scrollBarFadeDuration`: Define the scrollbar fade duration in milliseconds.
* `rendererPriorityPolicy`: Set the renderer priority policy for this WebView.
* `disableDefaultErrorPage`: Sets whether the default Android error page should be disabled. The default value is `false`.

##### `InAppWebView` iOS-specific options

* `disallowOverScroll`: Set to `true` to disable the bouncing of the WebView when the scrolling has reached an edge of the content. The default value is `false`.
* `enableViewportScale`: Set to `true` to allow a viewport meta tag to either disable or restrict the range of user scaling. The default value is `false`.
* `suppressesIncrementalRendering`: Set to `true` if you want the WebView suppresses content rendering until it is fully loaded into memory. The default value is `false`.
* `allowsAirPlayForMediaPlayback`: Set to `true` to allow AirPlay. The default value is `true`.
* `allowsBackForwardNavigationGestures`: Set to `true` to allow the horizontal swipe gestures trigger back-forward list navigations. The default value is `true`.
* `allowsLinkPreview`: Set to `true` to allow that pressing on a link displays a preview of the destination for the link. The default value is `true`.
* `ignoresViewportScaleLimits`: Set to `true` if you want that the WebView should always allow scaling of the webpage, regardless of the author's intent.
* `allowsInlineMediaPlayback`: Set to `true` to allow HTML5 media playback to appear inline within the screen layout, using browser-supplied controls rather than native controls.
* `allowsPictureInPictureMediaPlayback`: Set to `true` to allow HTML5 videos play picture-in-picture. The default value is `true`.
* `isFraudulentWebsiteWarningEnabled`: A Boolean value indicating whether warnings should be shown for suspected fraudulent content such as phishing or malware.
* `selectionGranularity`: The level of granularity with which the user can interactively select content in the web view.
* `dataDetectorTypes`: Specifying a dataDetectoryTypes value adds interactivity to web content that matches the value.
* `sharedCookiesEnabled`: Set `true` if shared cookies from `HTTPCookieStorage.shared` should used for every load request in the WebView.
* `automaticallyAdjustsScrollIndicatorInsets`: Configures whether the scroll indicator insets are automatically adjusted by the system. The default value is `false`.
* `accessibilityIgnoresInvertColors`: A Boolean value indicating whether the view ignores an accessibility request to invert its colors. The default value is `false`.
* `decelerationRate`: A `IOSUIScrollViewDecelerationRate` value that determines the rate of deceleration after the user lifts their finger. The default value is `IOSUIScrollViewDecelerationRate.NORMAL`.
* `alwaysBounceVertical`: A Boolean value that determines whether bouncing always occurs when vertical scrolling reaches the end of the content. The default value is `false`.
* `alwaysBounceHorizontal`: A Boolean value that determines whether bouncing always occurs when horizontal scrolling reaches the end of the content view. The default value is `false`.
* `scrollsToTop`: A Boolean value that controls whether the scroll-to-top gesture is enabled. The default value is `true`.
* `isPagingEnabled`: A Boolean value that determines whether paging is enabled for the scroll view. The default value is `false`.
* `maximumZoomScale`: A floating-point value that specifies the maximum scale factor that can be applied to the scroll view's content. The default value is `1.0`.
* `minimumZoomScale`: A floating-point value that specifies the minimum scale factor that can be applied to the scroll view's content. The default value is `1.0`.
* `contentInsetAdjustmentBehavior`: Configures how safe area insets are added to the adjusted content inset. The default value is `IOSUIScrollViewContentInsetAdjustmentBehavior.NEVER`.

#### `InAppWebView` Events

Event names that starts with `android` or `ios` are events platform-specific.  

* `onWebViewCreated`: Event fired when the InAppWebView is created.
* `onLoadStart`: Event fired when the InAppWebView starts to load an url.
* `onLoadStop`: Event fired when the InAppWebView finishes loading an url.
* `onLoadError`: Event fired when the InAppWebView encounters an error loading an url.
* `onLoadHttpError`: Event fired when the InAppWebView main page receives an HTTP error.
* `onProgressChanged`: Event fired when the current progress of loading a page is changed.
* `onConsoleMessage`: Event fired when the InAppWebView receives a ConsoleMessage.
* `shouldOverrideUrlLoading`: Give the host application a chance to take control when a URL is about to be loaded in the current WebView (to use this event, the `useShouldOverrideUrlLoading` option must be `true`). This event is not called on the initial load of the WebView.
* `onUpdateVisitedHistory`: Event fired when the host application updates its visited links database. This event is also fired when the navigation state of the InAppWebView changes, for example through the usage of the javascript **[History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API)** functions.
* `onLoadResource`: Event fired when the InAppWebView loads a resource (to use this event, the `useOnLoadResource` option must be `true`).
* `onScrollChanged`: Event fired when the InAppWebView scrolls.
* `onDownloadStart`: Event fired when InAppWebView recognizes a downloadable file (to use this event, the `useOnDownloadStart` option must be `true`). To download the file, you can use the [flutter_downloader](https://pub.dev/packages/flutter_downloader) plugin.
* `onLoadResourceCustomScheme`: Event fired when the InAppWebView finds the `custom-scheme` while loading a resource. Here you can handle the url request and return a CustomSchemeResponse to load a specific resource encoded to `base64`.
* `onCreateWindow`: Event fired when the InAppWebView requests the host application to create a new window, for example when trying to open a link with `target="_blank"` or when `window.open()` is called by JavaScript side.
* `onCloseWindow`: Event fired when the host application should close the given WebView and remove it from the view system if necessary.
* `onJsAlert`: Event fired when javascript calls the `alert()` method to display an alert dialog.
* `onJsConfirm`: Event fired when javascript calls the `confirm()` method to display a confirm dialog.
* `onJsPrompt`: Event fired when javascript calls the `prompt()` method to display a prompt dialog.
* `onReceivedHttpAuthRequest`: Event fired when the WebView received an HTTP authentication request. The default behavior is to cancel the request.
* `onReceivedServerTrustAuthRequest`: Event fired when the WebView need to perform server trust authentication (certificate validation).
* `onReceivedClientCertRequest`: Notify the host application to handle an SSL client certificate request.
* `onFindResultReceived`: Event fired as find-on-page operations progress.
* `shouldInterceptAjaxRequest`: Event fired when an `XMLHttpRequest` is sent to a server (to use this event, the `useShouldInterceptAjaxRequest` option must be `true`).
* `onAjaxReadyStateChange`: Event fired whenever the `readyState` attribute of an `XMLHttpRequest` changes (to use this event, the `useShouldInterceptAjaxRequest` option must be `true`).
* `onAjaxProgress`: Event fired as an `XMLHttpRequest` progress (to use this event, the `useShouldInterceptAjaxRequest` option must be `true`).
* `shouldInterceptFetchRequest`: Event fired when a request is sent to a server through [Fetch API](https://developer.mozilla.org/it/docs/Web/API/Fetch_API) (to use this event, the `useShouldInterceptFetchRequest` option must be `true`).
* `onPrint`: Event fired when `window.print()` is called from JavaScript side.
* `onLongPressHitTestResult`: Event fired when an HTML element of the webview has been clicked and held.
* `onEnterFullscreen`: Event fired when the current page has entered full screen mode.
* `onExitFullscreen`: Event fired when the current page has exited full screen mode.
* `onPageCommitVisible`: Called when the web view begins to receive web content.
* `onTitleChanged`: Event fired when a change in the document title occurred.
* `onWindowFocus`: Event fired when the JavaScript `window` object of the WebView has received focus. This is the result of the `focus` JavaScript event applied to the `window` object.
* `onWindowBlur`: Event fired when the JavaScript `window` object of the WebView has lost focus. This is the result of the `blur` JavaScript event applied to the `window` object.
* `androidOnSafeBrowsingHit`: Event fired when the webview notifies that a loading URL has been flagged by Safe Browsing (available only on Android).
* `androidOnPermissionRequest`: Event fired when the webview is requesting permission to access the specified resources and the permission currently isn't granted or denied (available only on Android).
* `androidOnGeolocationPermissionsShowPrompt`: Event that notifies the host application that web content from the specified origin is attempting to use the Geolocation API, but no permission state is currently set for that origin (available only on Android).
* `androidOnGeolocationPermissionsHidePrompt`: Notify the host application that a request for Geolocation permissions, made with a previous call to `androidOnGeolocationPermissionsShowPrompt` has been canceled (available only on Android).
* `androidShouldInterceptRequest`: Notify the host application of a resource request and allow the application to return the data (available only on Android). To use this event, the `useShouldInterceptRequest` option must be `true`.
* `androidOnRenderProcessGone`: Event fired when the given WebView's render process has exited (available only on Android).
* `androidOnRenderProcessResponsive`: Event called once when an unresponsive renderer currently associated with the WebView becomes responsive (available only on Android).
* `androidOnRenderProcessUnresponsive`: Event called when the renderer currently associated with the WebView becomes unresponsive as a result of a long running blocking task such as the execution of JavaScript (available only on Android).
* `androidOnFormResubmission`: As the host application if the browser should resend data as the requested page was a result of a POST. The default is to not resend the data (available only on Android).
* `androidOnScaleChanged`: Event fired when the scale applied to the WebView has changed (available only on Android).
* `androidOnRequestFocus`: Event fired when there is a request to display and focus for this WebView (available only on Android).
* `androidOnReceivedIcon`: Event fired when there is new favicon for the current page (available only on Android).
* `androidOnReceivedTouchIconUrl`: Event fired when there is an url for an apple-touch-icon (available only on Android).
* `androidOnJsBeforeUnload`: Event fired when the client should display a dialog to confirm navigation away from the current page. This is the result of the `onbeforeunload` javascript event (available only on Android).
* `androidOnReceivedLoginRequest`: Event fired when a request to automatically log in the user has been processed (available only on Android).
* `iosOnWebContentProcessDidTerminate`: Invoked when the web view's web content process is terminated (available only on iOS).
* `iosOnDidReceiveServerRedirectForProvisionalNavigation`: Called when a web view receives a server redirect (available only on iOS).

### `ContextMenu` class

Class that represents the WebView context menu. It used by `WebView.contextMenu`.

`ContextMenu.menuItems` contains the list of the custom `ContextMenuItem`.

**NOTE**: To make it work properly on Android, JavaScript should be enabled!

Example:
```dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  InAppWebViewController webView;
  ContextMenu contextMenu;
  String url = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(androidId: 1, iosId: "1", title: "Special", action: () async {
            print("Menu item Special clicked!");
          })
        ],
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webView.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) {
          var id = (Platform.isAndroid) ? contextMenuItemClicked.androidId : contextMenuItemClicked.iosId;
          print("onContextMenuActionItemClicked: " + id.toString() + " " + contextMenuItemClicked.title);
        }
    );

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
          title: const Text('InAppWebView Example'),
        ),
        body: Container(
            child: Column(children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: Text(
                    "CURRENT URL\n${(url.length > 50) ? url.substring(0, 50) + "..." : url}"),
              ),
              Container(
                  padding: EdgeInsets.all(10.0),
                  child: progress < 1.0
                      ? LinearProgressIndicator(value: progress)
                      : Container()),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration:
                  BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                  child: InAppWebView(
                    initialUrl: "https://flutter.dev/",
                    contextMenu: contextMenu,
                    initialHeaders: {},
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          debuggingEnabled: true,
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {
                      setState(() {
                        this.url = url;
                      });
                    },
                    onLoadStop: (InAppWebViewController controller, String url) async {
                      setState(() {
                        this.url = url;
                      });
                    },
                    onProgressChanged: (InAppWebViewController controller, int progress) {
                      setState(() {
                        this.progress = progress / 100;
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
            ])),
      ),
    );
  }
}
```

### `ContextMenu` options

* `hideDefaultSystemContextMenuItems`: Whether all the default system context menu items should be hidden or not. The default value is `false`.

### `ContextMenu` Events

* `onCreateContextMenu`: Event fired when the context menu for this WebView is being built.
* `onHideContextMenu`: Event fired when the context menu for this WebView is being hidden.
* `onContextMenuActionItemClicked`: Event fired when a context menu item has been clicked. 

### `HeadlessInAppWebView` class

Class that represents a WebView in headless mode. It can be used to run a WebView in background without attaching an `InAppWebView` to the widget tree.

Remember to dispose it when you don't need it anymore.

As `InAppWebView`, it has the same options and events. Use `InAppWebViewController` to control the WebView instance.

Example:
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  HeadlessInAppWebView headlessWebView;
  String url = "";

  @override
  void initState() {
    super.initState();

    headlessWebView = new HeadlessInAppWebView(
      initialUrl: "https://flutter.dev/",
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          debuggingEnabled: true,
        ),
      ),
      onWebViewCreated: (controller) {
        print('HeadlessInAppWebView created!');
      },
      onConsoleMessage: (controller, consoleMessage) {
        print("CONSOLE MESSAGE: " + consoleMessage.message);
      },
      onLoadStart: (controller, url) async {
        print("onLoadStart $url");
        setState(() {
          this.url = url;
        });
      },
      onLoadStop: (controller, url) async {
        print("onLoadStop $url");
        setState(() {
          this.url = url;
        });
      },
      onUpdateVisitedHistory: (InAppWebViewController controller, String url, bool androidIsReload) {
        print("onUpdateVisitedHistory $url");
        setState(() {
          this.url = url;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    headlessWebView.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              "HeadlessInAppWebView",
            )),
        body: SafeArea(
            child: Column(children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: Text(
                    "CURRENT URL\n${(url.length > 50) ? url.substring(0, 50) + "..." : url}"),
              ),
              Center(
                child: RaisedButton(
                    onPressed: () async {
                      await headlessWebView.dispose();
                      await headlessWebView.run();
                    },
                    child: Text("Run HeadlessInAppWebView")),
              ),
              Center(
                child: RaisedButton(
                    onPressed: () async {
                      try {
                        await headlessWebView.webViewController.evaluateJavascript(source: """console.log('Here is the message!');""");
                      } on MissingPluginException catch(e) {
                        print("HeadlessInAppWebView is not running. Click on \"Run HeadlessInAppWebView\"!");
                      }
                    },
                    child: Text("Send console.log message")),
              ),
              Center(
                child: RaisedButton(
                    onPressed: () {
                      headlessWebView.dispose();
                    },
                    child: Text("Dispose HeadlessInAppWebView")),
              )
            ])
        )
    );
  }
}
```

### `InAppBrowser` class

In-App Browser using native WebView.

`inAppBrowser.webViewController` can be used to access the `InAppWebView` API.

Create a Class that extends the `InAppBrowser` Class in order to override the callbacks to manage the browser events.
Example:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyInAppBrowser extends InAppBrowser {
  @override
  Future onBrowserCreated() async {
    print("\n\nBrowser Created!\n\n");
  }

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
    print("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(int progress) {
    print("Progress: $progress");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }

  @override
  Future<ShouldOverrideUrlLoadingAction> shouldOverrideUrlLoading(ShouldOverrideUrlLoadingRequest shouldOverrideUrlLoadingRequest) async {
    print("\n\n override ${shouldOverrideUrlLoadingRequest.url}\n\n");
    return ShouldOverrideUrlLoadingAction.ALLOW;
  }

  @override
  void onLoadResource(LoadedResource response) {
    print("Started at: " +
        response.startTime.toString() +
        "ms ---> duration: " +
        response.duration.toString() +
        "ms " +
        response.url);
  }

  @override
  void onConsoleMessage(ConsoleMessage consoleMessage) {
    print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    new MyApp(),
  );
}

class MyApp extends StatefulWidget {
  final MyInAppBrowser browser = new MyInAppBrowser();
  
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('InAppBrowser Example'),
        ),
        body: Center(
          child: RaisedButton(
              onPressed: () {
                widget.browser.openFile(
                    assetFilePath: "assets/index.html",
                    options: InAppBrowserClassOptions(
                        inAppWebViewGroupOptions: InAppWebViewGroupOptions(
                            crossPlatform: InAppWebViewOptions(
                              useShouldOverrideUrlLoading: true,
                              useOnLoadResource: true,
                            ))));
              },
              child: Text("Open InAppBrowser")),
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

#### `InAppBrowser` Methods

* `open({String url = "about:blank", Map<String, String> headers = const {}, InAppBrowserClassOptions options})`: Opens an `url` in a new `InAppBrowser` instance.
* `openFile({@required String assetFilePath, Map<String, String> headers = const {}, InAppBrowserClassOptions options})`: Opens the given `assetFilePath` file in a new `InAppBrowser` instance. The other arguments are the same of `InAppBrowser.open`.
* `openData({@required String data, String mimeType = "text/html", String encoding = "utf8", String baseUrl = "about:blank", String historyUrl = "about:blank", InAppBrowserClassOptions options})`: Opens a new `InAppBrowser` instance with `data` as a content, using `baseUrl` as the base URL for it.
* `openWithSystemBrowser({@required String url})`: This is a static method that opens an `url` in the system browser. You wont be able to use the `InAppBrowser` methods here!
* `show`: Displays an `InAppBrowser` window that was opened hidden. Calling this has no effect if the `InAppBrowser` was already visible.
* `hide`: Hides the `InAppBrowser` window. Calling this has no effect if the `InAppBrowser` was already hidden.
* `close`: Closes the `InAppBrowser` window.
* `isHidden`: Check if the Web View of the `InAppBrowser` instance is hidden.
* `setOptions({@required InAppBrowserClassOptions options})`: Sets the `InAppBrowser` options with the new `options` and evaluates them.
* `getOptions`: Gets the current `InAppBrowser` options as a `Map`. Returns `null` if the options are not setted yet.
* `isOpened`: Returns `true` if the `InAppBrowser` instance is opened, otherwise `false`.

#### `InAppBrowser` options

They are the same of the `InAppWebView` class. 
Specific options of the `InAppBrowser` class are:

##### `InAppBrowser` Cross-platform options

* `hidden`: Set to `true` to create the browser and load the page, but not show it. Omit or set to `false` to have the browser open and load normally. The default value is `false`.
* `toolbarTop`: Set to `false` to hide the toolbar at the top of the WebView. The default value is `true`.
* `toolbarTopBackgroundColor`: Set the custom background color of the toolbar at the top.
* `hideUrlBar`: Set to `true` to hide the url bar on the toolbar at the top. The default value is `false`.

##### `InAppBrowser` Android-specific options

* `hideTitleBar`: Set to `true` if you want the title should be displayed. The default value is `false`.
* `toolbarTopFixedTitle`: Set the action bar's title.
* `closeOnCannotGoBack`: Set to `false` to not close the InAppBrowser when the user click on the back button and the WebView cannot go back to the history. The default value is `true`.
* `progressBar`: Set to `false` to hide the progress bar at the bottom of the toolbar at the top. The default value is `true`.

##### `InAppBrowser` iOS-specific options

* `toolbarBottom`: Set to `false` to hide the toolbar at the bottom of the WebView. The default value is `true`.
* `toolbarBottomBackgroundColor`: Set the custom background color of the toolbar at the bottom.
* `toolbarBottomTranslucent`: Set to `true` to set the toolbar at the bottom translucent. The default value is `true`.
* `closeButtonCaption`: Set the custom text for the close button.
* `closeButtonColor`: Set the custom color for the close button.
* `presentationStyle`: Set the custom modal presentation style when presenting the WebView. The default value is `IOSUIModalPresentationStyle.FULL_SCREEN`.
* `transitionStyle`: Set to the custom transition style when presenting the WebView. The default value is `IOSUIModalTransitionStyle.COVER_VERTICAL`.
* `spinner`: Set to `false` to hide the spinner when the WebView is loading a page. The default value is `true`.

#### `InAppBrowser` Events

They are the same of the `InAppWebView` class, except for `InAppWebView.onWebViewCreated` event. 
Specific events of the `InAppBrowser` class are:

* `onBrowserCreated`: Event fired when the `InAppBrowser` is created.
* `onExit`: Event fired when the `InAppBrowser` window is closed.

### `ChromeSafariBrowser` class

[Chrome Custom Tabs](https://developer.android.com/reference/android/support/customtabs/package-summary) on Android / [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) on iOS.

You can initialize the `ChromeSafariBrowser` instance with an `InAppBrowser` fallback instance.

Create a Class that extends the `ChromeSafariBrowser` Class in order to override the callbacks to manage the browser events. Example:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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

class MyChromeSafariBrowser extends ChromeSafariBrowser {

  MyChromeSafariBrowser(browserFallback) : super(bFallback: browserFallback);

  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    new MyApp(),
  );
}

class MyApp extends StatefulWidget {
  final ChromeSafariBrowser browser = new MyChromeSafariBrowser(new MyInAppBrowser());

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    widget.browser.addMenuItem(new ChromeSafariBrowserMenuItem(id: 1, label: 'Custom item menu 1', action: (url, title) {
      print('Custom item menu 1 clicked!');
      print(url);
      print(title);
    }));
    widget.browser.addMenuItem(new ChromeSafariBrowserMenuItem(id: 2, label: 'Custom item menu 2', action: (url, title) {
      print('Custom item menu 2 clicked!');
      print(url);
      print(title);
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ChromeSafariBrowser Example'),
        ),
        body: Center(
          child: RaisedButton(
              onPressed: () async {
                await widget.browser.open(
                    url: "https://flutter.dev/",
                    options: ChromeSafariBrowserClassOptions(
                        android: AndroidChromeCustomTabsOptions(addDefaultShareMenuItem: false),
                        ios: IOSSafariOptions(barCollapsingEnabled: true)));
              },
              child: Text("Open Chrome Safari Browser")),
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

#### `ChromeSafariBrowser` Methods

* `open({@required String url, ChromeSafariBrowserClassOptions options, Map<String, String> headersFallback = const {}, InAppBrowserClassOptions optionsFallback})`: Opens an `url` in a new `ChromeSafariBrowser` instance.
* `isOpened`: Returns `true` if the `ChromeSafariBrowser` instance is opened, otherwise `false`.
* `close`: Closes the `ChromeSafariBrowser` instance.
* `addMenuItem`: Adds a `ChromeSafariBrowserMenuItem` to the menu.
* `addMenuItems`: Adds a list of `ChromeSafariBrowserMenuItem` to the menu.
* `static isAvailable`: On Android, returns `true` if Chrome Custom Tabs is available. On iOS, returns `true` if SFSafariViewController is available. Otherwise returns `false`.

#### `ChromeSafariBrowser` options

##### `ChromeSafariBrowser` Android-specific options

* `addDefaultShareMenuItem`: Set to `false` if you don't want the default share item to the menu. The default value is `true`.
* `showTitle`: Set to `false` if the title shouldn't be shown in the custom tab. The default value is `true`.
* `toolbarBackgroundColor`: Set the custom background color of the toolbar.
* `enableUrlBarHiding`: Set to `true` to enable the url bar to hide as the user scrolls down on the page. The default value is `false`.
* `instantAppsEnabled`: Set to `true` to enable Instant Apps. The default value is `false`.
* `packageName`: Set the name of the application package to handle the intent (for example `com.android.chrome`), or null to allow any application package.
* `keepAliveEnabled`: Set to `true` to enable Keep Alive. The default value is `false`.

##### `ChromeSafariBrowser` iOS-specific options

* `entersReaderIfAvailable`: Set to `true` if Reader mode should be entered automatically when it is available for the webpage. The default value is `false`.
* `barCollapsingEnabled`: Set to `true` to enable bar collapsing. The default value is `false`.
* `dismissButtonStyle`: Set the custom style for the dismiss button. The default value is `IOSSafariDismissButtonStyle.DONE`.
* `preferredBarTintColor`: Set the custom background color of the navigation bar and the toolbar.
* `preferredControlTintColor`: Set the custom color of the control buttons on the navigation bar and the toolbar.
* `presentationStyle`: Set the custom modal presentation style when presenting the WebView. The default value is `IOSUIModalPresentationStyle.FULL_SCREEN`.
* `transitionStyle`: Set to the custom transition style when presenting the WebView. The default value is `IOSUIModalTransitionStyle.COVER_VERTICAL`.

#### `ChromeSafariBrowser` Events

* `onOpened`: Event fires when the `ChromeSafariBrowser` is opened.
* `onCompletedInitialLoad`: Event fires when the initial URL load is complete.
* `onClosed`: Event fires when the `ChromeSafariBrowser` is closed.

### `InAppLocalhostServer` class

This class allows you to create a simple server on `http://localhost:[port]/` in order to be able to load your assets file on a server. The default `port` value is `8080`.

Example:
```dart
// ...

InAppLocalhostServer localhostServer = new InAppLocalhostServer();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await localhostServer.start();
  runApp(new MyApp());
}

// ...

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('InAppWebView Example'),
        ),
        body: Container(
          child: Column(children: <Widget>[
            Expanded(
              child: Container(
                child: InAppWebView(
                  initialUrl: "http://localhost:8080/assets/index.html",
                  initialHeaders: {},
                  initialOptions: InAppWebViewGroupOptions(
                      inAppWebViewOptions: InAppWebViewOptions(
                        debuggingEnabled: true,
                      )
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
  
                  },
                  onLoadStart: (InAppWebViewController controller, String url) {
  
                  },
                  onLoadStop: (InAppWebViewController controller, String url) {
  
                  },
                ),
              ),
            )]
          )
        ),
      ),
    );
  }

// ...

```

#### `InAppLocalhostServer` methods

* `start`: Starts a server on `http://localhost:[port]/`.
* `close`: Closes the server.

### `CookieManager` class

This class implements a singleton object (shared instance) which manages the cookies used by WebView instances.

On Android, it is implemented using [CookieManager](https://developer.android.com/reference/android/webkit/CookieManager).
On iOS, it is implemented using [WKHTTPCookieStore](https://developer.apple.com/documentation/webkit/wkhttpcookiestore).

**NOTE for iOS**: available from iOS 11.0+.

#### `CookieManager` methods

* `instance`: Gets the cookie manager shared instance.
* `setCookie({@required String url, @required String name, @required String value, String domain, String path = "/", int expiresDate, int maxAge, bool isSecure })`: Sets a cookie for the given `url`. Any existing cookie with the same `host`, `path` and `name` will be replaced with the new cookie. The cookie being set will be ignored if it is expired.
* `getCookies({@required String url})`: Gets all the cookies for the given `url`.
* `getCookie({@required String url, @required String name})`: Gets a cookie by its `name` for the given `url`.
* `deleteCookie({@required String url, @required String name, String domain = "", String path = "/"})`: Removes a cookie by its `name` for the given `url`, `domain` and `path`.
* `deleteCookies({@required String url, String domain = "", String path = "/"})`: Removes all cookies for the given `url`, `domain` and `path`.
* `deleteAllCookies()`: Removes all cookies.

### `HttpAuthCredentialDatabase` class

This class implements a singleton object (shared instance) which manages the shared HTTP auth credentials cache.
On iOS, this class uses the [URLCredentialStorage](https://developer.apple.com/documentation/foundation/urlcredentialstorage) class.
On Android, this class has a custom implementation using `android.database.sqlite.SQLiteDatabase` because [WebViewDatabase](https://developer.android.com/reference/android/webkit/WebViewDatabase) doesn't offer the same functionalities as iOS `URLCredentialStorage`.

#### `HttpAuthCredentialDatabase` methods

* `instance`: Gets the database shared instance.
* `getAllAuthCredentials`: Gets a map list of all HTTP auth credentials saved.
* `getHttpAuthCredentials({@required ProtectionSpace protectionSpace})`: Gets all the HTTP auth credentials saved for that `protectionSpace`.
* `setHttpAuthCredential({@required ProtectionSpace protectionSpace, @required HttpAuthCredential credential})`: Saves an HTTP auth `credential` for that `protectionSpace`.
* `removeHttpAuthCredential({@required ProtectionSpace protectionSpace, @required HttpAuthCredential credential})`: Removes an HTTP auth `credential` for that `protectionSpace`.
* `removeHttpAuthCredentials({@required ProtectionSpace protectionSpace})`: Removes all the HTTP auth credentials saved for that `protectionSpace`.
* `clearAllAuthCredentials()`: Removes all the HTTP auth credentials saved in the database.

### `WebStorageManager` class

This class implements a singleton object (shared instance) which manages the web storage used by WebView instances.

On Android, it is implemented using [WebStorage](https://developer.android.com/reference/android/webkit/WebStorage.html). 
On iOS, it is implemented using [WKWebsiteDataStore.default()](https://developer.apple.com/documentation/webkit/wkwebsitedatastore)

**NOTE for iOS**: available from iOS 9.0+.

#### `WebStorageManager` methods

* `instance`: Gets the WebStorage manager shared instance.

#### `WebStorageManager` Android-specific methods

Android-specific methods can be called using the `WebStorageManager.instance().android` attribute.

`AndroidWebStorageManager` class is used to manage the JavaScript storage APIs provided by the WebView. It manages the Application Cache API, the Web SQL Database API and the HTML5 Web Storage API.

* `getOrigins`: Gets the origins currently using either the Application Cache or Web SQL Database APIs.
* `deleteAllData`: Clears all storage currently being used by the JavaScript storage APIs.
* `deleteOrigin({@required String origin})`: Clears the storage currently being used by both the Application Cache and Web SQL Database APIs by the given `origin`.
* `getQuotaForOrigin({@required String origin})`: Gets the storage quota for the Web SQL Database API for the given `origin`.
* `getUsageForOrigin({@required String origin})`: Gets the amount of storage currently being used by both the Application Cache and Web SQL Database APIs by the given `origin`.

#### `WebStorageManager` iOS-specific methods

iOS-specific methods can be called using the `WebStorageManager.instance().ios` attribute.

`IOSWebStorageManager` class represents various types of data that a website might make use of. This includes cookies, disk and memory caches, and persistent data such as WebSQL, IndexedDB databases, and local storage.

* `fetchDataRecords({@required Set<IOSWKWebsiteDataType> dataTypes})`: Fetches data records containing the given website data types.
* `removeDataFor({@required Set<IOSWKWebsiteDataType> dataTypes, @required List<IOSWKWebsiteDataRecord> dataRecords})`: Removes website data of the given types for the given data records.
* `removeDataModifiedSince({@required Set<IOSWKWebsiteDataType> dataTypes, @required DateTime date})`: Removes all website data of the given types that has been modified since the given date.
