// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favicon.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a favicon of a website. It is used by [PlatformInAppWebViewController.getFavicons] method.
class Favicon {
  ///The height of the favicon image.
  int? height;

  ///The relationship between the current web page and the favicon image.
  String? rel;

  ///The url of the favicon image.
  WebUri url;

  ///The width of the favicon image.
  int? width;
  Favicon({this.height, this.rel, required this.url, this.width});

  ///Gets a possible [Favicon] instance from a [Map] value.
  static Favicon? fromMap(Map<String, dynamic>? map, {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = Favicon(
      height: map['height'],
      rel: map['rel'],
      url: WebUri(map['url']),
      width: map['width'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "height": height,
      "rel": rel,
      "url": url.toString(),
      "width": width,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'Favicon{height: $height, rel: $rel, url: $url, width: $width}';
  }
}
