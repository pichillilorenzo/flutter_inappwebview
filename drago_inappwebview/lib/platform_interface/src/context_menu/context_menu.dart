import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import '../types/in_app_webview_hit_test_result.dart';
import 'context_menu_item.dart';
import 'context_menu_settings.dart';
import '../types/enum_method.dart';

part 'context_menu.g.dart';

///Class that represents the WebView context menu. It used by [PlatformWebViewCreationParams.contextMenu].
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(
      note:
          'To make it work properly on Android, JavaScript should be enabled!',
    ),
    IOSPlatform(),
    WindowsPlatform(
      apiName: 'ICoreWebView2_11.add_ContextMenuRequested',
      apiUrl:
          'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_11#add_contextmenurequested',
    ),
  ],
)
@ExchangeableObject()
class ContextMenu_ {
  ///Event fired when the context menu for this WebView is being built.
  ///
  ///[hitTestResult] represents the hit result for hitting an HTML elements.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      WindowsPlatform(
        apiName: 'ICoreWebView2_11.add_ContextMenuRequested',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_11#add_contextmenurequested',
      ),
    ],
  )
  final void Function(InAppWebViewHitTestResult_ hitTestResult)?
  onCreateContextMenu;

  ///Event fired when the context menu for this WebView is being hidden.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      WindowsPlatform(
        apiName: 'ICoreWebView2_11.add_ContextMenuRequested',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_11#add_contextmenurequested',
        note: 'On Windows this event fires only after a custom menu item has been clicked.',
      ),
    ],
  )
  final void Function()? onHideContextMenu;

  ///Event fired when a context menu item has been clicked.
  ///
  ///[contextMenuItemClicked] represents the [ContextMenuItem] clicked.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      WindowsPlatform(
        apiName: 'ICoreWebView2_11.add_ContextMenuRequested',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_11#add_contextmenurequested',
      ),
    ],
  )
  final void Function(ContextMenuItem_ contextMenuItemClicked)?
  onContextMenuActionItemClicked;

  ///Use [settings] instead
  @Deprecated("Use settings instead")
  final ContextMenuOptions_? options;

  ///Context menu settings.
  final ContextMenuSettings_? settings;

  ///List of the custom [ContextMenuItem].
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      WindowsPlatform(
        apiName: 'ICoreWebView2Environment9.CreateContextMenuItem',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environment9#createcontextmenuitem',
      ),
    ],
  )
  final List<ContextMenuItem_> menuItems;

  @ExchangeableObjectConstructor()
  ContextMenu_({
    this.menuItems = const [],
    this.onCreateContextMenu,
    this.onHideContextMenu,
    @Deprecated("Use settings instead") this.options,
    this.settings,
    this.onContextMenuActionItemClicked,
  });

  @ExchangeableObjectMethod(toMapMergeWith: true)
  // ignore: unused_element
  Map<String, dynamic> _toMapMergeWith({EnumMethod? enumMethod}) {
    return {
      "settings":
          (settings as ContextMenuSettings?)?.toMap(enumMethod: enumMethod) ??
          (options as ContextMenuOptions?)?.toMap(enumMethod: enumMethod),
    };
  }
}
