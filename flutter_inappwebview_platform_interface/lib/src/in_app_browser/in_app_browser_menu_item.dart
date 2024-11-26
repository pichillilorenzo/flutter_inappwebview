import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../util.dart';

import 'platform_in_app_browser.dart';
import '../types/main.dart';
import '../types/enum_method.dart';

part 'in_app_browser_menu_item.g.dart';

dynamic _serializeIcon(dynamic icon, {EnumMethod? enumMethod}) {
  return icon is Uint8List ? icon : icon?.toMap(enumMethod: enumMethod);
}

dynamic _deserializeIcon(dynamic icon, {EnumMethod? enumMethod}) {
  if (icon is Uint8List) {
    return icon;
  }
  if (icon is Map<String, dynamic>) {
    final iconMap = icon as Map<String, dynamic>;
    if (iconMap.containsKey('defType')) {
      return AndroidResource.fromMap(iconMap, enumMethod: enumMethod);
    }
    if (iconMap.containsKey('systemName')) {
      return UIImage.fromMap(iconMap, enumMethod: enumMethod);
    }
  }
  return null;
}

///Class that represents a custom menu item for a [PlatformInAppBrowser] instance.
@SupportedPlatforms(platforms: [
  AndroidPlatform(),
  IOSPlatform(),
  MacOSPlatform(),
])
@ExchangeableObject()
class InAppBrowserMenuItem_ {
  ///The menu item id.
  int id;

  ///The title of the menu item.
  String title;

  ///Item icon.
  @ExchangeableObjectProperty(
      serializer: _serializeIcon, deserializer: _deserializeIcon)
  dynamic icon;

  ///Icon color.
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(available: "13.0"),
    MacOSPlatform(),
  ])
  Color_? iconColor;

  ///Item order.
  int? order;

  ///Show this item as a button in the Action Bar.
  bool showAsAction;

  ///Callback function to be invoked when the menu item is clicked
  void Function()? onClick;

  InAppBrowserMenuItem_(
      {required this.id,
      required this.title,
      this.icon,
      this.iconColor,
      this.onClick,
      this.order,
      this.showAsAction = false}) {
    assert(this.icon == null ||
        this.icon is Uint8List ||
        this.icon is UIImage ||
        this.icon is AndroidResource);
  }
}
