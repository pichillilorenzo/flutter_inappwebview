import 'package:flutter/foundation.dart';

import 'webview.dart';
import 'types.dart';

///Class that represents the WebView context menu. It used by [WebView.contextMenu].
///
///**NOTE**: To make it work properly on Android, JavaScript should be enabled!
class ContextMenu {
  ///Event fired when the context menu for this WebView is being built.
  ///
  ///[hitTestResult] represents the hit result for hitting an HTML elements.
  final void Function(InAppWebViewHitTestResult hitTestResult)
      onCreateContextMenu;

  ///Event fired when the context menu for this WebView is being hidden.
  final void Function() onHideContextMenu;

  ///Event fired when a context menu item has been clicked.
  ///
  ///[contextMenuItemClicked] represents the [ContextMenuItem] clicked.
  final void Function(ContextMenuItem contextMenuItemClicked)
      onContextMenuActionItemClicked;

  ///Context menu options.
  final ContextMenuOptions options;

  ///List of the custom [ContextMenuItem].
  final List<ContextMenuItem> menuItems;

  ContextMenu(
      {this.menuItems = const [],
      this.onCreateContextMenu,
      this.onHideContextMenu,
      this.options,
      this.onContextMenuActionItemClicked})
      : assert(menuItems != null);

  Map<String, dynamic> toMap() {
    return {
      "menuItems": menuItems.map((menuItem) => menuItem?.toMap()).toList(),
      "options": options?.toMap()
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
  ///Android menu item ID.
  int androidId;

  ///iOS menu item ID.
  String iosId;

  ///Menu item title.
  String title;

  ///Menu item action that will be called when an user clicks on it.
  Function() action;

  ContextMenuItem(
      {@required this.androidId,
      @required this.iosId,
      @required this.title,
      this.action});

  Map<String, dynamic> toMap() {
    return {"androidId": androidId, "iosId": iosId, "title": title};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents available options used by [ContextMenu].
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
