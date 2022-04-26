import 'safe_browsing_response.dart';

///Class used by [SafeBrowsingResponse] class.
class SafeBrowsingResponseAction {
  final int _value;

  const SafeBrowsingResponseAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Act as if the user clicked the "back to safety" button.
  static const BACK_TO_SAFETY = const SafeBrowsingResponseAction._internal(0);

  ///Act as if the user clicked the "visit this unsafe site" button.
  static const PROCEED = const SafeBrowsingResponseAction._internal(1);

  ///Display the default interstitial.
  static const SHOW_INTERSTITIAL =
  const SafeBrowsingResponseAction._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}