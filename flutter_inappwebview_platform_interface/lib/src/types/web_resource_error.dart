import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'web_resource_error_type.dart';
import 'enum_method.dart';

part 'web_resource_error.g.dart';

WebResourceErrorType _typeDeserializer(
  dynamic value, {
  EnumMethod? enumMethod,
}) {
  // Native error codes that are not mapped to a WebResourceErrorType
  // (for example new platform error codes) must not throw a null check error.
  return switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => WebResourceErrorType.fromNativeValue(value),
        EnumMethod.value => WebResourceErrorType.fromValue(value),
        EnumMethod.name => WebResourceErrorType.byName(value),
      } ??
      WebResourceErrorType.UNKNOWN;
}

///Encapsulates information about errors occurred during loading of web resources.
@ExchangeableObject()
class WebResourceError_ {
  ///The type of the error.
  ///
  ///If the native error code is not known, [WebResourceErrorType.UNKNOWN] is used.
  @ExchangeableObjectProperty(deserializer: _typeDeserializer)
  WebResourceErrorType_ type;

  ///The string describing the error.
  String description;

  WebResourceError_({required this.type, required this.description});
}
