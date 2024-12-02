import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../context_menu/context_menu.dart';
import '../debug_logging_settings.dart';
import '../find_interaction/platform_find_interaction_controller.dart';
import '../in_app_webview/in_app_webview_settings.dart';
import '../in_app_webview/platform_inappwebview_controller.dart';
import '../inappwebview_platform.dart';
import '../platform_webview_feature.dart';
import '../print_job/main.dart';
import '../pull_to_refresh/main.dart';
import '../pull_to_refresh/platform_pull_to_refresh_controller.dart';
import '../types/main.dart';
import '../web_uri.dart';
import '../webview_environment/platform_webview_environment.dart';
import 'in_app_browser_menu_item.dart';
import 'in_app_browser_settings.dart';

/// Object specifying creation parameters for creating a [PlatformInAppBrowser].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformInAppBrowserCreationParams {
  /// Used by the platform implementation to create a new [PlatformInAppBrowser].
  const PlatformInAppBrowserCreationParams({
    this.contextMenu,
    this.pullToRefreshController,
    this.findInteractionController,
    this.initialUserScripts,
    this.windowId,
    this.webViewEnvironment,
  });

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.contextMenu}
  final ContextMenu? contextMenu;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.pullToRefreshController}
  final PlatformPullToRefreshController? pullToRefreshController;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.findInteractionController}
  final PlatformFindInteractionController? findInteractionController;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.initialUserScripts}
  final UnmodifiableListView<UserScript>? initialUserScripts;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.windowId}
  final int? windowId;

  ///Used to create the [PlatformInAppBrowser] using the specified environment.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  final PlatformWebViewEnvironment? webViewEnvironment;
}

