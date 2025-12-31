import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

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
  ],
)
@ExchangeableObject()
class ContextMenu_ {
  ///Event fired when the context menu for this WebView is being built.
  ///
  ///[hitTestResult] represents the hit result for hitting an HTML elements.
  final void Function(InAppWebViewHitTestResult_ hitTestResult)?
  onCreateContextMenu;

  ///Event fired when the context menu for this WebView is being hidden.
  final void Function()? onHideContextMenu;

  ///Event fired when a context menu item has been clicked.
  ///
  ///[contextMenuItemClicked] represents the [ContextMenuItem] clicked.
  final void Function(ContextMenuItem_ contextMenuItemClicked)?
  onContextMenuActionItemClicked;

  ///Use [settings] instead
  @Deprecated("Use settings instead")
  final ContextMenuOptions_? options;

  ///Context menu settings.
  final ContextMenuSettings_? settings;

  ///List of the custom [ContextMenuItem].
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
