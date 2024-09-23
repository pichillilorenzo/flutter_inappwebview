import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'context_menu.dart';

part 'context_menu_settings.g.dart';

///Class that represents available settings used by [ContextMenu].
@ExchangeableObject(copyMethod: true)
class ContextMenuSettings_ {
  ///Whether all the default system context menu items should be hidden or not. The default value is `false`.
  bool hideDefaultSystemContextMenuItems;

  ContextMenuSettings_({this.hideDefaultSystemContextMenuItems = false});
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
