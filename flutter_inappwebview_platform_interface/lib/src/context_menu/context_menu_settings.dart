import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'context_menu.dart';
import '../types/enum_method.dart';

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
@ExchangeableObject(copyMethod: true)
class ContextMenuOptions_ {
  ///Whether all the default system context menu items should be hidden or not. The default value is `false`.
  bool hideDefaultSystemContextMenuItems;

  ContextMenuOptions_({this.hideDefaultSystemContextMenuItems = false});
}
