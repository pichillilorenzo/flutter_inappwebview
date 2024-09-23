import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'web_archive_format.g.dart';

///Class that represents the known Web Archive formats used when saving a web page.
@ExchangeableEnum()
class WebArchiveFormat_ {
  // ignore: unused_field
  final String _value;
  const WebArchiveFormat_._internal(this._value);

  ///Web Archive format used only by Android.
  static const MHT = const WebArchiveFormat_._internal("mht");

  ///Web Archive format used only by iOS.
  static const WEBARCHIVE = const WebArchiveFormat_._internal("webarchive");
}
