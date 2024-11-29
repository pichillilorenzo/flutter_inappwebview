import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../context_menu/main.dart';
import '../debug_logging_settings.dart';
import '../find_interaction/platform_find_interaction_controller.dart';
import '../in_app_browser/platform_in_app_browser.dart';
import '../inappwebview_platform.dart';
import '../platform_webview_feature.dart';
import '../print_job/main.dart';
import '../types/main.dart';
import '../web_message/main.dart';
import '../web_storage/platform_web_storage.dart';
import '../web_uri.dart';

import 'in_app_webview_keep_alive.dart';
import 'in_app_webview_settings.dart';
import 'platform_headless_in_app_webview.dart';
import 'platform_inappwebview_widget.dart';
import 'platform_webview.dart';

///List of forbidden names for JavaScript handlers used internally bu the plugin.
final kJavaScriptHandlerForbiddenNames = UnmodifiableListView<String>([
  "onLoadResource",
  "onConsoleMessage",
  "shouldInterceptAjaxRequest",
  "onAjaxReadyStateChange",
  "onAjaxProgress",
  "shouldInterceptFetchRequest",
  "onPrintRequest",
  "onWindowFocus",
  "onWindowBlur",
  "callAsyncJavaScript",
  "evaluateJavaScriptWithContentWorld",
  "onFindResultReceived",
  "onCallAsyncJavaScriptResultBelowIOS14Received",
  "onWebMessagePortMessageReceived",
  "onWebMessageListenerPostMessageReceived",
  "onScrollChanged"
]);

/// Object specifying creation parameters for creating a [PlatformInAppWebViewController].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformInAppWebViewControllerCreationParams {
  /// Used by the platform implementation to create a new [PlatformInAppWebViewController].
  const PlatformInAppWebViewControllerCreationParams(
      {required this.id, this.webviewParams});

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.id}
  final dynamic id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.webviewParams}
  final PlatformWebViewCreationParams? webviewParams;
}

