import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../context_menu/context_menu.dart';
import '../find_interaction/find_interaction_controller.dart';
import '../pull_to_refresh/main.dart';
import '../types/main.dart';

import '../in_app_webview/in_app_webview_controller.dart';
import '../in_app_webview/in_app_webview_settings.dart';

import '../util.dart';
import '../print_job/main.dart';
import '../web_uri.dart';
import 'in_app_browser_menu_item.dart';
import 'in_app_browser_settings.dart';
import '../debug_logging_settings.dart';
import '../pull_to_refresh/pull_to_refresh_controller.dart';

///This class uses the native WebView of the platform.
///The [webViewController] field can be used to access the [InAppWebViewController] API.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class InAppBrowser extends ChannelController {
  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  ///View ID used internally.
  late final String id;

  ///Context menu used by the browser. It should be set before opening the browser.
  ContextMenu? contextMenu;

  ///Represents the pull-to-refresh feature controller.
  PullToRefreshController? pullToRefreshController;

  ///Represents the find interaction feature controller.
  FindInteractionController? findInteractionController;

  ///Initial list of user scripts to be loaded at start or end of a page loading.
  final UnmodifiableListView<UserScript>? initialUserScripts;

  bool _isOpened = false;
  static const MethodChannel _sharedChannel =
      const MethodChannel('com.pichillilorenzo/flutter_inappbrowser');

  InAppWebViewController? _webViewController;

  Map<int, InAppBrowserMenuItem> _menuItems = new HashMap();

  ///WebView Controller that can be used to access the [InAppWebViewController] API.
  ///When [onExit] is fired, this will be `null` and cannot be used anymore.
  InAppWebViewController? get webViewController {
    return _isOpened ? _webViewController : null;
  }

  ///The window id of a [CreateWindowAction.windowId].
  final int? windowId;

  InAppBrowser({this.windowId, this.initialUserScripts}) {
    id = IdGenerator.generate();
  }

  _init() {
    channel =
        MethodChannel('com.pichillilorenzo/flutter_inappbrowser_$id');
    handler = _handleMethod;
    initMethodCallHandler();

    _webViewController = new InAppWebViewController.fromInAppBrowser(
        channel!, this, this.initialUserScripts);
    pullToRefreshController?.init(id);
    findInteractionController?.init(id);
  }

  _debugLog(String method, dynamic args) {
    debugLog(
        className: this.runtimeType.toString(),
        id: id,
        debugLoggingSettings: InAppBrowser.debugLoggingSettings,
        method: method,
        args: args);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onBrowserCreated":
        _debugLog(call.method, call.arguments);
        onBrowserCreated();
        break;
      case "onMenuItemClicked":
        _debugLog(call.method, call.arguments);
        int id = call.arguments["id"].toInt();
        if (this._menuItems[id] != null) {
          if (this._menuItems[id]?.onClick != null) {
            this._menuItems[id]?.onClick!();
          }
        }
        break;
      case "onExit":
        _debugLog(call.method, call.arguments);
        _isOpened = false;
        dispose();
        onExit();
        break;
      default:
        return _webViewController?.handleMethod(call);
    }
  }

  Map<String, dynamic> _prepareOpenRequest(
      { // ignore: deprecated_member_use_from_same_package
      @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
      InAppBrowserClassSettings? settings}) {
    assert(!_isOpened, 'The browser is already opened.');
    _isOpened = true;
    _init();

    var initialSettings = settings?.toMap() ??
        options?.toMap() ??
        InAppBrowserClassSettings().toMap();

    Map<String, dynamic> pullToRefreshSettings =
        pullToRefreshController?.settings.toMap() ??
            // ignore: deprecated_member_use_from_same_package
            pullToRefreshController?.options.toMap() ??
            PullToRefreshSettings(enabled: false).toMap();

    List<Map<String, dynamic>> menuItemList = [];
    _menuItems.forEach((key, value) {
      menuItemList.add(value.toMap());
    });

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('id', () => id);
    args.putIfAbsent('settings', () => initialSettings);
    args.putIfAbsent('contextMenu', () => contextMenu?.toMap() ?? {});
    args.putIfAbsent('windowId', () => windowId);
    args.putIfAbsent('initialUserScripts',
        () => initialUserScripts?.map((e) => e.toMap()).toList() ?? []);
    args.putIfAbsent('pullToRefreshSettings', () => pullToRefreshSettings);
    args.putIfAbsent('menuItems', () => menuItemList);
    return args;
  }

  ///Opens the [InAppBrowser] instance with an [urlRequest].
  ///
  ///[urlRequest]: The [urlRequest] to load.
  ///
  ///[options]: Options for the [InAppBrowser].
  ///
  ///[settings]: Settings for the [InAppBrowser].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> openUrlRequest(
      {required URLRequest urlRequest,
      // ignore: deprecated_member_use_from_same_package
      @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
      InAppBrowserClassSettings? settings}) async {
    assert(urlRequest.url != null && urlRequest.url.toString().isNotEmpty);

    Map<String, dynamic> args =
        _prepareOpenRequest(options: options, settings: settings);
    args.putIfAbsent('urlRequest', () => urlRequest.toMap());
    await _sharedChannel.invokeMethod('open', args);
  }

  ///Opens the [InAppBrowser] instance with the given [assetFilePath] file.
  ///
  ///[options]: Options for the [InAppBrowser].
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
  ///[options]: Options for the [InAppBrowser].
  ///
  ///[settings]: Settings for the [InAppBrowser].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> openFile(
      {required String assetFilePath,
      // ignore: deprecated_member_use_from_same_package
      @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
      InAppBrowserClassSettings? settings}) async {
    assert(assetFilePath.isNotEmpty);

    Map<String, dynamic> args =
        _prepareOpenRequest(options: options, settings: settings);
    args.putIfAbsent('assetFilePath', () => assetFilePath);
    await _sharedChannel.invokeMethod('open', args);
  }

  ///Opens the [InAppBrowser] instance with [data] as a content, using [baseUrl] as the base URL for it.
  ///
  ///The [mimeType] parameter specifies the format of the data. The default value is `"text/html"`.
  ///
  ///The [encoding] parameter specifies the encoding of the data. The default value is `"utf8"`.
  ///
  ///The [androidHistoryUrl] parameter is the URL to use as the history entry. The default value is `about:blank`. If non-null, this must be a valid URL. This parameter is used only on Android.
  ///
  ///The [options] parameter specifies the options for the [InAppBrowser].
  ///
  ///[settings]: Settings for the [InAppBrowser].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> openData(
      {required String data,
      String mimeType = "text/html",
      String encoding = "utf8",
      WebUri? baseUrl,
      @Deprecated("Use historyUrl instead") Uri? androidHistoryUrl,
      WebUri? historyUrl,
      // ignore: deprecated_member_use_from_same_package
      @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
      InAppBrowserClassSettings? settings}) async {
    Map<String, dynamic> args =
        _prepareOpenRequest(options: options, settings: settings);
    args.putIfAbsent('data', () => data);
    args.putIfAbsent('mimeType', () => mimeType);
    args.putIfAbsent('encoding', () => encoding);
    args.putIfAbsent('baseUrl', () => baseUrl?.toString() ?? "about:blank");
    args.putIfAbsent('historyUrl',
        () => (historyUrl ?? androidHistoryUrl)?.toString() ?? "about:blank");
    await _sharedChannel.invokeMethod('open', args);
  }

  ///This is a static method that opens an [url] in the system browser. You wont be able to use the [InAppBrowser] methods here!
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  static Future<void> openWithSystemBrowser({required WebUri url}) async {
    assert(url.toString().isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    return await _sharedChannel.invokeMethod('openWithSystemBrowser', args);
  }

  ///Adds a [InAppBrowserMenuItem] to the menu.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  ///- iOS 14.0+
  void addMenuItem(InAppBrowserMenuItem menuItem) {
    _menuItems[menuItem.id] = menuItem;
  }

  ///Adds a list of [InAppBrowserMenuItem] to the menu.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  ///- iOS 14.0+
  void addMenuItems(List<InAppBrowserMenuItem> menuItems) {
    menuItems.forEach((menuItem) {
      _menuItems[menuItem.id] = menuItem;
    });
  }

  ///Removes the [menuItem] from the list.
  ///Returns `true` if it was in the list, `false` otherwise.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  ///- iOS 14.0+
  bool removeMenuItem(InAppBrowserMenuItem menuItem) {
    return _menuItems.remove(menuItem.id) != null;
  }

  ///Removes a list of [menuItems] from the list.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  ///- iOS 14.0+
  void removeMenuItems(List<InAppBrowserMenuItem> menuItems) {
    for (final menuItem in menuItems) {
      removeMenuItem(menuItem);
    }
  }

  ///Removes all the menu items from the list.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  ///- iOS 14.0+
  void removeAllMenuItem() {
    _menuItems.clear();
  }

  ///Returns `true` if the [menuItem] has been already added, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS 14.0+
  bool hasMenuItem(InAppBrowserMenuItem menuItem) {
    return _menuItems.containsKey(menuItem.id);
  }

  ///Displays an [InAppBrowser] window that was opened hidden. Calling this has no effect if the [InAppBrowser] was already visible.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> show() async {
    assert(_isOpened, 'The browser is not opened.');

    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('show', args);
  }

  ///Hides the [InAppBrowser] window. Calling this has no effect if the [InAppBrowser] was already hidden.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> hide() async {
    assert(_isOpened, 'The browser is not opened.');

    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('hide', args);
  }

  ///Closes the [InAppBrowser] window.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> close() async {
    assert(_isOpened, 'The browser is not opened.');

    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('close', args);
  }

  ///Check if the Web View of the [InAppBrowser] instance is hidden.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<bool> isHidden() async {
    assert(_isOpened, 'The browser is not opened.');

    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('isHidden', args) ?? false;
  }

  ///Use [setSettings] instead.
  @Deprecated('Use setSettings instead')
  Future<void> setOptions({required InAppBrowserClassOptions options}) async {
    assert(_isOpened, 'The browser is not opened.');

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('settings', () => options.toMap());
    await channel?.invokeMethod('setSettings', args);
  }

  ///Use [getSettings] instead.
  @Deprecated('Use getSettings instead')
  Future<InAppBrowserClassOptions?> getOptions() async {
    assert(_isOpened, 'The browser is not opened.');
    Map<String, dynamic> args = <String, dynamic>{};

    Map<dynamic, dynamic>? options =
        await channel?.invokeMethod('getSettings', args);
    if (options != null) {
      options = options.cast<String, dynamic>();
      return InAppBrowserClassOptions.fromMap(options as Map<String, dynamic>);
    }

    return null;
  }

  ///Sets the [InAppBrowser] settings with the new [settings] and evaluates them.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> setSettings(
      {required InAppBrowserClassSettings settings}) async {
    assert(_isOpened, 'The browser is not opened.');

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('settings', () => settings.toMap());
    await channel?.invokeMethod('setSettings', args);
  }

  ///Gets the current [InAppBrowser] settings. Returns `null` if it wasn't able to get them.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<InAppBrowserClassSettings?> getSettings() async {
    assert(_isOpened, 'The browser is not opened.');

    Map<String, dynamic> args = <String, dynamic>{};

    Map<dynamic, dynamic>? settings =
        await channel?.invokeMethod('getSettings', args);
    if (settings != null) {
      settings = settings.cast<String, dynamic>();
      return InAppBrowserClassSettings.fromMap(
          settings as Map<String, dynamic>);
    }

    return null;
  }

  ///Returns `true` if the [InAppBrowser] instance is opened, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool isOpened() {
    return this._isOpened;
  }

  ///Event fired when the [InAppBrowser] is created.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  void onBrowserCreated() {}

  ///Event fired when the [InAppBrowser] window is closed.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  void onExit() {}

  ///Event fired when the [InAppBrowser] starts to load an [url].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onPageStarted](https://developer.android.com/reference/android/webkit/WebViewClient#onPageStarted(android.webkit.WebView,%20java.lang.String,%20android.graphics.Bitmap)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455621-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455621-webview))
  void onLoadStart(WebUri? url) {}

  ///Event fired when the [InAppBrowser] finishes loading an [url].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onPageFinished](https://developer.android.com/reference/android/webkit/WebViewClient#onPageFinished(android.webkit.WebView,%20java.lang.String)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455629-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455629-webview))
  void onLoadStop(WebUri? url) {}

  ///Use [onReceivedError] instead.
  @Deprecated("Use onReceivedError instead")
  void onLoadError(Uri? url, int code, String message) {}

  ///Event fired when the [InAppBrowser] encounters an [error] loading a [request].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedError](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedError(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20android.webkit.WebResourceError)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455623-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455623-webview))
  void onReceivedError(WebResourceRequest request, WebResourceError error) {}

  ///Use [onReceivedHttpError] instead.
  @Deprecated("Use onReceivedHttpError instead")
  void onLoadHttpError(Uri? url, int statusCode, String description) {}

  ///Event fired when the [InAppBrowser] receives an HTTP error.
  ///
  ///[request] represents the originating request.
  ///
  ///[errorResponse] represents the information about the error occurred.
  ///
  ///**NOTE**: available on Android 23+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedHttpError](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpError(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20android.webkit.WebResourceResponse)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview))
  void onReceivedHttpError(
      WebResourceRequest request, WebResourceResponse errorResponse) {}

  ///Event fired when the current [progress] (range 0-100) of loading a page is changed.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onProgressChanged](https://developer.android.com/reference/android/webkit/WebChromeClient#onProgressChanged(android.webkit.WebView,%20int)))
  ///- iOS
  ///- MacOS
  void onProgressChanged(int progress) {}

  ///Event fired when the [InAppBrowser] webview receives a [ConsoleMessage].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onConsoleMessage](https://developer.android.com/reference/android/webkit/WebChromeClient#onConsoleMessage(android.webkit.ConsoleMessage)))
  ///- iOS
  ///- MacOS
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
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.shouldOverrideUrlLoading](https://developer.android.com/reference/android/webkit/WebViewClient#shouldOverrideUrlLoading(android.webkit.WebView,%20java.lang.String)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455641-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455641-webview))
  Future<NavigationActionPolicy?>? shouldOverrideUrlLoading(
      NavigationAction navigationAction) {
    return null;
  }

  ///Event fired when the [InAppBrowser] webview loads a resource.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useOnLoadResource] and [InAppWebViewSettings.javaScriptEnabled] setting to `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  void onLoadResource(LoadedResource resource) {}

  ///Event fired when the [InAppBrowser] webview scrolls.
  ///
  ///[x] represents the current horizontal scroll origin in pixels.
  ///
  ///[y] represents the current vertical scroll origin in pixels.
  ///
  ///**NOTE for MacOS**: this method is implemented with using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.onScrollChanged](https://developer.android.com/reference/android/webkit/WebView#onScrollChanged(int,%20int,%20int,%20int)))
  ///- iOS ([Official API - UIScrollViewDelegate.scrollViewDidScroll](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619392-scrollviewdidscroll))
  ///- MacOS
  void onScrollChanged(int x, int y) {}

  ///Use [onDownloadStartRequest] instead
  @Deprecated('Use onDownloadStartRequest instead')
  void onDownloadStart(Uri url) {}

  ///Event fired when [WebView] recognizes a downloadable file.
  ///To download the file, you can use the [flutter_downloader](https://pub.dev/packages/flutter_downloader) plugin.
  ///
  ///[downloadStartRequest] represents the request of the file to download.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useOnDownloadStart] setting to `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.setDownloadListener](https://developer.android.com/reference/android/webkit/WebView#setDownloadListener(android.webkit.DownloadListener)))
  ///- iOS
  ///- MacOS
  void onDownloadStartRequest(DownloadStartRequest downloadStartRequest) {}

  ///Use [onLoadResourceWithCustomScheme] instead.
  @Deprecated('Use onLoadResourceWithCustomScheme instead')
  Future<CustomSchemeResponse?>? onLoadResourceCustomScheme(Uri url) {
    return null;
  }

  ///Event fired when the [InAppBrowser] webview finds the `custom-scheme` while loading a resource.
  ///Here you can handle the url [request] and return a [CustomSchemeResponse] to load a specific resource encoded to `base64`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKURLSchemeHandler](https://developer.apple.com/documentation/webkit/wkurlschemehandler))
  ///- MacOS ([Official API - WKURLSchemeHandler](https://developer.apple.com/documentation/webkit/wkurlschemehandler))
  Future<CustomSchemeResponse?>? onLoadResourceWithCustomScheme(
      WebResourceRequest request) {
    return null;
  }

  ///Event fired when the [InAppBrowser] webview requests the host application to create a new window,
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
  ///Also, note that calling [InAppWebViewController.setSettings] method using the controller of the new created WebView,
  ///it will update also the WebView options of the caller WebView.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onCreateWindow](https://developer.android.com/reference/android/webkit/WebChromeClient#onCreateWindow(android.webkit.WebView,%20boolean,%20boolean,%20android.os.Message)))
  ///- iOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview))
  ///- MacOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview))
  Future<bool?>? onCreateWindow(CreateWindowAction createWindowAction) {
    return null;
  }

  ///Event fired when the host application should close the given WebView and remove it from the view system if necessary.
  ///At this point, WebCore has stopped any loading in this window and has removed any cross-scripting ability in javascript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onCloseWindow](https://developer.android.com/reference/android/webkit/WebChromeClient#onCloseWindow(android.webkit.WebView)))
  ///- iOS ([Official API - WKUIDelegate.webViewDidClose](https://developer.apple.com/documentation/webkit/wkuidelegate/1537390-webviewdidclose))
  ///- MacOS ([Official API - WKUIDelegate.webViewDidClose](https://developer.apple.com/documentation/webkit/wkuidelegate/1537390-webviewdidclose))
  void onCloseWindow() {}

  ///Event fired when the JavaScript `window` object of the WebView has received focus.
  ///This is the result of the `focus` javascript event applied to the `window` object.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  void onWindowFocus() {}

  ///Event fired when the JavaScript `window` object of the WebView has lost focus.
  ///This is the result of the `blur` javascript event applied to the `window` object.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  void onWindowBlur() {}

  ///Event fired when javascript calls the `alert()` method to display an alert dialog.
  ///If [JsAlertResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsAlertRequest] contains the message to be displayed in the alert dialog and the of the page requesting the dialog.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onJsAlert](https://developer.android.com/reference/android/webkit/WebChromeClient#onJsAlert(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)))
  ///- iOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1537406-webview))
  ///- MacOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1537406-webview))
  Future<JsAlertResponse?>? onJsAlert(JsAlertRequest jsAlertRequest) {
    return null;
  }

  ///Event fired when javascript calls the `confirm()` method to display a confirm dialog.
  ///If [JsConfirmResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsConfirmRequest] contains the message to be displayed in the confirm dialog and the of the page requesting the dialog.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onJsConfirm](https://developer.android.com/reference/android/webkit/WebChromeClient#onJsConfirm(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)))
  ///- iOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1536489-webview))
  ///- MacOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1536489-webview))
  Future<JsConfirmResponse?>? onJsConfirm(JsConfirmRequest jsConfirmRequest) {
    return null;
  }

  ///Event fired when javascript calls the `prompt()` method to display a prompt dialog.
  ///If [JsPromptResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsPromptRequest] contains the message to be displayed in the prompt dialog, the default value displayed in the prompt dialog, and the of the page requesting the dialog.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onJsPrompt](https://developer.android.com/reference/android/webkit/WebChromeClient#onJsPrompt(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String,%20android.webkit.JsPromptResult)))
  ///- iOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1538086-webview))
  ///- MacOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1538086-webview))
  Future<JsPromptResponse?>? onJsPrompt(JsPromptRequest jsPromptRequest) {
    return null;
  }

  ///Event fired when the WebView received an HTTP authentication request. The default behavior is to cancel the request.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [URLAuthenticationChallenge].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedHttpAuthRequest](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpAuthRequest(android.webkit.WebView,%20android.webkit.HttpAuthHandler,%20java.lang.String,%20java.lang.String)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  Future<HttpAuthResponse?>? onReceivedHttpAuthRequest(
      URLAuthenticationChallenge challenge) {
    return null;
  }

  ///Event fired when the WebView need to perform server trust authentication (certificate validation).
  ///The host application must return either [ServerTrustAuthResponse] instance with [ServerTrustAuthResponseAction.CANCEL] or [ServerTrustAuthResponseAction.PROCEED].
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ServerTrustChallenge].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedSslError](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedSslError(android.webkit.WebView,%20android.webkit.SslErrorHandler,%20android.net.http.SslError)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  Future<ServerTrustAuthResponse?>? onReceivedServerTrustAuthRequest(
      URLAuthenticationChallenge challenge) {
    return null;
  }

  ///Notify the host application to handle an SSL client certificate request.
  ///Webview stores the response in memory (for the life of the application) if [ClientCertResponseAction.PROCEED] or [ClientCertResponseAction.CANCEL]
  ///is called and does not call [onReceivedClientCertRequest] again for the same host and port pair.
  ///Note that, multiple layers in chromium network stack might be caching the responses.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ClientCertChallenge].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedClientCertRequest](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedClientCertRequest(android.webkit.WebView,%20android.webkit.ClientCertRequest)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  Future<ClientCertResponse?>? onReceivedClientCertRequest(
      URLAuthenticationChallenge challenge) {
    return null;
  }

  ///Use [FindInteractionController.onFindResultReceived] instead.
  @Deprecated('Use FindInteractionController.onFindResultReceived instead')
  void onFindResultReceived(
      int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting) {}

  ///Event fired when an `XMLHttpRequest` is sent to a server.
  ///It gives the host application a chance to take control over the request before sending it.
  ///
  ///[ajaxRequest] represents the `XMLHttpRequest`.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldInterceptAjaxRequest] setting to `true`.
  ///Also, unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the ajax requests will be intercept for sure.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<AjaxRequest?>? shouldInterceptAjaxRequest(AjaxRequest ajaxRequest) {
    return null;
  }

  ///Event fired whenever the `readyState` attribute of an `XMLHttpRequest` changes.
  ///It gives the host application a chance to abort the request.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldInterceptAjaxRequest] setting to `true`.
  ///Also, unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the ajax requests will be intercept for sure.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<AjaxRequestAction?>? onAjaxReadyStateChange(AjaxRequest ajaxRequest) {
    return null;
  }

  ///Event fired as an `XMLHttpRequest` progress.
  ///It gives the host application a chance to abort the request.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldInterceptAjaxRequest] setting to `true`.
  ///Also, unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the ajax requests will be intercept for sure.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<AjaxRequestAction?>? onAjaxProgress(AjaxRequest ajaxRequest) {
    return null;
  }

  ///Event fired when a request is sent to a server through [Fetch API](https://developer.mozilla.org/it/docs/Web/API/Fetch_API).
  ///It gives the host application a chance to take control over the request before sending it.
  ///
  ///[fetchRequest] represents a resource request.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldInterceptFetchRequest] setting to `true`.
  ///Also, unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept fetch requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the fetch requests will be intercept for sure.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<FetchRequest?>? shouldInterceptFetchRequest(
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
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.doUpdateVisitedHistory](https://developer.android.com/reference/android/webkit/WebViewClient#doUpdateVisitedHistory(android.webkit.WebView,%20java.lang.String,%20boolean)))
  ///- iOS
  ///- MacOS
  void onUpdateVisitedHistory(WebUri? url, bool? isReload) {}

  ///Use [onPrintRequest] instead
  @Deprecated("Use onPrintRequest instead")
  void onPrint(Uri? url) {}

  ///Event fired when `window.print()` is called from JavaScript side.
  ///Return `true` if you want to handle the print job.
  ///Otherwise return `false`, so the [PrintJobController] will be handled and disposed automatically by the system.
  ///
  ///[url] represents the url on which is called.
  ///
  ///[printJobController] represents the controller of the print job created.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<bool?>? onPrintRequest(
      WebUri? url, PrintJobController? printJobController) {
    return null;
  }

  ///Event fired when an HTML element of the webview has been clicked and held.
  ///
  ///[hitTestResult] represents the hit result for hitting an HTML elements.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.setOnLongClickListener](https://developer.android.com/reference/android/view/View#setOnLongClickListener(android.view.View.OnLongClickListener)))
  ///- iOS ([Official API - UILongPressGestureRecognizer](https://developer.apple.com/documentation/uikit/uilongpressgesturerecognizer))
  void onLongPressHitTestResult(InAppWebViewHitTestResult hitTestResult) {}

  ///Event fired when the current page has entered full screen mode.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onShowCustomView](https://developer.android.com/reference/android/webkit/WebChromeClient#onShowCustomView(android.view.View,%20android.webkit.WebChromeClient.CustomViewCallback)))
  ///- iOS ([Official API - UIWindow.didBecomeVisibleNotification](https://developer.apple.com/documentation/uikit/uiwindow/1621621-didbecomevisiblenotification))
  ///- MacOS ([Official API - NSWindow.didEnterFullScreenNotification](https://developer.apple.com/documentation/appkit/nswindow/1419651-didenterfullscreennotification))
  void onEnterFullscreen() {}

  ///Event fired when the current page has exited full screen mode.
  ///
  ///**Supported Platforms/Implementations**:
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
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onPageCommitVisible](https://developer.android.com/reference/android/webkit/WebViewClient#onPageCommitVisible(android.webkit.WebView,%20java.lang.String)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455635-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455635-webview))
  void onPageCommitVisible(WebUri? url) {}

  ///Event fired when a change in the document title occurred.
  ///
  ///[title] represents the string containing the new title of the document.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onReceivedTitle](https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTitle(android.webkit.WebView,%20java.lang.String)))
  ///- iOS
  ///- MacOS
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
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.onOverScrolled](https://developer.android.com/reference/android/webkit/WebView#onOverScrolled(int,%20int,%20boolean,%20boolean)))
  ///- iOS
  void onOverScrolled(int x, int y, bool clampedX, bool clampedY) {}

  ///Event fired when the zoom scale of the WebView has changed.
  ///
  ///[oldScale] The old zoom scale factor.
  ///
  ///[newScale] The new zoom scale factor.ì
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onScaleChanged](https://developer.android.com/reference/android/webkit/WebViewClient#onScaleChanged(android.webkit.WebView,%20float,%20float)))
  ///- iOS ([Official API - UIScrollViewDelegate.scrollViewDidZoom](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619409-scrollviewdidzoom))
  void onZoomScaleChanged(double oldScale, double newScale) {}

  ///Use [onSafeBrowsingHit] instead.
  @Deprecated("Use onSafeBrowsingHit instead")
  Future<SafeBrowsingResponse?>? androidOnSafeBrowsingHit(
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
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onSafeBrowsingHit](https://developer.android.com/reference/android/webkit/WebViewClient#onSafeBrowsingHit(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20int,%20android.webkit.SafeBrowsingResponse)))
  Future<SafeBrowsingResponse?>? onSafeBrowsingHit(
      WebUri url, SafeBrowsingThreat? threatType) {
    return null;
  }

  ///Use [onPermissionRequest] instead.
  @Deprecated("Use onPermissionRequest instead")
  Future<PermissionRequestResponse?>? androidOnPermissionRequest(
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
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onPermissionRequest](https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequest(android.webkit.PermissionRequest)))
  ///- iOS
  ///- MacOS
  Future<PermissionResponse?>? onPermissionRequest(
      PermissionRequest permissionRequest) {
    return null;
  }

  ///Use [onGeolocationPermissionsShowPrompt] instead.
  @Deprecated("Use onGeolocationPermissionsShowPrompt instead")
  Future<GeolocationPermissionShowPromptResponse?>?
      androidOnGeolocationPermissionsShowPrompt(String origin) {
    return null;
  }

  ///Event that notifies the host application that web content from the specified origin is attempting to use the Geolocation API, but no permission state is currently set for that origin.
  ///Note that for applications targeting Android N and later SDKs (API level > `Build.VERSION_CODES.M`) this method is only called for requests originating from secure origins such as https.
  ///On non-secure origins geolocation requests are automatically denied.
  ///
  ///[origin] represents the origin of the web content attempting to use the Geolocation API.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onGeolocationPermissionsShowPrompt](https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsShowPrompt(java.lang.String,%20android.webkit.GeolocationPermissions.Callback)))
  Future<GeolocationPermissionShowPromptResponse?>?
      onGeolocationPermissionsShowPrompt(String origin) {
    return null;
  }

  ///Use [onGeolocationPermissionsHidePrompt] instead.
  @Deprecated("Use onGeolocationPermissionsHidePrompt instead")
  void androidOnGeolocationPermissionsHidePrompt() {}

  ///Notify the host application that a request for Geolocation permissions, made with a previous call to [onGeolocationPermissionsShowPrompt] has been canceled.
  ///Any related UI should therefore be hidden.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onGeolocationPermissionsHidePrompt](https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsHidePrompt()))
  void onGeolocationPermissionsHidePrompt() {}

  ///Use [shouldInterceptRequest] instead.
  @Deprecated("Use shouldInterceptRequest instead")
  Future<WebResourceResponse?>? androidShouldInterceptRequest(
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
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.shouldInterceptRequest](https://developer.android.com/reference/android/webkit/WebViewClient#shouldInterceptRequest(android.webkit.WebView,%20android.webkit.WebResourceRequest)))
  Future<WebResourceResponse?>? shouldInterceptRequest(
      WebResourceRequest request) {
    return null;
  }

  ///Use [onRenderProcessUnresponsive] instead.
  @Deprecated("Use onRenderProcessUnresponsive instead")
  Future<WebViewRenderProcessAction?>? androidOnRenderProcessUnresponsive(
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
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewRenderProcessClient.onRenderProcessUnresponsive](https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessUnresponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)))
  Future<WebViewRenderProcessAction?>? onRenderProcessUnresponsive(
      WebUri? url) {
    return null;
  }

  ///Use [onRenderProcessResponsive] instead.
  @Deprecated("Use onRenderProcessResponsive instead")
  Future<WebViewRenderProcessAction?>? androidOnRenderProcessResponsive(
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
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewRenderProcessClient.onRenderProcessResponsive](https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessResponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)))
  Future<WebViewRenderProcessAction?>? onRenderProcessResponsive(WebUri? url) {
    return null;
  }

  ///Use [onRenderProcessGone] instead.
  @Deprecated("Use onRenderProcessGone instead")
  void androidOnRenderProcessGone(RenderProcessGoneDetail detail) {}

  ///Event fired when the given WebView's render process has exited.
  ///The application's implementation of this callback should only attempt to clean up the WebView.
  ///The WebView should be removed from the view hierarchy, all references to it should be cleaned up.
  ///
  ///[detail] the reason why it exited.
  ///
  ///**NOTE**: available only on Android 26+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onRenderProcessGone](https://developer.android.com/reference/android/webkit/WebViewClient#onRenderProcessGone(android.webkit.WebView,%20android.webkit.RenderProcessGoneDetail)))
  void onRenderProcessGone(RenderProcessGoneDetail detail) {}

  ///Use [onFormResubmission] instead.
  @Deprecated('Use onFormResubmission instead')
  Future<FormResubmissionAction?>? androidOnFormResubmission(Uri? url) {
    return null;
  }

  ///As the host application if the browser should resend data as the requested page was a result of a POST. The default is to not resend the data.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onFormResubmission](https://developer.android.com/reference/android/webkit/WebViewClient#onFormResubmission(android.webkit.WebView,%20android.os.Message,%20android.os.Message)))
  Future<FormResubmissionAction?>? onFormResubmission(WebUri? url) {
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
  ///**Supported Platforms/Implementations**:
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
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onReceivedTouchIconUrl](https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTouchIconUrl(android.webkit.WebView,%20java.lang.String,%20boolean)))
  void onReceivedTouchIconUrl(WebUri url, bool precomposed) {}

  ///Use [onJsBeforeUnload] instead.
  @Deprecated('Use onJsBeforeUnload instead')
  Future<JsBeforeUnloadResponse?>? androidOnJsBeforeUnload(
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
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onJsBeforeUnload](https://developer.android.com/reference/android/webkit/WebChromeClient#onJsBeforeUnload(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)))
  Future<JsBeforeUnloadResponse?>? onJsBeforeUnload(
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
  ///**Supported Platforms/Implementations**:
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
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onPermissionRequestCanceled](https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequestCanceled(android.webkit.PermissionRequest)))
  void onPermissionRequestCanceled(PermissionRequest permissionRequest) {}

  ///Request display and focus for this WebView.
  ///This may happen due to another WebView opening a link in this WebView and requesting that this WebView be displayed.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onRequestFocus](https://developer.android.com/reference/android/webkit/WebChromeClient#onRequestFocus(android.webkit.WebView)))
  void onRequestFocus() {}

  ///Use [onWebContentProcessDidTerminate] instead.
  @Deprecated('Use onWebContentProcessDidTerminate instead')
  void iosOnWebContentProcessDidTerminate() {}

  ///Invoked when the web view's web content process is terminated.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationDelegate.webViewWebContentProcessDidTerminate](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455639-webviewwebcontentprocessdidtermi))
  ///- MacOS ([Official API - WKNavigationDelegate.webViewWebContentProcessDidTerminate](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455639-webviewwebcontentprocessdidtermi))
  void onWebContentProcessDidTerminate() {}

  ///Use [onDidReceiveServerRedirectForProvisionalNavigation] instead.
  @Deprecated('Use onDidReceiveServerRedirectForProvisionalNavigation instead')
  void iosOnDidReceiveServerRedirectForProvisionalNavigation() {}

  ///Called when a web view receives a server redirect.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455627-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455627-webview))
  void onDidReceiveServerRedirectForProvisionalNavigation() {}

  ///Use [onNavigationResponse] instead.
  @Deprecated('Use onNavigationResponse instead')
  Future<IOSNavigationResponseAction?>? iosOnNavigationResponse(
      IOSWKNavigationResponse navigationResponse) {
    return null;
  }

  ///Called when a web view asks for permission to navigate to new content after the response to the navigation request is known.
  ///
  ///[navigationResponse] represents the navigation response.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useOnNavigationResponse] setting to `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview))
  Future<NavigationResponseAction?>? onNavigationResponse(
      NavigationResponse navigationResponse) {
    return null;
  }

  ///Use [shouldAllowDeprecatedTLS] instead.
  @Deprecated('Use shouldAllowDeprecatedTLS instead')
  Future<IOSShouldAllowDeprecatedTLSAction?>? iosShouldAllowDeprecatedTLS(
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
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/3601237-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/3601237-webview))
  Future<ShouldAllowDeprecatedTLSAction?>? shouldAllowDeprecatedTLS(
      URLAuthenticationChallenge challenge) {
    return null;
  }

  ///Event fired when a change in the camera capture state occurred.
  ///
  ///**NOTE for iOS**: available only on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
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
  ///**Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  void onMicrophoneCaptureStateChanged(
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  ) {}

  ///Event fired when the content size of the [WebView] changes.
  ///
  ///[oldContentSize] represents the old content size value.
  ///
  ///[newContentSize] represents the new content size value.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  void onContentSizeChanged(Size oldContentSize, Size newContentSize) {}

  ///Disposes the channel and controllers.
  @override
  @mustCallSuper
  void dispose() {
    disposeChannel();
    _webViewController?.dispose();
    _webViewController = null;
    pullToRefreshController?.dispose();
    pullToRefreshController = null;
    findInteractionController?.dispose();
    findInteractionController = null;
  }
}
