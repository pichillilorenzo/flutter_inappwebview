import 'url_request.dart';

///Class that represents the constants used to indicate the entities that can make a network request.
class URLRequestAttribution {
  final int _value;

  const URLRequestAttribution._internal(this._value);

  ///Set of all values of [URLRequestAttribution].
  static final Set<URLRequestAttribution> values = [
    URLRequestAttribution.DEVELOPER,
    URLRequestAttribution.USER,
  ].toSet();

  ///Gets a possible [URLRequestAttribution] instance from an [int] value.
  static URLRequestAttribution? fromValue(int? value) {
    if (value != null) {
      try {
        return URLRequestAttribution.values
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
        return "USER";
      case 0:
      default:
        return "DEVELOPER";
    }
  }

  ///A developer-initiated network request.
  ///
  ///Use this value for the attribution parameter of a [URLRequest] that your app makes for any purpose other than when the user explicitly accesses a link.
  ///This includes requests that your app makes to get user data. This is the default value.
  ///
  ///For cases where the user enters a URL, like in the navigation bar of a web browser, or taps or clicks a URL to load the content it represents, use the [URLRequestAttribution.USER] value instead.
  static const DEVELOPER =
  const URLRequestAttribution._internal(0);

  ///Use this value for the attribution parameter of a [URLRequest] that satisfies a user request to access an explicit, unmodified URL.
  ///In all other cases, use the [URLRequestAttribution.DEVELOPER] value instead.
  static const USER =
  const URLRequestAttribution._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}