// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_menu.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the WebView context menu. It used by [PlatformWebViewCreationParams.contextMenu].
///
///**Officially Supported Platforms/Implementations**:
///- Android WebView:
///    - To make it work properly on Android, JavaScript should be enabled!
///- iOS WKWebView
///- Windows WebView2 ([Official API - ICoreWebView2_11.add_ContextMenuRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_11#add_contextmenurequested))
class ContextMenu {
  ///List of the custom [ContextMenuItem].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Windows WebView2 ([Official API - ICoreWebView2Environment9.CreateContextMenuItem](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environment9#createcontextmenuitem))
  final List<ContextMenuItem> menuItems;

  ///Event fired when a context menu item has been clicked.
  ///
  ///[contextMenuItemClicked] represents the [ContextMenuItem] clicked.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Windows WebView2 ([Official API - ICoreWebView2_11.add_ContextMenuRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_11#add_contextmenurequested))
  final void Function(ContextMenuItem)? onContextMenuActionItemClicked;

  ///Event fired when the context menu for this WebView is being built.
  ///
  ///[hitTestResult] represents the hit result for hitting an HTML elements.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Windows WebView2 ([Official API - ICoreWebView2_11.add_ContextMenuRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_11#add_contextmenurequested))
  final void Function(InAppWebViewHitTestResult)? onCreateContextMenu;

  ///Event fired when the context menu for this WebView is being hidden.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Windows WebView2 ([Official API - ICoreWebView2_11.add_ContextMenuRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_11#add_contextmenurequested)):
  ///    - On Windows this event fires only after a custom menu item has been clicked.
  final void Function()? onHideContextMenu;

  ///Use [settings] instead
  @Deprecated('Use settings instead')
  final ContextMenuOptions? options;

  ///Context menu settings.
  final ContextMenuSettings? settings;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - To make it work properly on Android, JavaScript should be enabled!
  ///- iOS WKWebView
  ///- Windows WebView2 ([Official API - ICoreWebView2_11.add_ContextMenuRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_11#add_contextmenurequested))
  ContextMenu({
    this.menuItems = const [],
    this.onCreateContextMenu,
    this.onHideContextMenu,
    @Deprecated("Use settings instead") this.options,
    this.settings,
    this.onContextMenuActionItemClicked,
  });

  ///Gets a possible [ContextMenu] instance from a [Map] value.
  static ContextMenu? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = ContextMenu(
      menuItems: List<ContextMenuItem>.from(
        map['menuItems'].map(
          (e) => ContextMenuItem.fromMap(
            e?.cast<String, dynamic>(),
            enumMethod: enumMethod,
          )!,
        ),
      ),
      options: ContextMenuOptions.fromMap(
        map['settings']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      settings: ContextMenuSettings.fromMap(
        map['settings']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
    );
    return instance;
  }

  @ExchangeableObjectMethod(toMapMergeWith: true)
  Map<String, dynamic> _toMapMergeWith({EnumMethod? enumMethod}) {
    return {
      "settings":
          (settings as ContextMenuSettings?)?.toMap(enumMethod: enumMethod) ??
          (options as ContextMenuOptions?)?.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "menuItems": menuItems
          .map((e) => e.toMap(enumMethod: enumMethod))
          .toList(),
      "settings": settings?.toMap(enumMethod: enumMethod),
      ..._toMapMergeWith(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ContextMenu{menuItems: $menuItems, settings: $settings}';
  }
}
