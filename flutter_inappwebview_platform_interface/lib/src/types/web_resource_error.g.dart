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
  ///
  ///If the native error code is not known, [WebResourceErrorType.UNKNOWN] is used.
  WebResourceErrorType type;
  WebResourceError({required this.description, required this.type});

  ///Gets a possible [WebResourceError] instance from a [Map] value.
  static WebResourceError? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebResourceError(
      description: map['description'],
      type: _typeDeserializer(map['type'], enumMethod: enumMethod),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "description": description,
      "type": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => type.toNativeValue(),
        EnumMethod.value => type.toValue(),
        EnumMethod.name => type.name(),
      },
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
