// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_tag.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a `<meta>` HTML tag. It is used by the [PlatformInAppWebViewController.getMetaTags] method.
class MetaTag {
  ///The meta tag attributes list.
  List<MetaTagAttribute>? attrs;

  ///The meta tag content value.
  String? content;

  ///The meta tag name value.
  String? name;
  MetaTag({this.attrs, this.content, this.name});

  ///Gets a possible [MetaTag] instance from a [Map] value.
  static MetaTag? fromMap(Map<String, dynamic>? map, {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = MetaTag(
      attrs: map['attrs'] != null
          ? List<MetaTagAttribute>.from(map['attrs'].map((e) =>
              MetaTagAttribute.fromMap(e?.cast<String, dynamic>(),
                  enumMethod: enumMethod)!))
          : null,
      content: map['content'],
      name: map['name'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "attrs": attrs?.map((e) => e.toMap(enumMethod: enumMethod)).toList(),
      "content": content,
      "name": name,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'MetaTag{attrs: $attrs, content: $content, name: $name}';
  }
}
