// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favicon.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a favicon of a website. It is used by [InAppWebViewController.getFavicons] method.
class Favicon {
  ///The url of the favicon image.
  Uri url;

  ///The relationship between the current web page and the favicon image.
  String? rel;

  ///The width of the favicon image.
  int? width;

  ///The height of the favicon image.
  int? height;
  Favicon({required this.url, this.rel, this.width, this.height});

  ///Gets a possible [Favicon] instance from a [Map] value.
  static Favicon? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = Favicon(
      url: Uri.parse(map['url']),
      rel: map['rel'],
      width: map['width'],
      height: map['height'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "url": url.toString(),
      "rel": rel,
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
    return 'Favicon{url: $url, rel: $rel, width: $width, height: $height}';
  }
}
