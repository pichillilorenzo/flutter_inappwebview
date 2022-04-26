import '../in_app_webview/webview.dart';

///Class that is used by [WebView.onNavigationResponse] event.
///It represents the policy to pass back to the decision handler.
class NavigationResponseAction {
  final int _value;

  const NavigationResponseAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Cancel the navigation.
  static const CANCEL = const NavigationResponseAction._internal(0);

  ///Allow the navigation to continue.
  static const ALLOW = const NavigationResponseAction._internal(1);

  ///Turn the navigation into a download.
  ///
  ///**NOTE**: available only on iOS 14.5+. It will fallback to [CANCEL].
  static const DOWNLOAD = const NavigationResponseAction._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  Map<String, dynamic> toMap() {
    return {
      "action": _value,
    };
  }
}

///Class that is used by [WebView.onNavigationResponse] event.
///It represents the policy to pass back to the decision handler.
///Use [NavigationResponseAction] instead.
@Deprecated("Use NavigationResponseAction instead")
class IOSNavigationResponseAction {
  final int _value;

  const IOSNavigationResponseAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Cancel the navigation.
  static const CANCEL = const IOSNavigationResponseAction._internal(0);

  ///Allow the navigation to continue.
  static const ALLOW = const IOSNavigationResponseAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  Map<String, dynamic> toMap() {
    return {
      "action": _value,
    };
  }
}