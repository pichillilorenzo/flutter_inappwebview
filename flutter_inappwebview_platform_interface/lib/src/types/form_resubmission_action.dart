import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import '../in_app_webview/platform_webview.dart';
part 'form_resubmission_action.g.dart';

///Class that represents the action to take used by the [PlatformWebViewCreationParams.onFormResubmission] event.
@ExchangeableEnum()
class FormResubmissionAction_ {
  // ignore: unused_field
  final int _value;
  const FormResubmissionAction_._internal(this._value);

  ///Resend data
  static const RESEND = const FormResubmissionAction_._internal(0);

  ///Don't resend data
  static const DONT_RESEND = const FormResubmissionAction_._internal(1);
}
