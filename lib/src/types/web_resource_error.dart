import 'web_resource_error_type.dart';

///Encapsulates information about errors occurred during loading of web resources.
class WebResourceError {
  ///The type of the error.
  WebResourceErrorType type;

  ///The string describing the error.
  String description;

  WebResourceError({required this.type, required this.description});

  ///Gets a possible [WebResourceError] instance from a [Map] value.
  static WebResourceError? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    return WebResourceError(
        type: WebResourceErrorType.fromIntValue(map["errorCode"])!,
        description: map["description"]
    );
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "description": description
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