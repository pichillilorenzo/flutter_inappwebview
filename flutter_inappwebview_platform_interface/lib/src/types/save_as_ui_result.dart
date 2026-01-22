import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'save_as_ui_result.g.dart';

///Constants that describe the result of a programmatic Save As call.
@ExchangeableEnum()
class SaveAsUIResult_ {
  // ignore: unused_field
  final int _value;
  const SaveAsUIResult_._internal(this._value);

  ///The Save As operation completed successfully.
  static const SUCCESS = SaveAsUIResult_._internal(0);

  ///The destination file path is invalid.
  static const INVALID_PATH = SaveAsUIResult_._internal(1);

  ///The destination file path already exists.
  static const FILE_ALREADY_EXISTS = SaveAsUIResult_._internal(2);

  ///The selected Save As kind is not supported.
  static const KIND_NOT_SUPPORTED = SaveAsUIResult_._internal(3);

  ///The user cancelled the Save As operation.
  static const CANCELLED = SaveAsUIResult_._internal(4);
}
