import 'in_app_webview/webview.dart';
import 'types/main.dart';
import 'util.dart';

///Class that represents the WebView context menu. It used by [WebView.contextMenu].
///
///**NOTE**: To make it work properly on Android, JavaScript should be enabled!
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
class ContextMenu {
  ///Event fired when the context menu for this WebView is being built.
  ///
  ///[hitTestResult] represents the hit result for hitting an HTML elements.
  final void Function(InAppWebViewHitTestResult hitTestResult)?
      onCreateContextMenu;

  ///Event fired when the context menu for this WebView is being hidden.
  final void Function()? onHideContextMenu;

  ///Event fired when a context menu item has been clicked.
  ///
  ///[contextMenuItemClicked] represents the [ContextMenuItem] clicked.
  final void Function(ContextMenuItem contextMenuItemClicked)?
      onContextMenuActionItemClicked;

  ///Use [settings] instead
  @Deprecated("Use settings instead")
  final ContextMenuOptions? options;

  ///Context menu settings.
  final ContextMenuSettings? settings;

  ///List of the custom [ContextMenuItem].
  final List<ContextMenuItem> menuItems;

  ContextMenu(
      {this.menuItems = const [],
      this.onCreateContextMenu,
      this.onHideContextMenu,
      @Deprecated("Use settings instead") this.options,
      this.settings,
      this.onContextMenuActionItemClicked});

  Map<String, dynamic> toMap() {
    return {
      "menuItems": menuItems.map((menuItem) => menuItem.toMap()).toList(),
      // ignore: deprecated_member_use_from_same_package
      "settings": settings?.toMap() ?? options?.toMap()
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represent an item of the [ContextMenu].
class ContextMenuItem {
  ///Use [id] instead.
  @Deprecated("Use id instead")
  int? androidId;

  ///Use [id] instead.
  @Deprecated("Use id instead")
  String? iosId;

  ///Menu item ID. It cannot be `null` and it can be a [String] or an [int].
  ///
  ///**NOTE for Android**: it must be an [int] value.
  dynamic id;

  ///Menu item title.
  String title;

  ///Menu item action that will be called when an user clicks on it.
  Function()? action;

  ContextMenuItem(
      {this.id,
      @Deprecated("Use id instead") this.androidId,
      @Deprecated("Use id instead") this.iosId,
      required this.title,
      this.action}) {
    if (Util.isAndroid) {
      // ignore: deprecated_member_use_from_same_package
      this.id = this.id ?? this.androidId;
      assert(this.id is int);
    } else if (Util.isIOS) {
      // ignore: deprecated_member_use_from_same_package
      this.id = this.id ?? this.iosId;
    }
    assert(this.id != null && (this.id is int || this.id is String));
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      // ignore: deprecated_member_use_from_same_package
      "androidId": androidId,
      // ignore: deprecated_member_use_from_same_package
      "iosId": iosId,
      "title": title
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents available settings used by [ContextMenu].
class ContextMenuSettings {
  ///Whether all the default system context menu items should be hidden or not. The default value is `false`.
  bool hideDefaultSystemContextMenuItems;

  ContextMenuSettings({this.hideDefaultSystemContextMenuItems = false});

  Map<String, dynamic> toMap() {
    return {
      "hideDefaultSystemContextMenuItems": hideDefaultSystemContextMenuItems
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Use [ContextMenuSettings] instead.
@Deprecated("Use ContextMenuSettings instead")
class ContextMenuOptions {
  ///Whether all the default system context menu items should be hidden or not. The default value is `false`.
  bool hideDefaultSystemContextMenuItems;

  ContextMenuOptions({this.hideDefaultSystemContextMenuItems = false});

  Map<String, dynamic> toMap() {
    return {
      "hideDefaultSystemContextMenuItems": hideDefaultSystemContextMenuItems
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
