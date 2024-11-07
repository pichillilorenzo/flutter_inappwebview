import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'web_resource_error_type.dart';
import 'enum_method.dart';

part 'web_resource_error.g.dart';

///Encapsulates information about errors occurred during loading of web resources.
@ExchangeableObject()
class WebResourceError_ {
  ///The type of the error.
  WebResourceErrorType_ type;

  ///The string describing the error.
  String description;

  WebResourceError_({required this.type, required this.description});
}
