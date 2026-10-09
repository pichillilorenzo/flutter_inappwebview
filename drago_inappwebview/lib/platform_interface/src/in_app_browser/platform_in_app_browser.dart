import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';
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

///{@template drago_inappwebview.PlatformInAppBrowserCreationParams}
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

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.contextMenu}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.contextMenu.supported_platforms}
  final ContextMenu? contextMenu;

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.pullToRefreshController}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.pullToRefreshController.supported_platforms}
  final PlatformPullToRefreshController? pullToRefreshController;

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.findInteractionController}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.findInteractionController.supported_platforms}
  final PlatformFindInteractionController? findInteractionController;

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.initialUserScripts}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.initialUserScripts.supported_platforms}
  final UnmodifiableListView<UserScript>? initialUserScripts;

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.windowId}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.windowId.supported_platforms}
  final int? windowId;

  ///{@template drago_inappwebview.PlatformInAppBrowserCreationParams.webViewEnvironment}
  ///Used to create the [PlatformInAppBrowser] using the specified environment.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.webViewEnvironment.supported_platforms}
  final PlatformWebViewEnvironment? webViewEnvironment;
}

///{@template drago_inappwebview.PlatformInAppBrowser}
///This class represents a native WebView displayed on top of the Flutter App,
///so it's not integrated into the Flutter widget tree.
///It uses the native WebView of the platform.
///The [webViewController] field can be used to access the [PlatformInAppWebViewController] API.
///{@endtemplate}
///
///{@macro drago_inappwebview.PlatformInAppBrowser.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
    LinuxPlatform(
      apiName: 'GtkWindow + WPE WebKit',
      apiUrl:
          'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.WebView.html',
    ),
  ],
)
abstract class PlatformInAppBrowser extends PlatformInterface
    implements Disposable {
  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  /// Event handler object that handles the [PlatformInAppBrowser] events.
  PlatformInAppBrowserEvents? eventHandler;

  ///{@template drago_inappwebview.PlatformInAppBrowser.id}
  ///View ID used internally.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.id.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  String get id {
    throw UnimplementedError('id is not implemented on the current platform');
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.contextMenu}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.contextMenu.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  ContextMenu? get contextMenu => params.contextMenu;

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.pullToRefreshController}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.pullToRefreshController.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  PlatformPullToRefreshController? get pullToRefreshController =>
      params.pullToRefreshController;

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.findInteractionController}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.findInteractionController.supported_platforms}
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  PlatformFindInteractionController? get findInteractionController =>
      params.findInteractionController;

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.initialUserScripts}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.initialUserScripts.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        note:
            """This property will be ignored if the [PlatformWebViewCreationParams.windowId] has been set.
There isn't any way to add/remove user scripts specific to iOS window WebViews.
This is a limitation of the native WebKit APIs.""",
      ),
      MacOSPlatform(
        note:
            """This property will be ignored if the [PlatformWebViewCreationParams.windowId] has been set.
There isn't any way to add/remove user scripts specific to iOS window WebViews.
This is a limitation of the native WebKit APIs.""",
      ),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  UnmodifiableListView<UserScript>? get initialUserScripts =>
      params.initialUserScripts;

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.windowId}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.windowId.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  int? get windowId => params.windowId;

  ///{@macro drago_inappwebview.PlatformInAppBrowserCreationParams.webViewEnvironment}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.webViewEnvironment.supported_platforms}
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  PlatformWebViewEnvironment? get webViewEnvironment =>
      params.webViewEnvironment;

  ///{@template drago_inappwebview.PlatformInAppBrowser.webViewController}
  ///WebView Controller that can be used to access the [PlatformInAppWebViewController] API.
  ///When [onExit] is fired, this will be `null` and cannot be used anymore.
  ///{@endtemplate}
  PlatformInAppWebViewController? get webViewController {
    throw UnimplementedError(
      'webViewController is not implemented on the current platform',
    );
  }

  /// Creates a new [PlatformInAppBrowser]
  factory PlatformInAppBrowser(PlatformInAppBrowserCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `drago_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInAppBrowser inAppBrowser = InAppWebViewPlatform.instance!
        .createPlatformInAppBrowser(params);
    PlatformInterface.verify(inAppBrowser, _token);
    return inAppBrowser;
  }

  /// Creates a new [PlatformInAppBrowser] to access static methods.
  factory PlatformInAppBrowser.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `drago_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInAppBrowser inAppBrowserStatic = InAppWebViewPlatform
        .instance!
        .createPlatformInAppBrowserStatic();
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

  ///{@template drago_inappwebview.PlatformInAppBrowser.openUrlRequest}
  ///Opens the [PlatformInAppBrowser] instance with an [urlRequest].
  ///
  ///[urlRequest]: The [urlRequest] to load.
  ///
  ///[options]: Options for the [PlatformInAppBrowser].
  ///
  ///[settings]: Settings for the [PlatformInAppBrowser].
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.openUrlRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> openUrlRequest({
    required URLRequest urlRequest,
    // ignore: deprecated_member_use_from_same_package
    @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
    InAppBrowserClassSettings? settings,
  }) {
    throw UnimplementedError(
      'openUrlRequest is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.openFile}
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
  ///{@macro drago_inappwebview.PlatformInAppBrowser.openFile.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> openFile({
    required String assetFilePath,
    // ignore: deprecated_member_use_from_same_package
    @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
    InAppBrowserClassSettings? settings,
  }) {
    throw UnimplementedError(
      'openFile is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.openData}
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
  ///{@macro drago_inappwebview.PlatformInAppBrowser.openData.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> openData({
    required String data,
    String mimeType = "text/html",
    String encoding = "utf8",
    WebUri? baseUrl,
    @Deprecated("Use historyUrl instead") Uri? androidHistoryUrl,
    WebUri? historyUrl,
    // ignore: deprecated_member_use_from_same_package
    @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
    InAppBrowserClassSettings? settings,
  }) {
    throw UnimplementedError(
      'openData is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.openWithSystemBrowser}
  ///This is a static method that opens an [url] in the system browser.
  ///You wont be able to use the [PlatformInAppBrowser] events and methods here.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.openWithSystemBrowser.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> openWithSystemBrowser({required WebUri url}) {
    throw UnimplementedError(
      'openWithSystemBrowser is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.addMenuItem}
  ///Adds a [InAppBrowserMenuItem] to the menu.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.addMenuItem.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(available: '14.0'),
      MacOSPlatform(available: '10.15'),
    ],
  )
  void addMenuItem(InAppBrowserMenuItem menuItem) {
    throw UnimplementedError(
      'addMenuItem is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.addMenuItems}
  ///Adds a list of [InAppBrowserMenuItem] to the menu.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.addMenuItems.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(available: '14.0'),
      MacOSPlatform(available: '10.15'),
    ],
  )
  void addMenuItems(List<InAppBrowserMenuItem> menuItems) {
    throw UnimplementedError(
      'addMenuItems is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.removeMenuItem}
  ///Removes the [menuItem] from the list.
  ///Returns `true` if it was in the list, `false` otherwise.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.removeMenuItem.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(available: '14.0'),
      MacOSPlatform(available: '10.15'),
    ],
  )
  bool removeMenuItem(InAppBrowserMenuItem menuItem) {
    throw UnimplementedError(
      'removeMenuItem is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.removeMenuItems}
  ///Removes a list of [menuItems] from the list.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.removeMenuItems.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(available: '14.0'),
      MacOSPlatform(available: '10.15'),
    ],
  )
  void removeMenuItems(List<InAppBrowserMenuItem> menuItems) {
    throw UnimplementedError(
      'removeMenuItems is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.removeAllMenuItem}
  ///Removes all the menu items from the list.
  ///If the browser is already open,
  ///it will take effect the next time it is opened.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.removeAllMenuItem.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(available: '14.0'),
      MacOSPlatform(available: '10.15'),
    ],
  )
  void removeAllMenuItem() {
    throw UnimplementedError(
      'removeAllMenuItem is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.hasMenuItem}
  ///Returns `true` if the [menuItem] has been already added, otherwise `false`.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.hasMenuItem.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(available: '14.0'),
      MacOSPlatform(available: '10.15'),
    ],
  )
  bool hasMenuItem(InAppBrowserMenuItem menuItem) {
    throw UnimplementedError(
      'hasMenuItem is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.show}
  ///Displays a [PlatformInAppBrowser] window that was opened hidden. Calling this has no effect if the [PlatformInAppBrowser] was already visible.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.show.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> show() {
    throw UnimplementedError('show is not implemented on the current platform');
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.hide}
  ///Hides the [PlatformInAppBrowser] window. Calling this has no effect if the [PlatformInAppBrowser] was already hidden.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.hide.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> hide() {
    throw UnimplementedError('hide is not implemented on the current platform');
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.close}
  ///Closes the [PlatformInAppBrowser] window.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.close.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> close() {
    throw UnimplementedError(
      'close is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.isHidden}
  ///Check if the Web View of the [PlatformInAppBrowser] instance is hidden.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.isHidden.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<bool> isHidden() {
    throw UnimplementedError(
      'isHidden is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.setOptions}
  ///Use [setSettings] instead.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.setOptions.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  @Deprecated('Use setSettings instead')
  Future<void> setOptions({required InAppBrowserClassOptions options}) {
    throw UnimplementedError(
      'setOptions is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.getOptions}
  ///Use [getSettings] instead.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.getOptions.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  @Deprecated('Use getSettings instead')
  Future<InAppBrowserClassOptions?> getOptions() {
    throw UnimplementedError(
      'getOptions is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.setSettings}
  ///Sets the [PlatformInAppBrowser] settings with the new [settings] and evaluates them.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.setSettings.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> setSettings({required InAppBrowserClassSettings settings}) {
    throw UnimplementedError(
      'setSettings is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.getSettings}
  ///Gets the current [PlatformInAppBrowser] settings. Returns `null` if it wasn't able to get them.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.getSettings.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<InAppBrowserClassSettings?> getSettings() {
    throw UnimplementedError(
      'getSettings is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.isOpened}
  ///Returns `true` if the [PlatformInAppBrowser] instance is opened, otherwise `false`.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.isOpened.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  bool isOpened() {
    throw UnimplementedError(
      'isOpened is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.dispose}
  ///Disposes the channel and controllers.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowser.dispose.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  @override
  @mustCallSuper
  void dispose() {
    eventHandler = null;
  }

  ///{@template drago_inappwebview.PlatformInAppBrowser.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformInAppBrowserClassSupported.isClassSupported(platform: platform);

  ///{@template drago_inappwebview.PlatformInAppBrowser.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformInAppBrowserProperty property, {
    TargetPlatform? platform,
  }) => _PlatformInAppBrowserPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );

  ///{@template drago_inappwebview.PlatformInAppBrowser.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformInAppBrowserMethod method, {
    TargetPlatform? platform,
  }) => _PlatformInAppBrowserMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );

  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.isMethodSupported}
  bool isEventMethodSupported(
    PlatformInAppBrowserEventsMethod method, {
    TargetPlatform? platform,
  }) =>
      PlatformInAppBrowserEvents.isMethodSupported(method, platform: platform);
}

@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
    LinuxPlatform(),
  ],
)
abstract class PlatformInAppBrowserEvents {
  ///{@template drago_inappwebview.PlatformInAppBrowserEvents.onBrowserCreated}
  ///Event fired when the [PlatformInAppBrowser] is created.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onBrowserCreated.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  void onBrowserCreated() {}

  ///{@template drago_inappwebview.PlatformInAppBrowserEvents.onExit}
  ///Event fired when the [PlatformInAppBrowser] window is closed.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onExit.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  void onExit() {}

  ///{@template drago_inappwebview.PlatformInAppBrowserEvents.onMainWindowWillClose}
  ///Event fired when the main window is about to close.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onMainWindowWillClose.supported_platforms}
  @SupportedPlatforms(platforms: [MacOSPlatform()])
  void onMainWindowWillClose() {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onLoadStart}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onLoadStart.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  void onLoadStart(WebUri? url) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onLoadStop}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onLoadStop.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  void onLoadStop(WebUri? url) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onLoadError}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onLoadError.supported_platforms}
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  @Deprecated("Use onReceivedError instead")
  void onLoadError(Uri? url, int code, String message) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onReceivedError}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onReceivedError.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  void onReceivedError(WebResourceRequest request, WebResourceError error) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onLoadHttpError}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onLoadHttpError.supported_platforms}
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  @Deprecated("Use onReceivedHttpError instead")
  void onLoadHttpError(Uri? url, int statusCode, String description) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onReceivedHttpError}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onReceivedHttpError.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onReceivedHttpError',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpError(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20android.webkit.WebResourceResponse)',
        available: '23',
      ),
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
    ],
  )
  void onReceivedHttpError(
    WebResourceRequest request,
    WebResourceResponse errorResponse,
  ) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onProgressChanged}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onProgressChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onProgressChanged',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onProgressChanged(android.webkit.WebView,%20int)',
      ),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  void onProgressChanged(int progress) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onConsoleMessage}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onConsoleMessage.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onConsoleMessage',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onConsoleMessage(android.webkit.ConsoleMessage)',
      ),
      IOSPlatform(note: 'This event is implemented using JavaScript.'),
      MacOSPlatform(note: 'This event is implemented using JavaScript.'),
      WebPlatform(),
      WindowsPlatform(),
    ],
  )
  void onConsoleMessage(ConsoleMessage consoleMessage) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.shouldOverrideUrlLoading}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.shouldOverrideUrlLoading.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
