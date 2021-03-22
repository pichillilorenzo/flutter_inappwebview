# Flutter InAppWebView Plugin [![Share on Twitter](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=Flutter%20InAppBrowser%20plugin!&url=https://github.com/pichillilorenzo/flutter_inappwebview&hashtags=flutter,flutterio,dart,dartlang,webview) [![Share on Facebook](https://img.shields.io/badge/share-facebook-blue.svg?longCache=true&style=flat&colorB=%234267b2)](https://www.facebook.com/sharer/sharer.php?u=https%3A//github.com/pichillilorenzo/flutter_inappwebview)

[![Pub](https://img.shields.io/pub/v/flutter_inappwebview.svg)](https://pub.dartlang.org/packages/flutter_inappwebview)
[![pub points](https://badges.bar/flutter_inappwebview/pub%20points)](https://pub.dev/packages/flutter_inappwebview/score)
[![popularity](https://badges.bar/flutter_inappwebview/popularity)](https://pub.dev/packages/flutter_inappwebview/score)
[![likes](https://badges.bar/flutter_inappwebview/likes)](https://pub.dev/packages/flutter_inappwebview/score)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter-inappwebview)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](/LICENSE)

[![Donate to this project](https://img.shields.io/badge/support-donate-yellow.svg)](https://inappwebview.dev/donate/)
[![GitHub contributors](https://img.shields.io/github/contributors/pichillilorenzo/flutter_inappwebview)](https://github.com/pichillilorenzo/flutter_inappwebview/graphs/contributors)
[![GitHub forks](https://img.shields.io/github/forks/pichillilorenzo/flutter_inappwebview?style=social)](https://github.com/pichillilorenzo/flutter_inappwebview)
[![GitHub stars](https://img.shields.io/github/stars/pichillilorenzo/flutter_inappwebview?style=social)](https://github.com/pichillilorenzo/flutter_inappwebview)


![InAppWebView-logo](https://user-images.githubusercontent.com/5956938/110180687-8751f480-7e0a-11eb-89cc-d62f85c148cb.png)

A Flutter plugin that allows you to add an inline webview, to use an headless webview, and to open an in-app browser window.

# Announcement

All the configuration and info about Getting Started with this plugin and code examples will be moved from here to the new [inappwebview.dev official website](https://inappwebview.dev/)!
I will create a new section there for better visualization and management.

Stay tuned!

## API Reference

See the online [API Reference](https://pub.dartlang.org/documentation/flutter_inappwebview/latest/) to get the **full documentation**.

Note that the API shown in this `README.md` file shows only a **part** of the documentation and, also, that conforms to the **GitHub master branch only**!
So, here you could have methods, options, and events that **aren't published/released yet**!
If you need a specific version, please change the **GitHub branch** of this repository to your version or use the **online [API Reference](https://pub.dartlang.org/documentation/flutter_inappwebview/latest/)** (recommended).

Also, check the [example/integration_test/webview_flutter_test.dart](https://github.com/pichillilorenzo/flutter_inappwebview/blob/master/example/integration_test/webview_flutter_test.dart) file for code examples.

## Articles/Resources

- [Official website: inappwebview.dev](https://inappwebview.dev)
- [InAppWebView: The Real Power of WebViews in Flutter](https://medium.com/flutter-community/inappwebview-the-real-power-of-webviews-in-flutter-c6d52374209d?source=friends_link&sk=cb74487219bcd85e610a670ee0b447d0) (valid for plugin version 4.0.0)
- [Creating a Full-Featured Browser using WebViews in Flutter](https://medium.com/flutter-community/creating-a-full-featured-browser-using-webviews-in-flutter-9c8f2923c574?source=friends_link&sk=55fc8267f351082aa9e73ced546f6bcb) (valid for plugin version 4.0.0)
- [Flutter Browser App: A Full-Featured Mobile Browser App (such as the Google Chrome mobile browser) created using Flutter and the features offered by the flutter_inappwebview plugin](https://github.com/pichillilorenzo/flutter_browser_app)

## Showcase - Who use it

Check the [Showcase](https://inappwebview.dev/showcase/) page to see an open list of Apps built with **Flutter** and **Flutter InAppWebView**.

#### Are you using the **Flutter InAppWebView** plugin and would you like to add your App there?

Send a submission request to the [Submit App](https://inappwebview.dev/submit-app/) page!

## Requirements

- Dart sdk: ">=2.12.0-0 <3.0.0"
- Flutter: ">=1.22.2"
- Android: `minSdkVersion 17` and add support for `androidx` (see [AndroidX Migration](https://flutter.dev/docs/development/androidx-migration) to migrate an existing app)
- iOS: `--ios-language swift`, Xcode version `>= 12`

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

Also, note that to use the `InAppWebView` widget on Android, it requires **Android API 20+** (see [AndroidView](https://api.flutter.dev/flutter/widgets/AndroidView-class.html))  
or **Android API 19+** if you enable the `useHybridComposition` Android-specific option.

**Support HTTP request**: Starting with Android 9 (API level 28), cleartext support is disabled by default:
- Check the official [Network security configuration - "Opt out of cleartext traffic"](https://developer.android.com/training/articles/security-config#CleartextTrafficPermitted) section.
- Also, check this StackOverflow issue answer: [Cleartext HTTP traffic not permitted](https://stackoverflow.com/a/50834600/4637638).

If you want to use the `ChromeSafariBrowser` class on Android 11+ you need to specify your app querying for `android.support.customtabs.action.CustomTabsService` in your `AndroidManifest.xml` (you can read more about it here: https://developers.google.com/web/android/custom-tabs/best-practices#applications_targeting_android_11_api_level_30_or_above).

#### Debugging Android WebViews
On Android, in order to enable/disable debugging WebViews using `chrome://inspect` on Chrome, you should use the `AndroidInAppWebViewController.setWebContentsDebuggingEnabled(bool debuggingEnabled)` static method.

For example, you could call it inside the main function:
```dart
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(new MyApp());
}
```

#### Enable Material Components for Android
To use Material Components when the user interacts with input elements in the WebView, follow the steps described in the [Enabling Material Components instructions](https://flutter.dev/docs/deployment/android#enabling-material-components).

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

#### Debugging iOS WebViews
On iOS, debugging WebViews on Safari through developer tools is always enabled. There isn't a way to enable or disable it.

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

- [InAppWebView](#inappwebview-class): Flutter Widget for adding an **inline native WebView** integrated into the flutter widget tree. Note that on Android it requires **Android API 20+** (see [AndroidView](https://api.flutter.dev/flutter/widgets/AndroidView-class.html)) or **Android API 19+** if you enable the `useHybridComposition` Android-specific option.
  - [methods](#inappwebviewcontroller-methods)
  - [options](#inappwebview-options)
  - [events](#inappwebview-events)
- [ContextMenu](#contextmenu-class): This class represents the WebView context menu.
  - [options](#contextmenu-options)
  - [events](#contextmenu-events)
- [HeadlessInAppWebView](#headlessinappwebview-class): Class that represents a WebView in headless mode. It can be used to run a WebView in background without attaching an `InAppWebView` to the widget tree.
  - [methods](#inappwebviewcontroller-methods)
  - [options](#inappwebview-options)
  - [events](#inappwebview-events)
- [InAppBrowser](#inappbrowser-class): In-App Browser using native WebView.
  - [methods](#inappbrowser-methods)
  - [options](#inappbrowser-options)
  - [events](#inappbrowser-events)
- [ChromeSafariBrowser](#chromesafaribrowser-class): In-App Browser using [Chrome Custom Tabs](https://developer.android.com/reference/android/support/customtabs/package-summary) on Android / [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) on iOS.
  - [methods](#chromesafaribrowser-methods)
  - [options](#chromesafaribrowser-options)
  - [events](#chromesafaribrowser-events)
- [InAppLocalhostServer](#inapplocalhostserver-class): This class allows you to create a simple server on `http://localhost:[port]/`. The default `port` value is `8080`.
- [CookieManager](#cookiemanager-class): This class implements a singleton object (shared instance) which manages the cookies used by WebView instances. **LIMITED SUPPORT for iOS below 11.0**.
  - [methods](#cookiemanager-methods)
- [HttpAuthCredentialDatabase](#httpauthcredentialdatabase-class): This class implements a singleton object (shared instance) which manages the shared HTTP auth credentials cache.
  - [methods](#httpauthcredentialdatabase-methods)
- [WebStorageManager](#webstoragemanager-class): This class implements a singleton object (shared instance) which manages the web storage used by WebView instances.
  - [methods](#webstoragemanager-methods)
- [WebRTC](#webrtc)
- [Service Worker API](#service-worker-api)

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

Note that on Android it requires **Android API 20+** (see [AndroidView](https://api.flutter.dev/flutter/widgets/AndroidView-class.html))
or **Android API 19+** if you enable the `useHybridComposition` Android-specific option.

Use `InAppWebViewController` to control the WebView instance.
Example:
```dart
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
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
          appBar: AppBar(title: Text("Official InAppWebView website")),
          body: SafeArea(
              child: Column(children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search)
                  ),
                  controller: urlController,
                  keyboardType: TextInputType.url,
                  onSubmitted: (value) {
                    var url = Uri.parse(value);
                    if (url.scheme.isEmpty) {
                      url = Uri.parse("https://www.google.com/search?q=" + value);
                    }
                    webViewController?.loadUrl(
                        urlRequest: URLRequest(url: url));
                  },
                ),
                Expanded(
                  child: Stack(
                    children: [
                      InAppWebView(
                        key: webViewKey,
                        initialUrlRequest:
                        URLRequest(url: Uri.parse("https://inappwebview.dev/")),
                        initialOptions: options,
                        pullToRefreshController: pullToRefreshController,
                        onWebViewCreated: (controller) {
                          webViewController = controller;
                        },
                        onLoadStart: (controller, url) {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        androidOnPermissionRequest: (controller, origin, resources) async {
                          return PermissionRequestResponse(
                              resources: resources,
                              action: PermissionRequestResponseAction.GRANT);
                        },
                        shouldOverrideUrlLoading: (controller, navigationAction) async {
                          var uri = navigationAction.request.url!;

                          if (![ "http", "https", "file", "chrome",
                            "data", "javascript", "about"].contains(uri.scheme)) {
                            if (await canLaunch(url)) {
                              // Launch the App
                              await launch(
                                url,
                              );
                              // and cancel the request
                              return NavigationActionPolicy.CANCEL;
                            }
                          }

                          return NavigationActionPolicy.ALLOW;
                        },
                        onLoadStop: (controller, url) async {
                          pullToRefreshController.endRefreshing();
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        onLoadError: (controller, url, code, message) {
                          pullToRefreshController.endRefreshing();
                        },
                        onProgressChanged: (controller, progress) {
                          if (progress == 100) {
                            pullToRefreshController.endRefreshing();
                          }
                          setState(() {
                            this.progress = progress / 100;
                            urlController.text = this.url;
                          });
                        },
                        onUpdateVisitedHistory: (controller, url, androidIsReload) {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        onConsoleMessage: (controller, consoleMessage) {
                          print(consoleMessage);
                        },
                      ),
                      progress < 1.0
                          ? LinearProgressIndicator(value: progress)
                          : Container(),
                    ],
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      child: Icon(Icons.arrow_back),
                      onPressed: () {
                        webViewController?.goBack();
                      },
                    ),
                    ElevatedButton(
                      child: Icon(Icons.arrow_forward),
                      onPressed: () {
                        webViewController?.goForward();
                      },
                    ),
                    ElevatedButton(
                      child: Icon(Icons.refresh),
                      onPressed: () {
                        webViewController?.reload();
                      },
                    ),
                  ],
                ),
              ]))),
    );
  }
}
```

Screenshots:
- Android:

![android](https://user-images.githubusercontent.com/5956938/110179602-a18ad300-7e08-11eb-849b-2c7f1af28155.gif)

- iOS:

![ios](https://user-images.githubusercontent.com/5956938/110179614-a8194a80-7e08-11eb-85f9-3da10acbbcb2.gif)

#### `InAppWebViewController` Methods

##### `InAppWebViewController` Cross-platform methods

* `addJavaScriptHandler({required String handlerName, required JavaScriptHandlerCallback callback})`: Adds a JavaScript message handler callback that listen to post messages sent from JavaScript by the handler with name `handlerName`.
* `addUserScript({required UserScript userScript})`: Injects the specified `userScript` into the webpage’s content.
* `addUserScripts({required List<UserScript> userScripts})`: Injects the `userScripts` into the webpage’s content.
* `callAsyncJavaScript({required String functionBody, Map<String, dynamic> arguments = const <String, dynamic>{}, ContentWorld? contentWorld})`: Executes the specified string as an asynchronous JavaScript function.
* `canGoBackOrForward({required int steps})`: Returns a boolean value indicating whether the WebView can go back or forward the given number of steps. Steps is negative if backward and positive if forward.
* `canGoBack`: Returns a boolean value indicating whether the WebView can move backward.
* `canGoForward`: Returns a boolean value indicating whether the WebView can move forward.
* `clearCache`: Clears all the webview's cache.
* `clearFocus`: Clears the current focus. It will clear also, for example, the current text selection.
* `clearMatches`: Clears the highlighting surrounding text matches created by `findAllAsync()`.
* `evaluateJavascript({required String source, ContentWorld? contentWorld})`: Evaluates JavaScript code into the WebView and returns the result of the evaluation.
* `findAllAsync({required String find})`: Finds all instances of find on the page and highlights them. Notifies `onFindResultReceived` listener.
* `findNext({required bool forward})`: Highlights and scrolls to the next match found by `findAllAsync()`. Notifies `onFindResultReceived` listener.
* `getCertificate`: Gets the SSL certificate for the main top-level page or null if there is no certificate (the site is not secure).
* `getContentHeight`: Gets the height of the HTML content.
* `getCopyBackForwardList`: Gets the `WebHistory` for this WebView. This contains the back/forward list for use in querying each item in the history stack.
* `getFavicons`: Gets the list of all favicons for the current page.
* `getHitTestResult`: Gets the hit result for hitting an HTML elements.
* `getHtml`: Gets the content html of the page.
* `getMetaTags`: Returns the list of `<meta>` tags of the current WebView.
* `getMetaThemeColor`: Returns an instance of `Color` representing the `content` value of the `<meta name="theme-color" content="">` tag of the current WebView, if available, otherwise `null`.
* `getOptions`: Gets the current WebView options. Returns the options with `null` value if they are not set yet.
* `getProgress`: Gets the progress for the current page. The progress value is between 0 and 100.
* `getScale`: Gets the current scale of this WebView.
* `getScrollX`: Returns the scrolled left position of the current WebView.
* `getScrollY`: Returns the scrolled top position of the current WebView.
* `getSelectedText`: Gets the selected text.
* `getTRexRunnerCss`: Gets the css of the Chromium's t-rex runner game. Used in combination with `getTRexRunnerHtml()`.
* `getTRexRunnerHtml`: Gets the html (with javascript) of the Chromium's t-rex runner game. Used in combination with `getTRexRunnerCss()`.
* `getTitle`: Gets the title for the current page.
* `getUrl`: Gets the URL for the current page.
* `goBackOrForward({required int steps})`: Goes to the history item that is the number of steps away from the current item. Steps is negative if backward and positive if forward.
* `goBack`: Goes back in the history of the WebView.
* `goForward`: Goes forward in the history of the WebView.
* `goTo({required WebHistoryItem historyItem})`: Navigates to a `WebHistoryItem` from the back-forward `WebHistory.list` and sets it as the current item.
* `injectCSSCode({required String source})`: Injects CSS into the WebView.
* `injectCSSFileFromAsset({required String assetFilePath})`: Injects a CSS file into the WebView from the flutter assets directory.
* `injectCSSFileFromUrl({required String urlFile, CSSLinkHtmlTagAttributes? cssLinkHtmlTagAttributes})`: Injects an external CSS file into the WebView from a defined url.
* `injectJavascriptFileFromAsset({required String assetFilePath})`: Injects a JavaScript file into the WebView from the flutter assets directory.
* `injectJavascriptFileFromUrl({required Uri urlFile, ScriptHtmlTagAttributes? scriptHtmlTagAttributes})`: Injects an external JavaScript file into the WebView from a defined url.
* `isLoading`: Check if the WebView instance is in a loading state.
* `isSecureContext`: Indicates whether the webpage context is capable of using features that require secure contexts.
* `loadData({required String data, String mimeType = "text/html", String encoding = "utf8", Uri? baseUrl, Uri? androidHistoryUrl})`: Loads the given data into this WebView.
* `loadFile({required String assetFilePath})`: Loads the given `assetFilePath` with optional headers specified as a map from name to value.
* `loadUrl({required URLRequest urlRequest, Uri? iosAllowingReadAccessTo})`: Loads the given url with optional headers specified as a map from name to value.
* `pauseTimers`: On Android, it pauses all layout, parsing, and JavaScript timers for all WebViews. This is a global requests, not restricted to just this WebView. This can be useful if the application has been paused. On iOS, it is restricted to just this WebView.
* `postUrl({required Uri url, required Uint8List postData})`: Loads the given url with postData using `POST` method into this WebView.
* `printCurrentPage`: Prints the current page.
* `reload`: Reloads the WebView.
* `removeAllUserScripts()`: Removes all the user scripts from the webpage’s content.
* `removeJavaScriptHandler({required String handlerName})`: Removes a JavaScript message handler previously added with the `addJavaScriptHandler()` associated to `handlerName` key.
* `removeUserScript({required UserScript userScript})`: Removes the specified `userScript` from the webpage’s content.
* `removeUserScriptsByGroupName({required String groupName})`: Removes all the `UserScript`s with `groupName` as group name from the webpage’s content.
* `removeUserScripts({required List<UserScript> userScripts})`: Removes the `userScripts` from the webpage’s content.
* `requestFocusNodeHref`: Requests the anchor or image element URL at the last tapped point.
* `requestImageRef`: Requests the URL of the image last touched by the user.
* `resumeTimers`: On Android, it resumes all layout, parsing, and JavaScript timers for all WebViews. This will resume dispatching all timers. On iOS, it resumes all layout, parsing, and JavaScript timers to just this WebView.
* `saveWebArchive({required String filePath, bool autoname = false})`: Saves the current view as a web archive.
* `scrollBy({required int x, required int y, bool animated = false})`: Moves the scrolled position of the WebView.
* `scrollTo({required int x, required int y, bool animated = false})`: Scrolls the WebView to the position.
* `setContextMenu(ContextMenu? contextMenu)`: Sets or updates the WebView context menu to be used next time it will appear.
* `setOptions({required InAppWebViewGroupOptions options})`: Sets the WebView options with the new options and evaluates them.
* `stopLoading`: Stops the WebView from loading.
* `takeScreenshot({ScreenshotConfiguration? screenshotConfiguration})`: Takes a screenshot (in PNG format) of the WebView's visible viewport and returns a `Uint8List`. Returns `null` if it wasn't be able to take it.
* `zoomBy({required double zoomFactor, bool iosAnimated = false})`: Performs a zoom operation in this WebView.
* `static getDefaultUserAgent`: Gets the default user agent.

##### `InAppWebViewController.webStorage`

`InAppWebViewController.webStorage` provides access to the JavaScript [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API):
* `WebStorage.localStorage`: provides access to `window.localStorage`;
* `WebStorage.sessionStorage`: provides access to `window.sessionStorage`.

Methods available:
* `length`: Returns an integer representing the number of data items stored in the Storage object.
* `setItem({required String key, required dynamic value})`: When passed a `key` name and `value`, will add that key to the storage, or update that key's value if it already exists.
* `getItem({required String key})`: When passed a `key` name, will return that key's value, or `null` if the key does not exist, in the given Storage object.
* `removeItem({required String key})`: When passed a `key` name, will remove that key from the given Storage object if it exists.
* `getItems`: Returns the list of all items from the given Storage object.
* `clear`: Clears all keys stored in a given Storage object.
* `key({required int index})`: When passed a number `index`, returns the name of the nth key in a given Storage object.

##### `InAppWebViewController` Android-specific methods

Android-specific methods can be called using the `InAppWebViewController.android` attribute. Static methods can be called using the `AndroidInAppWebViewController` class directly.

* `startSafeBrowsing`: Starts Safe Browsing initialization.
* `clearSslPreferences`: Clears the SSL preferences table stored in response to proceeding with SSL certificate errors.
* `pause`: Does a best-effort attempt to pause any processing that can be paused safely, such as animations and geolocation. Note that this call does not pause JavaScript.
* `resume`: Resumes a WebView after a previous call to `pause()`.
* `getOriginalUrl`: Gets the URL that was originally requested for the current page.
* `pageDown({required bool bottom})`: Scrolls the contents of this WebView down by half the page size.
* `pageUp({required bool top})`: Scrolls the contents of this WebView up by half the view size.
* `zoomIn`: Performs zoom in in this WebView.
* `zoomOut`: Performs zoom out in this WebView.
* `clearHistory`: Clears the internal back/forward list.
* `static clearClientCertPreferences`: Clears the client certificate preferences stored in response to proceeding/cancelling client cert requests.
* `static getSafeBrowsingPrivacyPolicyUrl`: Returns a URL pointing to the privacy policy for Safe Browsing reporting. This value will never be `null`.
* `static setSafeBrowsingWhitelist({required List<String> hosts})`: Sets the list of hosts (domain names/IP addresses) that are exempt from SafeBrowsing checks. The list is global for all the WebViews.
* `static getCurrentWebViewPackage`: Gets the current Android WebView package info.
* `static setWebContentsDebuggingEnabled(bool debuggingEnabled)`: Enables debugging of web contents (HTML / CSS / JavaScript) loaded into any WebViews of this application. Debugging is disabled by default.

##### `InAppWebViewController` iOS-specific methods

iOS-specific methods can be called using the `InAppWebViewController.ios` attribute. Static methods can be called using the `IOSInAppWebViewController` class directly.

* `createPdf({IOSWKPDFConfiguration? iosWKPdfConfiguration})`: Generates PDF data from the web view’s contents asynchronously.
* `createWebArchiveData`: Creates a web archive of the web view’s current contents asynchronously.
* `hasOnlySecureContent`: A Boolean value indicating whether all resources on the page have been loaded over securely encrypted connections.
* `reloadFromOrigin`: Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible.
* `static handlesURLScheme(String urlScheme)`: Returns a Boolean value that indicates whether WebKit natively supports resources with the specified URL scheme.

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

* `allowFileAccessFromFileURLs`: Sets whether JavaScript running in the context of a file scheme URL should be allowed to access content from other file scheme URLs. The default value is `false`.
* `allowUniversalAccessFromFileURLs`: Sets whether JavaScript running in the context of a file scheme URL should be allowed to access content from any origin. The default value is `false`.
* `applicationNameForUserAgent`: Append to the existing user-agent. Setting userAgent will override this.
* `cacheEnabled`: Sets whether WebView should use browser caching. The default value is `true`.
* `clearCache`: Set to `true` to have all the browser's cache cleared before the new WebView is opened. The default value is `false`.
* `contentBlockers`: List of `ContentBlocker` that are a set of rules used to block content in the browser window.
* `disableContextMenu`: Set to `true` to disable context menu. The default value is `false`.
* `disableHorizontalScroll`: Set to `true` to disable horizontal scroll. The default value is `false`.
* `disableVerticalScroll`: Set to `true` to disable vertical scroll. The default value is `false`.
* `horizontalScrollBarEnabled`: Define whether the horizontal scrollbar should be drawn or not. The default value is `true`.
* `incognito`: Set to `true` to open a browser window with incognito mode. The default value is `false`.
* `javaScriptCanOpenWindowsAutomatically`: Set to `true` to allow JavaScript open windows without user interaction. The default value is `false`.
* `javaScriptEnabled`: Set to `true` to enable JavaScript. The default value is `true`.
* `mediaPlaybackRequiresUserGesture`: Set to `true` to prevent HTML5 audio or video from autoplaying. The default value is `true`.
* `minimumFontSize`: Sets the minimum font size. The default value is `8` for Android, `0` for iOS.
* `preferredContentMode`: Sets the content mode that the WebView needs to use when loading and rendering a webpage. The default value is `InAppWebViewUserPreferredContentMode.RECOMMENDED`.
* `resourceCustomSchemes`: List of custom schemes that the WebView must handle. Use the `onLoadResourceCustomScheme` event to intercept resource requests with custom scheme.
* `supportZoom`: Set to `false` if the WebView should not support zooming using its on-screen zoom controls and gestures. The default value is `true`.
* `transparentBackground`: Set to `true` to make the background of the WebView transparent. If your app has a dark theme, this can prevent a white flash on initialization. The default value is `false`.
* `useOnDownloadStart`: Set to `true` to be able to listen at the `onDownloadStart` event. The default value is `false`.
* `useOnLoadResource`: Set to `true` to be able to listen at the `onLoadResource` event. The default value is `false`.
* `useShouldInterceptAjaxRequest`: Set to `true` to be able to listen at the `shouldInterceptAjaxRequest` event. The default value is `false`.
* `useShouldInterceptFetchRequest`: Set to `true` to be able to listen at the `shouldInterceptFetchRequest` event. The default value is `false`.
* `useShouldOverrideUrlLoading`: Set to `true` to be able to listen at the `shouldOverrideUrlLoading` event. The default value is `false`.
* `userAgent`: Sets the user-agent for the WebView.
* `verticalScrollBarEnabled`: Define whether the vertical scrollbar should be drawn or not. The default value is `true`.

##### `InAppWebView` Android-specific options

* `allowContentAccess`: Enables or disables content URL access within WebView. Content URL access allows WebView to load content from a content provider installed in the system. The default value is `true`.
* `allowFileAccess`: Enables or disables file access within WebView. Note that this enables or disables file system access only.
* `appCachePath`: Sets the path to the Application Caches files. In order for the Application Caches API to be enabled, this option must be set a path to which the application can write.
* `blockNetworkImage`: Sets whether the WebView should not load image resources from the network (resources accessed via http and https URI schemes). The default value is `false`.
* `blockNetworkLoads`: Sets whether the WebView should not load resources from the network. The default value is `false`.
* `builtInZoomControls`: Set to `true` if the WebView should use its built-in zoom mechanisms. The default value is `true`.
* `cacheMode`: Overrides the way the cache is used. The way the cache is used is based on the navigation type. For a normal page load, the cache is checked and content is re-validated as needed.
* `clearSessionCache`: Set to `true` to have the session cookie cache cleared before the new window is opened.
* `cursiveFontFamily`: Sets the cursive font family name. The default value is `"cursive"`.
* `databaseEnabled`: Set to `true` if you want the database storage API is enabled. The default value is `true`.
* `defaultFixedFontSize`: Sets the default fixed font size. The default value is `16`.
* `defaultFontSize`: Sets the default font size. The default value is `16`.
* `defaultTextEncodingName`: Sets the default text encoding name to use when decoding html pages. The default value is `"UTF-8"`.
* `disableDefaultErrorPage`: Sets whether the default Android error page should be disabled. The default value is `false`.
* `disabledActionModeMenuItems`: Disables the action mode menu items according to menuItems flag.
* `displayZoomControls`: Set to `true` if the WebView should display on-screen zoom controls when using the built-in zoom mechanisms. The default value is `false`.
* `domStorageEnabled`: Set to `true` if you want the DOM storage API is enabled. The default value is `true`.
* `fantasyFontFamily`: Sets the fantasy font family name. The default value is `"fantasy"`.
* `fixedFontFamily`: Sets the fixed font family name. The default value is `"monospace"`.
* `forceDark`: Set the force dark mode for this WebView. The default value is `AndroidInAppWebViewForceDark.FORCE_DARK_OFF`.
* `geolocationEnabled`: Sets whether Geolocation API is enabled. The default value is `true`.
* `hardwareAcceleration`: Boolean value to enable Hardware Acceleration in the WebView.
* `horizontalScrollbarThumbColor`: Sets the horizontal scrollbar thumb color.
* `horizontalScrollbarTrackColor`: Sets the horizontal scrollbar track color.
* `initialScale`: Sets the initial scale for this WebView. 0 means default. The behavior for the default scale depends on the state of `useWideViewPort` and `loadWithOverviewMode`.
* `layoutAlgorithm`: Sets the underlying layout algorithm. This will cause a re-layout of the WebView.
* `loadWithOverviewMode`: Sets whether the WebView loads pages in overview mode, that is, zooms out the content to fit on screen by width.
* `loadsImagesAutomatically`: Sets whether the WebView should load image resources. Note that this method controls loading of all images, including those embedded using the data URI scheme.
* `minimumLogicalFontSize`: Sets the minimum logical font size. The default is `8`.
* `mixedContentMode`: Configures the WebView's behavior when a secure origin attempts to load a resource from an insecure origin.
* `needInitialFocus`: Tells the WebView whether it needs to set a node. The default value is `true`.
* `networkAvailable`: Informs WebView of the network state.
* `offscreenPreRaster`: Sets whether this WebView should raster tiles when it is offscreen but attached to a window.
* `overScrollMode`: Sets the WebView's over-scroll mode. The default value is `AndroidOverScrollMode.OVER_SCROLL_IF_CONTENT_SCROLLS`.
* `regexToCancelSubFramesLoading`: Regular expression used by `shouldOverrideUrlLoading` event to cancel navigation for frames that are not the main frame. If the url request of a subframe matches the regular expression, then the request of that subframe is canceled.
* `rendererPriorityPolicy`: Set the renderer priority policy for this WebView.
* `safeBrowsingEnabled`: Sets whether Safe Browsing is enabled. Safe Browsing allows WebView to protect against malware and phishing attacks by verifying the links.
* `sansSerifFontFamily`: Sets the sans-serif font family name. The default value is `"sans-serif"`.
* `saveFormData`: Sets whether the WebView should save form data. In Android O, the platform has implemented a fully functional Autofill feature to store form data.
* `scrollBarDefaultDelayBeforeFade`: Defines the delay in milliseconds that a scrollbar waits before fade out.
* `scrollBarFadeDuration`: Define the scrollbar fade duration in milliseconds.
* `scrollBarStyle`: Specify the style of the scrollbars. The scrollbars can be overlaid or inset. The default value is `AndroidScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY`.
* `scrollbarFadingEnabled`: Define whether scrollbars will fade when the view is not scrolling. The default value is `true`.
* `serifFontFamily`: Sets the serif font family name. The default value is `"sans-serif"`.
* `standardFontFamily`: Sets the standard font family name. The default value is `"sans-serif"`.
* `supportMultipleWindows`: Sets whether the WebView whether supports multiple windows.
* `textZoom`: Sets the text zoom of the page in percent. The default value is `100`.
* `thirdPartyCookiesEnabled`: Boolean value to enable third party cookies in the WebView.
* `useHybridComposition`: Set to `true` to use Flutter's new Hybrid Composition rendering method, which fixes all issues [here](https://github.com/flutter/flutter/issues/61133). The default value is `false`. Note that this option requires Flutter v1.20+ and should only be used on Android 10+ for release apps, as animations will drop frames on < Android 10 (see [Hybrid-Composition#performance](https://github.com/flutter/flutter/wiki/Hybrid-Composition#performance)).
* `useOnRenderProcessGone`: Set to `true` to be able to listen at the `androidOnRenderProcessGone` event. The default value is `false`.
* `useShouldInterceptRequest`: Set to `true` to be able to listen at the `androidShouldInterceptRequest` event. The default value is `false`.
* `useWideViewPort`: Set to `true` if the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport.
* `verticalScrollbarPosition`: Set the position of the vertical scroll bar. The default value is `AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT`.
* `verticalScrollbarThumbColor`: Sets the vertical scrollbar thumb color.
* `verticalScrollbarTrackColor`: Sets the vertical scrollbar track color.

##### `InAppWebView` iOS-specific options

* `accessibilityIgnoresInvertColors`: A Boolean value indicating whether the view ignores an accessibility request to invert its colors. The default value is `false`.
* `allowingReadAccessTo`: Used in combination with `WebView.initialUrl` (with `file://` scheme), it represents the URL from which to read the web content. This URL must be a file-based URL (with `file://` scheme).
* `allowsAirPlayForMediaPlayback`: Set to `true` to allow AirPlay. The default value is `true`.
* `allowsBackForwardNavigationGestures`: Set to `true` to allow the horizontal swipe gestures trigger back-forward list navigations. The default value is `true`.
* `allowsInlineMediaPlayback`: Set to `true` to allow HTML5 media playback to appear inline within the screen layout, using browser-supplied controls rather than native controls.
* `allowsLinkPreview`: Set to `true` to allow that pressing on a link displays a preview of the destination for the link. The default value is `true`.
* `allowsPictureInPictureMediaPlayback`: Set to `true` to allow HTML5 videos play picture-in-picture. The default value is `true`.
* `alwaysBounceHorizontal`: A Boolean value that determines whether bouncing always occurs when horizontal scrolling reaches the end of the content view. The default value is `false`.
* `alwaysBounceVertical`: A Boolean value that determines whether bouncing always occurs when vertical scrolling reaches the end of the content. The default value is `false`.
* `applePayAPIEnabled`: Set to `true` to enable Apple Pay API for the WebView at its first page load or on the next page load (using `InAppWebViewController.setOptions`). See the documentation for more info and to know the cons of enabling this option. The default value is `false`.
* `automaticallyAdjustsScrollIndicatorInsets`: Configures whether the scroll indicator insets are automatically adjusted by the system. The default value is `false`.
* `contentInsetAdjustmentBehavior`: Configures how safe area insets are added to the adjusted content inset. The default value is `IOSUIScrollViewContentInsetAdjustmentBehavior.NEVER`.
* `dataDetectorTypes`: Specifying a dataDetectoryTypes value adds interactivity to web content that matches the value.
* `decelerationRate`: A `IOSUIScrollViewDecelerationRate` value that determines the rate of deceleration after the user lifts their finger. The default value is `IOSUIScrollViewDecelerationRate.NORMAL`.
* `disableLongPressContextMenuOnLinks`: Set to `true` to disable the context menu (copy, select, etc.) that is shown when the user emits a long press event on a HTML link.
* `disallowOverScroll`: Set to `true` to disable the bouncing of the WebView when the scrolling has reached an edge of the content. The default value is `false`.
* `enableViewportScale`: Set to `true` to allow a viewport meta tag to either disable or restrict the range of user scaling. The default value is `false`.
* `ignoresViewportScaleLimits`: Set to `true` if you want that the WebView should always allow scaling of the webpage, regardless of the author's intent.
* `isFraudulentWebsiteWarningEnabled`: A Boolean value indicating whether warnings should be shown for suspected fraudulent content such as phishing or malware.
* `isPagingEnabled`: A Boolean value that determines whether paging is enabled for the scroll view. The default value is `false`.
* `isDirectionalLockEnabled`: A Boolean value that determines whether scrolling is disabled in a particular direction. The default value is `false`.
* `limitsNavigationsToAppBoundDomains`: A Boolean value that indicates whether the web view limits navigation to pages within the app’s domain. The default value is `false`.
* `maximumZoomScale`: A floating-point value that specifies the maximum scale factor that can be applied to the scroll view's content. The default value is `1.0`.
* `mediaType`: The media type for the contents of the web view. The default value is `null`.
* `minimumZoomScale`: A floating-point value that specifies the minimum scale factor that can be applied to the scroll view's content. The default value is `1.0`.
* `pageZoom`: The scale factor by which the web view scales content relative to its bounds. The default value is `1.0`.
* `scrollsToTop`: A Boolean value that controls whether the scroll-to-top gesture is enabled. The default value is `true`.
* `selectionGranularity`: The level of granularity with which the user can interactively select content in the web view.
* `sharedCookiesEnabled`: Set `true` if shared cookies from `HTTPCookieStorage.shared` should used for every load request in the WebView.
* `suppressesIncrementalRendering`: Set to `true` if you want the WebView suppresses content rendering until it is fully loaded into memory. The default value is `false`.
* `useOnNavigationResponse`: Set to `true` to be able to listen to the `iosOnNavigationResponse` event. The default value is `false`.

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
* `androidOnReceivedIcon`: Event fired when there is new favicon for the current page (available only on Android).
* `androidOnReceivedTouchIconUrl`: Event fired when there is an url for an apple-touch-icon (available only on Android).
* `androidOnJsBeforeUnload`: Event fired when the client should display a dialog to confirm navigation away from the current page. This is the result of the `onbeforeunload` javascript event (available only on Android).
* `androidOnReceivedLoginRequest`: Event fired when a request to automatically log in the user has been processed (available only on Android).
* `iosOnWebContentProcessDidTerminate`: Invoked when the web view's web content process is terminated (available only on iOS).
* `iosOnDidReceiveServerRedirectForProvisionalNavigation`: Called when a web view receives a server redirect (available only on iOS).
* `iosOnNavigationResponse`: Called when a web view asks for permission to navigate to new content after the response to the navigation request is known (available only on iOS). To use this event, the `useOnNavigationResponse` iOS-specific option must be `true`.
* `iosShouldAllowDeprecatedTLS`: Called when a web view asks whether to continue with a connection that uses a deprecated version of TLS (v1.0 and v1.1) (available only on iOS).

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
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  InAppWebViewController? webView;
  ContextMenu? contextMenu;
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
          print(await webView?.getSelectedText());
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
                    initialUrlRequest: URLRequest(
                      url: Uri.parse("https://flutter.dev/")
                    ),
                    contextMenu: contextMenu,
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(

                      ),
                      ios: IOSInAppWebViewOptions(

                      ),
                      android: AndroidInAppWebViewOptions(
                        useHybridComposition: true
                      )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        this.url = url?.toString() ?? '';
                      });
                    },
                    onLoadStop: (controller, url) async {
                      setState(() {
                        this.url = url?.toString() ?? '';
                      });
                    },
                    onProgressChanged: (controller, progress) {
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
                  ElevatedButton(
                    child: Icon(Icons.arrow_back),
                    onPressed: () {
                      webView?.goBack();
                    },
                  ),
                  ElevatedButton(
                    child: Icon(Icons.arrow_forward),
                    onPressed: () {
                      webView?.goForward();
                    },
                  ),
                  ElevatedButton(
                    child: Icon(Icons.refresh),
                    onPressed: () {
                      webView?.reload();
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
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  HeadlessInAppWebView? headlessWebView;
  String url = "";

  @override
  void initState() {
    super.initState();

    headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
        url: Uri.parse("https://flutter.dev/")
      ),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(

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
          this.url = url?.toString() ?? '';
        });
      },
      onLoadStop: (controller, url) async {
        print("onLoadStop $url");
        setState(() {
          this.url = url?.toString() ?? '';
        });
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) {
        print("onUpdateVisitedHistory $url");
        setState(() {
          this.url = url?.toString() ?? '';
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    headlessWebView?.dispose();
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
                child: ElevatedButton(
                    onPressed: () async {
                      await headlessWebView?.dispose();
                      await headlessWebView?.run();
                    },
                    child: Text("Run HeadlessInAppWebView")),
              ),
              Center(
                child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await headlessWebView?.webViewController.evaluateJavascript(source: """console.log('Here is the message!');""");
                      } on MissingPluginException catch(e) {
                        print("HeadlessInAppWebView is not running. Click on \"Run HeadlessInAppWebView\"!");
                      }
                    },
                    child: Text("Send console.log message")),
              ),
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      headlessWebView?.dispose();
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
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyInAppBrowser extends InAppBrowser {
  @override
  Future onBrowserCreated() async {
    print("\n\nBrowser Created!\n\n");
  }

  @override
  Future onLoadStart(url) async {
    print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(url) async {
    print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(url, code, message) {
    print("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(progress) {
    print("Progress: $progress");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }

  @override
  Future<NavigationActionPolicy?>? shouldOverrideUrlLoading(NavigationAction navigationAction)  async {
    print("\n\n override ${navigationAction.request.url}\n\n");
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(LoadedResource response) {
    print("Started at: " +
        response.startTime.toString() +
        "ms ---> duration: " +
        response.duration.toString() +
        "ms " +
        (response.url?.toString() ?? ''));
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

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
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
          child: ElevatedButton(
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

![ios](https://user-images.githubusercontent.com/5956938/109074100-92fd3700-76f7-11eb-8e75-34ce7377e35f.gif)

- Android:

![android](https://user-images.githubusercontent.com/5956938/45934080-26ffcd00-bf99-11e8-8136-d39a81bd83e7.gif)

#### `InAppBrowser` Methods

* `openUrlRequest({required URLRequest urlRequest, InAppBrowserClassOptions? options})`: Opens an `url` in a new `InAppBrowser` instance.
* `openFile({required String assetFilePath, InAppBrowserClassOptions? options})`: Opens the given `assetFilePath` file in a new `InAppBrowser` instance. The other arguments are the same of `InAppBrowser.open`.
* `openData({required String data, String mimeType = "text/html", String encoding = "utf8", Uri? baseUrl, Uri? androidHistoryUrl, InAppBrowserClassOptions? options})`: Opens a new `InAppBrowser` instance with `data` as a content, using `baseUrl` as the base URL for it.
* `openWithSystemBrowser({required Uri url})`: This is a static method that opens an `url` in the system browser. You wont be able to use the `InAppBrowser` methods here!
* `show`: Displays an `InAppBrowser` window that was opened hidden. Calling this has no effect if the `InAppBrowser` was already visible.
* `hide`: Hides the `InAppBrowser` window. Calling this has no effect if the `InAppBrowser` was already hidden.
* `close`: Closes the `InAppBrowser` window.
* `isHidden`: Check if the Web View of the `InAppBrowser` instance is hidden.
* `setOptions({required InAppBrowserClassOptions options})`: Sets the `InAppBrowser` options with the new `options` and evaluates them.
* `getOptions`: Gets the current `InAppBrowser` options as a `Map`. Returns `null` if the options are not setted yet.
* `isOpened`: Returns `true` if the `InAppBrowser` instance is opened, otherwise `false`.

#### `InAppBrowser` options

They are the same of the `InAppWebView` class.
Specific options of the `InAppBrowser` class are:

##### `InAppBrowser` Cross-platform options

* `hidden`: Set to `true` to create the browser and load the page, but not show it. Omit or set to `false` to have the browser open and load normally. The default value is `false`.
* `hideUrlBar`: Set to `true` to hide the url bar on the toolbar at the top. The default value is `false`.
* `hideProgressBar`: Set to `true` to hide the progress bar when the WebView is loading a page. The default value is `false`.
* `hideToolbarTop`: Set to `true` to hide the toolbar at the top of the WebView. The default value is `false`.
* `toolbarTopBackgroundColor`: Set the custom background color of the toolbar at the top.

##### `InAppBrowser` Android-specific options

* `closeOnCannotGoBack`: Set to `false` to not close the InAppBrowser when the user click on the back button and the WebView cannot go back to the history. The default value is `true`.
* `hideTitleBar`: Set to `true` if you want the title should be displayed. The default value is `false`.
* `toolbarTopFixedTitle`: Set the action bar's title.

##### `InAppBrowser` iOS-specific options

* `closeButtonCaption`: Set the custom text for the close button.
* `closeButtonColor`: Set the custom color for the close button.
* `hideToolbarBottom`: Set to `true` to hide the toolbar at the bottom of the WebView. The default value is `false`.
* `presentationStyle`: Set the custom modal presentation style when presenting the WebView. The default value is `IOSUIModalPresentationStyle.FULL_SCREEN`.
* `toolbarBottomBackgroundColor`: Set the custom background color of the toolbar at the bottom.
* `toolbarBottomTintColor`: Set the tint color to apply to the bar button items.
* `toolbarBottomTranslucent`: Set to `true` to set the toolbar at the bottom translucent. The default value is `true`.
* `toolbarTopTranslucent`: Set to `true` to set the toolbar at the top translucent. The default value is `true`.
* `toolbarTopBarTintColor`: Set the tint color to apply to the navigation bar background.
* `toolbarTopTintColor`: Set the tint color to apply to the navigation items and bar button items.
* `transitionStyle`: Set to the custom transition style when presenting the WebView. The default value is `IOSUIModalTransitionStyle.COVER_VERTICAL`.

#### `InAppBrowser` Events

They are the same of the `InAppWebView` class, except for `InAppWebView.onWebViewCreated` event.
Specific events of the `InAppBrowser` class are:

* `onBrowserCreated`: Event fired when the `InAppBrowser` is created.
* `onExit`: Event fired when the `InAppBrowser` window is closed.

### `ChromeSafariBrowser` class

[Chrome Custom Tabs](https://developer.android.com/reference/android/support/customtabs/package-summary) on Android / [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) on iOS.

If you want to use the `ChromeSafariBrowser` class on Android 11+ you need to specify your app querying for `android.support.customtabs.action.CustomTabsService` in your `AndroidManifest.xml` (you can read more about it here: https://developers.google.com/web/android/custom-tabs/best-practices#applications_targeting_android_11_api_level_30_or_above).

Create a Class that extends the `ChromeSafariBrowser` Class in order to override the callbacks to manage the browser events. Example:
```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyInAppBrowser extends InAppBrowser {

  @override
  Future onLoadStart(url) async {
    print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(url) async {
    print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(url, code, message) {
    print("\n\nCan't load $url.. Error: $message\n\n");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }

}

class MyChromeSafariBrowser extends ChromeSafariBrowser {

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

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  final ChromeSafariBrowser browser = new MyChromeSafariBrowser();

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
          child: ElevatedButton(
              onPressed: () async {
                await widget.browser.open(
                    url: Uri.parse("https://flutter.dev/"),
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

* `addMenuItem`: Adds a `ChromeSafariBrowserMenuItem` to the menu.
* `addMenuItems`: Adds a list of `ChromeSafariBrowserMenuItem` to the menu.
* `close`: Closes the `ChromeSafariBrowser` instance.
* `isOpened`: Returns `true` if the `ChromeSafariBrowser` instance is opened, otherwise `false`.
* `open({required Uri url, ChromeSafariBrowserClassOptions? options})`: Opens an `url` in a new `ChromeSafariBrowser` instance.
* `static isAvailable`: On Android, returns `true` if Chrome Custom Tabs is available. On iOS, returns `true` if SFSafariViewController is available. Otherwise returns `false`.

#### `ChromeSafariBrowser` options

##### `ChromeSafariBrowser` Android-specific options

* `addDefaultShareMenuItem`: Set to `false` if you don't want the default share item to the menu. The default value is `true`.
* `enableUrlBarHiding`: Set to `true` to enable the url bar to hide as the user scrolls down on the page. The default value is `false`.
* `instantAppsEnabled`: Set to `true` to enable Instant Apps. The default value is `false`.
* `keepAliveEnabled`: Set to `true` to enable Keep Alive. The default value is `false`.
* `packageName`: Set the name of the application package to handle the intent (for example `com.android.chrome`), or null to allow any application package.
* `showTitle`: Set to `false` if the title shouldn't be shown in the custom tab. The default value is `true`.
* `toolbarBackgroundColor`: Set the custom background color of the toolbar.

##### `ChromeSafariBrowser` iOS-specific options

* `barCollapsingEnabled`: Set to `true` to enable bar collapsing. The default value is `false`.
* `dismissButtonStyle`: Set the custom style for the dismiss button. The default value is `IOSSafariDismissButtonStyle.DONE`.
* `entersReaderIfAvailable`: Set to `true` if Reader mode should be entered automatically when it is available for the webpage. The default value is `false`.
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
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
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
                    initialUrlRequest: URLRequest(
                      url: Uri.parse("http://localhost:8080/assets/index.html")
                    ),
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(

                        )
                    ),
                    onWebViewCreated: (controller) {

                    },
                    onLoadStart: (controller, url) {

                    },
                    onLoadStop: (controller, url) {

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

**NOTE for iOS below 11.0 (LIMITED SUPPORT!)**: in this case, almost all of the methods (`CookieManager.deleteAllCookies` and `IOSCookieManager.getAllCookies` are not supported!) has been implemented using JavaScript because there is no other way to work with them on iOS below 11.0. See https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies for JavaScript restrictions.

#### `CookieManager` methods

* `instance`: Gets the cookie manager shared instance.
* `setCookie({required Uri url, required String name, required String value, String? domain, String path = "/", int? expiresDate, int? maxAge, bool? isSecure, bool? isHttpOnly, HTTPCookieSameSitePolicy? sameSite, InAppWebViewController? iosBelow11WebViewController})`: Sets a cookie for the given `url`. Any existing cookie with the same `host`, `path` and `name` will be replaced with the new cookie. The cookie being set will be ignored if it is expired.
* `getCookies({required Uri url, InAppWebViewController? iosBelow11WebViewController})`: Gets all the cookies for the given `url`.
* `getCookie({required Uri url, required String name, InAppWebViewController? iosBelow11WebViewController})`: Gets a cookie by its `name` for the given `url`.
* `deleteCookie({required Uri url, required String name, String domain = "", String path = "/", InAppWebViewController? iosBelow11WebViewController})`: Removes a cookie by its `name` for the given `url`, `domain` and `path`.
* `deleteCookies({required Uri url, String domain = "", String path = "/", InAppWebViewController? iosBelow11WebViewController})`: Removes all cookies for the given `url`, `domain` and `path`.
* `deleteAllCookies()`: Removes all cookies.

#### `CookieManager` iOS-specific methods

iOS-specific methods can be called using the `CookieManager.instance().ios` attribute.

* `getAllCookies()`: Fetches all stored cookies.

### `HttpAuthCredentialDatabase` class

This class implements a singleton object (shared instance) which manages the shared HTTP auth credentials cache.
On iOS, this class uses the [URLCredentialStorage](https://developer.apple.com/documentation/foundation/urlcredentialstorage) class.
On Android, this class has a custom implementation using `android.database.sqlite.SQLiteDatabase` because [WebViewDatabase](https://developer.android.com/reference/android/webkit/WebViewDatabase) doesn't offer the same functionalities as iOS `URLCredentialStorage`.

#### `HttpAuthCredentialDatabase` methods

* `instance`: Gets the database shared instance.
* `getAllAuthCredentials`: Gets a map list of all HTTP auth credentials saved.
* `getHttpAuthCredentials({required URLProtectionSpace protectionSpace})`: Gets all the HTTP auth credentials saved for that `protectionSpace`.
* `setHttpAuthCredential({required URLProtectionSpace protectionSpace, required URLCredential credential})`: Saves an HTTP auth `credential` for that `protectionSpace`.
* `removeHttpAuthCredential({required URLProtectionSpace protectionSpace, required URLCredential credential})`: Removes an HTTP auth `credential` for that `protectionSpace`.
* `removeHttpAuthCredentials({required URLProtectionSpace protectionSpace})`: Removes all the HTTP auth credentials saved for that `protectionSpace`.
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
* `deleteOrigin({required String origin})`: Clears the storage currently being used by both the Application Cache and Web SQL Database APIs by the given `origin`.
* `getQuotaForOrigin({required String origin})`: Gets the storage quota for the Web SQL Database API for the given `origin`.
* `getUsageForOrigin({required String origin})`: Gets the amount of storage currently being used by both the Application Cache and Web SQL Database APIs by the given `origin`.

#### `WebStorageManager` iOS-specific methods

iOS-specific methods can be called using the `WebStorageManager.instance().ios` attribute.

`IOSWebStorageManager` class represents various types of data that a website might make use of. This includes cookies, disk and memory caches, and persistent data such as WebSQL, IndexedDB databases, and local storage.

* `fetchDataRecords({required Set<IOSWKWebsiteDataType> dataTypes})`: Fetches data records containing the given website data types.
* `removeDataFor({required Set<IOSWKWebsiteDataType> dataTypes, required List<IOSWKWebsiteDataRecord> dataRecords})`: Removes website data of the given types for the given data records.
* `removeDataModifiedSince({required Set<IOSWKWebsiteDataType> dataTypes, required DateTime date})`: Removes all website data of the given types that has been modified since the given date.

### WebRTC

To work with WebRTC, you need to request `camera` and `microphone` permissions, for example using the [permission_handler](https://pub.dev/packages/permission_handler) plugin:
```dart
import 'package:permission_handler/permission_handler.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.camera.request();
  await Permission.microphone.request();

  runApp(MyApp());
}
```
Also, you need to set the cross-platform option `mediaPlaybackRequiresUserGesture` to `false` in order to autoplay HTML5 audio and video.

After that, follow the instructions below for each platform where you want to use it.

To test WebRTC, you can try to visit https://appr.tc/.

#### WebRTC on Android

On Android, you need to implement the `androidOnPermissionRequest` event, that is an event fired when the WebView is requesting permission to access a specific resource.
This event is used to grant permissions for the WebRTC API, for example:
```dart
androidOnPermissionRequest: (controller, origin, resources) async {
  return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
}
```

Also, you need to add these permissions in your `AndroidManifest.xml` file:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.VIDEO_CAPTURE" />
<uses-permission android:name="android.permission.AUDIO_CAPTURE" />
```

#### WebRTC on iOS

On iOS, WebRTC is supported starting from 14.3+.

You need to set the iOS-specific option `allowsInlineMediaPlayback` to `true`, for example:
```dart
initialOptions: InAppWebViewGroupOptions(
  crossPlatform: InAppWebViewOptions(
    mediaPlaybackRequiresUserGesture: false,
  ),
  android: AndroidInAppWebViewOptions(
    useHybridComposition: true
  ),
  ios: IOSInAppWebViewOptions(
    allowsInlineMediaPlayback: true,
  )
),
```
Note that on iOS, to be able to play video inline, the `video` HTML element must have the `playsinline` attribute, for example:
```html
<video autoplay playsinline src="..."></video>
```
In your `Info.plist` file, you need to add also the following properties:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Flutter requires access to microphone.</string>

<key>NSCameraUsageDescription</key>
<string>Flutter requires access to camera.</string>
```
If you open this file In Xcode, the `NSMicrophoneUsageDescription` property is represented by `Privacy - Microphone Usage Description` and
`NSCameraUsageDescription` is represented by `Privacy - Camera Usage Description`.

### Service Worker API

Check https://caniuse.com/serviceworkers for JavaScript Service Worker API availability.

#### Service Worker API on Android

On Android, the `AndroidServiceWorkerController` and `AndroidServiceWorkerClient` classes can be used to intercept requests.
Before using these classes or their methods, you should check if the service worker features you want to use are supported or not, for example:
```dart
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController = AndroidServiceWorkerController.instance();

      serviceWorkerController.serviceWorkerClient = AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      );
    }
  }

  runApp(MyApp());
}
```

#### Service Worker API on iOS

The JavaScript Service Worker API is available starting from iOS 14.0+.

To enable this JavaScript API on iOS there are only 2 ways:
- using "App-Bound Domains"
- your App proposes itself as a possible "Default Browser" such as iOS Safari or Google Chrome

##### iOS App-Bound Domains

Read the [WebKit - App-Bound Domains](https://webkit.org/blog/10882/app-bound-domains/) article for details.

You can specify up to 10 "app-bound" domains using the new Info.plist key `WKAppBoundDomains`, for example:
```xml
<dict>
<key>WKAppBoundDomains</key>
<array>
    <string>flutter.dev</string>
    <string>github.com</string>
</array>
</dict>
```

After that, you need to set to `true` the `limitsNavigationsToAppBoundDomains` iOS-specific WebView option, for example:
```dart
InAppWebViewGroupOptions(
  ios: IOSInAppWebViewOptions(
    limitsNavigationsToAppBoundDomains: true // adds Service Worker API on iOS 14.0+
  )
)
```

##### iOS Default Browser

Read the [Preparing Your App to be the Default Browser or Email Client](https://developer.apple.com/documentation/xcode/allowing_apps_and_websites_to_link_to_your_content/preparing_your_app_to_be_the_default_browser_or_email_client) article for details.

