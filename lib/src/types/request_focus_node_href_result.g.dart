// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_focus_node_href_result.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the result used by the [InAppWebViewController.requestFocusNodeHref] method.
class RequestFocusNodeHrefResult {
  ///The anchor's href attribute.
  Uri? url;

  ///The anchor's text.
  String? title;

  ///The image's src attribute.
  String? src;
  RequestFocusNodeHrefResult({this.url, this.title, this.src});

  ///Gets a possible [RequestFocusNodeHrefResult] instance from a [Map] value.
  static RequestFocusNodeHrefResult? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = RequestFocusNodeHrefResult(
      url: map['url'] != null ? Uri.parse(map['url']) : null,
      title: map['title'],
      src: map['src'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "title": title,
      "src": src,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'RequestFocusNodeHrefResult{url: $url, title: $title, src: $src}';
  }
}
