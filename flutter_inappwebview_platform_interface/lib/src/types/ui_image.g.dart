// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_image.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents an object that manages iOS and MacOS image data in your app.
///
///Check iOS [UIKit.UIImage](https://developer.apple.com/documentation/uikit/uiimage) for more details.
///Check MacOS [AppKit.NSImage](https://developer.apple.com/documentation/appkit/nsimage) for more details.
///
///**Officially Supported Platforms/Implementations**:
///- iOS
///- MacOS
class UIImage {
  ///The data object containing the image data.
  Uint8List? data;

  ///The name of the image asset or file.
  String? name;

  ///The name of the system symbol image.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS 13.0+
  ///- MacOS 11.0+
  String? systemName;
  UIImage({this.name, this.systemName, this.data}) {
    assert(this.name != null || this.systemName != null || this.data != null);
  }

  ///Gets a possible [UIImage] instance from a [Map] value.
  static UIImage? fromMap(Map<String, dynamic>? map, {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = UIImage(
      data: map['data'] != null
          ? Uint8List.fromList(map['data'].cast<int>())
          : null,
      name: map['name'],
      systemName: map['systemName'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "data": data,
      "name": name,
      "systemName": systemName,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'UIImage{data: $data, name: $name, systemName: $systemName}';
  }
}
