// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_resource_error.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

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
    final instance = WebResourceError(
      type: WebResourceErrorType.fromNativeValue(map['type'])!,
      description: map['description'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "type": type.toNativeValue(),
      "description": description,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebResourceError{type: $type, description: $description}';
  }
}
