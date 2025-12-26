// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chrome_safari_action_button.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a custom action button for a [PlatformChromeSafariBrowser] instance.
///
///**Officially Supported Platforms/Implementations**:
///- Android WebView:
///    - Not available in an Android Trusted Web Activity.
class ChromeSafariBrowserActionButton {
  ///Use onClick instead.
  @Deprecated('Use onClick instead')
  void Function(String, String)? action;

  ///The description for the button. To be used for accessibility.
  String description;

  ///The icon byte data.
  Uint8List icon;

  ///The action button id. It should be different from the [ChromeSafariBrowserMenuItem.id].
  int id;

  ///Callback function to be invoked when the action button is clicked
  void Function(WebUri?, String)? onClick;

  ///Whether the action button should be tinted.
  bool shouldTint;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - Not available in an Android Trusted Web Activity.
  ChromeSafariBrowserActionButton(
      {required this.id,
      required this.icon,
      required this.description,
      @Deprecated("Use onClick instead") this.action,
      this.onClick,
      this.shouldTint = false});

  ///Gets a possible [ChromeSafariBrowserActionButton] instance from a [Map] value.
  static ChromeSafariBrowserActionButton? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = ChromeSafariBrowserActionButton(
      description: map['description'],
      icon: Uint8List.fromList(map['icon'].cast<int>()),
      id: map['id'],
    );
    if (map['shouldTint'] != null) {
      instance.shouldTint = map['shouldTint'];
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "description": description,
      "icon": icon,
      "id": id,
      "shouldTint": shouldTint,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ChromeSafariBrowserActionButton{description: $description, icon: $icon, id: $id, shouldTint: $shouldTint}';
  }
}