Also, this event is not called for POST requests and is not called on the first page load.""",
      ),
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
    ],
  )
  FutureOr<NavigationActionPolicy?>? shouldOverrideUrlLoading(
    NavigationAction navigationAction,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onLaunchingExternalUriScheme}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onLaunchingExternalUriScheme.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2_18.add_LaunchingExternalUriScheme',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_18?view=webview2-1.0.2849.39#add_launchingexternalurischeme',
      ),
    ],
  )
  FutureOr<LaunchingExternalUriSchemeResponse?>? onLaunchingExternalUriScheme(
    LaunchingExternalUriSchemeRequest request,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onLoadResource}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onLoadResource.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(note: 'This event is implemented using JavaScript.'),
      IOSPlatform(note: 'This event is implemented using JavaScript.'),
      MacOSPlatform(note: 'This event is implemented using JavaScript.'),
    ],
  )
  void onLoadResource(LoadedResource resource) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onScrollChanged}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onScrollChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
      MacOSPlatform(note: 'This event is implemented using JavaScript.'),
    ],
  )
  void onScrollChanged(int x, int y) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onDownloadStart}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onDownloadStart.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  @Deprecated('Use onDownloadStarting instead')
  void onDownloadStart(Uri url) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onDownloadStartRequest}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onDownloadStartRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  @Deprecated('Use onDownloadStarting instead')
  void onDownloadStartRequest(DownloadStartRequest downloadStartRequest) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onDownloadStarting}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onDownloadStarting.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  FutureOr<DownloadStartResponse?>? onDownloadStarting(
    DownloadStartRequest downloadStartRequest,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onDownloadProgress}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onDownloadProgress.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  void onDownloadProgress(DownloadProgress downloadProgress) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onLoadResourceCustomScheme}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onLoadResourceCustomScheme.supported_platforms}
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  @Deprecated('Use onLoadResourceWithCustomScheme instead')
  FutureOr<CustomSchemeResponse?>? onLoadResourceCustomScheme(Uri url) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onLoadResourceWithCustomScheme}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onLoadResourceWithCustomScheme.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  FutureOr<CustomSchemeResponse?>? onLoadResourceWithCustomScheme(
    WebResourceRequest request,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onCreateWindow}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onCreateWindow.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onCreateWindow',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onCreateWindow(android.webkit.WebView,%20boolean,%20boolean,%20android.os.Message)',
        note:
            'You need to set [InAppWebViewSettings.supportMultipleWindows] setting to `true`. Also, if the request has been created using JavaScript (`window.open()`), then there are some limitation: check the [NavigationAction] class.',
      ),
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
it will update also the WebView options of the caller WebView.""",
      ),
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
it will update also the WebView options of the caller WebView.""",
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_NewWindowRequested',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_newwindowrequested',
      ),
    ],
  )
  FutureOr<bool?>? onCreateWindow(CreateWindowAction createWindowAction) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onCloseWindow}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onCloseWindow.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  void onCloseWindow() {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onWindowFocus}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onWindowFocus.supported_platforms}
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  void onWindowFocus() {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onWindowBlur}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onWindowBlur.supported_platforms}
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  void onWindowBlur() {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onJsAlert}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onJsAlert.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  FutureOr<JsAlertResponse?>? onJsAlert(JsAlertRequest jsAlertRequest) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onJsConfirm}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onJsConfirm.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  FutureOr<JsConfirmResponse?>? onJsConfirm(JsConfirmRequest jsConfirmRequest) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onJsPrompt}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onJsPrompt.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  FutureOr<JsPromptResponse?>? onJsPrompt(JsPromptRequest jsPromptRequest) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onReceivedHttpAuthRequest}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onReceivedHttpAuthRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  FutureOr<HttpAuthResponse?>? onReceivedHttpAuthRequest(
    HttpAuthenticationChallenge challenge,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onReceivedServerTrustAuthRequest}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onReceivedServerTrustAuthRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
See `NSAppTransportSecurity` in the [Information Property List Key Reference](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW1) for details.""",
      ),
      MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
        note:
            """To override the certificate verification logic, you have to provide ATS (App Transport Security) exceptions in your iOS/macOS `Info.plist`.
See `NSAppTransportSecurity` in the [Information Property List Key Reference](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW1) for details.""",
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2_14.add_ServerCertificateErrorDetected',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_14?view=webview2-1.0.2792.45#add_servercertificateerrordetected',
      ),
    ],
  )
  FutureOr<ServerTrustAuthResponse?>? onReceivedServerTrustAuthRequest(
    ServerTrustChallenge challenge,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onReceivedClientCertRequest}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onReceivedClientCertRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  FutureOr<ClientCertResponse?>? onReceivedClientCertRequest(
    ClientCertChallenge challenge,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onFindResultReceived}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onFindResultReceived.supported_platforms}
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  @Deprecated('Use FindInteractionController.onFindResultReceived instead')
  void onFindResultReceived(
    int activeMatchOrdinal,
    int numberOfMatches,
    bool isDoneCounting,
  ) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.shouldInterceptAjaxRequest}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.shouldInterceptAjaxRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptAjaxRequest] setting documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("dragoInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure.""",
      ),
      IOSPlatform(),
      MacOSPlatform(),
    ],
  )
  FutureOr<AjaxRequest?>? shouldInterceptAjaxRequest(AjaxRequest ajaxRequest) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onAjaxReadyStateChange}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onAjaxReadyStateChange.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptAjaxRequest] and [InAppWebViewSettings.useOnAjaxReadyStateChange] settings documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("dragoInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure.""",
      ),
      IOSPlatform(),
      MacOSPlatform(),
    ],
  )
  FutureOr<AjaxRequestAction?>? onAjaxReadyStateChange(
    AjaxRequest ajaxRequest,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onAjaxProgress}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onAjaxProgress.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptAjaxRequest] and [InAppWebViewSettings.useOnAjaxProgress] settings documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("dragoInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure.""",
      ),
      IOSPlatform(),
      MacOSPlatform(),
    ],
  )
  FutureOr<AjaxRequestAction?>? onAjaxProgress(AjaxRequest ajaxRequest) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.shouldInterceptFetchRequest}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.shouldInterceptFetchRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptFetchRequest] setting documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("dragoInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure.""",
      ),
      IOSPlatform(),
      MacOSPlatform(),
    ],
  )
  FutureOr<FetchRequest?>? shouldInterceptFetchRequest(
    FetchRequest fetchRequest,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onUpdateVisitedHistory}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onUpdateVisitedHistory.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  void onUpdateVisitedHistory(
    WebUri? url,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) bool? isReload,
  ) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onPrint}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onPrint.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  @Deprecated("Use onPrintRequest instead")
  void onPrint(Uri? url) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onPrintRequest}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onPrintRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
      MacOSPlatform(note: 'This method is implemented using JavaScript.'),
    ],
  )
  FutureOr<bool?>? onPrintRequest(
    WebUri? url,
    PlatformPrintJobController? printJobController,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onLongPressHitTestResult}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onLongPressHitTestResult.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  void onLongPressHitTestResult(InAppWebViewHitTestResult hitTestResult) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onEnterFullscreen}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onEnterFullscreen.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_ContainsFullScreenElementChanged',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_containsfullscreenelementchanged',
      ),
    ],
  )
  void onEnterFullscreen() {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onExitFullscreen}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onExitFullscreen.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_ContainsFullScreenElementChanged',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_containsfullscreenelementchanged',
      ),
    ],
  )
  void onExitFullscreen() {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onContentLoading}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onContentLoading.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_ContentLoading',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_contentloading',
      ),
    ],
  )
  void onContentLoading(WebUri? url) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onDOMContentLoaded}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onDOMContentLoaded.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2_2.add_DOMContentLoaded',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_2?view=webview2-1.0.2210.55#add_domcontentloaded',
      ),
    ],
  )
  void onDOMContentLoaded(WebUri? url) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onPageCommitVisible}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onPageCommitVisible.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  void onPageCommitVisible(WebUri? url) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onTitleChanged}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onTitleChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  void onTitleChanged(String? title) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onOverScrolled}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onOverScrolled.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.onOverScrolled',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#onOverScrolled(int,%20int,%20boolean,%20boolean)',
      ),
      IOSPlatform(),
    ],
  )
  void onOverScrolled(int x, int y, bool clampedX, bool clampedY) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onZoomScaleChanged}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onZoomScaleChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  void onZoomScaleChanged(double oldScale, double newScale) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.androidOnSafeBrowsingHit}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.androidOnSafeBrowsingHit.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated("Use onSafeBrowsingHit instead")
  FutureOr<SafeBrowsingResponse?>? androidOnSafeBrowsingHit(
    Uri url,
    SafeBrowsingThreat? threatType,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onSafeBrowsingHit}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onSafeBrowsingHit.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onSafeBrowsingHit',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onSafeBrowsingHit(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20int,%20android.webkit.SafeBrowsingResponse)',
        available: '27',
      ),
    ],
  )
  FutureOr<SafeBrowsingResponse?>? onSafeBrowsingHit(
    WebUri url,
    SafeBrowsingThreat? threatType,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.androidOnPermissionRequest}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.androidOnPermissionRequest.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated("Use onPermissionRequest instead")
  FutureOr<PermissionRequestResponse?>? androidOnPermissionRequest(
    String origin,
    List<String> resources,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onPermissionRequest}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onPermissionRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onPermissionRequest',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequest(android.webkit.PermissionRequest)',
        available: '21',
      ),
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
    ],
  )
  FutureOr<PermissionResponse?>? onPermissionRequest(
    PermissionRequest permissionRequest,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.androidOnGeolocationPermissionsShowPrompt}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.androidOnGeolocationPermissionsShowPrompt.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated("Use onGeolocationPermissionsShowPrompt instead")
  FutureOr<GeolocationPermissionShowPromptResponse?>?
  androidOnGeolocationPermissionsShowPrompt(String origin) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onGeolocationPermissionsShowPrompt}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onGeolocationPermissionsShowPrompt.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onGeolocationPermissionsShowPrompt',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsShowPrompt(java.lang.String,%20android.webkit.GeolocationPermissions.Callback)',
      ),
    ],
  )
  FutureOr<GeolocationPermissionShowPromptResponse?>?
  onGeolocationPermissionsShowPrompt(String origin) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.androidOnGeolocationPermissionsHidePrompt}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.androidOnGeolocationPermissionsHidePrompt.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated("Use onGeolocationPermissionsHidePrompt instead")
  void androidOnGeolocationPermissionsHidePrompt() {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onGeolocationPermissionsHidePrompt}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onGeolocationPermissionsHidePrompt.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onGeolocationPermissionsHidePrompt',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsHidePrompt()',
      ),
    ],
  )
  void onGeolocationPermissionsHidePrompt() {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.androidShouldInterceptRequest}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.androidShouldInterceptRequest.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated("Use shouldInterceptRequest instead")
  FutureOr<WebResourceResponse?>? androidShouldInterceptRequest(
    WebResourceRequest request,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.shouldInterceptRequest}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.shouldInterceptRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  FutureOr<WebResourceResponse?>? shouldInterceptRequest(
    WebResourceRequest request,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.androidOnRenderProcessUnresponsive}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.androidOnRenderProcessUnresponsive.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated("Use onRenderProcessUnresponsive instead")
  FutureOr<WebViewRenderProcessAction?>? androidOnRenderProcessUnresponsive(
    Uri? url,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onRenderProcessUnresponsive}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onRenderProcessUnresponsive.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewRenderProcessClient.onRenderProcessUnresponsive',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessUnresponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)',
        available: '29',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_ProcessFailed',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed',
      ),
    ],
  )
  FutureOr<WebViewRenderProcessAction?>? onRenderProcessUnresponsive(
    WebUri? url,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.androidOnRenderProcessResponsive}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.androidOnRenderProcessResponsive.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated("Use onRenderProcessResponsive instead")
  FutureOr<WebViewRenderProcessAction?>? androidOnRenderProcessResponsive(
    Uri? url,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onRenderProcessResponsive}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onRenderProcessResponsive.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewRenderProcessClient.onRenderProcessResponsive',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessResponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)',
        available: '29',
      ),
    ],
  )
  FutureOr<WebViewRenderProcessAction?>? onRenderProcessResponsive(
    WebUri? url,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.androidOnRenderProcessGone}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.androidOnRenderProcessGone.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated("Use onRenderProcessGone instead")
  void androidOnRenderProcessGone(RenderProcessGoneDetail detail) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onRenderProcessGone}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onRenderProcessGone.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onRenderProcessGone',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onRenderProcessGone(android.webkit.WebView,%20android.webkit.RenderProcessGoneDetail)',
        available: '26',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_ProcessFailed',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed',
      ),
    ],
  )
  void onRenderProcessGone(RenderProcessGoneDetail detail) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.androidOnFormResubmission}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.androidOnFormResubmission.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated('Use onFormResubmission instead')
  FutureOr<FormResubmissionAction?>? androidOnFormResubmission(Uri? url) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onFormResubmission}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onFormResubmission.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onFormResubmission',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onFormResubmission(android.webkit.WebView,%20android.os.Message,%20android.os.Message)',
      ),
    ],
  )
  FutureOr<FormResubmissionAction?>? onFormResubmission(WebUri? url) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.androidOnScaleChanged}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.androidOnScaleChanged.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated('Use onZoomScaleChanged instead')
  void androidOnScaleChanged(double oldScale, double newScale) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.androidOnReceivedIcon}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.androidOnReceivedIcon.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated('Use onReceivedIcon instead')
  void androidOnReceivedIcon(Uint8List icon) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onReceivedIcon}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onReceivedIcon.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onReceivedIcon',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedIcon(android.webkit.WebView,%20android.graphics.Bitmap)',
      ),
    ],
  )
  @Deprecated('Use onFaviconChanged instead')
  void onReceivedIcon(Uint8List icon) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onFaviconChanged}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onFaviconChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onReceivedIcon',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedIcon(android.webkit.WebView,%20android.graphics.Bitmap)',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2_15.add_FaviconChanged',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_15?view=webview2-1.0.2849.39#add_faviconchanged',
      ),
    ],
  )
  void onFaviconChanged(FaviconChangedRequest faviconChangedRequest) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.androidOnReceivedTouchIconUrl}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.androidOnReceivedTouchIconUrl.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated('Use onReceivedTouchIconUrl instead')
  void androidOnReceivedTouchIconUrl(Uri url, bool precomposed) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.androidOnReceivedTouchIconUrl}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.androidOnReceivedTouchIconUrl.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onReceivedTouchIconUrl',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTouchIconUrl(android.webkit.WebView,%20java.lang.String,%20boolean)',
      ),
    ],
  )
  void onReceivedTouchIconUrl(WebUri url, bool precomposed) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.androidOnJsBeforeUnload}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.androidOnJsBeforeUnload.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated('Use onJsBeforeUnload instead')
  FutureOr<JsBeforeUnloadResponse?>? androidOnJsBeforeUnload(
    JsBeforeUnloadRequest jsBeforeUnloadRequest,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onJsBeforeUnload}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onJsBeforeUnload.supported_platforms}
  FutureOr<JsBeforeUnloadResponse?>? onJsBeforeUnload(
    JsBeforeUnloadRequest jsBeforeUnloadRequest,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.androidOnReceivedLoginRequest}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.androidOnReceivedLoginRequest.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated('Use onReceivedLoginRequest instead')
  void androidOnReceivedLoginRequest(LoginRequest loginRequest) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onReceivedLoginRequest}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onReceivedLoginRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onReceivedLoginRequest',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedLoginRequest(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String)',
      ),
    ],
  )
  void onReceivedLoginRequest(LoginRequest loginRequest) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onPermissionRequestCanceled}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onPermissionRequestCanceled.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onPermissionRequestCanceled',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequestCanceled(android.webkit.PermissionRequest)',
        available: '21',
      ),
    ],
  )
  void onPermissionRequestCanceled(PermissionRequest permissionRequest) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onRequestFocus}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onRequestFocus.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onRequestFocus',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onRequestFocus(android.webkit.WebView)',
      ),
    ],
  )
  void onRequestFocus() {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.iosOnWebContentProcessDidTerminate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.iosOnWebContentProcessDidTerminate.supported_platforms}
  @SupportedPlatforms(platforms: [IOSPlatform()])
  @Deprecated('Use onWebContentProcessDidTerminate instead')
  void iosOnWebContentProcessDidTerminate() {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onWebContentProcessDidTerminate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onWebContentProcessDidTerminate.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  void onWebContentProcessDidTerminate() {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.iosOnDidReceiveServerRedirectForProvisionalNavigation}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.iosOnDidReceiveServerRedirectForProvisionalNavigation.supported_platforms}
  @SupportedPlatforms(platforms: [IOSPlatform()])
  @Deprecated('Use onDidReceiveServerRedirectForProvisionalNavigation instead')
  void iosOnDidReceiveServerRedirectForProvisionalNavigation() {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onDidReceiveServerRedirectForProvisionalNavigation}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onDidReceiveServerRedirectForProvisionalNavigation.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  void onDidReceiveServerRedirectForProvisionalNavigation() {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.iosOnNavigationResponse}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.iosOnNavigationResponse.supported_platforms}
  @SupportedPlatforms(platforms: [IOSPlatform()])
  @Deprecated('Use onNavigationResponse instead')
  FutureOr<IOSNavigationResponseAction?>? iosOnNavigationResponse(
    IOSWKNavigationResponse navigationResponse,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onNavigationResponse}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onNavigationResponse.supported_platforms}
  @SupportedPlatforms(
    platforms: [
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
    ],
  )
  FutureOr<NavigationResponseAction?>? onNavigationResponse(
    NavigationResponse navigationResponse,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.iosShouldAllowDeprecatedTLS}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.iosShouldAllowDeprecatedTLS.supported_platforms}
  @SupportedPlatforms(platforms: [IOSPlatform()])
  @Deprecated('Use shouldAllowDeprecatedTLS instead')
  FutureOr<IOSShouldAllowDeprecatedTLSAction?>? iosShouldAllowDeprecatedTLS(
    URLAuthenticationChallenge challenge,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.shouldAllowDeprecatedTLS}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.shouldAllowDeprecatedTLS.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/3601237-webview',
        available: '14.0',
      ),
      MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/3601237-webview',
        available: '11.0',
      ),
    ],
  )
  FutureOr<ShouldAllowDeprecatedTLSAction?>? shouldAllowDeprecatedTLS(
    URLAuthenticationChallenge challenge,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onCameraCaptureStateChanged}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onCameraCaptureStateChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(available: '15.0'),
      MacOSPlatform(available: '12.0'),
    ],
  )
  void onCameraCaptureStateChanged(
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  ) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onMicrophoneCaptureStateChanged}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onMicrophoneCaptureStateChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(available: '15.0'),
      MacOSPlatform(available: '12.0'),
    ],
  )
  void onMicrophoneCaptureStateChanged(
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  ) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onContentSizeChanged}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onContentSizeChanged.supported_platforms}
  @SupportedPlatforms(platforms: [IOSPlatform()])
  void onContentSizeChanged(Size oldContentSize, Size newContentSize) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onProcessFailed}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onProcessFailed.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_ProcessFailed',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed',
      ),
    ],
  )
  void onProcessFailed(ProcessFailedDetail detail) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onNotificationReceived}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onNotificationReceived.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2_24.add_NotificationReceived',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_24?view=webview2-1.0.2849.39#add_notificationreceived',
      ),
    ],
  )
  FutureOr<NotificationReceivedResponse?>? onNotificationReceived(
    NotificationReceivedRequest request,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onSaveAsUIShowing}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onSaveAsUIShowing.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2_25.add_SaveAsUIShowing',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_25?view=webview2-1.0.2849.39#add_saveasuishowing',
      ),
    ],
  )
  FutureOr<SaveAsUIShowingResponse?>? onSaveAsUIShowing(
    SaveAsUIShowingRequest request,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onSaveFileSecurityCheckStarting}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onSaveFileSecurityCheckStarting.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2_26.add_SaveFileSecurityCheckStarting',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_26?view=webview2-1.0.2849.39#add_savefilesecuritycheckstarting',
      ),
    ],
  )
  FutureOr<SaveFileSecurityCheckStartingResponse?>?
  onSaveFileSecurityCheckStarting(
    SaveFileSecurityCheckStartingRequest request,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onScreenCaptureStarting}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onScreenCaptureStarting.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2_27.add_ScreenCaptureStarting',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_27?view=webview2-1.0.2849.39#add_screencapturestarting',
      ),
    ],
  )
  FutureOr<ScreenCaptureStartingResponse?>? onScreenCaptureStarting(
    ScreenCaptureStartingRequest request,
  ) {
    return null;
  }

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onAcceleratorKeyPressed}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onAcceleratorKeyPressed.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2Controller.add_AcceleratorKeyPressed',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controller?view=webview2-1.0.2849.39#add_acceleratorkeypressed',
      ),
    ],
  )
  void onAcceleratorKeyPressed(AcceleratorKeyPressedDetail detail) {}

  ///{@macro drago_inappwebview.PlatformWebViewCreationParams.onShowFileChooser}
  ///
  ///{@macro drago_inappwebview.PlatformInAppBrowserEvents.onShowFileChooser.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onShowFileChooser',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onShowFileChooser(android.webkit.WebView,%20android.webkit.ValueCallback%3Candroid.net.Uri[]%3E,%20android.webkit.WebChromeClient.FileChooserParams)',
      ),
    ],
  )
  FutureOr<ShowFileChooserResponse?> onShowFileChooser(
    ShowFileChooserRequest request,
  ) {
    return null;
  }

  ///{@template drago_inappwebview.PlatformInAppBrowserEvents.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isMethodSupported(
    PlatformInAppBrowserEventsMethod method, {
    TargetPlatform? platform,
  }) => _PlatformInAppBrowserEventsMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}
