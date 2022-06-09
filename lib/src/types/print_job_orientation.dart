import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../print_job/main.dart';

part 'print_job_orientation.g.dart';

///Class representing the orientation of a [PrintJobController].
@ExchangeableEnum()
class PrintJobOrientation_ {
  // ignore: unused_field
  final int _value;
  const PrintJobOrientation_._internal(this._value);

  ///Pages are printed in portrait orientation.
  static const PORTRAIT = const PrintJobOrientation_._internal(0);

  ///Pages are printed in landscape orientation.
  static const LANDSCAPE = const PrintJobOrientation_._internal(1);
}
