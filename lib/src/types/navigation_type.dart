import '../in_app_webview/webview.dart';

///Class that represents the type of action triggering a navigation for the [WebView.shouldOverrideUrlLoading] event.
class NavigationType {
  final int _value;

  const NavigationType._internal(this._value);

  ///Set of all values of [NavigationType].
  static final Set<NavigationType> values = [
    NavigationType.LINK_ACTIVATED,
    NavigationType.FORM_SUBMITTED,
    NavigationType.BACK_FORWARD,
    NavigationType.RELOAD,
    NavigationType.FORM_RESUBMITTED,
    NavigationType.OTHER,
  ].toSet();

  ///Gets a possible [NavigationType] instance from an [int] value.
  static NavigationType? fromValue(int? value) {
    if (value != null) {
      try {
        return NavigationType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///A link with an href attribute was activated by the user.
  static const LINK_ACTIVATED = const NavigationType._internal(0);

  ///A form was submitted.
  static const FORM_SUBMITTED = const NavigationType._internal(1);

  ///An item from the back-forward list was requested.
  static const BACK_FORWARD = const NavigationType._internal(2);

  ///The webpage was reloaded.
  static const RELOAD = const NavigationType._internal(3);

  ///A form was resubmitted (for example by going back, going forward, or reloading).
  static const FORM_RESUBMITTED = const NavigationType._internal(4);

  ///Navigation is taking place for some other reason.
  static const OTHER = const NavigationType._internal(-1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() {
    switch (_value) {
      case 0:
        return "LINK_ACTIVATED";
      case 1:
        return "FORM_SUBMITTED";
      case 2:
        return "BACK_FORWARD";
      case 3:
        return "RELOAD";
      case 4:
        return "FORM_RESUBMITTED";
      case -1:
      default:
        return "OTHER";
    }
  }
}

///Class that represents the type of action triggering a navigation on iOS for the [WebView.shouldOverrideUrlLoading] event.
///Use [NavigationType] instead.
@Deprecated("Use NavigationType instead")
class IOSWKNavigationType {
  final int _value;

  const IOSWKNavigationType._internal(this._value);

  ///Set of all values of [IOSWKNavigationType].
  static final Set<IOSWKNavigationType> values = [
    IOSWKNavigationType.LINK_ACTIVATED,
    IOSWKNavigationType.FORM_SUBMITTED,
    IOSWKNavigationType.BACK_FORWARD,
    IOSWKNavigationType.RELOAD,
    IOSWKNavigationType.FORM_RESUBMITTED,
    IOSWKNavigationType.OTHER,
  ].toSet();

  ///Gets a possible [IOSWKNavigationType] instance from an [int] value.
  static IOSWKNavigationType? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSWKNavigationType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///A link with an href attribute was activated by the user.
  static const LINK_ACTIVATED = const IOSWKNavigationType._internal(0);

  ///A form was submitted.
  static const FORM_SUBMITTED = const IOSWKNavigationType._internal(1);

  ///An item from the back-forward list was requested.
  static const BACK_FORWARD = const IOSWKNavigationType._internal(2);

  ///The webpage was reloaded.
  static const RELOAD = const IOSWKNavigationType._internal(3);

  ///A form was resubmitted (for example by going back, going forward, or reloading).
  static const FORM_RESUBMITTED = const IOSWKNavigationType._internal(4);

  ///Navigation is taking place for some other reason.
  static const OTHER = const IOSWKNavigationType._internal(-1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() {
    switch (_value) {
      case 0:
        return "LINK_ACTIVATED";
      case 1:
        return "FORM_SUBMITTED";
      case 2:
        return "BACK_FORWARD";
      case 3:
        return "RELOAD";
      case 4:
        return "FORM_RESUBMITTED";
      case -1:
      default:
        return "OTHER";
    }
  }
}