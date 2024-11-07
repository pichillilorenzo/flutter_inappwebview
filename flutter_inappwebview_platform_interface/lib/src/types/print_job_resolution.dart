import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../print_job/main.dart';
import 'enum_method.dart';

part 'print_job_resolution.g.dart';

///Class representing the supported resolution in DPI (dots per inch) for a [PlatformPrintJobController].
///Resolution defines how many points with different color can be placed
///on one inch in horizontal or vertical direction of the target media.
///For example, a printer with 600 DPI can produce higher quality images
///the one with 300 DPI resolution.
@ExchangeableObject()
class PrintJobResolution_ {
  ///The unique resolution id.
  ///
  ///It is unique amongst other resolutions supported by the printer.
  ///This id is defined by the client that generated the resolution
  ///instance and should not be interpreted by other parties.
  final String id;

  ///The human readable label.
  final String label;

  ///The vertical resolution in DPI (dots per inch).
  final int verticalDpi;

  ///The horizontal resolution in DPI (dots per inch).
  final int horizontalDpi;

  const PrintJobResolution_(
      {required this.id,
      required this.label,
      required this.verticalDpi,
      required this.horizontalDpi});
}
