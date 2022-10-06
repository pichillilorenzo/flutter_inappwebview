import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../print_job/main.dart';

part 'print_job_color_mode.g.dart';

///Class representing how the printed content of a [PrintJobController] should be laid out.
@ExchangeableEnum()
class PrintJobColorMode_ {
  // ignore: unused_field
  final int _value;
  const PrintJobColorMode_._internal(this._value);

  ///Monochrome color scheme, for example one color is used.
  static const MONOCHROME = const PrintJobColorMode_._internal(1);

  ///Color color scheme, for example many colors are used.
  static const COLOR = const PrintJobColorMode_._internal(2);
}
