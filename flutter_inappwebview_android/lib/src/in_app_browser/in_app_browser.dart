import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../find_interaction/find_interaction_controller.dart';
import '../in_app_webview/in_app_webview_controller.dart';
import '../pull_to_refresh/pull_to_refresh_controller.dart';

/// Object specifying creation parameters for creating a [AndroidInAppBrowser].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformInAppBrowserCreationParams] for
/// more information.
class AndroidInAppBrowserCreationParams
    extends PlatformInAppBrowserCreationParams {
  /// Creates a new [AndroidInAppBrowserCreationParams] instance.
  AndroidInAppBrowserCreationParams(
      {super.contextMenu,
      this.pullToRefreshController,
      this.findInteractionController,
      super.initialUserScripts,
      super.windowId});

  /// Creates a [AndroidInAppBrowserCreationParams] instance based on [PlatformInAppBrowserCreationParams].
  factory AndroidInAppBrowserCreationParams.fromPlatformInAppBrowserCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformInAppBrowserCreationParams params) {
    return AndroidInAppBrowserCreationParams(
        contextMenu: params.contextMenu,
        pullToRefreshController:
            params.pullToRefreshController as AndroidPullToRefreshController?,
        findInteractionController: params.findInteractionController
            as AndroidFindInteractionController?,
        initialUserScripts: params.initialUserScripts,
        windowId: params.windowId);
  }

  @override
  final AndroidFindInteractionController? findInteractionController;

  @override
  final AndroidPullToRefreshController? pullToRefreshController;
}

///This class uses the native WebView of the platform.
///The [webViewController] field can be used to access the [InAppWebViewController] API.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class AndroidInAppBrowser extends PlatformInAppBrowser with ChannelController {
  ///View ID used internally.
  final String id = IdGenerator.generate();

  /// Constructs a [AndroidInAppBrowser].
  AndroidInAppBrowser(PlatformInAppBrowserCreationParams params)
      : super.implementation(
          params is AndroidInAppBrowserCreationParams
              ? params
              : AndroidInAppBrowserCreationParams
                  .fromPlatformInAppBrowserCreationParams(params),
        ) {
    _contextMenu = params.contextMenu;
  }

  static final AndroidInAppBrowser _staticValue =
      AndroidInAppBrowser(AndroidInAppBrowserCreationParams());

  factory AndroidInAppBrowser.static() {
    return _staticValue;
  }

  AndroidInAppBrowserCreationParams get _androidParams =>
      params as AndroidInAppBrowserCreationParams;

  static const MethodChannel _staticChannel =
      const MethodChannel('com.pichillilorenzo/flutter_inappbrowser');

  ContextMenu? _contextMenu;

  ContextMenu? get contextMenu => _contextMenu;

  Map<int, InAppBrowserMenuItem> _menuItems = HashMap();
  bool _isOpened = false;
  AndroidInAppWebViewController? _webViewController;

  ///WebView Controller that can be used to access the [AndroidInAppWebViewController] API.
  ///When [onExit] is fired, this will be `null` and cannot be used anymore.
  AndroidInAppWebViewController? get webViewController {
    return _isOpened ? _webViewController : null;
  }

  _init() {
    channel = MethodChannel('com.pichillilorenzo/flutter_inappbrowser_$id');
    handler = _handleMethod;
    initMethodCallHandler();

    _webViewController = AndroidInAppWebViewController.fromInAppBrowser(
        AndroidInAppWebViewControllerCreationParams(id: id),
        channel!,
        this,
        this.initialUserScripts);
    _androidParams.pullToRefreshController?.init(id);
    _androidParams.findInteractionController?.init(id);
  }

  _debugLog(String method, dynamic args) {
    debugLog(
        className: this.runtimeType.toString(),
        id: id,
        debugLoggingSettings: PlatformInAppBrowser.debugLoggingSettings,
        method: method,
        args: args);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onBrowserCreated":
        _debugLog(call.method, call.arguments);
        eventHandler?.onBrowserCreated();
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
        eventHandler?.onExit();
        break;
      default:
        return _webViewController?.handleMethod(call);
    }
  }

  Map<String, dynamic> _prepareOpenRequest(
      {@Deprecated('Use settings instead') InAppBrowserClassOptions? options,
      InAppBrowserClassSettings? settings}) {
    assert(!_isOpened, 'The browser is already opened.');
    _isOpened = true;
    _init();

    var initialSettings = settings?.toMap() ??
        options?.toMap() ??
        InAppBrowserClassSettings().toMap();

    Map<String, dynamic> pullToRefreshSettings =
        pullToRefreshController?.settings.toMap() ??
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

  ///Opens the [PlatformInAppBrowser] instance with an [urlRequest].
  ///
  ///[urlRequest]: The [urlRequest] to load.
  ///
  ///[options]: Options for the [PlatformInAppBrowser].
  ///
  ///[settings]: Settings for the [PlatformInAppBrowser].
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
    await _staticChannel.invokeMethod('open', args);
  }

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
    await _staticChannel.invokeMethod('open', args);
  }

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
    await _staticChannel.invokeMethod('open', args);
  }

  ///This is a static method that opens an [url] in the system browser. You wont be able to use the [PlatformInAppBrowser] methods here!
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> openWithSystemBrowser({required WebUri url}) async {
    assert(url.toString().isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    return await _staticChannel.invokeMethod('openWithSystemBrowser', args);
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

  ///Displays an [PlatformInAppBrowser] window that was opened hidden. Calling this has no effect if the [PlatformInAppBrowser] was already visible.
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

  ///Hides the [PlatformInAppBrowser] window. Calling this has no effect if the [PlatformInAppBrowser] was already hidden.
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

  ///Closes the [PlatformInAppBrowser] window.
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

  ///Check if the Web View of the [PlatformInAppBrowser] instance is hidden.
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

  ///Sets the [PlatformInAppBrowser] settings with the new [settings] and evaluates them.
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

  ///Gets the current [PlatformInAppBrowser] settings. Returns `null` if it wasn't able to get them.
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

  ///Returns `true` if the [PlatformInAppBrowser] instance is opened, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool isOpened() {
    return this._isOpened;
  }

  ///Disposes the channel and controllers.
  @override
  @mustCallSuper
  void dispose() {
    disposeChannel();
    _webViewController?.dispose();
    _webViewController = null;
    pullToRefreshController?.dispose();
    findInteractionController?.dispose();
    eventHandler = null;
  }
}

extension InternalInAppBrowser on AndroidInAppBrowser {
  void setContextMenu(ContextMenu? contextMenu) {
    _contextMenu = contextMenu;
  }
}
