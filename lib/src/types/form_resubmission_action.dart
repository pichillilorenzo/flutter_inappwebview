import '../in_app_webview/webview.dart';

///Class that represents the action to take used by the [WebView.onFormResubmission] event.
class FormResubmissionAction {
  final int _value;

  const FormResubmissionAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Resend data
  static const RESEND = const FormResubmissionAction._internal(0);

  ///Don't resend data
  static const DONT_RESEND = const FormResubmissionAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"action": _value};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}