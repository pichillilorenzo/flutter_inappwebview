// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_tag.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a `<meta>` HTML tag. It is used by the [InAppWebViewController.getMetaTags] method.
class MetaTag {
  ///The meta tag name value.
  String? name;

  ///The meta tag content value.
  String? content;

  ///The meta tag attributes list.
  List<MetaTagAttribute>? attrs;
  MetaTag({this.name, this.content, this.attrs});

  ///Gets a possible [MetaTag] instance from a [Map] value.
  static MetaTag? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = MetaTag(
      name: map['name'],
      content: map['content'],
      attrs: map['attrs'] != null
          ? List<MetaTagAttribute>.from(map['attrs'].map(
              (e) => MetaTagAttribute.fromMap(e?.cast<String, dynamic>())!))
          : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "content": content,
      "attrs": attrs?.map((e) => e.toMap()).toList(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'MetaTag{name: $name, content: $content, attrs: $attrs}';
  }
}