///Controls a WebView, such as an [InAppWebView] widget instance, a [HeadlessInAppWebView] instance or [PlatformInAppBrowser] WebView instance.
///
///If you are using the [InAppWebView] widget, an [PlatformInAppWebViewController] instance can be obtained by setting the [InAppWebView.onWebViewCreated]
///callback. Instead, if you are using an [PlatformInAppBrowser] instance, you can get it through the [PlatformInAppBrowser.webViewController] attribute.
abstract class PlatformInAppWebViewController extends PlatformInterface
    implements Disposable {
  ///Debug settings used by [PlatformInAppWebViewWidget], [PlatformHeadlessInAppWebView] and [PlatformInAppBrowser].
  ///The default value excludes the [PlatformWebViewCreationParams.onScrollChanged], [PlatformWebViewCreationParams.onOverScrolled] and [PlatformWebViewCreationParams.onReceivedIcon] events.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings(
      maxLogMessageLength: 1000,
      excludeFilter: [
        RegExp(r"onScrollChanged"),
        RegExp(r"onOverScrolled"),
        RegExp(r"onReceivedIcon")
      ]);

  /// Creates a new [PlatformInAppWebViewController]
  factory PlatformInAppWebViewController(
      PlatformInAppWebViewControllerCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInAppWebViewController inAppWebViewController =
        InAppWebViewPlatform.instance!
            .createPlatformInAppWebViewController(params);
    PlatformInterface.verify(inAppWebViewController, _token);
    return inAppWebViewController;
  }

  /// Creates a new [PlatformInAppWebViewController] to access static methods.
  factory PlatformInAppWebViewController.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInAppWebViewController inAppWebViewControllerStatic =
        InAppWebViewPlatform.instance!
            .createPlatformInAppWebViewControllerStatic();
    PlatformInterface.verify(inAppWebViewControllerStatic, _token);
    return inAppWebViewControllerStatic;
  }

  /// Used by the platform implementation to create a new [PlatformInAppWebViewController].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformInAppWebViewController.implementation(this.params)
      : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformInAppWebViewController].
  final PlatformInAppWebViewControllerCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.id}
  /// WebView ID.
  ///{@endtemplate}
  dynamic get id => params.id;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.webviewParams}
  /// WebView params.
  ///{@endtemplate}
  PlatformWebViewCreationParams? get webviewParams => params.webviewParams;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.webStorage}
  ///Provides access to the JavaScript [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API): `window.sessionStorage` and `window.localStorage`.
  ///{@endtemplate}
  PlatformWebStorage get webStorage => throw UnimplementedError(
      'webStorage is not implemented on the current platform');

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getUrl}
  ///Gets the URL for the current page.
  ///This is not always the same as the URL passed to [PlatformWebViewCreationParams.onLoadStart] because although the load for that URL has begun, the current page may not have changed.
  ///
  ///**NOTE for Web**: If `window.location.href` isn't accessible inside the iframe,
  ///it will return the current value of the `iframe.src` attribute.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getUrl](https://developer.android.com/reference/android/webkit/WebView#getUrl()))
  ///- iOS ([Official API - WKWebView.url](https://developer.apple.com/documentation/webkit/wkwebview/1415005-url))
  ///- MacOS ([Official API - WKWebView.url](https://developer.apple.com/documentation/webkit/wkwebview/1415005-url))
  ///- Web
  ///- Windows ([Official API - ICoreWebView2.get_Source](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#get_source))
  ///{@endtemplate}
  Future<WebUri?> getUrl() {
    throw UnimplementedError(
        'getUrl is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getTitle}
  ///Gets the title for the current page.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getTitle](https://developer.android.com/reference/android/webkit/WebView#getTitle()))
  ///- iOS ([Official API - WKWebView.title](https://developer.apple.com/documentation/webkit/wkwebview/1415015-title))
  ///- MacOS ([Official API - WKWebView.title](https://developer.apple.com/documentation/webkit/wkwebview/1415015-title))
  ///- Web
  ///- Windows ([Official API - ICoreWebView2.get_DocumentTitle](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#get_documenttitle))
  ///{@endtemplate}
  Future<String?> getTitle() {
    throw UnimplementedError(
        'getTitle is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getProgress}
  ///Gets the progress for the current page. The progress value is between 0 and 100.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getProgress](https://developer.android.com/reference/android/webkit/WebView#getProgress()))
  ///- iOS ([Official API - WKWebView.estimatedProgress](https://developer.apple.com/documentation/webkit/wkwebview/1415007-estimatedprogress))
  ///- MacOS ([Official API - WKWebView.estimatedProgress](https://developer.apple.com/documentation/webkit/wkwebview/1415007-estimatedprogress))
  ///{@endtemplate}
  Future<int?> getProgress() {
    throw UnimplementedError(
        'getProgress is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getHtml}
  ///Gets the content html of the page. It first tries to get the content through javascript.
  ///If this doesn't work, it tries to get the content reading the file:
  ///- checking if it is an asset (`file:///`) or
  ///- downloading it using an `HttpClient` through the WebView's current url.
  ///
  ///Returns `null` if it was unable to get it.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<String?> getHtml() {
    throw UnimplementedError(
        'getHtml is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getFavicons}
  ///Gets the list of all favicons for the current page.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<List<Favicon>> getFavicons() {
    throw UnimplementedError(
        'getFavicons is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadUrl}
  ///Loads the given [urlRequest].
  ///
  ///- [allowingReadAccessTo], used in combination with [urlRequest] (using the `file://` scheme),
  ///it represents the URL from which to read the web content.
  ///This URL must be a file-based URL (using the `file://` scheme).
  ///Specify the same value as the URL parameter to prevent WebView from reading any other content.
  ///Specify a directory to give WebView permission to read additional files in the specified directory.
  ///**NOTE**: available only on iOS and MacOS.
  ///
  ///**NOTE for Android**: when loading an URL Request using "POST" method, headers are ignored.
  ///
  ///**NOTE for Web**: if method is "GET" and headers are empty, it will change the `src` of the iframe.
  ///For all other cases it will try to create an XMLHttpRequest and load the result inside the iframe.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.loadUrl](https://developer.android.com/reference/android/webkit/WebView#loadUrl(java.lang.String))). If method is "POST", [Official API - WebView.postUrl](https://developer.android.com/reference/android/webkit/WebView#postUrl(java.lang.String,%20byte[]))
  ///- iOS ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load). If [allowingReadAccessTo] is used, [Official API - WKWebView.loadFileURL](https://developer.apple.com/documentation/webkit/wkwebview/1414973-loadfileurl))
  ///- MacOS ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load). If [allowingReadAccessTo] is used, [Official API - WKWebView.loadFileURL](https://developer.apple.com/documentation/webkit/wkwebview/1414973-loadfileurl))
  ///- Web
  ///- Windows ([Official API - ICoreWebView2_2.NavigateWithWebResourceRequest](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_2?view=webview2-1.0.2210.55#navigatewithwebresourcerequest))
  ///{@endtemplate}
  Future<void> loadUrl(
      {required URLRequest urlRequest,
      @Deprecated('Use allowingReadAccessTo instead')
      Uri? iosAllowingReadAccessTo,
      WebUri? allowingReadAccessTo}) {
    throw UnimplementedError(
        'loadUrl is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.postUrl}
  ///Loads the given [url] with [postData] (x-www-form-urlencoded) using `POST` method into this WebView.
  ///
  ///Example:
  ///```dart
  ///var postData = Uint8List.fromList(utf8.encode("firstname=Foo&surname=Bar"));
  ///controller.postUrl(url: WebUri("https://www.example.com/"), postData: postData);
  ///```
  ///
  ///**NOTE for Web**: it will try to create an XMLHttpRequest and load the result inside the iframe.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.postUrl](https://developer.android.com/reference/android/webkit/WebView#postUrl(java.lang.String,%20byte[])))
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<void> postUrl({required WebUri url, required Uint8List postData}) {
    throw UnimplementedError(
        'postUrl is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadData}
  ///Loads the given [data] into this WebView, using [baseUrl] as the base URL for the content.
  ///
  ///- [mimeType] argument specifies the format of the data. The default value is `"text/html"`.
  ///- [encoding] argument specifies the encoding of the data. The default value is `"utf8"`.
  ///**NOTE**: not used on Web.
  ///- [historyUrl] is an Android-specific argument that represents the URL to use as the history entry. The default value is `about:blank`. If non-null, this must be a valid URL.
  ///**NOTE**: not used on Web.
  ///- [allowingReadAccessTo], used in combination with [baseUrl] (using the `file://` scheme),
  ///it represents the URL from which to read the web content.
  ///This [baseUrl] must be a file-based URL (using the `file://` scheme).
  ///Specify the same value as the [baseUrl] parameter to prevent WebView from reading any other content.
  ///Specify a directory to give WebView permission to read additional files in the specified directory.
  ///**NOTE**: available only on iOS and MacOS.
  ///
  ///**NOTE for Windows**: only the [data] parameter is used.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.loadDataWithBaseURL](https://developer.android.com/reference/android/webkit/WebView#loadDataWithBaseURL(java.lang.String,%20java.lang.String,%20java.lang.String,%20java.lang.String,%20java.lang.String)))
  ///- iOS ([Official API - WKWebView.loadHTMLString](https://developer.apple.com/documentation/webkit/wkwebview/1415004-loadhtmlstring) or [Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1415011-load))
  ///- MacOS ([Official API - WKWebView.loadHTMLString](https://developer.apple.com/documentation/webkit/wkwebview/1415004-loadhtmlstring) or [Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1415011-load))
  ///- Web
  ///- Windows ([Official API - ICoreWebView2.NavigateToString](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#navigatetostring))
  ///{@endtemplate}
  Future<void> loadData(
      {required String data,
      String mimeType = "text/html",
      String encoding = "utf8",
      WebUri? baseUrl,
      @Deprecated('Use historyUrl instead') Uri? androidHistoryUrl,
      WebUri? historyUrl,
      @Deprecated('Use allowingReadAccessTo instead')
      Uri? iosAllowingReadAccessTo,
      WebUri? allowingReadAccessTo}) {
    throw UnimplementedError(
        'loadData is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadFile}
  ///Loads the given [assetFilePath].
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
  ///Example:
  ///```dart
  ///...
  ///controller.loadFile(assetFilePath: "assets/index.html");
  ///...
  ///```
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.loadUrl](https://developer.android.com/reference/android/webkit/WebView#loadUrl(java.lang.String)))
  ///- iOS ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load))
  ///- MacOS ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load))
  ///- Web
  ///- Windows ([Official API - ICoreWebView2.Navigate](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#navigate))
  ///{@endtemplate}
  Future<void> loadFile({required String assetFilePath}) {
    throw UnimplementedError(
        'loadFile is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.reload}
  ///Reloads the WebView.
  ///
  ///**NOTE for Web**: if `window.location.reload()` is not accessible inside the iframe, it will reload using the iframe `src` attribute.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.reload](https://developer.android.com/reference/android/webkit/WebView#reload()))
  ///- iOS ([Official API - WKWebView.reload](https://developer.apple.com/documentation/webkit/wkwebview/1414969-reload))
  ///- MacOS ([Official API - WKWebView.reload](https://developer.apple.com/documentation/webkit/wkwebview/1414969-reload))
  ///- Web ([Official API - Location.reload](https://developer.mozilla.org/en-US/docs/Web/API/Location/reload))
  ///- Windows ([Official API - ICoreWebView2.Reload](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#reload))
  ///{@endtemplate}
  Future<void> reload() {
    throw UnimplementedError(
        'reload is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goBack}
  ///Goes back in the history of the WebView.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.goBack](https://developer.android.com/reference/android/webkit/WebView#goBack()))
  ///- iOS ([Official API - WKWebView.goBack](https://developer.apple.com/documentation/webkit/wkwebview/1414952-goback))
  ///- MacOS ([Official API - WKWebView.goBack](https://developer.apple.com/documentation/webkit/wkwebview/1414952-goback))
  ///- Web ([Official API - History.back](https://developer.mozilla.org/en-US/docs/Web/API/History/back))
  ///- Windows ([Official API - ICoreWebView2.GoBack](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#goback))
  ///{@endtemplate}
  Future<void> goBack() {
    throw UnimplementedError(
        'goBack is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canGoBack}
  ///Returns a boolean value indicating whether the WebView can move backward.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.canGoBack](https://developer.android.com/reference/android/webkit/WebView#canGoBack()))
  ///- iOS ([Official API - WKWebView.canGoBack](https://developer.apple.com/documentation/webkit/wkwebview/1414966-cangoback))
  ///- MacOS ([Official API - WKWebView.canGoBack](https://developer.apple.com/documentation/webkit/wkwebview/1414966-cangoback))
  ///- Windows ([Official API - ICoreWebView2.get_CanGoBack](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#get_cangoback))
  ///{@endtemplate}
  Future<bool> canGoBack() {
    throw UnimplementedError(
        'canGoBack is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goForward}
  ///Goes forward in the history of the WebView.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.goForward](https://developer.android.com/reference/android/webkit/WebView#goForward()))
  ///- iOS ([Official API - WKWebView.goForward](https://developer.apple.com/documentation/webkit/wkwebview/1414993-goforward))
  ///- MacOS ([Official API - WKWebView.goForward](https://developer.apple.com/documentation/webkit/wkwebview/1414993-goforward))
  ///- Web ([Official API - History.forward](https://developer.mozilla.org/en-US/docs/Web/API/History/forward))
  ///- Windows ([Official API - ICoreWebView2.GoForward](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#goforward))
  ///{@endtemplate}
  Future<void> goForward() {
    throw UnimplementedError(
        'goForward is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canGoForward}
  ///Returns a boolean value indicating whether the WebView can move forward.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.canGoForward](https://developer.android.com/reference/android/webkit/WebView#canGoForward()))
  ///- iOS ([Official API - WKWebView.canGoForward](https://developer.apple.com/documentation/webkit/wkwebview/1414962-cangoforward))
  ///- MacOS ([Official API - WKWebView.canGoForward](https://developer.apple.com/documentation/webkit/wkwebview/1414962-cangoforward))
  ///- Windows ([Official API - ICoreWebView2.get_CanGoForward](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#get_cangoforward))
  ///{@endtemplate}
  Future<bool> canGoForward() {
    throw UnimplementedError(
        'canGoForward is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goBackOrForward}
  ///Goes to the history item that is the number of steps away from the current item. Steps is negative if backward and positive if forward.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.goBackOrForward](https://developer.android.com/reference/android/webkit/WebView#goBackOrForward(int)))
  ///- iOS ([Official API - WKWebView.go](https://developer.apple.com/documentation/webkit/wkwebview/1414991-go))
  ///- MacOS ([Official API - WKWebView.go](https://developer.apple.com/documentation/webkit/wkwebview/1414991-go))
  ///- Web ([Official API - History.go](https://developer.mozilla.org/en-US/docs/Web/API/History/go))
  ///- Windows
  ///{@endtemplate}
  Future<void> goBackOrForward({required int steps}) {
    throw UnimplementedError(
        'goBackOrForward is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canGoBackOrForward}
  ///Returns a boolean value indicating whether the WebView can go back or forward the given number of steps. Steps is negative if backward and positive if forward.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.canGoBackOrForward](https://developer.android.com/reference/android/webkit/WebView#canGoBackOrForward(int)))
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Future<bool> canGoBackOrForward({required int steps}) {
    throw UnimplementedError(
        'canGoBackOrForward is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goTo}
  ///Navigates to a [WebHistoryItem] from the back-forward [WebHistory.list] and sets it as the current item.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///- Windows
  ///{@endtemplate}
  Future<void> goTo({required WebHistoryItem historyItem}) {
    throw UnimplementedError('goTo is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isLoading}
  ///Check if the WebView instance is in a loading state.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///- Windows
  ///{@endtemplate}
  Future<bool> isLoading() {
    throw UnimplementedError(
        'isLoading is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.stopLoading}
  ///Stops the WebView from loading.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.stopLoading](https://developer.android.com/reference/android/webkit/WebView#stopLoading()))
  ///- iOS ([Official API - WKWebView.stopLoading](https://developer.apple.com/documentation/webkit/wkwebview/1414981-stoploading))
  ///- MacOS ([Official API - WKWebView.stopLoading](https://developer.apple.com/documentation/webkit/wkwebview/1414981-stoploading))
  ///- Web ([Official API - Window.stop](https://developer.mozilla.org/en-US/docs/Web/API/Window/stop))
  ///- Windows ([Official API - ICoreWebView2.Stop](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#stop))
  ///{@endtemplate}
  Future<void> stopLoading() {
    throw UnimplementedError(
        'stopLoading is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.evaluateJavascript}
  ///Evaluates JavaScript [source] code into the WebView and returns the result of the evaluation.
  ///
  ///[contentWorld], on iOS, it represents the namespace in which to evaluate the JavaScript [source] code.
  ///Instead, on Android, it will run the [source] code into an iframe, using `eval(source);` to get and return the result.
  ///This parameter doesn’t apply to changes you make to the underlying web content, such as the document’s DOM structure.
  ///Those changes remain visible to all scripts, regardless of which content world you specify.
  ///For more information about content worlds, see [ContentWorld].
  ///Available on iOS 14.0+ and MacOS 11.0+.
  ///**NOTE**: not used on Web and on Windows platforms.
  ///
  ///**NOTE**: This method shouldn't be called in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events,
  ///because, in these events, the `WebView` is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [PlatformWebViewCreationParams.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.evaluateJavascript](https://developer.android.com/reference/android/webkit/WebView#evaluateJavascript(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.String%3E)))
  ///- iOS ([Official API - WKWebView.evaluateJavascript](https://developer.apple.com/documentation/webkit/wkwebview/3656442-evaluatejavascript))
  ///- MacOS ([Official API - WKWebView.evaluateJavascript](https://developer.apple.com/documentation/webkit/wkwebview/3656442-evaluatejavascript))
  ///- Web ([Official API - Window.eval](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/eval?retiredLocale=it))
  ///- Windows
  ///{@endtemplate}
  Future<dynamic> evaluateJavascript(
      {required String source, ContentWorld? contentWorld}) {
    throw UnimplementedError(
        'evaluateJavascript is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectJavascriptFileFromUrl}
  ///Injects an external JavaScript file into the WebView from a defined url.
  ///
  ///[scriptHtmlTagAttributes] represents the possible the `<script>` HTML attributes to be set.
  ///
  ///**NOTE**: This method shouldn't be called in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events,
  ///because, in these events, the `WebView` is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [PlatformWebViewCreationParams.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<void> injectJavascriptFileFromUrl(
      {required WebUri urlFile,
      ScriptHtmlTagAttributes? scriptHtmlTagAttributes}) {
    throw UnimplementedError(
        'injectJavascriptFileFromUrl is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectJavascriptFileFromAsset}
  ///Evaluates the content of a JavaScript file into the WebView from the flutter assets directory.
  ///
  ///**NOTE**: This method shouldn't be called in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events,
  ///because, in these events, the `WebView` is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [PlatformWebViewCreationParams.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///- Windows
  ///{@endtemplate}
  Future<dynamic> injectJavascriptFileFromAsset(
      {required String assetFilePath}) {
    throw UnimplementedError(
        'injectJavascriptFileFromAsset is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSCode}
  ///Injects CSS into the WebView.
  ///
  ///**NOTE**: This method shouldn't be called in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events,
  ///because, in these events, the `WebView` is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [PlatformWebViewCreationParams.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<void> injectCSSCode({required String source}) {
    throw UnimplementedError(
        'injectCSSCode is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSFileFromUrl}
  ///Injects an external CSS file into the WebView from a defined url.
  ///
  ///[cssLinkHtmlTagAttributes] represents the possible CSS stylesheet `<link>` HTML attributes to be set.
  ///
  ///**NOTE**: This method shouldn't be called in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events,
  ///because, in these events, the `WebView` is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [PlatformWebViewCreationParams.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<void> injectCSSFileFromUrl(
      {required WebUri urlFile,
      CSSLinkHtmlTagAttributes? cssLinkHtmlTagAttributes}) {
    throw UnimplementedError(
        'injectCSSFileFromUrl is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSFileFromAsset}
  ///Injects a CSS file into the WebView from the flutter assets directory.
  ///
  ///**NOTE**: This method shouldn't be called in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events,
  ///because, in these events, the `WebView` is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [PlatformWebViewCreationParams.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<void> injectCSSFileFromAsset({required String assetFilePath}) {
    throw UnimplementedError(
        'injectCSSFileFromAsset is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addJavaScriptHandler}
  ///Adds a JavaScript message handler [callback] ([JavaScriptHandlerCallback] or [JavaScriptHandlerFunction]) that listen to post messages sent from JavaScript by the handler with name [handlerName].
  ///Forbidden [handlerName]s are represented by [kJavaScriptHandlerForbiddenNames], they are used internally by this plugin.
  ///
  ///The Android implementation uses [addJavascriptInterface](https://developer.android.com/reference/android/webkit/WebView#addJavascriptInterface(java.lang.Object,%20java.lang.String)).
  ///The iOS/macOS implementation uses [addScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537172-addscriptmessagehandler?language=objc)
  ///
  ///The JavaScript function that can be used to call the handler is `window.flutter_inappwebview.callHandler(handlerName <String>, ...args)`, where `args` are [rest parameters](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters).
  ///The `args` will be stringified automatically using `JSON.stringify(args)` method and then they will be decoded on the Dart side.
  ///
  ///In order to call `window.flutter_inappwebview.callHandler(handlerName <String>, ...args)` properly, you need to wait and listen the JavaScript event `flutterInAppWebViewPlatformReady`.
  ///This event will be dispatched as soon as the platform (Android or iOS) is ready to handle the `callHandler` method.
  ///```javascript
  ///   window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
  ///     console.log("ready");
  ///   });
  ///```
  ///
  ///`window.flutter_inappwebview.callHandler` returns a JavaScript [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)
  ///that can be used to get the json result returned by [JavaScriptHandlerCallback] or [JavaScriptHandlerFunction].
  ///In this case, simply return data that you want to send and it will be automatically json encoded using [jsonEncode] from the `dart:convert` library.
  ///
  ///So, on the JavaScript side, to get data coming from the Dart side, you will use:
  ///```html
  ///<script>
  ///   window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
  ///     window.flutter_inappwebview.callHandler('handlerFoo').then(function(result) {
  ///       console.log(result);
  ///     });
  ///
  ///     window.flutter_inappwebview.callHandler('handlerFooWithArgs', 1, true, ['bar', 5], {foo: 'baz'}).then(function(result) {
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
  ///    window.flutter_inappwebview.callHandler('test', 'Text from Javascript').then(function(result) {
  ///      console.log(result);
  ///    });
  ///  """);
  ///```
  ///
  ///There could be forbidden names for JavaScript handlers depending on the implementation platform.
  ///
  ///**NOTE**: This method should be called, for example, in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events or, at least,
  ///before you know that your JavaScript code will call the `window.flutter_inappwebview.callHandler` method,
  ///otherwise you won't be able to intercept the JavaScript message.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  void addJavaScriptHandler(
      {required String handlerName, required Function callback}) {
    throw UnimplementedError(
        'addJavaScriptHandler is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeJavaScriptHandler}
  ///Removes a JavaScript message handler previously added with the [addJavaScriptHandler] associated to [handlerName] key.
  ///Returns the value associated with [handlerName] before it was removed.
  ///Returns `null` if [handlerName] was not found.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Function? removeJavaScriptHandler({required String handlerName}) {
    throw UnimplementedError(
        'removeJavaScriptHandler is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasJavaScriptHandler}
  ///Returns `true` if a JavaScript handler with [handlerName] already exists, otherwise `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  bool hasJavaScriptHandler({required String handlerName}) {
    throw UnimplementedError(
        'hasJavaScriptHandler is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.takeScreenshot}
  ///Takes a screenshot of the WebView's visible viewport and returns a [Uint8List]. Returns `null` if it wasn't be able to take it.
  ///
  ///[screenshotConfiguration] represents the configuration data to use when generating an image from a web view’s contents.
  ///
  ///**NOTE for iOS**: available on iOS 11.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 10.13+.
  ///
  ///**NOTE for Android**: To be able to take screenshots outside the visible viewport,
  ///you must call [PlatformInAppWebViewController.enableSlowWholeDocumentDraw] before any WebViews are created.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKWebView.takeSnapshot](https://developer.apple.com/documentation/webkit/wkwebview/2873260-takesnapshot))
  ///- MacOS ([Official API - WKWebView.takeSnapshot](https://developer.apple.com/documentation/webkit/wkwebview/2873260-takesnapshot))
  ///- Windows
  ///{@endtemplate}
  Future<Uint8List?> takeScreenshot(
      {ScreenshotConfiguration? screenshotConfiguration}) {
    throw UnimplementedError(
        'takeScreenshot is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setSettings}
  ///Sets the WebView settings with the new [settings] and evaluates them.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<void> setSettings({required InAppWebViewSettings settings}) {
    throw UnimplementedError(
        'setSettings is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getSettings}
  ///Gets the current WebView settings. Returns `null` if it wasn't able to get them.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<InAppWebViewSettings?> getSettings() {
    throw UnimplementedError(
        'getSettings is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCopyBackForwardList}
  ///Gets the WebHistory for this WebView. This contains the back/forward list for use in querying each item in the history stack.
  ///This contains only a snapshot of the current state.
  ///Multiple calls to this method may return different objects.
  ///The object returned from this method will not be updated to reflect any new state.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.copyBackForwardList](https://developer.android.com/reference/android/webkit/WebView#copyBackForwardList()))
  ///- iOS ([Official API - WKWebView.backForwardList](https://developer.apple.com/documentation/webkit/wkwebview/1414977-backforwardlist))
  ///- MacOS ([Official API - WKWebView.backForwardList](https://developer.apple.com/documentation/webkit/wkwebview/1414977-backforwardlist))
  ///- Windows
  ///{@endtemplate}
  Future<WebHistory?> getCopyBackForwardList() {
    throw UnimplementedError(
        'getCopyBackForwardList is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearCache}
  ///Use [PlatformInAppWebViewController.clearAllCache] instead
  ///{@endtemplate}
  @Deprecated("Use InAppWebViewController.clearAllCache instead")
  Future<void> clearCache() {
    throw UnimplementedError(
        'clearCache is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.scrollTo}
  ///Scrolls the WebView to the position.
  ///
  ///[x] represents the x position to scroll to.
  ///
  ///[y] represents the y position to scroll to.
  ///
  ///[animated] `true` to animate the scroll transition, `false` to make the scoll transition immediate.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: this method is implemented using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.scrollTo](https://developer.android.com/reference/android/view/View#scrollTo(int,%20int)))
  ///- iOS ([Official API - UIScrollView.setContentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619400-setcontentoffset))
  ///- MacOS
  ///- Web ([Official API - Window.scrollTo](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollTo))
  ///{@endtemplate}
  Future<void> scrollTo(
      {required int x, required int y, bool animated = false}) {
    throw UnimplementedError(
        'scrollTo is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.scrollBy}
  ///Moves the scrolled position of the WebView.
  ///
  ///[x] represents the amount of pixels to scroll by horizontally.
  ///
  ///[y] represents the amount of pixels to scroll by vertically.
  ///
  ///[animated] `true` to animate the scroll transition, `false` to make the scoll transition immediate.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: this method is implemented using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.scrollBy](https://developer.android.com/reference/android/view/View#scrollBy(int,%20int)))
  ///- iOS ([Official API - UIScrollView.setContentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619400-setcontentoffset))
  ///- MacOS
  ///- Web ([Official API - Window.scrollBy](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollBy))
  ///{@endtemplate}
  Future<void> scrollBy(
      {required int x, required int y, bool animated = false}) {
    throw UnimplementedError(
        'scrollBy is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pauseTimers}
  ///On Android native WebView, it pauses all layout, parsing, and JavaScript timers for all WebViews.
  ///This is a global requests, not restricted to just this WebView. This can be useful if the application has been paused.
  ///
  ///**NOTE for iOS**: it is implemented using JavaScript and it is restricted to just this WebView.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript and it is restricted to just this WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.pauseTimers](https://developer.android.com/reference/android/webkit/WebView#pauseTimers()))
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<void> pauseTimers() {
    throw UnimplementedError(
        'pauseTimers is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.resumeTimers}
  ///On Android, it resumes all layout, parsing, and JavaScript timers for all WebViews. This will resume dispatching all timers.
  ///
  ///**NOTE for iOS**: it is implemented using JavaScript and it is restricted to just this WebView.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript and it is restricted to just this WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.resumeTimers](https://developer.android.com/reference/android/webkit/WebView#resumeTimers()))
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<void> resumeTimers() {
    throw UnimplementedError(
        'resumeTimers is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.printCurrentPage}
  ///Prints the current page.
  ///
  ///To obtain the [PlatformPrintJobController], use [settings] argument with [PrintJobSettings.handledByClient] to `true`.
  ///Otherwise this method will return `null` and the [PlatformPrintJobController] will be handled and disposed automatically by the system.
  ///
  ///**NOTE for Android**: available on Android 19+.
  ///
  ///**NOTE for MacOS**: [PlatformPrintJobController] is available on MacOS 11.0+.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin. Also, [PlatformPrintJobController] is always `null`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintManager.print](https://developer.android.com/reference/android/print/PrintManager#print(java.lang.String,%20android.print.PrintDocumentAdapter,%20android.print.PrintAttributes)))
  ///- iOS ([Official API - UIPrintInteractionController.present](https://developer.apple.com/documentation/uikit/uiprintinteractioncontroller/1618149-present))
  ///- MacOS (if 11.0+, [Official API - WKWebView.printOperation](https://developer.apple.com/documentation/webkit/wkwebview/3516861-printoperation), else [Official API - NSView.printView](https://developer.apple.com/documentation/appkit/nsview/1483705-printview))
  ///- Web ([Official API - Window.print](https://developer.mozilla.org/en-US/docs/Web/API/Window/print))
  ///{@endtemplate}
  Future<PlatformPrintJobController?> printCurrentPage(
      {PrintJobSettings? settings}) {
    throw UnimplementedError(
        'printCurrentPage is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getContentHeight}
  ///Gets the height of the HTML content.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getContentHeight](https://developer.android.com/reference/android/webkit/WebView#getContentHeight()))
  ///- iOS ([Official API - UIScrollView.contentSize](https://developer.apple.com/documentation/uikit/uiscrollview/1619399-contentsize))
  ///- MacOS
  ///- Web ([Official API - Document.documentElement.scrollHeight](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollHeight))
  ///{@endtemplate}
  Future<int?> getContentHeight() {
    throw UnimplementedError(
        'getContentHeight is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getContentWidth}
  ///Gets the width of the HTML content.
  ///
  ///**NOTE for Android**: it is implemented using JavaScript.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - UIScrollView.contentSize](https://developer.apple.com/documentation/uikit/uiscrollview/1619399-contentsize))
  ///- MacOS
  ///- Web ([Official API - Document.documentElement.scrollWidth](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollWidth))
  ///{@endtemplate}
  Future<int?> getContentWidth() {
    throw UnimplementedError(
        'getContentWidth is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.zoomBy}
  ///Performs a zoom operation in this WebView.
  ///
  ///[zoomFactor] represents the zoom factor to apply. On Android, the zoom factor will be clamped to the Webview's zoom limits and, also, this value must be in the range 0.01 (excluded) to 100.0 (included).
  ///
  ///[animated] `true` to animate the transition to the new scale, `false` to make the transition immediate.
  ///**NOTE**: available only on iOS.
  ///
  ///**NOTE**: available on Android 21+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.zoomBy](https://developer.android.com/reference/android/webkit/WebView#zoomBy(float)))
  ///- iOS ([Official API - UIScrollView.setZoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619412-setzoomscale))
  ///{@endtemplate}
  Future<void> zoomBy(
      {required double zoomFactor,
      @Deprecated('Use animated instead') bool? iosAnimated,
      bool animated = false}) {
    throw UnimplementedError(
        'zoomBy is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getOriginalUrl}
  ///Gets the URL that was originally requested for the current page.
  ///This is not always the same as the URL passed to [InAppWebView.onLoadStart] because although the load for that URL has begun,
  ///the current page may not have changed. Also, there may have been redirects resulting in a different URL to that originally requested.
  ///
  ///**NOTE for Web**: it will return the current value of the `iframe.src` attribute.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getOriginalUrl](https://developer.android.com/reference/android/webkit/WebView#getOriginalUrl()))
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<WebUri?> getOriginalUrl() {
    throw UnimplementedError(
        'getOriginalUrl is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getZoomScale}
  ///Gets the current zoom scale of the WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - UIScrollView.zoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619419-zoomscale))
  ///- Windows ([Official API - ICoreWebView2Controller.get_ZoomFactor](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controller?view=webview2-1.0.2849.39#get_zoomfactor))
  ///{@endtemplate}
  Future<double?> getZoomScale() {
    throw UnimplementedError(
        'getZoomScale is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getSelectedText}
  ///Gets the selected text.
  ///
  ///**NOTE**: this method is implemented with using JavaScript.
  ///
  ///**NOTE for Android native WebView**: available only on Android 19+.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<String?> getSelectedText() {
    throw UnimplementedError(
        'getSelectedText is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getHitTestResult}
  ///Gets the hit result for hitting an HTML elements.
  ///
  ///**NOTE**: On iOS, it is implemented using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getHitTestResult](https://developer.android.com/reference/android/webkit/WebView#getHitTestResult()))
  ///- iOS
  ///{@endtemplate}
  Future<InAppWebViewHitTestResult?> getHitTestResult() {
    throw UnimplementedError(
        'getHitTestResult is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestFocus}
  ///Call this method when you want to try the WebView to be the first responder.
  ///
  ///On Android, call this to try to give focus to the WebView and
  ///give it hints about the [direction] and a specific [previouslyFocusedRect] that the focus is coming from.
  ///The [previouslyFocusedRect] can help give larger views a finer grained hint about where focus is coming from,
  ///and therefore, where to show selection, or forward focus change internally.
  ///
  ///Returns `true` whether this WebView actually took focus; otherwise, `false`.
  ///
  ///**NOTE**: [direction] and [previouslyFocusedRect] are available only on Android.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.requestFocus](https://developer.android.com/reference/android/webkit/WebView#requestFocus(int,%20android.graphics.Rect)))
  ///- iOS ([Official API - UIResponder.becomeFirstResponder](https://developer.apple.com/documentation/uikit/uiresponder/1621113-becomefirstresponder))
  ///- MacOS ([Official API - NSWindow.makeFirstResponder](https://developer.apple.com/documentation/appkit/nswindow/1419366-makefirstresponder))
  ///{@endtemplate}
  Future<bool?> requestFocus(
      {FocusDirection? direction, InAppWebViewRect? previouslyFocusedRect}) {
    throw UnimplementedError(
        'requestFocus is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearFocus}
  ///Clears the current focus. On iOS and Android native WebView, it will clear also, for example, the current text selection.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - ViewGroup.clearFocus](https://developer.android.com/reference/android/view/ViewGroup#clearFocus()))
  ///- iOS ([Official API - UIResponder.resignFirstResponder](https://developer.apple.com/documentation/uikit/uiresponder/1621097-resignfirstresponder))
  ///- MacOS ([Official API - NSWindow.makeFirstResponder](https://developer.apple.com/documentation/appkit/nswindow/1419366-makefirstresponder))
  ///{@endtemplate}
  Future<void> clearFocus() {
    throw UnimplementedError(
        'clearFocus is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setInputMethodEnabled}
  ///Enables/Disables the input method (system-supplied keyboard) whilst interacting with the webview.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIResponder.inputView](https://developer.apple.com/documentation/uikit/uiresponder/1621092-inputview))
  ///{@endtemplate}
  Future<void> setInputMethodEnabled(bool enabled) {
    throw UnimplementedError(
        'setInputMethodEnabled is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.showInputMethod}
  ///Explicitly request that the current input method's soft input area be shown to the user, if needed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - InputMethodManager.showSoftInput](https://developer.android.com/reference/android/view/inputmethod/InputMethodManager#showSoftInput(android.view.View,%20int)))
  ///{@endtemplate}
  Future<void> showInputMethod() {
    throw UnimplementedError(
        'showInputMethod is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hideInputMethod}
  ///Request to hide the soft input view from the context of the view that is currently accepting input.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - InputMethodManager.hideSoftInputFromWindow](https://developer.android.com/reference/android/view/inputmethod/InputMethodManager#hideSoftInputFromWindow(android.os.IBinder,%20int)))
  ///- iOS ([Official API - UIView.endEditing](https://developer.apple.com/documentation/uikit/uiview/1619630-endediting))
  ///{@endtemplate}
  Future<void> hideInputMethod() {
    throw UnimplementedError(
        'hideInputMethod is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setContextMenu}
  ///Sets or updates the WebView context menu to be used next time it will appear.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///{@endtemplate}
  Future<void> setContextMenu(ContextMenu? contextMenu) {
    throw UnimplementedError(
        'setContextMenu is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestFocusNodeHref}
  ///Requests the anchor or image element URL at the last tapped point.
  ///
  ///**NOTE**: On iOS, it is implemented using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.requestFocusNodeHref](https://developer.android.com/reference/android/webkit/WebView#requestFocusNodeHref(android.os.Message)))
  ///- iOS
  ///{@endtemplate}
  Future<RequestFocusNodeHrefResult?> requestFocusNodeHref() {
    throw UnimplementedError(
        'requestFocusNodeHref is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestImageRef}
  ///Requests the URL of the image last touched by the user.
  ///
  ///**NOTE**: On iOS, it is implemented using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.requestImageRef](https://developer.android.com/reference/android/webkit/WebView#requestImageRef(android.os.Message)))
  ///- iOS
  ///{@endtemplate}
  Future<RequestImageRefResult?> requestImageRef() {
    throw UnimplementedError(
        'requestImageRef is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMetaTags}
  ///Returns the list of `<meta>` tags of the current WebView.
  ///
  ///**NOTE**: It is implemented using JavaScript.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<List<MetaTag>> getMetaTags() {
    throw UnimplementedError(
        'getMetaTags is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMetaThemeColor}
  ///Returns an instance of [Color] representing the `content` value of the
  ///`<meta name="theme-color" content="">` tag of the current WebView, if available, otherwise `null`.
  ///
  ///**NOTE**: on Android, Web, iOS < 15.0 and MacOS < 12.0, it is implemented using JavaScript.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKWebView.themeColor](https://developer.apple.com/documentation/webkit/wkwebview/3794258-themecolor))
  ///- MacOS ([Official API - WKWebView.themeColor](https://developer.apple.com/documentation/webkit/wkwebview/3794258-themecolor))
  ///- Web
  ///{@endtemplate}
  Future<Color?> getMetaThemeColor() {
    throw UnimplementedError(
        'getMetaThemeColor is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getScrollX}
  ///Returns the scrolled left position of the current WebView.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.getScrollX](https://developer.android.com/reference/android/view/View#getScrollX()))
  ///- iOS ([Official API - UIScrollView.contentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619404-contentoffset))
  ///- MacOS
  ///- Web ([Official API - Window.scrollX](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollX))
  ///{@endtemplate}
  Future<int?> getScrollX() {
    throw UnimplementedError(
        'getScrollX is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getScrollY}
  ///Returns the scrolled top position of the current WebView.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.getScrollY](https://developer.android.com/reference/android/view/View#getScrollY()))
  ///- iOS ([Official API - UIScrollView.contentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619404-contentoffset))
  ///- MacOS
  ///- Web ([Official API - Window.scrollY](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollY))
  ///{@endtemplate}
  Future<int?> getScrollY() {
    throw UnimplementedError(
        'getScrollY is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCertificate}
  ///Gets the SSL certificate for the main top-level page or null if there is no certificate (the site is not secure).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getCertificate](https://developer.android.com/reference/android/webkit/WebView#getCertificate()))
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Future<SslCertificate?> getCertificate() {
    throw UnimplementedError(
        'getCertificate is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addUserScript}
  ///Injects the specified [userScript] into the webpage’s content.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKUserContentController.addUserScript](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537448-adduserscript))
  ///- MacOS ([Official API - WKUserContentController.addUserScript](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537448-adduserscript))
  ///- Windows
  ///{@endtemplate}
  Future<void> addUserScript({required UserScript userScript}) {
    throw UnimplementedError(
        'addUserScript is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addUserScripts}
  ///Injects the [userScripts] into the webpage’s content.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Future<void> addUserScripts({required List<UserScript> userScripts}) {
    throw UnimplementedError(
        'addUserScripts is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScript}
  ///Removes the specified [userScript] from the webpage’s content.
  ///User scripts already loaded into the webpage's content cannot be removed. This will have effect only on the next page load.
  ///Returns `true` if [userScript] was in the list, `false` otherwise.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Future<bool> removeUserScript({required UserScript userScript}) {
    throw UnimplementedError(
        'removeUserScript is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScriptsByGroupName}
  ///Removes all the [UserScript]s with [groupName] as group name from the webpage’s content.
  ///User scripts already loaded into the webpage's content cannot be removed. This will have effect only on the next page load.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Future<void> removeUserScriptsByGroupName({required String groupName}) {
    throw UnimplementedError(
        'removeUserScriptsByGroupName is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScripts}
  ///Removes the [userScripts] from the webpage’s content.
  ///User scripts already loaded into the webpage's content cannot be removed. This will have effect only on the next page load.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Future<void> removeUserScripts({required List<UserScript> userScripts}) {
    throw UnimplementedError(
        'removeUserScripts is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeAllUserScripts}
  ///Removes all the user scripts from the webpage’s content.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKUserContentController.removeAllUserScripts](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1536540-removealluserscripts))
  ///- MacOS ([Official API - WKUserContentController.removeAllUserScripts](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1536540-removealluserscripts))
  ///- Windows
  ///{@endtemplate}
  Future<void> removeAllUserScripts() {
    throw UnimplementedError(
        'removeAllUserScripts is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasUserScript}
  ///Returns `true` if the [userScript] has been already added, otherwise `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  bool hasUserScript({required UserScript userScript}) {
    throw UnimplementedError(
        'hasUserScript is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.callAsyncJavaScript}
  ///Executes the specified string as an asynchronous JavaScript function.
  ///
  ///[functionBody] is the JavaScript string to use as the function body.
  ///This method treats the string as an anonymous JavaScript function body and calls it with the named arguments in the arguments parameter.
  ///
  ///[arguments] is a `Map` of the arguments to pass to the function call.
  ///Each key in the `Map` corresponds to the name of an argument in the [functionBody] string,
  ///and the value of that key is the value to use during the evaluation of the code.
  ///Supported value types can be found in the official Flutter docs:
  ///[Platform channel data types support and codecs](https://flutter.dev/docs/development/platform-integration/platform-channels#codec),
  ///except for [Uint8List], [Int32List], [Int64List], and [Float64List] that should be converted into a [List].
  ///All items in a `List` or `Map` must also be one of the supported types.
  ///
  ///[contentWorld], on iOS, it represents the namespace in which to evaluate the JavaScript [source] code.
  ///Instead, on Android, it will run the [source] code into an iframe.
  ///This parameter doesn’t apply to changes you make to the underlying web content, such as the document’s DOM structure.
  ///Those changes remain visible to all scripts, regardless of which content world you specify.
  ///For more information about content worlds, see [ContentWorld].
  ///Available on iOS 14.3+.
  ///
  ///**NOTE**: This method shouldn't be called in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events,
  ///because, in these events, the `WebView` is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [PlatformWebViewCreationParams.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for iOS**: available only on iOS 10.3+.
  ///
  ///**NOTE for Android**: available only on Android 21+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKWebView.callAsyncJavaScript](https://developer.apple.com/documentation/webkit/wkwebview/3656441-callasyncjavascript))
  ///- MacOS ([Official API - WKWebView.callAsyncJavaScript](https://developer.apple.com/documentation/webkit/wkwebview/3656441-callasyncjavascript))
  ///- Windows
  ///{@endtemplate}
  Future<CallAsyncJavaScriptResult?> callAsyncJavaScript(
      {required String functionBody,
      Map<String, dynamic> arguments = const <String, dynamic>{},
      ContentWorld? contentWorld}) {
    throw UnimplementedError(
        'callAsyncJavaScript is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.saveWebArchive}
  ///Saves the current WebView as a web archive.
  ///Returns the file path under which the web archive file was saved, or `null` if saving the file failed.
  ///
  ///[filePath] represents the file path where the archive should be placed. This value cannot be `null`.
  ///
  ///[autoname] if `false`, takes [filePath] to be a file.
  ///If `true`, [filePath] is assumed to be a directory in which a filename will be chosen according to the URL of the current page.
  ///
  ///**NOTE for iOS**: Available on iOS 14.0+. If [autoname] is `false`, the [filePath] must ends with the [WebArchiveFormat.WEBARCHIVE] file extension.
  ///
  ///**NOTE for MacOS**: Available on MacOS 11.0+. If [autoname] is `false`, the [filePath] must ends with the [WebArchiveFormat.WEBARCHIVE] file extension.
  ///
  ///**NOTE for Android**: if [autoname] is `false`, the [filePath] must ends with the [WebArchiveFormat.MHT] file extension.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.saveWebArchive](https://developer.android.com/reference/android/webkit/WebView#saveWebArchive(java.lang.String,%20boolean,%20android.webkit.ValueCallback%3Cjava.lang.String%3E)))
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<String?> saveWebArchive(
      {required String filePath, bool autoname = false}) {
    throw UnimplementedError(
        'saveWebArchive is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isSecureContext}
  ///Indicates whether the webpage context is capable of using features that require [secure contexts](https://developer.mozilla.org/en-US/docs/Web/Security/Secure_Contexts).
  ///This is implemented using Javascript (see [window.isSecureContext](https://developer.mozilla.org/en-US/docs/Web/API/Window/isSecureContext)).
  ///
  ///**NOTE for Android**: available Android 21.0+.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin. Returns `false` otherwise.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web ([Official API - Window.isSecureContext](https://developer.mozilla.org/en-US/docs/Web/API/Window/isSecureContext))
  ///{@endtemplate}
  Future<bool> isSecureContext() {
    throw UnimplementedError(
        'isSecureContext is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.createWebMessageChannel}
  ///Creates a message channel to communicate with JavaScript and returns the message channel with ports that represent the endpoints of this message channel.
  ///The HTML5 message channel functionality is described [here](https://html.spec.whatwg.org/multipage/comms.html#messagechannel).
  ///
  ///The returned message channels are entangled and already in started state.
  ///
  ///This method should be called when the page is loaded, for example, when the [PlatformWebViewCreationParams.onLoadStop] is fired, otherwise the [PlatformWebMessageChannel] won't work.
  ///
  ///**NOTE for Android native WebView**: This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL].
  ///
  ///**NOTE for iOS**: it is implemented using JavaScript.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.createWebMessageChannel](https://developer.android.com/reference/androidx/webkit/WebViewCompat#createWebMessageChannel(android.webkit.WebView)))
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<PlatformWebMessageChannel?> createWebMessageChannel() {
    throw UnimplementedError(
        'createWebMessageChannel is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.postWebMessage}
  ///Post a message to main frame. The embedded application can restrict the messages to a certain target origin.
  ///See [HTML5 spec](https://html.spec.whatwg.org/multipage/comms.html#posting-messages) for how target origin can be used.
  ///
  ///A target origin can be set as a wildcard ("*"). However this is not recommended.
  ///
  ///**NOTE for Android native WebView**: This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.POST_WEB_MESSAGE].
  ///
  ///**NOTE for iOS**: it is implemented using JavaScript.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.postWebMessage](https://developer.android.com/reference/androidx/webkit/WebViewCompat#postWebMessage(android.webkit.WebView,%20androidx.webkit.WebMessageCompat,%20android.net.Uri)))
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<void> postWebMessage(
      {required WebMessage message, WebUri? targetOrigin}) {
    throw UnimplementedError(
        'postWebMessage is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addWebMessageListener}
  ///Adds a [PlatformWebMessageListener] to the WebView and injects a JavaScript object into each frame that the [PlatformWebMessageListener] will listen on.
  ///
  ///The injected JavaScript object will be named [PlatformWebMessageListener.jsObjectName] in the global scope.
  ///This will inject the JavaScript object in any frame whose origin matches [PlatformWebMessageListener.allowedOriginRules]
  ///for every navigation after this call, and the JavaScript object will be available immediately when the page begins to load.
  ///
  ///Each [PlatformWebMessageListener.allowedOriginRules] entry must follow the format `SCHEME "://" [ HOSTNAME_PATTERN [ ":" PORT ] ]`, each part is explained in the below table:
  ///
  ///<table>
  ///   <colgroup>
  ///      <col width="25%">
  ///   </colgroup>
  ///   <tbody>
  ///      <tr>
  ///         <th>Rule</th>
  ///         <th>Description</th>
  ///         <th>Example</th>
  ///      </tr>
  ///      <tr>
  ///         <td>http/https with hostname</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is http or https; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> is a regular hostname; <code translate="no" dir="ltr">PORT</code> is optional, when not present, the rule will match port <code translate="no" dir="ltr">80</code> for http and port
  ///            <code translate="no" dir="ltr">443</code> for https.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">https://foobar.com:8080</code> - Matches https:// URL on port 8080, whose normalized
  ///                  host is foobar.com.
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://www.example.com</code> - Matches https:// URL on port 443, whose normalized host
  ///                  is www.example.com.
  ///               </li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td>http/https with pattern matching</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is http or https; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> is a sub-domain matching
  ///            pattern with a leading <code translate="no" dir="ltr">*.<wbr></code>; <code translate="no" dir="ltr">PORT</code> is optional, when not present, the rule will
  ///            match port <code translate="no" dir="ltr">80</code> for http and port <code translate="no" dir="ltr">443</code> for https.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">https://*.example.com</code> - Matches https://calendar.example.com and
  ///                  https://foo.bar.example.com but not https://example.com.
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://*.example.com:8080</code> - Matches https://calendar.example.com:8080</li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td>http/https with IP literal</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is https or https; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> is IP literal; <code translate="no" dir="ltr">PORT</code> is
  ///            optional, when not present, the rule will match port <code translate="no" dir="ltr">80</code> for http and port <code translate="no" dir="ltr">443</code>
  ///            for https.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">https://127.0.0.1</code> - Matches https:// URL on port 443, whose IPv4 address is
  ///                  127.0.0.1
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://[::1]</code> or <code translate="no" dir="ltr">https://[0:0::1]</code>- Matches any URL to the IPv6 loopback
  ///                  address with port 443.
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://[::1]:99</code> - Matches any https:// URL to the IPv6 loopback on port 99.</li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td>Custom scheme</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is a custom scheme; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> and <code translate="no" dir="ltr">PORT</code> must not be
  ///            present.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">my-app-scheme://</code> - Matches any my-app-scheme:// URL.</li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td><code translate="no" dir="ltr">*</code></td>
  ///         <td>Wildcard rule, matches any origin.</td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">*</code></li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///   </tbody>
  ///</table>
  ///
  ///Note that this is a powerful API, as the JavaScript object will be injected when the frame's origin matches any one of the allowed origins.
  ///The HTTPS scheme is strongly recommended for security; allowing HTTP origins exposes the injected object to any potential network-based attackers.
  ///If a wildcard "*" is provided, it will inject the JavaScript object to all frames.
  ///A wildcard should only be used if the app wants **any** third party web page to be able to use the injected object.
  ///When using a wildcard, the app must treat received messages as untrustworthy and validate any data carefully.
  ///
  ///This method can be called multiple times to inject multiple JavaScript objects.
  ///
  ///Let's say the injected JavaScript object is named `myObject`. We will have following methods on that object once it is available to use:
  ///
  ///```javascript
  /// // Web page (in JavaScript)
  /// // message needs to be a JavaScript String, MessagePorts is an optional parameter.
  /// myObject.postMessage(message[, MessagePorts]) // on Android
  /// myObject.postMessage(message) // on iOS
  ///
  /// // To receive messages posted from the app side, assign a function to the "onmessage"
  /// // property. This function should accept a single "event" argument. "event" has a "data"
  /// // property, which is the message string from the app side.
  /// myObject.onmessage = function(event) { ... }
  ///
  /// // To be compatible with DOM EventTarget's addEventListener, it accepts type and listener
  /// // parameters, where type can be only "message" type and listener can only be a JavaScript
  /// // function for myObject. An event object will be passed to listener with a "data" property,
  /// // which is the message string from the app side.
  /// myObject.addEventListener(type, listener)
  ///
  /// // To be compatible with DOM EventTarget's removeEventListener, it accepts type and listener
  /// // parameters, where type can be only "message" type and listener can only be a JavaScript
  /// // function for myObject.
  /// myObject.removeEventListener(type, listener)
  ///```
  ///
  ///We start the communication between JavaScript and the app from the JavaScript side.
  ///In order to send message from the app to JavaScript, it needs to post a message from JavaScript first,
  ///so the app will have a [PlatformJavaScriptReplyProxy] object to respond. Example:
  ///
  ///```javascript
  /// // Web page (in JavaScript)
  /// myObject.onmessage = function(event) {
  ///   // prints "Got it!" when we receive the app's response.
  ///   console.log(event.data);
  /// }
  /// myObject.postMessage("I'm ready!");
  ///```
  ///
  ///```dart
  /// // Flutter App
  /// child: InAppWebView(
  ///   onWebViewCreated: (controller) async {
  ///     if (defaultTargetPlatform != TargetPlatform.android || await WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) {
  ///       await controller.addWebMessageListener(WebMessageListener(
  ///         jsObjectName: "myObject",
  ///         onPostMessage: (message, sourceOrigin, isMainFrame, replyProxy) {
  ///           // do something about message, sourceOrigin and isMainFrame.
  ///           replyProxy.postMessage("Got it!");
  ///         },
  ///       ));
  ///     }
  ///     await controller.loadUrl(urlRequest: URLRequest(url: WebUri("https://www.example.com")));
  ///   },
  /// ),
  ///```
  ///
  ///**NOTE for Android**: This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.WEB_MESSAGE_LISTENER].
  ///
  ///**NOTE for iOS**: it is implemented using JavaScript.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.WebMessageListener](https://developer.android.com/reference/androidx/webkit/WebViewCompat#addWebMessageListener(android.webkit.WebView,%20java.lang.String,%20java.util.Set%3Cjava.lang.String%3E,%20androidx.webkit.WebViewCompat.WebMessageListener)))
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<void> addWebMessageListener(
      PlatformWebMessageListener webMessageListener) {
    throw UnimplementedError(
        'addWebMessageListener is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasWebMessageListener}
  ///Returns `true` if the [webMessageListener] has been already added, otherwise `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  bool hasWebMessageListener(PlatformWebMessageListener webMessageListener) {
    throw UnimplementedError(
        'hasWebMessageListener is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canScrollVertically}
  ///Returns `true` if the webpage can scroll vertically, otherwise `false`.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<bool> canScrollVertically() {
    throw UnimplementedError(
        'canScrollVertically is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canScrollHorizontally}
  ///Returns `true` if the webpage can scroll horizontally, otherwise `false`.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<bool> canScrollHorizontally() {
    throw UnimplementedError(
        'canScrollHorizontally is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.startSafeBrowsing}
  ///Starts Safe Browsing initialization.
  ///
  ///URL loads are not guaranteed to be protected by Safe Browsing until after the this method returns true.
  ///Safe Browsing is not fully supported on all devices. For those devices this method will returns false.
  ///
  ///This should not be called if Safe Browsing has been disabled by manifest tag or [AndroidInAppWebViewOptions.safeBrowsingEnabled].
  ///This prepares resources used for Safe Browsing.
  ///
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.START_SAFE_BROWSING].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.startSafeBrowsing](https://developer.android.com/reference/android/webkit/WebView#startSafeBrowsing(android.content.Context,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  ///{@endtemplate}
  Future<bool> startSafeBrowsing() {
    throw UnimplementedError(
        'startSafeBrowsing is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearSslPreferences}
  ///Clears the SSL preferences table stored in response to proceeding with SSL certificate errors.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.clearSslPreferences](https://developer.android.com/reference/android/webkit/WebView#clearSslPreferences()))
  ///- Windows ([Official API - ICoreWebView2_3.ClearServerCertificateErrorActions](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_14?view=webview2-1.0.2792.45#clearservercertificateerroractions))
  ///{@endtemplate}
  Future<void> clearSslPreferences() {
    throw UnimplementedError(
        'clearSslPreferences is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pause}
  ///Does a best-effort attempt to pause any processing that can be paused safely, such as animations and geolocation. Note that this call does not pause JavaScript.
  ///To pause JavaScript globally, use [PlatformInAppWebViewController.pauseTimers]. To resume WebView, call [resume].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.onPause](https://developer.android.com/reference/android/webkit/WebView#onPause()))
  ///- Windows ([Official API - ICoreWebView2_3.TrySuspend](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_3?view=webview2-1.0.2792.45#trysuspend)
  ///{@endtemplate}
  Future<void> pause() {
    throw UnimplementedError(
        'pause is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.resume}
  ///Resumes a WebView after a previous call to [pause].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.onResume](https://developer.android.com/reference/android/webkit/WebView#onResume()))
  ///- Windows ([Official API - ICoreWebView2_3.Resume](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_3?view=webview2-1.0.2792.45#resume)
  ///{@endtemplate}
  Future<void> resume() {
    throw UnimplementedError(
        'resume is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pageDown}
  ///Scrolls the contents of this WebView down by half the page size.
  ///Returns `true` if the page was scrolled.
  ///
  ///[bottom] `true` to jump to bottom of page.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.pageDown](https://developer.android.com/reference/android/webkit/WebView#pageDown(boolean)))
  ///{@endtemplate}
  Future<bool> pageDown({required bool bottom}) {
    throw UnimplementedError(
        'pageDown is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pageUp}
  ///Scrolls the contents of this WebView up by half the view size.
  ///Returns `true` if the page was scrolled.
  ///
  ///[top] `true` to jump to the top of the page.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.pageUp](https://developer.android.com/reference/android/webkit/WebView#pageUp(boolean)))
  ///{@endtemplate}
  Future<bool> pageUp({required bool top}) {
    throw UnimplementedError(
        'pageUp is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.zoomIn}
  ///Performs zoom in in this WebView.
  ///Returns `true` if zoom in succeeds, `false` if no zoom changes.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.zoomIn](https://developer.android.com/reference/android/webkit/WebView#zoomIn()))
  ///{@endtemplate}
  Future<bool> zoomIn() {
    throw UnimplementedError(
        'zoomIn is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.zoomOut}
  ///Performs zoom out in this WebView.
  ///Returns `true` if zoom out succeeds, `false` if no zoom changes.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.zoomOut](https://developer.android.com/reference/android/webkit/WebView#zoomOut()))
  ///{@endtemplate}
  Future<bool> zoomOut() {
    throw UnimplementedError(
        'zoomOut is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearHistory}
  ///Clears the internal back/forward list.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.clearHistory](https://developer.android.com/reference/android/webkit/WebView#clearHistory()))
  ///{@endtemplate}
  Future<void> clearHistory() {
    throw UnimplementedError(
        'clearHistory is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearFormData}
  ///Removes the autocomplete popup from the currently focused form field, if present.
  ///Note this only affects the display of the autocomplete popup,
  ///it does not remove any saved form data from this WebView's store.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.clearFormData](https://developer.android.com/reference/android/webkit/WebView#clearFormData()))
  ///{@endtemplate}
  Future<void> clearFormData() {
    throw UnimplementedError(
        'clearFormData is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.reloadFromOrigin}
  ///Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.reloadFromOrigin](https://developer.apple.com/documentation/webkit/wkwebview/1414956-reloadfromorigin))
  ///- MacOS ([Official API - WKWebView.reloadFromOrigin](https://developer.apple.com/documentation/webkit/wkwebview/1414956-reloadfromorigin))
  ///{@endtemplate}
  Future<void> reloadFromOrigin() {
    throw UnimplementedError(
        'reloadFromOrigin is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.createPdf}
  ///Generates PDF data from the web view’s contents asynchronously.
  ///Returns `null` if a problem occurred.
  ///
  ///[pdfConfiguration] represents the object that specifies the portion of the web view to capture as PDF data.
  ///
  ///**NOTE for iOS**: available only on iOS 14.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 11.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.createPdf](https://developer.apple.com/documentation/webkit/wkwebview/3650490-createpdf))
  ///- MacOS ([Official API - WKWebView.createPdf](https://developer.apple.com/documentation/webkit/wkwebview/3650490-createpdf))
  ///{@endtemplate}
  Future<Uint8List?> createPdf(
      {@Deprecated("Use pdfConfiguration instead")
      // ignore: deprecated_member_use_from_same_package
      IOSWKPDFConfiguration? iosWKPdfConfiguration,
      PDFConfiguration? pdfConfiguration}) {
    throw UnimplementedError(
        'createPdf is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.createWebArchiveData}
  ///Creates a web archive of the web view’s current contents asynchronously.
  ///Returns `null` if a problem occurred.
  ///
  ///**NOTE for iOS**: available only on iOS 14.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 11.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.createWebArchiveData](https://developer.apple.com/documentation/webkit/wkwebview/3650491-createwebarchivedata))
  ///- MacOS ([Official API - WKWebView.createWebArchiveData](https://developer.apple.com/documentation/webkit/wkwebview/3650491-createwebarchivedata))
  ///{@endtemplate}
  Future<Uint8List?> createWebArchiveData() {
    throw UnimplementedError(
        'createWebArchiveData is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasOnlySecureContent}
  ///A Boolean value indicating whether all resources on the page have been loaded over securely encrypted connections.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.hasOnlySecureContent](https://developer.apple.com/documentation/webkit/wkwebview/1415002-hasonlysecurecontent))
  ///- MacOS ([Official API - WKWebView.hasOnlySecureContent](https://developer.apple.com/documentation/webkit/wkwebview/1415002-hasonlysecurecontent))
  ///{@endtemplate}
  Future<bool> hasOnlySecureContent() {
    throw UnimplementedError(
        'hasOnlySecureContent is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pauseAllMediaPlayback}
  ///Pauses playback of all media in the web view.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.pauseAllMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebview/3752240-pauseallmediaplayback))
  ///- MacOS ([Official API - WKWebView.pauseAllMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebview/3752240-pauseallmediaplayback))
  ///{@endtemplate}
  Future<void> pauseAllMediaPlayback() {
    throw UnimplementedError(
        'pauseAllMediaPlayback is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setAllMediaPlaybackSuspended}
  ///Changes whether the webpage is suspending playback of all media in the page.
  ///Pass `true` to pause all media the web view is playing. Neither the user nor the webpage can resume playback until you call this method again with `false`.
  ///
  ///[suspended] represents a [bool] value that indicates whether the webpage should suspend media playback.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.setAllMediaPlaybackSuspended](https://developer.apple.com/documentation/webkit/wkwebview/3752242-setallmediaplaybacksuspended))
  ///- MacOS ([Official API - WKWebView.setAllMediaPlaybackSuspended](https://developer.apple.com/documentation/webkit/wkwebview/3752242-setallmediaplaybacksuspended))
  ///{@endtemplate}
  Future<void> setAllMediaPlaybackSuspended({required bool suspended}) {
    throw UnimplementedError(
        'setAllMediaPlaybackSuspended is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.closeAllMediaPresentations}
  ///Closes all media the web view is presenting, including picture-in-picture video and fullscreen video.
  ///
  ///**NOTE for iOS**: available on iOS 14.5+.
  ///
  ///**NOTE for MacOS**: available on MacOS 11.3+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.closeAllMediaPresentations](https://developer.apple.com/documentation/webkit/wkwebview/3752235-closeallmediapresentations))
  ///- MacOS ([Official API - WKWebView.closeAllMediaPresentations](https://developer.apple.com/documentation/webkit/wkwebview/3752235-closeallmediapresentations))
  ///{@endtemplate}
  Future<void> closeAllMediaPresentations() {
    throw UnimplementedError(
        'closeAllMediaPresentations is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestMediaPlaybackState}
  ///Requests the playback status of media in the web view.
  ///Returns a [MediaPlaybackState] that indicates whether the media in the web view is playing, paused, or suspended.
  ///If there’s no media in the web view to play, this method provides [MediaPlaybackState.NONE].
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.requestMediaPlaybackState](https://developer.apple.com/documentation/webkit/wkwebview/3752241-requestmediaplaybackstate))
  ///- MacOS ([Official API - WKWebView.requestMediaPlaybackState](https://developer.apple.com/documentation/webkit/wkwebview/3752241-requestmediaplaybackstate))
  ///{@endtemplate}
  Future<MediaPlaybackState?> requestMediaPlaybackState() {
    throw UnimplementedError(
        'requestMediaPlaybackState is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isInFullscreen}
  ///Returns `true` if the `WebView` is in fullscreen mode, otherwise `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<bool> isInFullscreen() {
    throw UnimplementedError(
        'isInFullscreen is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCameraCaptureState}
  ///Returns a [MediaCaptureState] that indicates whether the webpage is using the camera to capture images or video.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.cameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763093-cameracapturestate))
  ///- MacOS ([Official API - WKWebView.cameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763093-cameracapturestate))
  ///{@endtemplate}
  Future<MediaCaptureState?> getCameraCaptureState() {
    throw UnimplementedError(
        'getCameraCaptureState is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setCameraCaptureState}
  ///Changes whether the webpage is using the camera to capture images or video.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.setCameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763097-setcameracapturestate))
  ///- MacOS ([Official API - WKWebView.setCameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763097-setcameracapturestate))
  ///{@endtemplate}
  Future<void> setCameraCaptureState({required MediaCaptureState state}) {
    throw UnimplementedError(
        'setCameraCaptureState is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMicrophoneCaptureState}
  ///Returns a [MediaCaptureState] that indicates whether the webpage is using the microphone to capture audio.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.microphoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763096-microphonecapturestate))
  ///- MacOS ([Official API - WKWebView.microphoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763096-microphonecapturestate))
  ///{@endtemplate}
  Future<MediaCaptureState?> getMicrophoneCaptureState() {
    throw UnimplementedError(
        'getMicrophoneCaptureState is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setMicrophoneCaptureState}
  ///Changes whether the webpage is using the microphone to capture audio.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.setMicrophoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763098-setmicrophonecapturestate))
  ///- MacOS ([Official API - WKWebView.setMicrophoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763098-setmicrophonecapturestate))
  ///{@endtemplate}
  Future<void> setMicrophoneCaptureState({required MediaCaptureState state}) {
    throw UnimplementedError(
        'setMicrophoneCaptureState is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadSimulatedRequest}
  ///Loads the web content from the data you provide as if the data were the response to the request.
  ///If [urlResponse] is `null`, it loads the web content from the data as an utf8 encoded HTML string as the response to the request.
  ///
  ///[urlRequest] represents a URL request that specifies the base URL and other loading details the system uses to interpret the data you provide.
  ///
  ///[urlResponse] represents a response the system uses to interpret the data you provide.
  ///
  ///[data] represents the data or the utf8 encoded HTML string to use as the contents of the webpage.
  ///
  ///Example:
  ///```dart
  ///controller.loadSimulateloadSimulatedRequestdRequest(urlRequest: URLRequest(
  ///    url: WebUri("https://flutter.dev"),
  ///  ),
  ///  data: Uint8List.fromList(utf8.encode("<h1>Hello</h1>"))
  ///);
  ///```
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.loadSimulatedRequest(_:response:responseData:)](https://developer.apple.com/documentation/webkit/wkwebview/3763094-loadsimulatedrequest) and [Official API - WKWebView.loadSimulatedRequest(_:responseHTML:)](https://developer.apple.com/documentation/webkit/wkwebview/3763095-loadsimulatedrequest))
  ///- MacOS ([Official API - WKWebView.loadSimulatedRequest(_:response:responseData:)](https://developer.apple.com/documentation/webkit/wkwebview/3763094-loadsimulatedrequest) and [Official API - WKWebView.loadSimulatedRequest(_:responseHTML:)](https://developer.apple.com/documentation/webkit/wkwebview/3763095-loadsimulatedrequest))
  ///{@endtemplate}
  Future<void> loadSimulatedRequest(
      {required URLRequest urlRequest,
      required Uint8List data,
      URLResponse? urlResponse}) {
    throw UnimplementedError(
        'loadSimulatedRequest is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.openDevTools}
  ///Opens the DevTools window for the current document in the WebView.
  ///Does nothing if run when the DevTools window is already open.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - ICoreWebView2.OpenDevToolsWindow](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#opendevtoolswindow))
  ///{@endtemplate}
  Future<void> openDevTools() {
    throw UnimplementedError(
        'openDevTools is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.callDevToolsProtocolMethod}
  ///Runs an asynchronous `DevToolsProtocol` method.
  ///
  ///For more information about available methods, navigate to [DevTools Protocol Viewer](https://chromedevtools.github.io/devtools-protocol/tot).
  ///The [methodName] parameter is the full name of the method in the `{domain}.{method}` format.
  ///The [parameters] will be a JSON formatted string containing the parameters for the corresponding method.
  ///This function throws an error if the [methodName] is unknown or the [parameters] has an error.
  ///In the case of such an error, the [parameters] parameter of the
  ///handler will include information about the error.
  ///Note even though WebView dispatches the CDP messages in the order called,
  ///CDP method calls may be processed out of order.
  ///If you require CDP methods to run in a particular order, you should wait for
  ///the previous method's completed handler to run before calling the next method.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - ICoreWebView2.CallDevToolsProtocolMethod](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#calldevtoolsprotocolmethod))
  ///{@endtemplate}
  Future<dynamic> callDevToolsProtocolMethod(
      {required String methodName, Map<String, dynamic>? parameters}) {
    throw UnimplementedError(
        'callDevToolsProtocolMethod is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addDevToolsProtocolEventListener}
  ///Subscribe to a `DevToolsProtocol` event.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - ICoreWebView2DevToolsProtocolEventReceiver.add_DevToolsProtocolEventReceived](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2devtoolsprotocoleventreceiver?view=webview2-1.0.2210.55#add_devtoolsprotocoleventreceived))
  ///{@endtemplate}
  Future<void> addDevToolsProtocolEventListener(
      {required String eventName, required Function(dynamic data) callback}) {
    throw UnimplementedError(
        'addDevToolsProtocolEventListener is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeDevToolsProtocolEventListener}
  ///Remove an event handler previously added with [addDevToolsProtocolEventListener].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - ICoreWebView2DevToolsProtocolEventReceiver.remove_DevToolsProtocolEventReceived](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2devtoolsprotocoleventreceiver?view=webview2-1.0.2210.55#remove_devtoolsprotocoleventreceived))
  ///{@endtemplate}
  Future<void> removeDevToolsProtocolEventListener(
      {required String eventName}) {
    throw UnimplementedError(
        'removeDevToolsProtocolEventListener is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isInterfaceSupported}
  ///Returns `true` if the WebView supports the specified [interface], otherwise `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  ///{@endtemplate}
  Future<bool> isInterfaceSupported(WebViewInterface interface) async {
    throw UnimplementedError(
        'isInterfaceSupported is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.saveState}
  ///Returns the current state of interaction in a web view so that you can restore
  ///that state later to another web view using the [restoreState] method.
  ///
  ///**NOTE for Android**: this method doesn't store the display data for this WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.saveState](https://developer.android.com/reference/android/webkit/WebView#saveState(android.os.Bundle)))
  ///- iOS 15.0+ ([Official API - WKWebView.interactionState](https://developer.apple.com/documentation/webkit/wkwebview/3752236-interactionstate))
  ///- MacOS 12.0+ ([Official API - WKWebView.interactionState](https://developer.apple.com/documentation/webkit/wkwebview/3752236-interactionstate))
  ///{@endtemplate}
  Future<Uint8List?> saveState() {
    throw UnimplementedError(
        'saveState is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.restoreState}
  ///Restores the state of this WebView from the given [state] returned by the [saveState] method.
  ///If it is called after this WebView has had a chance to build state (load pages, create a back/forward list, etc.),
  ///there may be undesirable side-effects.
  ///
  ///Returns `true` if the state was restored successfully, otherwise `false`.
  ///
  ///**NOTE for Android**: this method doesn't restore the display data for this WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.restoreState](https://developer.android.com/reference/android/webkit/WebView#restoreState(android.os.Bundle)))
  ///- iOS 15.0+ ([Official API - WKWebView.interactionState](https://developer.apple.com/documentation/webkit/wkwebview/3752236-interactionstate))
  ///- MacOS 12.0+ ([Official API - WKWebView.interactionState](https://developer.apple.com/documentation/webkit/wkwebview/3752236-interactionstate))
  ///{@endtemplate}
  Future<bool> restoreState(Uint8List state) {
    throw UnimplementedError(
        'restoreState is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getIFrameId}
  ///Returns the iframe `id` attribute used on the Web platform.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web
  ///{@endtemplate}
  Future<String?> getIFrameId() {
    throw UnimplementedError(
        'getIFrameId is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getViewId}
  ///View ID used internally.
  ///{@endtemplate}
  dynamic getViewId() {
    throw UnimplementedError(
        'getViewId is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getDefaultUserAgent}
  ///Gets the default user agent.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebSettings.getDefaultUserAgent](https://developer.android.com/reference/android/webkit/WebSettings#getDefaultUserAgent(android.content.Context)))
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<String> getDefaultUserAgent() {
    throw UnimplementedError(
        'getDefaultUserAgent is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearClientCertPreferences}
  ///Clears the client certificate preferences stored in response to proceeding/cancelling client cert requests.
  ///Note that WebView automatically clears these preferences when the system keychain is updated.
  ///The preferences are shared by all the WebViews that are created by the embedder application.
  ///
  ///**NOTE**: On iOS certificate-based credentials are never stored permanently.
  ///
  ///**NOTE**: available on Android 21+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.clearClientCertPreferences](https://developer.android.com/reference/android/webkit/WebView#clearClientCertPreferences(java.lang.Runnable)))
  ///{@endtemplate}
  Future<void> clearClientCertPreferences() {
    throw UnimplementedError(
        'clearClientCertPreferences is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getSafeBrowsingPrivacyPolicyUrl}
  ///Returns a URL pointing to the privacy policy for Safe Browsing reporting.
  ///
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SAFE_BROWSING_PRIVACY_POLICY_URL].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.getSafeBrowsingPrivacyPolicyUrl](https://developer.android.com/reference/androidx/webkit/WebViewCompat#getSafeBrowsingPrivacyPolicyUrl()))
  ///{@endtemplate}
  Future<WebUri?> getSafeBrowsingPrivacyPolicyUrl() {
    throw UnimplementedError(
        'getSafeBrowsingPrivacyPolicyUrl is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setSafeBrowsingAllowlist}
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
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SAFE_BROWSING_ALLOWLIST].
  ///
  ///[hosts] represents the list of hosts. This value must never be `null`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.setSafeBrowsingAllowlist](https://developer.android.com/reference/androidx/webkit/WebViewCompat#setSafeBrowsingAllowlist(java.util.Set%3Cjava.lang.String%3E,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  ///{@endtemplate}
  Future<bool> setSafeBrowsingAllowlist({required List<String> hosts}) {
    throw UnimplementedError(
        'setSafeBrowsingAllowlist is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCurrentWebViewPackage}
  ///If WebView has already been loaded into the current process this method will return the package that was used to load it.
  ///Otherwise, the package that would be used if the WebView was loaded right now will be returned;
  ///this does not cause WebView to be loaded, so this information may become outdated at any time.
  ///The WebView package changes either when the current WebView package is updated, disabled, or uninstalled.
  ///It can also be changed through a Developer Setting. If the WebView package changes, any app process that
  ///has loaded WebView will be killed.
  ///The next time the app starts and loads WebView it will use the new WebView package instead.
  ///
  ///**NOTE**: available only on Android 21+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.getCurrentWebViewPackage](https://developer.android.com/reference/androidx/webkit/WebViewCompat#getCurrentWebViewPackage(android.content.Context)))
  ///{@endtemplate}
  Future<WebViewPackageInfo?> getCurrentWebViewPackage() {
    throw UnimplementedError(
        'getCurrentWebViewPackage is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setWebContentsDebuggingEnabled}
  ///Enables debugging of web contents (HTML / CSS / JavaScript) loaded into any WebViews of this application.
  ///This flag can be enabled in order to facilitate debugging of web layouts and JavaScript code running inside WebViews.
  ///Please refer to WebView documentation for the debugging guide. The default is `false`.
  ///
  ///[debuggingEnabled] whether to enable web contents debugging.
  ///
  ///**NOTE**: available only on Android 19+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.setWebContentsDebuggingEnabled](https://developer.android.com/reference/android/webkit/WebView#setWebContentsDebuggingEnabled(boolean)))
  ///{@endtemplate}
  Future<void> setWebContentsDebuggingEnabled(bool debuggingEnabled) {
    throw UnimplementedError(
        'setWebContentsDebuggingEnabled is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getVariationsHeader}
  ///Gets the WebView variations encoded to be used as the X-Client-Data HTTP header.
  ///
  ///The app is responsible for adding the X-Client-Data header to any request
  ///that may use variations metadata, such as requests to Google web properties.
  ///The returned string will be a base64 encoded ClientVariations proto:
  ///https://source.chromium.org/chromium/chromium/src/+/main:components/variations/proto/client_variations.proto
  ///
  ///The string may be empty if the header is not available.
  ///
  ///**NOTE for Android native WebView**: This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.GET_VARIATIONS_HEADER].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.getVariationsHeader](https://developer.android.com/reference/androidx/webkit/WebViewCompat#getVariationsHeader()))
  ///{@endtemplate}
  Future<String?> getVariationsHeader() {
    throw UnimplementedError(
        'getVariationsHeader is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isMultiProcessEnabled}
  ///Returns `true` if WebView is running in multi process mode.
  ///
  ///In Android O and above, WebView may run in "multiprocess" mode.
  ///In multiprocess mode, rendering of web content is performed by a sandboxed
  ///renderer process separate to the application process.
  ///This renderer process may be shared with other WebViews in the application,
  ///but is not shared with other application processes.
  ///
  ///**NOTE for Android native WebView**: This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.MULTI_PROCESS].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.isMultiProcessEnabled](https://developer.android.com/reference/androidx/webkit/WebViewCompat#isMultiProcessEnabled()))
  ///{@endtemplate}
  Future<bool> isMultiProcessEnabled() {
    throw UnimplementedError(
        'isMultiProcessEnabled is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.disableWebView}
  ///Indicate that the current process does not intend to use WebView,
  ///and that an exception should be thrown if a WebView is created or any other
  ///methods in the `android.webkit` package are used.
  ///
  ///Applications with multiple processes may wish to call this in processes that
  ///are not intended to use WebView to avoid accidentally incurring the memory usage
  ///of initializing WebView in long-lived processes that have no need for it,
  ///and to prevent potential data directory conflicts (see [ProcessGlobalConfigSettings.dataDirectorySuffix]).
  ///
  ///**NOTE for Android**: available only on Android 28+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.disableWebView](https://developer.android.com/reference/android/webkit/WebView.html#disableWebView()))
  ///{@endtemplate}
  Future<void> disableWebView() {
    throw UnimplementedError(
        'disableWebView is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.handlesURLScheme}
  ///Returns a Boolean value that indicates whether WebKit natively supports resources with the specified URL scheme.
  ///
  ///[urlScheme] represents the URL scheme associated with the resource.
  ///
  ///**NOTE for iOS**: available only on iOS 11.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 10.13+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.handlesURLScheme](https://developer.apple.com/documentation/webkit/wkwebview/2875370-handlesurlscheme))
  ///- MacOS ([Official API - WKWebView.handlesURLScheme](https://developer.apple.com/documentation/webkit/wkwebview/2875370-handlesurlscheme))
  ///{@endtemplate}
  Future<bool> handlesURLScheme(String urlScheme) {
    throw UnimplementedError(
        'handlesURLScheme is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.disposeKeepAlive}
  ///Disposes the WebView that is using the [keepAlive] instance
  ///for the keep alive feature.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Future<void> disposeKeepAlive(InAppWebViewKeepAlive keepAlive) {
    throw UnimplementedError(
        'disposeKeepAlive is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearAllCache}
  ///Clears the resource cache. Note that the cache is per-application, so this will clear the cache for all WebViews used.
  ///
  ///[includeDiskFiles] if `false`, only the RAM cache is cleared. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<void> clearAllCache({bool includeDiskFiles = true}) {
    throw UnimplementedError(
        'clearAllCache is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.enableSlowWholeDocumentDraw}
  ///For apps targeting the L release, WebView has a new default behavior that reduces memory footprint and increases
  ///performance by intelligently choosing the portion of the HTML document that needs to be drawn.
  ///These optimizations are transparent to the developers.
  ///However, under certain circumstances, an App developer may want to disable them, for example
  ///when an app draws and accesses portions of the page that is way outside the visible portion of the page.
  ///Enabling drawing the entire HTML document has a significant performance cost.
  ///
  ///**NOTE**: This method should be called before any WebViews are created.
  ///
  ///**NOTE for Android**: available only on Android 21+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.enableSlowWholeDocumentDraw](https://developer.android.com/reference/android/webkit/WebView#enableSlowWholeDocumentDraw()))
  ///{@endtemplate}
  Future<void> enableSlowWholeDocumentDraw() {
    throw UnimplementedError(
        'enableSlowWholeDocumentDraw is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setJavaScriptBridgeName}
  ///Sets the name of the JavaScript Bridge object that will be used to interact with the WebView.
  ///This method should be called before any WebViews are created or when there are no WebViews.
  ///Calling this method after a WebView has been created will not change
  ///the current JavaScript Bridge object and could lead to errors.
  ///
  ///The [bridgeName] must be a non-empty string with only alphanumeric and underscore characters.
  ///It can't start with a number.
  ///
  ///The default name used by this plugin is `flutter_inappwebview`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- macOS
  ///- Windows
  ///{@endtemplate}
  Future<void> setJavaScriptBridgeName(String bridgeName) {
    throw UnimplementedError(
        'setJavaScriptBridgeName is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getJavaScriptBridgeName}
  ///Gets the name of the JavaScript Bridge object that is used to interact with the WebView.
  ///Use [setJavaScriptBridgeName] to set a custom name.
  ///The default name used by this plugin is `flutter_inappwebview`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- macOS
  ///- Windows
  ///{@endtemplate}
  Future<String> getJavaScriptBridgeName() {
    throw UnimplementedError(
        'getJavaScriptBridgeName is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.tRexRunnerHtml}
  ///Gets the html (with javascript) of the Chromium's t-rex runner game. Used in combination with [tRexRunnerCss].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<String> get tRexRunnerHtml => throw UnimplementedError(
      'tRexRunnerHtml is not implemented on the current platform');

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.tRexRunnerCss}
  ///Gets the css of the Chromium's t-rex runner game. Used in combination with [tRexRunnerHtml].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<String> get tRexRunnerCss => throw UnimplementedError(
      'tRexRunnerCss is not implemented on the current platform');

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setOptions}
  ///Use [setSettings] instead.
  ///{@endtemplate}
  @Deprecated('Use setSettings instead')
  Future<void> setOptions({required InAppWebViewGroupOptions options}) {
    throw UnimplementedError(
        'setOptions is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getOptions}
  ///Use [getSettings] instead.
  ///{@endtemplate}
  @Deprecated('Use getSettings instead')
  Future<InAppWebViewGroupOptions?> getOptions() {
    throw UnimplementedError(
        'getOptions is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.findAllAsync}
  ///Use [PlatformFindInteractionController.findAll] instead.
  ///{@endtemplate}
  @Deprecated("Use FindInteractionController.findAll instead")
  Future<void> findAllAsync({required String find}) {
    throw UnimplementedError(
        'findAllAsync is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.findNext}
  ///Use [PlatformFindInteractionController.findNext] instead.
  ///{@endtemplate}
  @Deprecated("Use FindInteractionController.findNext instead")
  Future<void> findNext({required bool forward}) {
    throw UnimplementedError(
        'findNext is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearMatches}
  ///Use [PlatformFindInteractionController.clearMatches] instead.
  ///{@endtemplate}
  @Deprecated("Use FindInteractionController.clearMatches instead")
  Future<void> clearMatches() {
    throw UnimplementedError(
        'clearMatches is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getTRexRunnerHtml}
  ///Use [tRexRunnerHtml] instead.
  ///{@endtemplate}
  @Deprecated("Use tRexRunnerHtml instead")
  Future<String> getTRexRunnerHtml() {
    throw UnimplementedError(
        'getTRexRunnerHtml is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getTRexRunnerCss}
  ///Use [tRexRunnerCss] instead.
  ///{@endtemplate}
  @Deprecated("Use tRexRunnerCss instead")
  Future<String> getTRexRunnerCss() {
    throw UnimplementedError(
        'getTRexRunnerCss is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getScale}
  ///Use [getZoomScale] instead.
  ///{@endtemplate}
  @Deprecated('Use getZoomScale instead')
  Future<double?> getScale() {
    throw UnimplementedError(
        'getScale is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setSafeBrowsingWhitelist}
  ///Use [setSafeBrowsingAllowlist] instead.
  ///{@endtemplate}
  @Deprecated("Use setSafeBrowsingAllowlist instead")
  Future<bool> setSafeBrowsingWhitelist({required List<String> hosts}) {
    throw UnimplementedError(
        'setSafeBrowsingWhitelist is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.dispose}
  ///Disposes the controller.
  ///{@endtemplate}
  void dispose({bool isKeepAlive = false}) {
    throw UnimplementedError(
        'dispose is not implemented on the current platform');
  }
}
