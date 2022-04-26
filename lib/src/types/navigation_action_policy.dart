import '../in_app_webview/webview.dart';

///Class that is used by [WebView.shouldOverrideUrlLoading] event.
///It represents the policy to pass back to the decision handler.
class NavigationActionPolicy {
  final int _value;

  const NavigationActionPolicy._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Cancel the navigation.
  static const CANCEL = const NavigationActionPolicy._internal(0);

  ///Allow the navigation to continue.
  static const ALLOW = const NavigationActionPolicy._internal(1);

  ///Turn the navigation into a download.
  ///
  ///**NOTE**: available only on iOS 14.5+. It will fallback to [CANCEL].
  static const DOWNLOAD = const NavigationActionPolicy._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "action": _value,
    };
  }
}