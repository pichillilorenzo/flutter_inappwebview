import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
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

part 'platform_in_app_browser.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowserCreationParams}
/// Object specifying creation parameters for creating a [PlatformInAppBrowser].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
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

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.contextMenu}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.contextMenu.supported_platforms}
  final ContextMenu? contextMenu;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.pullToRefreshController}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.pullToRefreshController.supported_platforms}
  final PlatformPullToRefreshController? pullToRefreshController;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.findInteractionController}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.findInteractionController.supported_platforms}
  final PlatformFindInteractionController? findInteractionController;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialUserScripts}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.initialUserScripts.supported_platforms}
  final UnmodifiableListView<UserScript>? initialUserScripts;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.windowId}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.windowId.supported_platforms}
  final int? windowId;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowserCreationParams.webViewEnvironment}
  ///Used to create the [PlatformInAppBrowser] using the specified environment.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.webViewEnvironment.supported_platforms}
  final PlatformWebViewEnvironment? webViewEnvironment;
}

///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser}
///This class represents a native WebView displayed on top of the Flutter App,
///so it's not integrated into the Flutter widget tree.
///It uses the native WebView of the platform.
///The [webViewController] field can be used to access the [PlatformInAppWebViewController] API.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.supported_platforms}
@SupportedPlatforms(platforms: [
  AndroidPlatform(),
  IOSPlatform(),
  MacOSPlatform(),
  WindowsPlatform(),
])
abstract class PlatformInAppBrowser extends PlatformInterface
    implements Disposable {
  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  /// Event handler object that handles the [PlatformInAppBrowser] events.
  PlatformInAppBrowserEvents? eventHandler;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.id}
  ///View ID used internally.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.id.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
  String get id {
    throw UnimplementedError('id is not implemented on the current platform');
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.contextMenu}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.contextMenu.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
  ])
  ContextMenu? get contextMenu => params.contextMenu;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.pullToRefreshController}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.pullToRefreshController.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
  ])
  PlatformPullToRefreshController? get pullToRefreshController =>
      params.pullToRefreshController;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.findInteractionController}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.findInteractionController.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  PlatformFindInteractionController? get findInteractionController =>
      params.findInteractionController;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialUserScripts}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.initialUserScripts.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(
        note:
            """This property will be ignored if the [PlatformWebViewCreationParams.windowId] has been set.
There isn't any way to add/remove user scripts specific to iOS window WebViews.
This is a limitation of the native WebKit APIs."""),
    MacOSPlatform(
        note:
            """This property will be ignored if the [PlatformWebViewCreationParams.windowId] has been set.
There isn't any way to add/remove user scripts specific to iOS window WebViews.
This is a limitation of the native WebKit APIs."""),
    WindowsPlatform(),
  ])
  UnmodifiableListView<UserScript>? get initialUserScripts =>
      params.initialUserScripts;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.windowId}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.windowId.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
  int? get windowId => params.windowId;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserCreationParams.webViewEnvironment}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.webViewEnvironment.supported_platforms}
  @SupportedPlatforms(platforms: [
    WindowsPlatform(),
  ])
  PlatformWebViewEnvironment? get webViewEnvironment =>
      params.webViewEnvironment;

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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.openUrlRequest.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.openFile.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.openData.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
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
  ///This is a static method that opens an [url] in the system browser.
  ///You wont be able to use the [PlatformInAppBrowser] events and methods here.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.openWithSystemBrowser.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
  Future<void> openWithSystemBrowser({required WebUri url}) {
    throw UnimplementedError(
        'openWithSystemBrowser is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.addMenuItem}
  ///Adds a [InAppBrowserMenuItem] to the menu.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.addMenuItem.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(available: '14.0'),
    MacOSPlatform(available: '10.15'),
  ])
  void addMenuItem(InAppBrowserMenuItem menuItem) {
    throw UnimplementedError(
        'addMenuItem is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.addMenuItems}
  ///Adds a list of [InAppBrowserMenuItem] to the menu.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.addMenuItems.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(available: '14.0'),
    MacOSPlatform(available: '10.15'),
  ])
  void addMenuItems(List<InAppBrowserMenuItem> menuItems) {
    throw UnimplementedError(
        'addMenuItems is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeMenuItem}
  ///Removes the [menuItem] from the list.
  ///Returns `true` if it was in the list, `false` otherwise.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeMenuItem.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(available: '14.0'),
    MacOSPlatform(available: '10.15'),
  ])
  bool removeMenuItem(InAppBrowserMenuItem menuItem) {
    throw UnimplementedError(
        'removeMenuItem is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeMenuItems}
  ///Removes a list of [menuItems] from the list.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeMenuItems.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(available: '14.0'),
    MacOSPlatform(available: '10.15'),
  ])
  void removeMenuItems(List<InAppBrowserMenuItem> menuItems) {
    throw UnimplementedError(
        'removeMenuItems is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeAllMenuItem}
  ///Removes all the menu items from the list.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeAllMenuItem.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(available: '14.0'),
    MacOSPlatform(available: '10.15'),
  ])
  void removeAllMenuItem() {
    throw UnimplementedError(
        'removeAllMenuItem is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.hasMenuItem}
  ///Returns `true` if the [menuItem] has been already added, otherwise `false`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.hasMenuItem.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(available: '14.0'),
    MacOSPlatform(available: '10.15'),
  ])
  bool hasMenuItem(InAppBrowserMenuItem menuItem) {
    throw UnimplementedError(
        'hasMenuItem is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.show}
  ///Displays a [PlatformInAppBrowser] window that was opened hidden. Calling this has no effect if the [PlatformInAppBrowser] was already visible.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.show.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
  Future<void> show() {
    throw UnimplementedError('show is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.hide}
  ///Hides the [PlatformInAppBrowser] window. Calling this has no effect if the [PlatformInAppBrowser] was already hidden.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.hide.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
  Future<void> hide() {
    throw UnimplementedError('hide is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.close}
  ///Closes the [PlatformInAppBrowser] window.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.close.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
  Future<void> close() {
    throw UnimplementedError(
        'close is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.isHidden}
  ///Check if the Web View of the [PlatformInAppBrowser] instance is hidden.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.isHidden.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
  Future<bool> isHidden() {
    throw UnimplementedError(
        'isHidden is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.setOptions}
  ///Use [setSettings] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.setOptions.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
  ])
  @Deprecated('Use setSettings instead')
  Future<void> setOptions({required InAppBrowserClassOptions options}) {
    throw UnimplementedError(
        'setOptions is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.getOptions}
  ///Use [getSettings] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.getOptions.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
  ])
  @Deprecated('Use getSettings instead')
  Future<InAppBrowserClassOptions?> getOptions() {
    throw UnimplementedError(
        'getOptions is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.setSettings}
  ///Sets the [PlatformInAppBrowser] settings with the new [settings] and evaluates them.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.setSettings.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
  Future<void> setSettings({required InAppBrowserClassSettings settings}) {
    throw UnimplementedError(
        'setSettings is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.getSettings}
  ///Gets the current [PlatformInAppBrowser] settings. Returns `null` if it wasn't able to get them.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.getSettings.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
  Future<InAppBrowserClassSettings?> getSettings() {
    throw UnimplementedError(
        'getSettings is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.isOpened}
  ///Returns `true` if the [PlatformInAppBrowser] instance is opened, otherwise `false`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.isOpened.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
  bool isOpened() {
    throw UnimplementedError(
        'isOpened is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.dispose}
  ///Disposes the channel and controllers.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.dispose.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
  @override
  @mustCallSuper
  void dispose() {
    eventHandler = null;
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformInAppBrowserClassSupported.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(PlatformInAppBrowserProperty property,
          {TargetPlatform? platform}) =>
      _PlatformInAppBrowserPropertySupported.isPropertySupported(property,
          platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowser.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(PlatformInAppBrowserMethod method,
          {TargetPlatform? platform}) =>
      _PlatformInAppBrowserMethodSupported.isMethodSupported(method,
          platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.isMethodSupported}
  bool isEventMethodSupported(PlatformInAppBrowserEventsMethod method,
          {TargetPlatform? platform}) =>
      PlatformInAppBrowserEvents.isMethodSupported(method, platform: platform);
}

@SupportedPlatforms(platforms: [
  AndroidPlatform(),
  IOSPlatform(),
  MacOSPlatform(),
  WindowsPlatform(),
])
abstract class PlatformInAppBrowserEvents {
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onBrowserCreated}
  ///Event fired when the [PlatformInAppBrowser] is created.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onBrowserCreated.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
  void onBrowserCreated() {}

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onExit}
  ///Event fired when the [PlatformInAppBrowser] window is closed.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onExit.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
  void onExit() {}

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onMainWindowWillClose}
  ///Event fired when the main window is about to close.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onMainWindowWillClose.supported_platforms}
  @SupportedPlatforms(platforms: [
    MacOSPlatform(),
  ])
  void onMainWindowWillClose() {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadStart}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onLoadStart.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebViewClient.onPageStarted',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebViewClient#onPageStarted(android.webkit.WebView,%20java.lang.String,%20android.graphics.Bitmap)',
    ),
    IOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455621-webview',
    ),
    MacOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455621-webview',
    ),
    WindowsPlatform(
      apiName: 'ICoreWebView2.add_NavigationStarting',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationstarting',
    ),
  ])
  void onLoadStart(WebUri? url) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadStop}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onLoadStop.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebViewClient.onPageFinished',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebViewClient#onPageFinished(android.webkit.WebView,%20java.lang.String)',
    ),
    IOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455629-webview',
    ),
    MacOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455629-webview',
    ),
    WindowsPlatform(
      apiName: 'ICoreWebView2.add_NavigationCompleted',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationcompleted',
    ),
  ])
  void onLoadStop(WebUri? url) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadError}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onLoadError.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  @Deprecated("Use onReceivedError instead")
  void onLoadError(Uri? url, int code, String message) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedError}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onReceivedError.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebViewClient.onReceivedError',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedError(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20android.webkit.WebResourceError)',
    ),
    IOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455623-webview',
    ),
    MacOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455623-webview',
    ),
    WindowsPlatform(
      apiName: 'ICoreWebView2.add_NavigationCompleted',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationcompleted',
    ),
  ])
  void onReceivedError(WebResourceRequest request, WebResourceError error) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadHttpError}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onLoadHttpError.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  @Deprecated("Use onReceivedHttpError instead")
  void onLoadHttpError(Uri? url, int statusCode, String description) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedHttpError}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onReceivedHttpError.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName: 'WebViewClient.onReceivedHttpError',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpError(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20android.webkit.WebResourceResponse)',
        available: '23'),
    IOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview',
    ),
    MacOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview',
    ),
    WindowsPlatform(
      apiName: 'ICoreWebView2.add_NavigationCompleted',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationcompleted',
    ),
  ])
  void onReceivedHttpError(
      WebResourceRequest request, WebResourceResponse errorResponse) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onProgressChanged}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onProgressChanged.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebChromeClient.onProgressChanged',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebChromeClient#onProgressChanged(android.webkit.WebView,%20int)',
    ),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
  void onProgressChanged(int progress) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onConsoleMessage}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onConsoleMessage.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebChromeClient.onConsoleMessage',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebChromeClient#onConsoleMessage(android.webkit.ConsoleMessage)',
    ),
    IOSPlatform(
      note: 'This event is implemented using JavaScript.',
    ),
    MacOSPlatform(
      note: 'This event is implemented using JavaScript.',
    ),
    WebPlatform(),
    WindowsPlatform(),
  ])
  void onConsoleMessage(ConsoleMessage consoleMessage) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldOverrideUrlLoading}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.shouldOverrideUrlLoading.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName: 'WebViewClient.shouldOverrideUrlLoading',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#shouldOverrideUrlLoading(android.webkit.WebView,%20java.lang.String)',
        note:
            """There isn't any way to load an URL for a frame that is not the main frame, so if the request is not for the main frame, the navigation is allowed by default.
However, if you want to cancel requests for subframes, you can use the [InAppWebViewSettings.regexToCancelSubFramesLoading] setting
to write a Regular Expression that, if the url request of a subframe matches, then the request of that subframe is canceled.
Instead, the [InAppWebViewSettings.regexToAllowSyncUrlLoading] setting could
be used to allow navigation requests synchronously, as this event is synchronous on native side
and the current plugin implementation will always cancel the current request and load a new request if
this event returns [NavigationActionPolicy.ALLOW] because Flutter method channels work only asynchronously.
Also, this event is not called for POST requests and is not called on the first page load."""),
    IOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455641-webview',
    ),
    MacOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455641-webview',
    ),
    WindowsPlatform(),
  ])
  FutureOr<NavigationActionPolicy?>? shouldOverrideUrlLoading(
      NavigationAction navigationAction) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadResource}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onLoadResource.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      note: 'This event is implemented using JavaScript.',
    ),
    IOSPlatform(
      note: 'This event is implemented using JavaScript.',
    ),
    MacOSPlatform(
      note: 'This event is implemented using JavaScript.',
    ),
  ])
  void onLoadResource(LoadedResource resource) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onScrollChanged}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onScrollChanged.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebView.onScrollChanged',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebView#onScrollChanged(int,%20int,%20int,%20int)',
    ),
    IOSPlatform(
      apiName: 'UIScrollViewDelegate.scrollViewDidScroll',
      apiUrl:
          'https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619392-scrollviewdidscroll',
    ),
    MacOSPlatform(
      note: 'This event is implemented using JavaScript.',
    ),
  ])
  void onScrollChanged(int x, int y) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDownloadStart}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onDownloadStart.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
  ])
  @Deprecated('Use onDownloadStarting instead')
  void onDownloadStart(Uri url) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDownloadStartRequest}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onDownloadStartRequest.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  @Deprecated('Use onDownloadStarting instead')
  void onDownloadStartRequest(DownloadStartRequest downloadStartRequest) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDownloadStarting}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onDownloadStarting.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebView.setDownloadListener',
      apiUrl:
          '(https://developer.android.com/reference/android/webkit/WebView#setDownloadListener(android.webkit.DownloadListener)',
    ),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(
      apiName: 'ICoreWebView2_4.add_DownloadStarting',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_4?view=webview2-1.0.2849.39#add_downloadstarting',
    ),
  ])
  FutureOr<DownloadStartResponse?>? onDownloadStarting(
      DownloadStartRequest downloadStartRequest) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadResourceCustomScheme}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onLoadResourceCustomScheme.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  @Deprecated('Use onLoadResourceWithCustomScheme instead')
  FutureOr<CustomSchemeResponse?>? onLoadResourceCustomScheme(Uri url) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadResourceWithCustomScheme}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onLoadResourceWithCustomScheme.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(
      apiName: 'WKURLSchemeHandler',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkurlschemehandler',
    ),
    MacOSPlatform(
      apiName: 'WKURLSchemeHandler',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkurlschemehandler',
    ),
    WindowsPlatform(),
  ])
  FutureOr<CustomSchemeResponse?>? onLoadResourceWithCustomScheme(
      WebResourceRequest request) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCreateWindow}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onCreateWindow.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName: 'WebChromeClient.onCreateWindow',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onCreateWindow(android.webkit.WebView,%20boolean,%20boolean,%20android.os.Message)',
        note:
            'You need to set [InAppWebViewSettings.supportMultipleWindows] setting to `true`. Also, if the request has been created using JavaScript (`window.open()`), then there are some limitation: check the [NavigationAction] class.'),
    IOSPlatform(
        apiName: 'WKUIDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview',
        note:
            """Setting these initial settings [InAppWebViewSettings.supportZoom], [InAppWebViewSettings.useOnLoadResource], [InAppWebViewSettings.useShouldInterceptAjaxRequest],
[InAppWebViewSettings.useShouldInterceptFetchRequest], [InAppWebViewSettings.applicationNameForUserAgent], [InAppWebViewSettings.javaScriptCanOpenWindowsAutomatically],
[InAppWebViewSettings.javaScriptEnabled], [InAppWebViewSettings.minimumFontSize], [InAppWebViewSettings.preferredContentMode], [InAppWebViewSettings.incognito],
[InAppWebViewSettings.cacheEnabled], [InAppWebViewSettings.mediaPlaybackRequiresUserGesture],
[InAppWebViewSettings.resourceCustomSchemes], [InAppWebViewSettings.sharedCookiesEnabled],
[InAppWebViewSettings.enableViewportScale], [InAppWebViewSettings.allowsAirPlayForMediaPlayback],
[InAppWebViewSettings.allowsPictureInPictureMediaPlayback], [InAppWebViewSettings.isFraudulentWebsiteWarningEnabled],
[InAppWebViewSettings.allowsInlineMediaPlayback], [InAppWebViewSettings.suppressesIncrementalRendering], [InAppWebViewSettings.selectionGranularity],
[InAppWebViewSettings.ignoresViewportScaleLimits], [InAppWebViewSettings.limitsNavigationsToAppBoundDomains],
[InAppWebViewSettings.upgradeKnownHostsToHTTPS],
will have no effect due to a `WKWebView` limitation when creating the new window WebView: it's impossible to return the new `WKWebView`
with a different `WKWebViewConfiguration` instance (see https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview).
So, these options will be inherited from the caller WebView.
Also, note that calling [InAppWebViewController.setSettings] method using the controller of the new created WebView,
it will update also the WebView options of the caller WebView."""),
    MacOSPlatform(
        apiName: 'WKUIDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview',
        note:
            """Setting these initial settings [InAppWebViewSettings.supportZoom], [InAppWebViewSettings.useOnLoadResource], [InAppWebViewSettings.useShouldInterceptAjaxRequest],
[InAppWebViewSettings.useShouldInterceptFetchRequest], [InAppWebViewSettings.applicationNameForUserAgent], [InAppWebViewSettings.javaScriptCanOpenWindowsAutomatically],
[InAppWebViewSettings.javaScriptEnabled], [InAppWebViewSettings.minimumFontSize], [InAppWebViewSettings.preferredContentMode], [InAppWebViewSettings.incognito],
[InAppWebViewSettings.cacheEnabled], [InAppWebViewSettings.mediaPlaybackRequiresUserGesture],
[InAppWebViewSettings.resourceCustomSchemes], [InAppWebViewSettings.sharedCookiesEnabled],
[InAppWebViewSettings.enableViewportScale], [InAppWebViewSettings.allowsAirPlayForMediaPlayback],
[InAppWebViewSettings.allowsPictureInPictureMediaPlayback], [InAppWebViewSettings.isFraudulentWebsiteWarningEnabled],
[InAppWebViewSettings.allowsInlineMediaPlayback], [InAppWebViewSettings.suppressesIncrementalRendering], [InAppWebViewSettings.selectionGranularity],
[InAppWebViewSettings.ignoresViewportScaleLimits], [InAppWebViewSettings.limitsNavigationsToAppBoundDomains],
[InAppWebViewSettings.upgradeKnownHostsToHTTPS],
will have no effect due to a `WKWebView` limitation when creating the new window WebView: it's impossible to return the new `WKWebView`
with a different `WKWebViewConfiguration` instance (see https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview).
So, these options will be inherited from the caller WebView.
Also, note that calling [InAppWebViewController.setSettings] method using the controller of the new created WebView,
it will update also the WebView options of the caller WebView."""),
    WindowsPlatform(
      apiName: 'ICoreWebView2.add_NewWindowRequested',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_newwindowrequested',
    ),
  ])
  FutureOr<bool?>? onCreateWindow(CreateWindowAction createWindowAction) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCloseWindow}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onCloseWindow.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebChromeClient.onCloseWindow',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebChromeClient#onCloseWindow(android.webkit.WebView)',
    ),
    IOSPlatform(
      apiName: 'WKUIDelegate.webViewDidClose',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkuidelegate/1537390-webviewdidclose',
    ),
    MacOSPlatform(
      apiName: 'WKUIDelegate.webViewDidClose',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkuidelegate/1537390-webviewdidclose',
    ),
    WebPlatform(),
    WindowsPlatform(
      apiName: 'ICoreWebView2.add_WindowCloseRequested',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_windowcloserequested',
    ),
  ])
  void onCloseWindow() {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWindowFocus}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onWindowFocus.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  void onWindowFocus() {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWindowBlur}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onWindowBlur.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  void onWindowBlur() {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsAlert}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onJsAlert.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebChromeClient.onJsAlert',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebChromeClient#onJsAlert(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)',
    ),
    IOSPlatform(
      apiName: 'WKUIDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkuidelegate/1537406-webview',
    ),
    MacOSPlatform(
      apiName: 'WKUIDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkuidelegate/1537406-webview',
    ),
  ])
  FutureOr<JsAlertResponse?>? onJsAlert(JsAlertRequest jsAlertRequest) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsConfirm}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onJsConfirm.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebChromeClient.onJsConfirm',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebChromeClient#onJsConfirm(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)',
    ),
    IOSPlatform(
      apiName: 'WKUIDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkuidelegate/1536489-webview',
    ),
    MacOSPlatform(
      apiName: 'WKUIDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkuidelegate/1536489-webview',
    ),
  ])
  FutureOr<JsConfirmResponse?>? onJsConfirm(JsConfirmRequest jsConfirmRequest) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsPrompt}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onJsPrompt.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebChromeClient.onJsPrompt',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebChromeClient#onJsPrompt(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String,%20android.webkit.JsPromptResult)',
    ),
    IOSPlatform(
      apiName: 'WKUIDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkuidelegate/1538086-webview',
    ),
    MacOSPlatform(
      apiName: 'WKUIDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkuidelegate/1538086-webview',
    ),
  ])
  FutureOr<JsPromptResponse?>? onJsPrompt(JsPromptRequest jsPromptRequest) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedHttpAuthRequest}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onReceivedHttpAuthRequest.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebViewClient.onReceivedHttpAuthRequest',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpAuthRequest(android.webkit.WebView,%20android.webkit.HttpAuthHandler,%20java.lang.String,%20java.lang.String)',
    ),
    IOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
    ),
    MacOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
    ),
    WindowsPlatform(
      apiName: 'ICoreWebView2_10.add_BasicAuthenticationRequested',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_10?view=webview2-1.0.2849.39#add_basicauthenticationrequested',
    ),
  ])
  FutureOr<HttpAuthResponse?>? onReceivedHttpAuthRequest(
      HttpAuthenticationChallenge challenge) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedServerTrustAuthRequest}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onReceivedServerTrustAuthRequest.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebViewClient.onReceivedSslError',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedSslError(android.webkit.WebView,%20android.webkit.SslErrorHandler,%20android.net.http.SslError)',
    ),
    IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
        note:
            """To override the certificate verification logic, you have to provide ATS (App Transport Security) exceptions in your iOS/macOS `Info.plist`.
See `NSAppTransportSecurity` in the [Information Property List Key Reference](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW1) for details."""),
    MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
        note:
            """To override the certificate verification logic, you have to provide ATS (App Transport Security) exceptions in your iOS/macOS `Info.plist`.
See `NSAppTransportSecurity` in the [Information Property List Key Reference](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW1) for details."""),
    WindowsPlatform(
      apiName: 'ICoreWebView2_14.add_ServerCertificateErrorDetected',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_14?view=webview2-1.0.2792.45#add_servercertificateerrordetected',
    ),
  ])
  FutureOr<ServerTrustAuthResponse?>? onReceivedServerTrustAuthRequest(
      ServerTrustChallenge challenge) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedClientCertRequest}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onReceivedClientCertRequest.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebViewClient.onReceivedClientCertRequest',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedClientCertRequest(android.webkit.WebView,%20android.webkit.ClientCertRequest)',
    ),
    IOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
    ),
    MacOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
    ),
    WindowsPlatform(
      apiName: 'ICoreWebView2_5.add_ClientCertificateRequested',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_5?view=webview2-1.0.2849.39#add_clientcertificaterequested',
    ),
  ])
  FutureOr<ClientCertResponse?>? onReceivedClientCertRequest(
      ClientCertChallenge challenge) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onFindResultReceived}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onFindResultReceived.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  @Deprecated('Use FindInteractionController.onFindResultReceived instead')
  void onFindResultReceived(
      int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptAjaxRequest}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.shouldInterceptAjaxRequest.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptAjaxRequest] setting documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("flutterInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure."""),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  FutureOr<AjaxRequest?>? shouldInterceptAjaxRequest(AjaxRequest ajaxRequest) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onAjaxReadyStateChange}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onAjaxReadyStateChange.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptAjaxRequest] and [InAppWebViewSettings.useOnAjaxReadyStateChange] settings documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("flutterInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure."""),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  FutureOr<AjaxRequestAction?>? onAjaxReadyStateChange(
      AjaxRequest ajaxRequest) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onAjaxProgress}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onAjaxProgress.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptAjaxRequest] and [InAppWebViewSettings.useOnAjaxProgress] settings documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("flutterInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure."""),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  FutureOr<AjaxRequestAction?>? onAjaxProgress(AjaxRequest ajaxRequest) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptFetchRequest}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.shouldInterceptFetchRequest.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptFetchRequest] setting documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("flutterInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure."""),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  FutureOr<FetchRequest?>? shouldInterceptFetchRequest(
      FetchRequest fetchRequest) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onUpdateVisitedHistory}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onUpdateVisitedHistory.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebViewClient.doUpdateVisitedHistory',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebViewClient#doUpdateVisitedHistory(android.webkit.WebView,%20java.lang.String,%20boolean)',
    ),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(
      apiName: 'ICoreWebView2.add_HistoryChanged',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_historychanged',
    ),
  ])
  void onUpdateVisitedHistory(WebUri? url,
      @SupportedPlatforms(platforms: [AndroidPlatform()]) bool? isReload) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPrint}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onPrint.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
  ])
  @Deprecated("Use onPrintRequest instead")
  void onPrint(Uri? url) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPrintRequest}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onPrintRequest.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'View.scrollBy',
      apiUrl:
          'https://developer.android.com/reference/android/view/View#scrollBy(int,%20int)',
    ),
    IOSPlatform(
      apiName: 'UIScrollView.setContentOffset',
      apiUrl:
          'https://developer.apple.com/documentation/uikit/uiscrollview/1619400-setcontentoffset',
    ),
    MacOSPlatform(
      note: 'This method is implemented using JavaScript.',
    ),
  ])
  FutureOr<bool?>? onPrintRequest(
      WebUri? url, PlatformPrintJobController? printJobController) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLongPressHitTestResult}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onLongPressHitTestResult.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'View.setOnLongClickListener',
      apiUrl:
          'https://developer.android.com/reference/android/view/View#setOnLongClickListener(android.view.View.OnLongClickListener)',
    ),
    IOSPlatform(
      apiName: 'UILongPressGestureRecognizer',
      apiUrl:
          'https://developer.apple.com/documentation/uikit/uilongpressgesturerecognizer',
    ),
  ])
  void onLongPressHitTestResult(InAppWebViewHitTestResult hitTestResult) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onEnterFullscreen}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onEnterFullscreen.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebChromeClient.onShowCustomView',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebChromeClient#onShowCustomView(android.view.View,%20android.webkit.WebChromeClient.CustomViewCallback)',
    ),
    IOSPlatform(
      apiName: 'UIWindow.didBecomeVisibleNotification',
      apiUrl:
          'https://developer.apple.com/documentation/uikit/uiwindow/1621621-didbecomevisiblenotification',
    ),
    MacOSPlatform(
      apiName: 'NSWindow.didEnterFullScreenNotification',
      apiUrl:
          'https://developer.apple.com/documentation/appkit/nswindow/1419651-didenterfullscreennotification',
    ),
  ])
  void onEnterFullscreen() {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onExitFullscreen}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onExitFullscreen.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebChromeClient.onHideCustomView',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebChromeClient#onHideCustomView()',
    ),
    IOSPlatform(
      apiName: 'UIWindow.didBecomeHiddenNotification',
      apiUrl:
          'https://developer.apple.com/documentation/uikit/uiwindow/1621617-didbecomehiddennotification',
    ),
    MacOSPlatform(
      apiName: 'NSWindow.didExitFullScreenNotification',
      apiUrl:
          'https://developer.apple.com/documentation/appkit/nswindow/1419177-didexitfullscreennotification',
    ),
  ])
  void onExitFullscreen() {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPageCommitVisible}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onPageCommitVisible.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebViewClient.onPageCommitVisible',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebViewClient#onPageCommitVisible(android.webkit.WebView,%20java.lang.String)',
    ),
    IOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455635-webview',
    ),
    MacOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455635-webview',
    ),
  ])
  void onPageCommitVisible(WebUri? url) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onTitleChanged}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onTitleChanged.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebChromeClient.onReceivedTitle',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTitle(android.webkit.WebView,%20java.lang.String)',
    ),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(
      apiName: 'ICoreWebView2.add_DocumentTitleChanged',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_documenttitlechanged',
    ),
  ])
  void onTitleChanged(String? title) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onOverScrolled}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onOverScrolled.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebView.onOverScrolled',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebView#onOverScrolled(int,%20int,%20boolean,%20boolean)',
    ),
    IOSPlatform(),
  ])
  void onOverScrolled(int x, int y, bool clampedX, bool clampedY) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onZoomScaleChanged}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onZoomScaleChanged.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebViewClient.onScaleChanged',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebViewClient#onScaleChanged(android.webkit.WebView,%20float,%20float)',
    ),
    IOSPlatform(
      apiName: 'UIScrollViewDelegate.scrollViewDidZoom',
      apiUrl:
          'https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619409-scrollviewdidzoom',
    ),
    WindowsPlatform(
      apiName: 'ICoreWebView2Controller.add_ZoomFactorChanged',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controller?view=webview2-1.0.2849.39#add_zoomfactorchanged',
    ),
  ])
  void onZoomScaleChanged(double oldScale, double newScale) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnSafeBrowsingHit}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.androidOnSafeBrowsingHit.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  @Deprecated("Use onSafeBrowsingHit instead")
  FutureOr<SafeBrowsingResponse?>? androidOnSafeBrowsingHit(
      Uri url, SafeBrowsingThreat? threatType) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onSafeBrowsingHit}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onSafeBrowsingHit.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName: 'WebViewClient.onSafeBrowsingHit',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onSafeBrowsingHit(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20int,%20android.webkit.SafeBrowsingResponse)',
        available: '27'),
  ])
  FutureOr<SafeBrowsingResponse?>? onSafeBrowsingHit(
      WebUri url, SafeBrowsingThreat? threatType) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnPermissionRequest}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.androidOnPermissionRequest.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  @Deprecated("Use onPermissionRequest instead")
  FutureOr<PermissionRequestResponse?>? androidOnPermissionRequest(
      String origin, List<String> resources) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPermissionRequest}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onPermissionRequest.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName: 'WebChromeClient.onPermissionRequest',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequest(android.webkit.PermissionRequest)',
        available: '21'),
    IOSPlatform(
      available: '15.0',
      note:
          'The default [PermissionResponse.action] is [PermissionResponseAction.PROMPT].',
    ),
    MacOSPlatform(
      available: '12.0',
      note:
          'The default [PermissionResponse.action] is [PermissionResponseAction.PROMPT].',
    ),
    WindowsPlatform(
      apiName: 'ICoreWebView2.add_PermissionRequested',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_permissionrequested',
    ),
  ])
  FutureOr<PermissionResponse?>? onPermissionRequest(
      PermissionRequest permissionRequest) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnGeolocationPermissionsShowPrompt}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.androidOnGeolocationPermissionsShowPrompt.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  @Deprecated("Use onGeolocationPermissionsShowPrompt instead")
  FutureOr<GeolocationPermissionShowPromptResponse?>?
      androidOnGeolocationPermissionsShowPrompt(String origin) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onGeolocationPermissionsShowPrompt}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onGeolocationPermissionsShowPrompt.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebChromeClient.onGeolocationPermissionsShowPrompt',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsShowPrompt(java.lang.String,%20android.webkit.GeolocationPermissions.Callback)',
    ),
  ])
  FutureOr<GeolocationPermissionShowPromptResponse?>?
      onGeolocationPermissionsShowPrompt(String origin) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnGeolocationPermissionsHidePrompt}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.androidOnGeolocationPermissionsHidePrompt.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  @Deprecated("Use onGeolocationPermissionsHidePrompt instead")
  void androidOnGeolocationPermissionsHidePrompt() {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onGeolocationPermissionsHidePrompt}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onGeolocationPermissionsHidePrompt.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebChromeClient.onGeolocationPermissionsHidePrompt',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsHidePrompt()',
    ),
  ])
  void onGeolocationPermissionsHidePrompt() {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidShouldInterceptRequest}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.androidShouldInterceptRequest.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  @Deprecated("Use shouldInterceptRequest instead")
  FutureOr<WebResourceResponse?>? androidShouldInterceptRequest(
      WebResourceRequest request) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptRequest}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.shouldInterceptRequest.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebViewClient.shouldInterceptRequest',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebViewClient#shouldInterceptRequest(android.webkit.WebView,%20android.webkit.WebResourceRequest)',
    ),
    WindowsPlatform(
      apiName: 'ICoreWebView2.add_WebResourceRequested',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2478.35#add_webresourcerequested',
    ),
  ])
  FutureOr<WebResourceResponse?>? shouldInterceptRequest(
      WebResourceRequest request) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnRenderProcessUnresponsive}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.androidOnRenderProcessUnresponsive.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  @Deprecated("Use onRenderProcessUnresponsive instead")
  FutureOr<WebViewRenderProcessAction?>? androidOnRenderProcessUnresponsive(
      Uri? url) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRenderProcessUnresponsive}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onRenderProcessUnresponsive.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName: 'WebViewRenderProcessClient.onRenderProcessUnresponsive',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessUnresponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)',
        available: '29'),
    WindowsPlatform(
      apiName: 'ICoreWebView2.add_ProcessFailed',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed',
    ),
  ])
  FutureOr<WebViewRenderProcessAction?>? onRenderProcessUnresponsive(
      WebUri? url) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnRenderProcessResponsive}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.androidOnRenderProcessResponsive.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  @Deprecated("Use onRenderProcessResponsive instead")
  FutureOr<WebViewRenderProcessAction?>? androidOnRenderProcessResponsive(
      Uri? url) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRenderProcessResponsive}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onRenderProcessResponsive.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName: 'WebViewRenderProcessClient.onRenderProcessResponsive',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessResponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)',
        available: '29'),
  ])
  FutureOr<WebViewRenderProcessAction?>? onRenderProcessResponsive(
      WebUri? url) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnRenderProcessGone}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.androidOnRenderProcessGone.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  @Deprecated("Use onRenderProcessGone instead")
  void androidOnRenderProcessGone(RenderProcessGoneDetail detail) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRenderProcessGone}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onRenderProcessGone.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName: 'WebViewClient.onRenderProcessGone',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onRenderProcessGone(android.webkit.WebView,%20android.webkit.RenderProcessGoneDetail)',
        available: '26'),
    WindowsPlatform(
      apiName: 'ICoreWebView2.add_ProcessFailed',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed',
    ),
  ])
  void onRenderProcessGone(RenderProcessGoneDetail detail) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnFormResubmission}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.androidOnFormResubmission.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  @Deprecated('Use onFormResubmission instead')
  FutureOr<FormResubmissionAction?>? androidOnFormResubmission(Uri? url) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onFormResubmission}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onFormResubmission.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebViewClient.onFormResubmission',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebViewClient#onFormResubmission(android.webkit.WebView,%20android.os.Message,%20android.os.Message)',
    ),
  ])
  FutureOr<FormResubmissionAction?>? onFormResubmission(WebUri? url) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnScaleChanged}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.androidOnScaleChanged.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  @Deprecated('Use onZoomScaleChanged instead')
  void androidOnScaleChanged(double oldScale, double newScale) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnReceivedIcon}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.androidOnReceivedIcon.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  @Deprecated('Use onReceivedIcon instead')
  void androidOnReceivedIcon(Uint8List icon) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedIcon}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onReceivedIcon.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebChromeClient.onReceivedIcon',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedIcon(android.webkit.WebView,%20android.graphics.Bitmap)',
    ),
  ])
  void onReceivedIcon(Uint8List icon) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnReceivedTouchIconUrl}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.androidOnReceivedTouchIconUrl.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  @Deprecated('Use onReceivedTouchIconUrl instead')
  void androidOnReceivedTouchIconUrl(Uri url, bool precomposed) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnReceivedTouchIconUrl}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.androidOnReceivedTouchIconUrl.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebChromeClient.onReceivedTouchIconUrl',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTouchIconUrl(android.webkit.WebView,%20java.lang.String,%20boolean)',
    ),
  ])
  void onReceivedTouchIconUrl(WebUri url, bool precomposed) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnJsBeforeUnload}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.androidOnJsBeforeUnload.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  @Deprecated('Use onJsBeforeUnload instead')
  FutureOr<JsBeforeUnloadResponse?>? androidOnJsBeforeUnload(
      JsBeforeUnloadRequest jsBeforeUnloadRequest) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsBeforeUnload}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onJsBeforeUnload.supported_platforms}
  FutureOr<JsBeforeUnloadResponse?>? onJsBeforeUnload(
      JsBeforeUnloadRequest jsBeforeUnloadRequest) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnReceivedLoginRequest}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.androidOnReceivedLoginRequest.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  @Deprecated('Use onReceivedLoginRequest instead')
  void androidOnReceivedLoginRequest(LoginRequest loginRequest) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedLoginRequest}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onReceivedLoginRequest.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebViewClient.onReceivedLoginRequest',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedLoginRequest(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String)',
    ),
  ])
  void onReceivedLoginRequest(LoginRequest loginRequest) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPermissionRequestCanceled}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onPermissionRequestCanceled.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName: 'WebChromeClient.onPermissionRequestCanceled',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequestCanceled(android.webkit.PermissionRequest)',
        available: '21'),
  ])
  void onPermissionRequestCanceled(PermissionRequest permissionRequest) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRequestFocus}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onRequestFocus.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebChromeClient.onRequestFocus',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebChromeClient#onRequestFocus(android.webkit.WebView)',
    ),
  ])
  void onRequestFocus() {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.iosOnWebContentProcessDidTerminate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.iosOnWebContentProcessDidTerminate.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(),
  ])
  @Deprecated('Use onWebContentProcessDidTerminate instead')
  void iosOnWebContentProcessDidTerminate() {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWebContentProcessDidTerminate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onWebContentProcessDidTerminate.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(
      apiName: 'WKNavigationDelegate.webViewWebContentProcessDidTerminate',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455639-webviewwebcontentprocessdidtermi',
    ),
    MacOSPlatform(
      apiName: 'WKNavigationDelegate.webViewWebContentProcessDidTerminate',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455639-webviewwebcontentprocessdidtermi',
    ),
    WindowsPlatform(
      apiName: 'ICoreWebView2.add_ProcessFailed',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed',
    ),
  ])
  void onWebContentProcessDidTerminate() {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.iosOnDidReceiveServerRedirectForProvisionalNavigation}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.iosOnDidReceiveServerRedirectForProvisionalNavigation.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(),
  ])
  @Deprecated('Use onDidReceiveServerRedirectForProvisionalNavigation instead')
  void iosOnDidReceiveServerRedirectForProvisionalNavigation() {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDidReceiveServerRedirectForProvisionalNavigation}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onDidReceiveServerRedirectForProvisionalNavigation.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455627-webview',
    ),
    MacOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455627-webview',
    ),
  ])
  void onDidReceiveServerRedirectForProvisionalNavigation() {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.iosOnNavigationResponse}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.iosOnNavigationResponse.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(),
  ])
  @Deprecated('Use onNavigationResponse instead')
  FutureOr<IOSNavigationResponseAction?>? iosOnNavigationResponse(
      IOSWKNavigationResponse navigationResponse) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onNavigationResponse}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onNavigationResponse.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview',
    ),
    MacOSPlatform(
      apiName: 'WKNavigationDelegate.webView',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview',
    ),
  ])
  FutureOr<NavigationResponseAction?>? onNavigationResponse(
      NavigationResponse navigationResponse) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.iosShouldAllowDeprecatedTLS}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.iosShouldAllowDeprecatedTLS.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(),
  ])
  @Deprecated('Use shouldAllowDeprecatedTLS instead')
  FutureOr<IOSShouldAllowDeprecatedTLSAction?>? iosShouldAllowDeprecatedTLS(
      URLAuthenticationChallenge challenge) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldAllowDeprecatedTLS}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.shouldAllowDeprecatedTLS.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/3601237-webview',
        available: '14.0'),
    MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/3601237-webview',
        available: '11.0'),
  ])
  FutureOr<ShouldAllowDeprecatedTLSAction?>? shouldAllowDeprecatedTLS(
      URLAuthenticationChallenge challenge) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCameraCaptureStateChanged}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onCameraCaptureStateChanged.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(
      available: '15.0',
    ),
    MacOSPlatform(
      available: '12.0',
    ),
  ])
  void onCameraCaptureStateChanged(
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  ) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onMicrophoneCaptureStateChanged}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onMicrophoneCaptureStateChanged.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(
      available: '15.0',
    ),
    MacOSPlatform(
      available: '12.0',
    ),
  ])
  void onMicrophoneCaptureStateChanged(
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  ) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onContentSizeChanged}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onContentSizeChanged.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(),
  ])
  void onContentSizeChanged(Size oldContentSize, Size newContentSize) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onProcessFailed}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onProcessFailed.supported_platforms}
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
      apiName: 'ICoreWebView2.add_ProcessFailed',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed',
    ),
  ])
  void onProcessFailed(ProcessFailedDetail detail) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onAcceleratorKeyPressed}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onAcceleratorKeyPressed.supported_platforms}
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
      apiName: 'ICoreWebView2Controller.add_AcceleratorKeyPressed',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controller?view=webview2-1.0.2849.39#add_acceleratorkeypressed',
    ),
  ])
  void onAcceleratorKeyPressed(AcceleratorKeyPressedDetail detail) {}

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onShowFileChooser}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.onShowFileChooser.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'WebChromeClient.onShowFileChooser',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebChromeClient#onShowFileChooser(android.webkit.WebView,%20android.webkit.ValueCallback%3Candroid.net.Uri[]%3E,%20android.webkit.WebChromeClient.FileChooserParams)',
    ),
  ])
  FutureOr<ShowFileChooserResponse?> onShowFileChooser(
      ShowFileChooserRequest request) {
    return null;
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isMethodSupported(PlatformInAppBrowserEventsMethod method,
          {TargetPlatform? platform}) =>
      _PlatformInAppBrowserEventsMethodSupported.isMethodSupported(method,
          platform: platform);
}
