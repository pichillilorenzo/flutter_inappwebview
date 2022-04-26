import '../in_app_webview/webview.dart';

///Class that is used by [WebView.shouldAllowDeprecatedTLS] event.
///It represents the policy to pass back to the decision handler.
class ShouldAllowDeprecatedTLSAction {
  final int _value;

  const ShouldAllowDeprecatedTLSAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Cancel the navigation.
  static const CANCEL = const ShouldAllowDeprecatedTLSAction._internal(0);

  ///Allow the navigation to continue.
  static const ALLOW = const ShouldAllowDeprecatedTLSAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  Map<String, dynamic> toMap() {
    return {
      "action": _value,
    };
  }
}

///Class that is used by [WebView.shouldAllowDeprecatedTLS] event.
///It represents the policy to pass back to the decision handler.
///Use [ShouldAllowDeprecatedTLSAction] instead.
@Deprecated("Use ShouldAllowDeprecatedTLSAction instead")
class IOSShouldAllowDeprecatedTLSAction {
  final int _value;

  const IOSShouldAllowDeprecatedTLSAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Cancel the navigation.
  static const CANCEL = const IOSShouldAllowDeprecatedTLSAction._internal(0);

  ///Allow the navigation to continue.
  static const ALLOW = const IOSShouldAllowDeprecatedTLSAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  Map<String, dynamic> toMap() {
    return {
      "action": _value,
    };
  }
}