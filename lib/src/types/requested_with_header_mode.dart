import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'requested_with_header_mode.g.dart';

///Class used to set how the WebView will set the `X-Requested-With` header on requests.
@ExchangeableEnum()
class RequestedWithHeaderMode_ {
  // ignore: unused_field
  final int _value;
  const RequestedWithHeaderMode_._internal(this._value);

  ///In this mode the WebView will not add an `X-Requested-With` header on HTTP requests automatically.
  static const NO_HEADER = const RequestedWithHeaderMode_._internal(0);

  ///In this mode the WebView automatically add an `X-Requested-With` header to outgoing requests,
  ///if the application or the loaded webpage has not already set a header value.
  ///The value of this automatically added header will be the package name of the app. This is the default mode.
  static const APP_PACKAGE_NAME = const RequestedWithHeaderMode_._internal(1);
}
