// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_button.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a custom button to show in `SFSafariViewController`'s toolbar.
///When tapped, it will invoke a Share or Action Extension bundled with your app.
///The default VoiceOver description of this button is the `CFBundleDisplayName` set in the extension's `Info.plist`.
///
///**Supported Platforms/Implementations**:
///- iOS
class ActivityButton {
  ///The name of the image asset or file.
  UIImage templateImage;

  ///The name of the system symbol image.
  String extensionIdentifier;
  ActivityButton(
      {required this.templateImage, required this.extensionIdentifier});

  ///Gets a possible [ActivityButton] instance from a [Map] value.
  static ActivityButton? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = ActivityButton(
      templateImage:
          UIImage.fromMap(map['templateImage']?.cast<String, dynamic>())!,
      extensionIdentifier: map['extensionIdentifier'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "templateImage": templateImage.toMap(),
      "extensionIdentifier": extensionIdentifier,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ActivityButton{templateImage: $templateImage, extensionIdentifier: $extensionIdentifier}';
  }
}