///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser}
///This class represents a native WebView displayed on top of the Flutter App,
///so it's not integrated into the Flutter widget tree.
///It uses the native WebView of the platform.
///The [webViewController] field can be used to access the [PlatformInAppWebViewController] API.
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
///- Windows
///{@endtemplate}
abstract class PlatformInAppBrowser extends PlatformInterface
    implements Disposable {
  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  /// Event handler object that handles the [PlatformInAppBrowser] events.
  PlatformInAppBrowserEvents? eventHandler;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.id}
  ///View ID used internally.
  ///{@endtemplate}
  String get id {
    throw UnimplementedError('id is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.contextMenu}
  ///Context menu used by the browser. It should be set before opening the browser.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///{@endtemplate}
  ContextMenu? get contextMenu => params.contextMenu;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.pullToRefreshController}
  ///Represents the pull-to-refresh feature controller.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///{@endtemplate}
  PlatformPullToRefreshController? get pullToRefreshController =>
      params.pullToRefreshController;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.findInteractionController}
  ///Represents the find interaction feature controller.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  PlatformFindInteractionController? get findInteractionController =>
      params.findInteractionController;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.initialUserScripts}
  ///Initial list of user scripts to be loaded at start or end of a page loading.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  UnmodifiableListView<UserScript>? get initialUserScripts =>
      params.initialUserScripts;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.windowId}
  ///The window id of a [CreateWindowAction.windowId].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  int? get windowId => params.windowId;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.webViewController}
  ///WebView Controller that can be used to access the [PlatformInAppWebViewController] API.
  ///When [onExit] is fired, this will be `null` and cannot be used anymore.
  ///{@endtemplate}
  PlatformInAppWebViewController? get webViewController {
    throw UnimplementedError(
        'webViewController is not implemented on the current platform');
  }

  /// Creates a new [PlatformInAppBrowser]
  factory PlatformInAppBrowser(PlatformInAppBrowserCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInAppBrowser inAppBrowser =
        InAppWebViewPlatform.instance!.createPlatformInAppBrowser(params);
    PlatformInterface.verify(inAppBrowser, _token);
    return inAppBrowser;
  }

  /// Creates a new [PlatformInAppBrowser] to access static methods.
  factory PlatformInAppBrowser.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInAppBrowser inAppBrowserStatic =
        InAppWebViewPlatform.instance!.createPlatformInAppBrowserStatic();
    PlatformInterface.verify(inAppBrowserStatic, _token);
    return inAppBrowserStatic;
  }

  /// Used by the platform implementation to create a new [PlatformInAppBrowser].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformInAppBrowser.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformInAppBrowser].
  final PlatformInAppBrowserCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.openUrlRequest}
  ///Opens the [PlatformInAppBrowser] instance with an [urlRequest].
  ///
  ///[urlRequest]: The [urlRequest] to load.
  ///
  ///[options]: Options for the [PlatformInAppBrowser].
  ///
  ///[settings]: Settings for the [PlatformInAppBrowser].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Future<void> openUrlRequest(
      {required URLRequest urlRequest,
      // ignore: deprecated_member_use_from_same_package
      @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
      InAppBrowserClassSettings? settings}) {
    throw UnimplementedError(
        'openUrlRequest is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.openFile}
  ///Opens the [PlatformInAppBrowser] instance with the given [assetFilePath] file.
  ///
  ///[options]: Options for the [PlatformInAppBrowser].
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
  ///[options]: Options for the [PlatformInAppBrowser].
  ///
  ///[settings]: Settings for the [PlatformInAppBrowser].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Future<void> openFile(
      {required String assetFilePath,
      // ignore: deprecated_member_use_from_same_package
      @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
      InAppBrowserClassSettings? settings}) {
    throw UnimplementedError(
        'openFile is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.openData}
  ///Opens the [PlatformInAppBrowser] instance with [data] as a content, using [baseUrl] as the base URL for it.
  ///
  ///The [mimeType] parameter specifies the format of the data. The default value is `"text/html"`.
  ///
  ///The [encoding] parameter specifies the encoding of the data. The default value is `"utf8"`.
  ///
  ///The [androidHistoryUrl] parameter is the URL to use as the history entry. The default value is `about:blank`. If non-null, this must be a valid URL. This parameter is used only on Android.
  ///
  ///The [options] parameter specifies the options for the [PlatformInAppBrowser].
  ///
  ///[settings]: Settings for the [PlatformInAppBrowser].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Future<void> openData(
      {required String data,
      String mimeType = "text/html",
      String encoding = "utf8",
      WebUri? baseUrl,
      @Deprecated("Use historyUrl instead") Uri? androidHistoryUrl,
      WebUri? historyUrl,
      // ignore: deprecated_member_use_from_same_package
      @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
      InAppBrowserClassSettings? settings}) {
    throw UnimplementedError(
        'openData is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.openWithSystemBrowser}
  ///This is a static method that opens an [url] in the system browser. You wont be able to use the [PlatformInAppBrowser] methods here!
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Future<void> openWithSystemBrowser({required WebUri url}) {
    throw UnimplementedError(
        'openWithSystemBrowser is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.addMenuItem}
  ///Adds a [InAppBrowserMenuItem] to the menu.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///- iOS 14.0+
  ///- macOS 10.15+
  ///{@endtemplate}
  void addMenuItem(InAppBrowserMenuItem menuItem) {
    throw UnimplementedError(
        'addMenuItem is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.addMenuItems}
  ///Adds a list of [InAppBrowserMenuItem] to the menu.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///- iOS 14.0+
  ///- macOS 10.15+
  ///{@endtemplate}
  void addMenuItems(List<InAppBrowserMenuItem> menuItems) {
    throw UnimplementedError(
        'addMenuItems is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeMenuItem}
  ///Removes the [menuItem] from the list.
  ///Returns `true` if it was in the list, `false` otherwise.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///- iOS 14.0+
  ///- macOS 10.15+
  ///{@endtemplate}
  bool removeMenuItem(InAppBrowserMenuItem menuItem) {
    throw UnimplementedError(
        'removeMenuItem is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeMenuItems}
  ///Removes a list of [menuItems] from the list.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///- iOS 14.0+
  ///- macOS 10.15+
  ///{@endtemplate}
  void removeMenuItems(List<InAppBrowserMenuItem> menuItems) {
    throw UnimplementedError(
        'removeMenuItems is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeAllMenuItem}
  ///Removes all the menu items from the list.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///- iOS 14.0+
  ///- macOS 10.15+
  ///{@endtemplate}
  void removeAllMenuItem() {
    throw UnimplementedError(
        'removeAllMenuItem is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.hasMenuItem}
  ///Returns `true` if the [menuItem] has been already added, otherwise `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS 14.0+
  ///- macOS 10.15+
  ///{@endtemplate}
  bool hasMenuItem(InAppBrowserMenuItem menuItem) {
    throw UnimplementedError(
        'hasMenuItem is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.show}
  ///Displays a [PlatformInAppBrowser] window that was opened hidden. Calling this has no effect if the [PlatformInAppBrowser] was already visible.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Future<void> show() {
    throw UnimplementedError('show is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.hide}
  ///Hides the [PlatformInAppBrowser] window. Calling this has no effect if the [PlatformInAppBrowser] was already hidden.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Future<void> hide() {
    throw UnimplementedError('hide is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.close}
  ///Closes the [PlatformInAppBrowser] window.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Future<void> close() {
    throw UnimplementedError(
        'close is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.isHidden}
  ///Check if the Web View of the [PlatformInAppBrowser] instance is hidden.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  Future<bool> isHidden() {
    throw UnimplementedError(
        'isHidden is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.setOptions}
  ///Use [setSettings] instead.
  ///{@endtemplate}
  @Deprecated('Use setSettings instead')
  Future<void> setOptions({required InAppBrowserClassOptions options}) {
    throw UnimplementedError(
        'setOptions is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.getOptions}
  ///Use [getSettings] instead.
  ///{@endtemplate}
  @Deprecated('Use getSettings instead')
  Future<InAppBrowserClassOptions?> getOptions() {
    throw UnimplementedError(
        'getOptions is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.setSettings}
  ///Sets the [PlatformInAppBrowser] settings with the new [settings] and evaluates them.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<void> setSettings({required InAppBrowserClassSettings settings}) {
    throw UnimplementedError(
        'setSettings is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.getSettings}
  ///Gets the current [PlatformInAppBrowser] settings. Returns `null` if it wasn't able to get them.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<InAppBrowserClassSettings?> getSettings() {
    throw UnimplementedError(
        'getSettings is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.isOpened}
  ///Returns `true` if the [PlatformInAppBrowser] instance is opened, otherwise `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  bool isOpened() {
    throw UnimplementedError(
        'isOpened is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.dispose}
  ///Disposes the channel and controllers.
  ///{@endtemplate}
  @override
  @mustCallSuper
  void dispose() {
    eventHandler = null;
  }
}

abstract class PlatformInAppBrowserEvents {
  ///Event fired when the [PlatformInAppBrowser] is created.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  void onBrowserCreated() {}

  ///Event fired when the [PlatformInAppBrowser] window is closed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  void onExit() {}

  ///Event fired when the main window is about to close.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  void onMainWindowWillClose() {}

  ///Event fired when the [PlatformInAppBrowser] starts to load an [url].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onPageStarted](https://developer.android.com/reference/android/webkit/WebViewClient#onPageStarted(android.webkit.WebView,%20java.lang.String,%20android.graphics.Bitmap)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455621-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455621-webview))
  ///- Windows ([Official API - ICoreWebView2.add_NavigationStarting](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationstarting))
  void onLoadStart(WebUri? url) {}

  ///Event fired when the [PlatformInAppBrowser] finishes loading an [url].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onPageFinished](https://developer.android.com/reference/android/webkit/WebViewClient#onPageFinished(android.webkit.WebView,%20java.lang.String)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455629-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455629-webview))
  ///- Windows ([Official API - ICoreWebView2.add_NavigationCompleted](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationcompleted))
  void onLoadStop(WebUri? url) {}

  ///Use [onReceivedError] instead.
  @Deprecated("Use onReceivedError instead")
  void onLoadError(Uri? url, int code, String message) {}

  ///Event fired when the [PlatformInAppBrowser] encounters an [error] loading a [request].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedError](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedError(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20android.webkit.WebResourceError)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455623-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455623-webview))
  ///- Windows ([Official API - ICoreWebView2.add_NavigationCompleted](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationcompleted))
  void onReceivedError(WebResourceRequest request, WebResourceError error) {}

  ///Use [onReceivedHttpError] instead.
  @Deprecated("Use onReceivedHttpError instead")
  void onLoadHttpError(Uri? url, int statusCode, String description) {}

  ///Event fired when the [PlatformInAppBrowser] receives an HTTP error.
  ///
  ///[request] represents the originating request.
  ///
  ///[errorResponse] represents the information about the error occurred.
  ///
  ///**NOTE**: available on Android 23+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedHttpError](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpError(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20android.webkit.WebResourceResponse)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview))
  ///- Windows ([Official API - ICoreWebView2.add_NavigationCompleted](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationcompleted))
  void onReceivedHttpError(
      WebResourceRequest request, WebResourceResponse errorResponse) {}

  ///Event fired when the current [progress] (range 0-100) of loading a page is changed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onProgressChanged](https://developer.android.com/reference/android/webkit/WebChromeClient#onProgressChanged(android.webkit.WebView,%20int)))
  ///- iOS
  ///- MacOS
  ///- Windows
  void onProgressChanged(int progress) {}

  ///Event fired when the [PlatformInAppBrowser] webview receives a [ConsoleMessage].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onConsoleMessage](https://developer.android.com/reference/android/webkit/WebChromeClient#onConsoleMessage(android.webkit.ConsoleMessage)))
  ///- iOS
  ///- MacOS
  ///- Windows
  void onConsoleMessage(ConsoleMessage consoleMessage) {}

  ///Give the host application a chance to take control when a URL is about to be loaded in the current WebView. This event is not called on the initial load of the WebView.
  ///
  ///Note that on Android there isn't any way to load an URL for a frame that is not the main frame, so if the request is not for the main frame, the navigation is allowed by default.
  ///However, if you want to cancel requests for subframes, you can use the [InAppWebViewSettings.regexToCancelSubFramesLoading] setting
  ///to write a Regular Expression that, if the url request of a subframe matches, then the request of that subframe is canceled.
  ///
  ///Also, on Android, this method is not called for POST requests.
  ///
  ///[navigationAction] represents an object that contains information about an action that causes navigation to occur.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldOverrideUrlLoading] setting to `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.shouldOverrideUrlLoading](https://developer.android.com/reference/android/webkit/WebViewClient#shouldOverrideUrlLoading(android.webkit.WebView,%20java.lang.String)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455641-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455641-webview))
  FutureOr<NavigationActionPolicy?>? shouldOverrideUrlLoading(
      NavigationAction navigationAction) {
    return null;
  }

  ///Event fired when the [PlatformInAppBrowser] webview loads a resource.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useOnLoadResource] and [InAppWebViewSettings.javaScriptEnabled] setting to `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  void onLoadResource(LoadedResource resource) {}

  ///Event fired when the [PlatformInAppBrowser] webview scrolls.
  ///
  ///[x] represents the current horizontal scroll origin in pixels.
  ///
  ///[y] represents the current vertical scroll origin in pixels.
  ///
  ///**NOTE for MacOS**: this method is implemented with using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.onScrollChanged](https://developer.android.com/reference/android/webkit/WebView#onScrollChanged(int,%20int,%20int,%20int)))
  ///- iOS ([Official API - UIScrollViewDelegate.scrollViewDidScroll](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619392-scrollviewdidscroll))
  ///- MacOS
  void onScrollChanged(int x, int y) {}

  ///Use [onDownloadStarting] instead
  @Deprecated('Use onDownloadStarting instead')
  void onDownloadStart(Uri url) {}

  ///Use [onDownloadStarting] instead
  @Deprecated('Use onDownloadStarting instead')
  void onDownloadStartRequest(DownloadStartRequest downloadStartRequest) {}

  ///Event fired when `WebView` recognizes a downloadable file.
  ///To download the file, you can use the [flutter_downloader](https://pub.dev/packages/flutter_downloader) plugin.
  ///
  ///[downloadStartRequest] represents the request of the file to download.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useOnDownloadStart] setting to `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.setDownloadListener](https://developer.android.com/reference/android/webkit/WebView#setDownloadListener(android.webkit.DownloadListener)))
  ///- iOS
  ///- MacOS
  ///- Windows ([Official API - ICoreWebView2_4.add_DownloadStarting](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_4?view=webview2-1.0.2849.39#add_downloadstarting))
  FutureOr<DownloadStartResponse?>? onDownloadStarting(
      DownloadStartRequest downloadStartRequest) {
    return null;
  }

  ///Use [onLoadResourceWithCustomScheme] instead.
  @Deprecated('Use onLoadResourceWithCustomScheme instead')
  FutureOr<CustomSchemeResponse?>? onLoadResourceCustomScheme(Uri url) {
    return null;
  }

  ///Event fired when the [PlatformInAppBrowser] webview finds the `custom-scheme` while loading a resource.
  ///Here you can handle the url [request] and return a [CustomSchemeResponse] to load a specific resource encoded to `base64`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKURLSchemeHandler](https://developer.apple.com/documentation/webkit/wkurlschemehandler))
  ///- MacOS ([Official API - WKURLSchemeHandler](https://developer.apple.com/documentation/webkit/wkurlschemehandler))
  ///- Windows
  FutureOr<CustomSchemeResponse?>? onLoadResourceWithCustomScheme(
      WebResourceRequest request) {
    return null;
  }

  ///Event fired when the [PlatformInAppBrowser] webview requests the host application to create a new window,
  ///for example when trying to open a link with `target="_blank"` or when `window.open()` is called by JavaScript side.
  ///If the host application chooses to honor this request, it should return `true` from this method, create a new WebView to host the window.
  ///If the host application chooses not to honor the request, it should return `false` from this method.
  ///The default implementation of this method does nothing and hence returns `false`.
  ///
  ///[createWindowAction] represents the request.
  ///
  ///**NOTE**: to allow JavaScript to open windows, you need to set [InAppWebViewSettings.javaScriptCanOpenWindowsAutomatically] setting to `true`.
  ///
  ///**NOTE**: on Android you need to set [InAppWebViewSettings.supportMultipleWindows] setting to `true`.
  ///
  ///**NOTE**: on iOS and MacOS, setting these initial settings: [InAppWebViewSettings.supportZoom], [InAppWebViewSettings.useOnLoadResource], [InAppWebViewSettings.useShouldInterceptAjaxRequest],
  ///[InAppWebViewSettings.useShouldInterceptFetchRequest], [InAppWebViewSettings.applicationNameForUserAgent], [InAppWebViewSettings.javaScriptCanOpenWindowsAutomatically],
  ///[InAppWebViewSettings.javaScriptEnabled], [InAppWebViewSettings.minimumFontSize], [InAppWebViewSettings.preferredContentMode], [InAppWebViewSettings.incognito],
  ///[InAppWebViewSettings.cacheEnabled], [InAppWebViewSettings.mediaPlaybackRequiresUserGesture],
  ///[InAppWebViewSettings.resourceCustomSchemes], [InAppWebViewSettings.sharedCookiesEnabled],
  ///[InAppWebViewSettings.enableViewportScale], [InAppWebViewSettings.allowsAirPlayForMediaPlayback],
  ///[InAppWebViewSettings.allowsPictureInPictureMediaPlayback], [InAppWebViewSettings.isFraudulentWebsiteWarningEnabled],
  ///[InAppWebViewSettings.allowsInlineMediaPlayback], [InAppWebViewSettings.suppressesIncrementalRendering], [InAppWebViewSettings.selectionGranularity],
  ///[InAppWebViewSettings.ignoresViewportScaleLimits], [InAppWebViewSettings.limitsNavigationsToAppBoundDomains],
  ///[InAppWebViewSettings.upgradeKnownHostsToHTTPS],
  ///will have no effect due to a `WKWebView` limitation when creating a new window WebView: it's impossible to return a new `WKWebView`
  ///with a different `WKWebViewConfiguration` instance (see https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview).
  ///So, these options will be inherited from the caller WebView.
  ///Also, note that calling [PlatformInAppWebViewController.setSettings] method using the controller of the new created WebView,
  ///it will update also the WebView options of the caller WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onCreateWindow](https://developer.android.com/reference/android/webkit/WebChromeClient#onCreateWindow(android.webkit.WebView,%20boolean,%20boolean,%20android.os.Message)))
  ///- iOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview))
  ///- MacOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview))
  ///- Windows ([Official API - ICoreWebView2.add_NewWindowRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_newwindowrequested))
  FutureOr<bool?>? onCreateWindow(CreateWindowAction createWindowAction) {
    return null;
  }

  ///Event fired when the host application should close the given WebView and remove it from the view system if necessary.
  ///At this point, WebCore has stopped any loading in this window and has removed any cross-scripting ability in javascript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onCloseWindow](https://developer.android.com/reference/android/webkit/WebChromeClient#onCloseWindow(android.webkit.WebView)))
  ///- iOS ([Official API - WKUIDelegate.webViewDidClose](https://developer.apple.com/documentation/webkit/wkuidelegate/1537390-webviewdidclose))
  ///- MacOS ([Official API - WKUIDelegate.webViewDidClose](https://developer.apple.com/documentation/webkit/wkuidelegate/1537390-webviewdidclose))
  ///- Windows ([Official API - ICoreWebView2.add_WindowCloseRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_windowcloserequested))
  void onCloseWindow() {}

  ///Event fired when the JavaScript `window` object of the WebView has received focus.
  ///This is the result of the `focus` javascript event applied to the `window` object.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  void onWindowFocus() {}

  ///Event fired when the JavaScript `window` object of the WebView has lost focus.
  ///This is the result of the `blur` javascript event applied to the `window` object.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  void onWindowBlur() {}

  ///Event fired when javascript calls the `alert()` method to display an alert dialog.
  ///If [JsAlertResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsAlertRequest] contains the message to be displayed in the alert dialog and the of the page requesting the dialog.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onJsAlert](https://developer.android.com/reference/android/webkit/WebChromeClient#onJsAlert(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)))
  ///- iOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1537406-webview))
  ///- MacOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1537406-webview))
  FutureOr<JsAlertResponse?>? onJsAlert(JsAlertRequest jsAlertRequest) {
    return null;
  }

  ///Event fired when javascript calls the `confirm()` method to display a confirm dialog.
  ///If [JsConfirmResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsConfirmRequest] contains the message to be displayed in the confirm dialog and the of the page requesting the dialog.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onJsConfirm](https://developer.android.com/reference/android/webkit/WebChromeClient#onJsConfirm(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)))
  ///- iOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1536489-webview))
  ///- MacOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1536489-webview))
  FutureOr<JsConfirmResponse?>? onJsConfirm(JsConfirmRequest jsConfirmRequest) {
    return null;
  }

  ///Event fired when javascript calls the `prompt()` method to display a prompt dialog.
  ///If [JsPromptResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsPromptRequest] contains the message to be displayed in the prompt dialog, the default value displayed in the prompt dialog, and the of the page requesting the dialog.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onJsPrompt](https://developer.android.com/reference/android/webkit/WebChromeClient#onJsPrompt(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String,%20android.webkit.JsPromptResult)))
  ///- iOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1538086-webview))
  ///- MacOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1538086-webview))
  FutureOr<JsPromptResponse?>? onJsPrompt(JsPromptRequest jsPromptRequest) {
    return null;
  }

  ///Event fired when the WebView received an HTTP authentication request. The default behavior is to cancel the request.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [URLAuthenticationChallenge].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedHttpAuthRequest](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpAuthRequest(android.webkit.WebView,%20android.webkit.HttpAuthHandler,%20java.lang.String,%20java.lang.String)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  ///- Windows ([Official API - ICoreWebView2_10.add_BasicAuthenticationRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_10?view=webview2-1.0.2849.39#add_basicauthenticationrequested))
  FutureOr<HttpAuthResponse?>? onReceivedHttpAuthRequest(
      HttpAuthenticationChallenge challenge) {
    return null;
  }

  ///Event fired when the WebView need to perform server trust authentication (certificate validation).
  ///The host application must return either [ServerTrustAuthResponse] instance with [ServerTrustAuthResponseAction.CANCEL] or [ServerTrustAuthResponseAction.PROCEED].
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ServerTrustChallenge].
  ///
  ///**NOTE for iOS and macOS**: to override the certificate verification logic, you have to provide ATS (App Transport Security) exceptions in your iOS/macOS `Info.plist`.
  ///See `NSAppTransportSecurity` in the [Information Property List Key Reference](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW1)
  ///for details.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedSslError](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedSslError(android.webkit.WebView,%20android.webkit.SslErrorHandler,%20android.net.http.SslError)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  ///- Windows ([Official API - ICoreWebView2_14.add_ServerCertificateErrorDetected](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_14?view=webview2-1.0.2792.45#add_servercertificateerrordetected))
  FutureOr<ServerTrustAuthResponse?>? onReceivedServerTrustAuthRequest(
      ServerTrustChallenge challenge) {
    return null;
  }

  ///Notify the host application to handle an SSL client certificate request.
  ///Webview stores the response in memory (for the life of the application) if [ClientCertResponseAction.PROCEED] or [ClientCertResponseAction.CANCEL]
  ///is called and does not call [onReceivedClientCertRequest] again for the same host and port pair.
  ///Note that, multiple layers in chromium network stack might be caching the responses.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ClientCertChallenge].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedClientCertRequest](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedClientCertRequest(android.webkit.WebView,%20android.webkit.ClientCertRequest)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  ///- Windows ([Official API - ICoreWebView2_5.add_ClientCertificateRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_5?view=webview2-1.0.2849.39#add_clientcertificaterequested))
  FutureOr<ClientCertResponse?>? onReceivedClientCertRequest(
      ClientCertChallenge challenge) {
    return null;
  }

  ///Use [FindInteractionController.onFindResultReceived] instead.
  @Deprecated('Use FindInteractionController.onFindResultReceived instead')
  void onFindResultReceived(
      int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting) {}

  ///Event fired when an `XMLHttpRequest` is sent to a server.
  ///It gives the host application a chance to take control over the request before sending it.
  ///This event is implemented using JavaScript under the hood.
  ///
  ///Due to the async nature of this event implementation, it will intercept only async `XMLHttpRequest`s ([AjaxRequest.isAsync] with `true`).
  ///To be able to intercept sync `XMLHttpRequest`s, use [InAppWebViewSettings.interceptOnlyAsyncAjaxRequests] to `false`.
  ///If necessary, you should implement your own logic using for example an [UserScript] overriding the
  ///[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) JavaScript object.
  ///
  ///[ajaxRequest] represents the `XMLHttpRequest`.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldInterceptAjaxRequest] setting to `true`.
  ///Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the ajax requests will be intercept for sure.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  FutureOr<AjaxRequest?>? shouldInterceptAjaxRequest(AjaxRequest ajaxRequest) {
    return null;
  }

  ///Event fired whenever the `readyState` attribute of an `XMLHttpRequest` changes.
  ///It gives the host application a chance to abort the request.
  ///This event is implemented using JavaScript under the hood.
  ///
  ///Due to the async nature of this event implementation,
  ///using it could cause some issues, so, be careful when using it.
  ///In this case, you should implement your own logic using for example an [UserScript] overriding the
  ///[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) JavaScript object.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldInterceptAjaxRequest] and [InAppWebViewSettings.useOnAjaxReadyStateChange] settings to `true`.
  ///Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, the javascript code
  ///used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the ajax requests will be intercept for sure.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  FutureOr<AjaxRequestAction?>? onAjaxReadyStateChange(
      AjaxRequest ajaxRequest) {
    return null;
  }

  ///Event fired as an `XMLHttpRequest` progress.
  ///It gives the host application a chance to abort the request.
  ///This event is implemented using JavaScript under the hood.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldInterceptAjaxRequest] and [InAppWebViewSettings.useOnAjaxProgress] settings to `true`.
  ///Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the ajax requests will be intercept for sure.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  FutureOr<AjaxRequestAction?>? onAjaxProgress(AjaxRequest ajaxRequest) {
    return null;
  }

  ///Event fired when a request is sent to a server through [Fetch API](https://developer.mozilla.org/it/docs/Web/API/Fetch_API).
  ///It gives the host application a chance to take control over the request before sending it.
  ///This event is implemented using JavaScript under the hood.
  ///
  ///[fetchRequest] represents a resource request.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldInterceptFetchRequest] setting to `true`.
  ///Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept fetch requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the fetch requests will be intercept for sure.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  FutureOr<FetchRequest?>? shouldInterceptFetchRequest(
      FetchRequest fetchRequest) {
    return null;
  }

  ///Event fired when the host application updates its visited links database.
  ///This event is also fired when the navigation state of the [InAppWebView] changes through the usage of
  ///javascript **[History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API)** functions (`pushState()`, `replaceState()`) and `onpopstate` event
  ///or, also, when the javascript `window.location` changes without reloading the webview (for example appending or modifying an hash to the url).
  ///
  ///[url] represents the url being visited.
  ///
  ///[isReload] indicates if this url is being reloaded. Available only on Android.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.doUpdateVisitedHistory](https://developer.android.com/reference/android/webkit/WebViewClient#doUpdateVisitedHistory(android.webkit.WebView,%20java.lang.String,%20boolean)))
  ///- iOS
  ///- MacOS
  ///- Windows ([Official API - ICoreWebView2.add_HistoryChanged](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_historychanged))
  void onUpdateVisitedHistory(WebUri? url, bool? isReload) {}

  ///Use [onPrintRequest] instead
  @Deprecated("Use onPrintRequest instead")
  void onPrint(Uri? url) {}

  ///Event fired when `window.print()` is called from JavaScript side.
  ///Return `true` if you want to handle the print job.
  ///Otherwise return `false`, so the [PlatformPrintJobController] will be handled and disposed automatically by the system.
  ///
  ///[url] represents the url on which is called.
  ///
  ///[printJobController] represents the controller of the print job created.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  FutureOr<bool?>? onPrintRequest(
      WebUri? url, PlatformPrintJobController? printJobController) {
    return null;
  }

  ///Event fired when an HTML element of the webview has been clicked and held.
  ///
  ///[hitTestResult] represents the hit result for hitting an HTML elements.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.setOnLongClickListener](https://developer.android.com/reference/android/view/View#setOnLongClickListener(android.view.View.OnLongClickListener)))
  ///- iOS ([Official API - UILongPressGestureRecognizer](https://developer.apple.com/documentation/uikit/uilongpressgesturerecognizer))
  void onLongPressHitTestResult(InAppWebViewHitTestResult hitTestResult) {}

  ///Event fired when the current page has entered full screen mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onShowCustomView](https://developer.android.com/reference/android/webkit/WebChromeClient#onShowCustomView(android.view.View,%20android.webkit.WebChromeClient.CustomViewCallback)))
  ///- iOS ([Official API - UIWindow.didBecomeVisibleNotification](https://developer.apple.com/documentation/uikit/uiwindow/1621621-didbecomevisiblenotification))
  ///- MacOS ([Official API - NSWindow.didEnterFullScreenNotification](https://developer.apple.com/documentation/appkit/nswindow/1419651-didenterfullscreennotification))
  void onEnterFullscreen() {}

  ///Event fired when the current page has exited full screen mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onHideCustomView](https://developer.android.com/reference/android/webkit/WebChromeClient#onHideCustomView()))
  ///- iOS ([Official API - UIWindow.didBecomeHiddenNotification](https://developer.apple.com/documentation/uikit/uiwindow/1621617-didbecomehiddennotification))
  ///- MacOS ([Official API - NSWindow.didExitFullScreenNotification](https://developer.apple.com/documentation/appkit/nswindow/1419177-didexitfullscreennotification))
  void onExitFullscreen() {}

  ///Called when the web view begins to receive web content.
  ///
  ///This event occurs early in the document loading process, and as such
  ///you should expect that linked resources (for example, CSS and images) may not be available.
  ///
  ///[url] represents the URL corresponding to the page navigation that triggered this callback.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onPageCommitVisible](https://developer.android.com/reference/android/webkit/WebViewClient#onPageCommitVisible(android.webkit.WebView,%20java.lang.String)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455635-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455635-webview))
  void onPageCommitVisible(WebUri? url) {}

  ///Event fired when a change in the document title occurred.
  ///
  ///[title] represents the string containing the new title of the document.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onReceivedTitle](https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTitle(android.webkit.WebView,%20java.lang.String)))
  ///- iOS
  ///- MacOS
  ///- Windows ([Official API - ICoreWebView2.add_DocumentTitleChanged](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_documenttitlechanged))
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
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.onOverScrolled](https://developer.android.com/reference/android/webkit/WebView#onOverScrolled(int,%20int,%20boolean,%20boolean)))
  ///- iOS
  void onOverScrolled(int x, int y, bool clampedX, bool clampedY) {}

  ///Event fired when the zoom scale of the WebView has changed.
  ///
  ///[oldScale] The old zoom scale factor.
  ///
  ///[newScale] The new zoom scale factor.ì
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onScaleChanged](https://developer.android.com/reference/android/webkit/WebViewClient#onScaleChanged(android.webkit.WebView,%20float,%20float)))
  ///- iOS ([Official API - UIScrollViewDelegate.scrollViewDidZoom](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619409-scrollviewdidzoom))
  ///- Windows ([Official API - ICoreWebView2Controller.add_ZoomFactorChanged](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controller?view=webview2-1.0.2849.39#add_zoomfactorchanged))
  void onZoomScaleChanged(double oldScale, double newScale) {}

  ///Use [onSafeBrowsingHit] instead.
  @Deprecated("Use onSafeBrowsingHit instead")
  FutureOr<SafeBrowsingResponse?>? androidOnSafeBrowsingHit(
      Uri url, SafeBrowsingThreat? threatType) {
    return null;
  }

  ///Event fired when the WebView notifies that a loading URL has been flagged by Safe Browsing.
  ///The default behavior is to show an interstitial to the user, with the reporting checkbox visible.
  ///
  ///[url] represents the url of the request.
  ///
  ///[threatType] represents the reason the resource was caught by Safe Browsing, corresponding to a [SafeBrowsingThreat].
  ///
  ///**NOTE**: available only on Android 27+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onSafeBrowsingHit](https://developer.android.com/reference/android/webkit/WebViewClient#onSafeBrowsingHit(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20int,%20android.webkit.SafeBrowsingResponse)))
  FutureOr<SafeBrowsingResponse?>? onSafeBrowsingHit(
      WebUri url, SafeBrowsingThreat? threatType) {
    return null;
  }

  ///Use [onPermissionRequest] instead.
  @Deprecated("Use onPermissionRequest instead")
  FutureOr<PermissionRequestResponse?>? androidOnPermissionRequest(
      String origin, List<String> resources) {
    return null;
  }

  ///Event fired when the WebView is requesting permission to access the specified resources and the permission currently isn't granted or denied.
  ///
  ///[permissionRequest] represents the permission request with an array of resources the web content wants to access
  ///and the origin of the web page which is trying to access the restricted resources.
  ///
  ///**NOTE for Android**: available only on Android 21+.
  ///
  ///**NOTE for iOS**: available only on iOS 15.0+. The default [PermissionResponse.action] is [PermissionResponseAction.PROMPT].
  ///
  ///**NOTE for MacOS**: available only on iOS 12.0+. The default [PermissionResponse.action] is [PermissionResponseAction.PROMPT].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onPermissionRequest](https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequest(android.webkit.PermissionRequest)))
  ///- iOS
  ///- MacOS
  ///- Windows ([Official API - ICoreWebView2.add_PermissionRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_permissionrequested))
  FutureOr<PermissionResponse?>? onPermissionRequest(
      PermissionRequest permissionRequest) {
    return null;
  }

  ///Use [onGeolocationPermissionsShowPrompt] instead.
  @Deprecated("Use onGeolocationPermissionsShowPrompt instead")
  FutureOr<GeolocationPermissionShowPromptResponse?>?
      androidOnGeolocationPermissionsShowPrompt(String origin) {
    return null;
  }

  ///Event that notifies the host application that web content from the specified origin is attempting to use the Geolocation API, but no permission state is currently set for that origin.
  ///Note that for applications targeting Android N and later SDKs (API level > `Build.VERSION_CODES.M`) this method is only called for requests originating from secure origins such as https.
  ///On non-secure origins geolocation requests are automatically denied.
  ///
  ///[origin] represents the origin of the web content attempting to use the Geolocation API.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onGeolocationPermissionsShowPrompt](https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsShowPrompt(java.lang.String,%20android.webkit.GeolocationPermissions.Callback)))
  FutureOr<GeolocationPermissionShowPromptResponse?>?
      onGeolocationPermissionsShowPrompt(String origin) {
    return null;
  }

  ///Use [onGeolocationPermissionsHidePrompt] instead.
  @Deprecated("Use onGeolocationPermissionsHidePrompt instead")
  void androidOnGeolocationPermissionsHidePrompt() {}

  ///Notify the host application that a request for Geolocation permissions, made with a previous call to [onGeolocationPermissionsShowPrompt] has been canceled.
  ///Any related UI should therefore be hidden.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onGeolocationPermissionsHidePrompt](https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsHidePrompt()))
  void onGeolocationPermissionsHidePrompt() {}

  ///Use [shouldInterceptRequest] instead.
  @Deprecated("Use shouldInterceptRequest instead")
  FutureOr<WebResourceResponse?>? androidShouldInterceptRequest(
      WebResourceRequest request) {
    return null;
  }

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
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldInterceptRequest] option to `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.shouldInterceptRequest](https://developer.android.com/reference/android/webkit/WebViewClient#shouldInterceptRequest(android.webkit.WebView,%20android.webkit.WebResourceRequest)))
  ///- Windows ([ICoreWebView2.add_WebResourceRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2478.35#add_webresourcerequested))
  FutureOr<WebResourceResponse?>? shouldInterceptRequest(
      WebResourceRequest request) {
    return null;
  }

  ///Use [onRenderProcessUnresponsive] instead.
  @Deprecated("Use onRenderProcessUnresponsive instead")
  FutureOr<WebViewRenderProcessAction?>? androidOnRenderProcessUnresponsive(
      Uri? url) {
    return null;
  }

  ///Event called when the renderer currently associated with the WebView becomes unresponsive as a result of a long running blocking task such as the execution of JavaScript.
  ///
  ///If a WebView fails to process an input event, or successfully navigate to a new URL within a reasonable time frame, the renderer is considered to be unresponsive, and this callback will be called.
  ///
  ///This callback will continue to be called at regular intervals as long as the renderer remains unresponsive.
  ///If the renderer becomes responsive again, [onRenderProcessResponsive] will be called once,
  ///and this method will not subsequently be called unless another period of unresponsiveness is detected.
  ///
  ///The minimum interval between successive calls to [onRenderProcessUnresponsive] is 5 seconds.
  ///
  ///No action is taken by WebView as a result of this method call.
  ///Applications may choose to terminate the associated renderer via the object that is passed to this callback,
  ///if in multiprocess mode, however this must be accompanied by correctly handling [onRenderProcessGone] for this WebView,
  ///and all other WebViews associated with the same renderer. Failure to do so will result in application termination.
  ///
  ///**NOTE**: available only on Android 29+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewRenderProcessClient.onRenderProcessUnresponsive](https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessUnresponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)))
  ///- Windows ([Official API - ICoreWebView2.add_ProcessFailed](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed))
  FutureOr<WebViewRenderProcessAction?>? onRenderProcessUnresponsive(
      WebUri? url) {
    return null;
  }

  ///Use [onRenderProcessResponsive] instead.
  @Deprecated("Use onRenderProcessResponsive instead")
  FutureOr<WebViewRenderProcessAction?>? androidOnRenderProcessResponsive(
      Uri? url) {
    return null;
  }

  ///Event called once when an unresponsive renderer currently associated with the WebView becomes responsive.
  ///
  ///After a WebView renderer becomes unresponsive, which is notified to the application by [onRenderProcessUnresponsive],
  ///it is possible for the blocking renderer task to complete, returning the renderer to a responsive state.
  ///In that case, this method is called once to indicate responsiveness.
  ///
  ///No action is taken by WebView as a result of this method call.
  ///
  ///**NOTE**: available only on Android 29+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewRenderProcessClient.onRenderProcessResponsive](https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessResponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)))
  FutureOr<WebViewRenderProcessAction?>? onRenderProcessResponsive(
      WebUri? url) {
    return null;
  }

  ///Use [onRenderProcessGone] instead.
  @Deprecated("Use onRenderProcessGone instead")
  void androidOnRenderProcessGone(RenderProcessGoneDetail detail) {}

  ///Event fired when the given WebView's render process has exited.
  ///The application's implementation of this callback should only attempt to clean up the WebView.
  ///The WebView should be removed from the view hierarchy, all references to it should be cleaned up.
  ///
  ///To cause an render process crash for test purpose, the application can call load url `"chrome://crash"` on the WebView.
  ///Note that multiple WebView instances may be affected if they share a render process, not just the specific WebView which loaded `"chrome://crash"`.
  ///
  ///[detail] the reason why it exited.
  ///
  ///**NOTE**: available only on Android 26+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onRenderProcessGone](https://developer.android.com/reference/android/webkit/WebViewClient#onRenderProcessGone(android.webkit.WebView,%20android.webkit.RenderProcessGoneDetail)))
  ///- Windows ([Official API - ICoreWebView2.add_ProcessFailed](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed))
  void onRenderProcessGone(RenderProcessGoneDetail detail) {}

  ///Use [onFormResubmission] instead.
  @Deprecated('Use onFormResubmission instead')
  FutureOr<FormResubmissionAction?>? androidOnFormResubmission(Uri? url) {
    return null;
  }

  ///As the host application if the browser should resend data as the requested page was a result of a POST. The default is to not resend the data.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onFormResubmission](https://developer.android.com/reference/android/webkit/WebViewClient#onFormResubmission(android.webkit.WebView,%20android.os.Message,%20android.os.Message)))
  FutureOr<FormResubmissionAction?>? onFormResubmission(WebUri? url) {
    return null;
  }

  ///Use [onZoomScaleChanged] instead.
  @Deprecated('Use onZoomScaleChanged instead')
  void androidOnScaleChanged(double oldScale, double newScale) {}

  ///Use [onReceivedIcon] instead.
  @Deprecated('Use onReceivedIcon instead')
  void androidOnReceivedIcon(Uint8List icon) {}

  ///Event fired when there is new favicon for the current page.
  ///
  ///[icon] represents the favicon for the current page.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onReceivedIcon](https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedIcon(android.webkit.WebView,%20android.graphics.Bitmap)))
  void onReceivedIcon(Uint8List icon) {}

  ///Use [onReceivedTouchIconUrl] instead.
  @Deprecated('Use onReceivedTouchIconUrl instead')
  void androidOnReceivedTouchIconUrl(Uri url, bool precomposed) {}

  ///Event fired when there is an url for an apple-touch-icon.
  ///
  ///[url] represents the icon url.
  ///
  ///[precomposed] is `true` if the url is for a precomposed touch icon.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onReceivedTouchIconUrl](https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTouchIconUrl(android.webkit.WebView,%20java.lang.String,%20boolean)))
  void onReceivedTouchIconUrl(WebUri url, bool precomposed) {}

  ///Use [onJsBeforeUnload] instead.
  @Deprecated('Use onJsBeforeUnload instead')
  FutureOr<JsBeforeUnloadResponse?>? androidOnJsBeforeUnload(
      JsBeforeUnloadRequest jsBeforeUnloadRequest) {
    return null;
  }

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
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onJsBeforeUnload](https://developer.android.com/reference/android/webkit/WebChromeClient#onJsBeforeUnload(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)))
  FutureOr<JsBeforeUnloadResponse?>? onJsBeforeUnload(
      JsBeforeUnloadRequest jsBeforeUnloadRequest) {
    return null;
  }

  ///Use [onReceivedLoginRequest] instead.
  @Deprecated('Use onReceivedLoginRequest instead')
  void androidOnReceivedLoginRequest(LoginRequest loginRequest) {}

  ///Event fired when a request to automatically log in the user has been processed.
  ///
  ///[loginRequest] contains the realm, account and args of the login request.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedLoginRequest](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedLoginRequest(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String)))
  void onReceivedLoginRequest(LoginRequest loginRequest) {}

  ///Notify the host application that the given permission request has been canceled. Any related UI should therefore be hidden.
  ///
  ///[permissionRequest] represents the permission request that needs be canceled
  ///with an array of resources the web content wants to access
  ///and the origin of the web page which is trying to access the restricted resources.
  ///
  ///**NOTE for Android**: available only on Android 21+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onPermissionRequestCanceled](https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequestCanceled(android.webkit.PermissionRequest)))
  void onPermissionRequestCanceled(PermissionRequest permissionRequest) {}

  ///Request display and focus for this WebView.
  ///This may happen due to another WebView opening a link in this WebView and requesting that this WebView be displayed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onRequestFocus](https://developer.android.com/reference/android/webkit/WebChromeClient#onRequestFocus(android.webkit.WebView)))
  void onRequestFocus() {}

  ///Use [onWebContentProcessDidTerminate] instead.
  @Deprecated('Use onWebContentProcessDidTerminate instead')
  void iosOnWebContentProcessDidTerminate() {}

  ///Invoked when the web view's web content process is terminated.
  ///Reloading the page will start a new render process if needed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationDelegate.webViewWebContentProcessDidTerminate](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455639-webviewwebcontentprocessdidtermi))
  ///- MacOS ([Official API - WKNavigationDelegate.webViewWebContentProcessDidTerminate](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455639-webviewwebcontentprocessdidtermi))
  ///- Windows ([Official API - ICoreWebView2.add_ProcessFailed](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed))
  void onWebContentProcessDidTerminate() {}

  ///Use [onDidReceiveServerRedirectForProvisionalNavigation] instead.
  @Deprecated('Use onDidReceiveServerRedirectForProvisionalNavigation instead')
  void iosOnDidReceiveServerRedirectForProvisionalNavigation() {}

  ///Called when a web view receives a server redirect.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455627-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455627-webview))
  void onDidReceiveServerRedirectForProvisionalNavigation() {}

  ///Use [onNavigationResponse] instead.
  @Deprecated('Use onNavigationResponse instead')
  FutureOr<IOSNavigationResponseAction?>? iosOnNavigationResponse(
      IOSWKNavigationResponse navigationResponse) {
    return null;
  }

  ///Called when a web view asks for permission to navigate to new content after the response to the navigation request is known.
  ///
  ///[navigationResponse] represents the navigation response.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useOnNavigationResponse] setting to `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview))
  FutureOr<NavigationResponseAction?>? onNavigationResponse(
      NavigationResponse navigationResponse) {
    return null;
  }

  ///Use [shouldAllowDeprecatedTLS] instead.
  @Deprecated('Use shouldAllowDeprecatedTLS instead')
  FutureOr<IOSShouldAllowDeprecatedTLSAction?>? iosShouldAllowDeprecatedTLS(
      URLAuthenticationChallenge challenge) {
    return null;
  }

  ///Called when a web view asks whether to continue with a connection that uses a deprecated version of TLS (v1.0 and v1.1).
  ///
  ///[challenge] represents the authentication challenge.
  ///
  ///**NOTE for iOS**: available only on iOS 14.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 11.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/3601237-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/3601237-webview))
  FutureOr<ShouldAllowDeprecatedTLSAction?>? shouldAllowDeprecatedTLS(
      URLAuthenticationChallenge challenge) {
    return null;
  }

  ///Event fired when a change in the camera capture state occurred.
  ///
  ///**NOTE for iOS**: available only on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 12.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  void onCameraCaptureStateChanged(
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  ) {}

  ///Event fired when a change in the microphone capture state occurred.
  ///Event fired when a change in the microphone capture state occurred.
  ///
  ///**NOTE for iOS**: available only on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 12.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  void onMicrophoneCaptureStateChanged(
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  ) {}

  ///Event fired when the content size of the `WebView` changes.
  ///
  ///[oldContentSize] represents the old content size value.
  ///
  ///[newContentSize] represents the new content size value.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  void onContentSizeChanged(Size oldContentSize, Size newContentSize) {}

  ///Invoked when any of the processes in the WebView Process Group encounters one of the following conditions:
  ///- Unexpected exit: The process indicated by the event args has exited unexpectedly (usually due to a crash).
  ///The failure might or might not be recoverable and some failures are auto-recoverable.
  ///- Unresponsiveness: The process indicated by the event args has become unresponsive to user input.
  ///This is only reported for renderer processes, and will run every few seconds until the process becomes responsive again.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - ICoreWebView2.add_ProcessFailed](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed))
  void onProcessFailed(ProcessFailedDetail detail) {}

  ///This event runs when an accelerator key or key combo is pressed or
  ///released while the WebView is focused.
  ///A key is considered an accelerator if either of the following conditions are `true`:
  ///- `Ctrl` or `Alt` is currently being held.
  ///- The pressed key does not map to a character.
  ///
  ///A few specific keys are never considered accelerators, such as `Shift`.
  ///The `Escape` key is always considered an accelerator.
  ///
  ///Auto-repeated key events caused by holding the key down also triggers this event.
  ///Filter out the auto-repeated key events by verifying the [AcceleratorKeyPressedDetail.physicalKeyStatus] property.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - ICoreWebView2Controller.add_AcceleratorKeyPressed](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controller?view=webview2-1.0.2849.39#add_acceleratorkeypressed))
  void onAcceleratorKeyPressed(AcceleratorKeyPressedDetail detail) {}

  ///Tell the client to show a file chooser.
  ///This is called to handle HTML forms with 'file' input type,
  ///in response to the user pressing the "Select File" button.
  ///To cancel the request, return a [ShowFileChooserResponse] with [ShowFileChooserResponse.filePaths] to `null`.
  ///
  ///Note that the WebView does not enforce any restrictions on the chosen file(s).
  ///WebView can access all files that your app can access.
  ///In case the file(s) are chosen through an untrusted source such as a third-party app,
  ///it is your own app's responsibility to check what the returned Uris refer
  ///to.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onShowFileChooser](https://developer.android.com/reference/android/webkit/WebChromeClient#onShowFileChooser(android.webkit.WebView,%20android.webkit.ValueCallback%3Candroid.net.Uri[]%3E,%20android.webkit.WebChromeClient.FileChooserParams)))
  FutureOr<ShowFileChooserResponse?> onShowFileChooser(
      ShowFileChooserRequest request) {
    return null;
  }
}
