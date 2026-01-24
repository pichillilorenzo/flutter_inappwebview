import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../print_job/main.dart';

part 'print_job_dialog_kind.g.dart';

///Class representing the print dialog kind used by a [PlatformPrintJobController].
@ExchangeableEnum()
class PrintJobDialogKind_ {
  // ignore: unused_field
  final int _value;
  const PrintJobDialogKind_._internal(this._value);

  ///Use the browser print dialog UI.
  static const BROWSER = PrintJobDialogKind_._internal(0);

  ///Use the system print dialog UI.
  static const SYSTEM = PrintJobDialogKind_._internal(1);
}
