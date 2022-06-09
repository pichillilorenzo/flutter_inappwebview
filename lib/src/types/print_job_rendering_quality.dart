import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../print_job/main.dart';

part 'print_job_rendering_quality.g.dart';

///Class representing the rendering quality of a [PrintJobController].
@ExchangeableEnum()
class PrintJobRenderingQuality_ {
  // ignore: unused_field
  final int _value;
  const PrintJobRenderingQuality_._internal(this._value);

  ///Renders the printing at the best possible quality, regardless of speed.
  static const BEST = const PrintJobRenderingQuality_._internal(0);

  ///Sacrifices the least possible amount of rendering quality for speed to maintain a responsive user interface.
  ///This option should be used only after establishing that best quality rendering does indeed make the user interface unresponsive.
  static const RESPONSIVE = const PrintJobRenderingQuality_._internal(1);
}
