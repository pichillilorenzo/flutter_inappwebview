import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import 'context_menu.dart';
import '../types/enum_method.dart';

part 'context_menu_settings.g.dart';

///Class that represents available settings used by [ContextMenu].
@ExchangeableObject(copyMethod: true)
class ContextMenuSettings_ {
  ///Whether all the default system context menu items should be hidden or not. The default value is `false`.
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
