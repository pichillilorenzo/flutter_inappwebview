import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/src/webview.dart';

import 'types.dart';

///Class that represents the WebView context menu. It used by [WebView.contextMenu].
///
///**NOTE**: To make it work properly on Android, JavaScript should be enabled!
class ContextMenu {

  ///Event fired when the context menu for this WebView is being built.
  ///
  ///[hitTestResult] represents the hit result for hitting an HTML elements.
  final void Function(InAppWebViewHitTestResult hitTestResult) onCreateContextMenu;

  ///Event fired when the context menu for this WebView is being hidden.
  final void Function() onHideContextMenu;

  ///Event fired when a context menu item has been clicked.
  ///
  ///[contextMenuItemClicked] represents the [ContextMenuItem] clicked.
  final void Function(ContextMenuItem contextMenuItemClicked) onContextMenuActionItemClicked;

  ///List of the custom [ContextMenuItem].
  List<ContextMenuItem> menuItems = List();

  ContextMenu({
    this.menuItems,
    this.onCreateContextMenu,
    this.onHideContextMenu,
    this.onContextMenuActionItemClicked
  });

  Map<String, dynamic> toMap() {
    return {
      "menuItems": menuItems.map((menuItem) => menuItem?.toMap()).toList()
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
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

  ContextMenuItem({@required this.androidId, @required this.iosId, @required this.title, this.action});

  Map<String, dynamic> toMap() {
    return {
      "androidId": androidId,
      "iosId": iosId,
      "title": title
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }
}
