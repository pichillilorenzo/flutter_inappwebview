///Class used to specify a `dataDetectoryTypes` value that adds interactivity to web content that matches the value.
class DataDetectorTypes {
  final String _value;

  const DataDetectorTypes._internal(this._value);

  ///Set of all values of [DataDetectorTypes].
  static final Set<DataDetectorTypes> values = [
    DataDetectorTypes.NONE,
    DataDetectorTypes.PHONE_NUMBER,
    DataDetectorTypes.LINK,
    DataDetectorTypes.ADDRESS,
    DataDetectorTypes.CALENDAR_EVENT,
    DataDetectorTypes.TRACKING_NUMBER,
    DataDetectorTypes.FLIGHT_NUMBER,
    DataDetectorTypes.LOOKUP_SUGGESTION,
    DataDetectorTypes.SPOTLIGHT_SUGGESTION,
    DataDetectorTypes.ALL,
  ].toSet();

  ///Gets a possible [DataDetectorTypes] instance from a [String] value.
  static DataDetectorTypes? fromValue(String? value) {
    if (value != null) {
      try {
        return DataDetectorTypes.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  @override
  String toString() => _value;

  ///No detection is performed.
  static const NONE = const DataDetectorTypes._internal("NONE");

  ///Phone numbers are detected and turned into links.
  static const PHONE_NUMBER = const DataDetectorTypes._internal("PHONE_NUMBER");

  ///URLs in text are detected and turned into links.
  static const LINK = const DataDetectorTypes._internal("LINK");

  ///Addresses are detected and turned into links.
  static const ADDRESS = const DataDetectorTypes._internal("ADDRESS");

  ///Dates and times that are in the future are detected and turned into links.
  static const CALENDAR_EVENT =
  const DataDetectorTypes._internal("CALENDAR_EVENT");

  ///Tracking numbers are detected and turned into links.
  static const TRACKING_NUMBER =
  const DataDetectorTypes._internal("TRACKING_NUMBER");

  ///Flight numbers are detected and turned into links.
  static const FLIGHT_NUMBER =
  const DataDetectorTypes._internal("FLIGHT_NUMBER");

  ///Lookup suggestions are detected and turned into links.
  static const LOOKUP_SUGGESTION =
  const DataDetectorTypes._internal("LOOKUP_SUGGESTION");

  ///Spotlight suggestions are detected and turned into links.
  static const SPOTLIGHT_SUGGESTION =
  const DataDetectorTypes._internal("SPOTLIGHT_SUGGESTION");

  ///All of the above data types are turned into links when detected. Choosing this value will automatically include any new detection type that is added.
  static const ALL = const DataDetectorTypes._internal("ALL");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An iOS-specific class used to specify a `dataDetectoryTypes` value that adds interactivity to web content that matches the value.
///
///**NOTE**: available on iOS 10.0+.
///
///Use [DataDetectorTypes] instead.
@Deprecated("Use DataDetectorTypes instead")
class IOSWKDataDetectorTypes {
  final String _value;

  const IOSWKDataDetectorTypes._internal(this._value);

  ///Set of all values of [IOSWKDataDetectorTypes].
  static final Set<IOSWKDataDetectorTypes> values = [
    IOSWKDataDetectorTypes.NONE,
    IOSWKDataDetectorTypes.PHONE_NUMBER,
    IOSWKDataDetectorTypes.LINK,
    IOSWKDataDetectorTypes.ADDRESS,
    IOSWKDataDetectorTypes.CALENDAR_EVENT,
    IOSWKDataDetectorTypes.TRACKING_NUMBER,
    IOSWKDataDetectorTypes.FLIGHT_NUMBER,
    IOSWKDataDetectorTypes.LOOKUP_SUGGESTION,
    IOSWKDataDetectorTypes.SPOTLIGHT_SUGGESTION,
    IOSWKDataDetectorTypes.ALL,
  ].toSet();

  ///Gets a possible [IOSWKDataDetectorTypes] instance from a [String] value.
  static IOSWKDataDetectorTypes? fromValue(String? value) {
    if (value != null) {
      try {
        return IOSWKDataDetectorTypes.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  @override
  String toString() => _value;

  ///No detection is performed.
  static const NONE = const IOSWKDataDetectorTypes._internal("NONE");

  ///Phone numbers are detected and turned into links.
  static const PHONE_NUMBER =
  const IOSWKDataDetectorTypes._internal("PHONE_NUMBER");

  ///URLs in text are detected and turned into links.
  static const LINK = const IOSWKDataDetectorTypes._internal("LINK");

  ///Addresses are detected and turned into links.
  static const ADDRESS = const IOSWKDataDetectorTypes._internal("ADDRESS");

  ///Dates and times that are in the future are detected and turned into links.
  static const CALENDAR_EVENT =
  const IOSWKDataDetectorTypes._internal("CALENDAR_EVENT");

  ///Tracking numbers are detected and turned into links.
  static const TRACKING_NUMBER =
  const IOSWKDataDetectorTypes._internal("TRACKING_NUMBER");

  ///Flight numbers are detected and turned into links.
  static const FLIGHT_NUMBER =
  const IOSWKDataDetectorTypes._internal("FLIGHT_NUMBER");

  ///Lookup suggestions are detected and turned into links.
  static const LOOKUP_SUGGESTION =
  const IOSWKDataDetectorTypes._internal("LOOKUP_SUGGESTION");

  ///Spotlight suggestions are detected and turned into links.
  static const SPOTLIGHT_SUGGESTION =
  const IOSWKDataDetectorTypes._internal("SPOTLIGHT_SUGGESTION");

  ///All of the above data types are turned into links when detected. Choosing this value will automatically include any new detection type that is added.
  static const ALL = const IOSWKDataDetectorTypes._internal("ALL");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}