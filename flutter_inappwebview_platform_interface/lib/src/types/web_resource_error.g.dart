// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_resource_error.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Encapsulates information about errors occurred during loading of web resources.
class WebResourceError {
  ///The string describing the error.
  String description;

  ///The type of the error.
  WebResourceErrorType type;
  WebResourceError({required this.description, required this.type});

  ///Gets a possible [WebResourceError] instance from a [Map] value.
  static WebResourceError? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = WebResourceError(
      description: map['description'],
      type: WebResourceErrorType.fromNativeValue(map['type'])!,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "description": description,
      "type": type.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebResourceError{description: $description, type: $type}';
  }
}
