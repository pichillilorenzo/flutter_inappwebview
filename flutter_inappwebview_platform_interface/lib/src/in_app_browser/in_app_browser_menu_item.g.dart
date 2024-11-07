// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_browser_menu_item.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a custom menu item for a [PlatformInAppBrowser] instance.
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class InAppBrowserMenuItem {
  ///Item icon.
  dynamic icon;

  ///Icon color.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS 13.0+
  ///- MacOS
  Color? iconColor;

  ///The menu item id.
  int id;

  ///Callback function to be invoked when the menu item is clicked
  void Function()? onClick;

  ///Item order.
  int? order;

  ///Show this item as a button in the Action Bar.
  bool showAsAction;

  ///The title of the menu item.
  String title;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  InAppBrowserMenuItem(
      {this.icon,
      this.iconColor,
      required this.id,
      this.onClick,
      this.order,
      this.showAsAction = false,
      required this.title});

  ///Gets a possible [InAppBrowserMenuItem] instance from a [Map] value.
  static InAppBrowserMenuItem? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = InAppBrowserMenuItem(
      icon: _deserializeIcon(map['icon'], enumMethod: enumMethod),
      iconColor: map['iconColor'] != null
          ? UtilColor.fromStringRepresentation(map['iconColor'])
          : null,
      id: map['id'],
      order: map['order'],
      title: map['title'],
    );
    if (map['showAsAction'] != null) {
      instance.showAsAction = map['showAsAction'];
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "icon": _serializeIcon(icon, enumMethod: enumMethod),
      "iconColor": iconColor?.toHex(),
      "id": id,
      "order": order,
      "showAsAction": showAsAction,
      "title": title,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'InAppBrowserMenuItem{icon: $icon, iconColor: $iconColor, id: $id, order: $order, showAsAction: $showAsAction, title: $title}';
  }
}
