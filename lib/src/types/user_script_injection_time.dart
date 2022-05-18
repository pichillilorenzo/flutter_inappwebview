import '../in_app_webview/webview.dart';
import 'user_script.dart';

///Class that represents contains the constants for the times at which to inject script content into a [WebView] used by an [UserScript].
class UserScriptInjectionTime {
  final int _value;

  const UserScriptInjectionTime._internal(this._value);

  ///Set of all values of [UserScriptInjectionTime].
  static final Set<UserScriptInjectionTime> values = [
    UserScriptInjectionTime.AT_DOCUMENT_START,
    UserScriptInjectionTime.AT_DOCUMENT_END,
  ].toSet();

  ///Gets a possible [UserScriptInjectionTime] instance from an [int] value.
  static UserScriptInjectionTime? fromValue(int? value) {
    if (value != null) {
      try {
        return UserScriptInjectionTime.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "AT_DOCUMENT_END";
      case 0:
      default:
        return "AT_DOCUMENT_START";
    }
  }

  ///**NOTE for iOS**: A constant to inject the script after the creation of the webpage’s document element, but before loading any other content.
  ///
  ///**NOTE for Android**: A constant to try to inject the script as soon as the page starts loading.
  static const AT_DOCUMENT_START = const UserScriptInjectionTime._internal(0);

  ///**NOTE for iOS**: A constant to inject the script after the document finishes loading, but before loading any other subresources.
  ///
  ///**NOTE for Android**: A constant to inject the script as soon as the page finishes loading.
  static const AT_DOCUMENT_END = const UserScriptInjectionTime._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}