// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chrome_safari_browser_menu_item.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a custom menu item for a [PlatformChromeSafariBrowser] instance.
///
///**NOTE for Android native WebView**: Not available in an Android Trusted Web Activity.
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
class ChromeSafariBrowserMenuItem {
  ///Use onClick instead.
  @Deprecated('Use onClick instead')
  void Function(String, String)? action;

  ///The menu item id. It should be different from [ChromeSafariBrowserActionButton.id].
  int id;

  ///Item image.
  UIImage? image;

  ///The label of the menu item.
  String label;

  ///Callback function to be invoked when the menu item is clicked
  void Function(WebUri?, String)? onClick;

  ///
  ///**NOTE for Android native WebView**: Not available in an Android Trusted Web Activity.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ChromeSafariBrowserMenuItem(
      {required this.id,
      required this.label,
      this.image,
      @Deprecated("Use onClick instead") this.action,
      this.onClick});

  ///Gets a possible [ChromeSafariBrowserMenuItem] instance from a [Map] value.
  static ChromeSafariBrowserMenuItem? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = ChromeSafariBrowserMenuItem(
      id: map['id'],
      image: UIImage.fromMap(map['image']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      label: map['label'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "id": id,
      "image": image?.toMap(enumMethod: enumMethod),
      "label": label,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ChromeSafariBrowserMenuItem{id: $id, image: $image, label: $label}';
  }
}
