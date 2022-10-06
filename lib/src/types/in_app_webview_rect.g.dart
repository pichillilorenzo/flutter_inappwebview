// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_webview_rect.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///A class that represents a structure that contains the location and dimensions of a rectangle.
class InAppWebViewRect {
  ///x position
  double x;

  ///y position
  double y;

  ///rect width
  double width;

  ///rect height
  double height;
  InAppWebViewRect(
      {required this.x,
      required this.y,
      required this.width,
      required this.height}) {
    assert(this.x >= 0 && this.y >= 0 && this.width >= 0 && this.height >= 0);
  }

  ///Gets a possible [InAppWebViewRect] instance from a [Map] value.
  static InAppWebViewRect? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = InAppWebViewRect(
      x: map['x'],
      y: map['y'],
      width: map['width'],
      height: map['height'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "x": x,
      "y": y,
      "width": width,
      "height": height,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'InAppWebViewRect{x: $x, y: $y, width: $width, height: $height}';
  }
}
