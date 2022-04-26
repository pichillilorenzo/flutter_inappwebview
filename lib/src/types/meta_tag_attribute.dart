import 'meta_tag.dart';

///Class that represents an attribute of a `<meta>` HTML tag. It is used by the [MetaTag] class.
class MetaTagAttribute {
  ///The attribute name.
  String? name;

  ///The attribute value.
  String? value;

  MetaTagAttribute({this.name, this.value});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "value": value,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}