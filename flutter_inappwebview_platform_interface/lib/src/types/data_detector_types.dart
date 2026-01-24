import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'data_detector_types.g.dart';

///Class used to specify a `dataDetectoryTypes` value that adds interactivity to web content that matches the value.
@ExchangeableEnum()
class DataDetectorTypes_ {
  // ignore: unused_field
  final String _value;
  const DataDetectorTypes_._internal(this._value);

  ///No detection is performed.
  static const NONE = const DataDetectorTypes_._internal("NONE");

  ///Phone numbers are detected and turned into links.
  static const PHONE_NUMBER = const DataDetectorTypes_._internal(
    "PHONE_NUMBER",
  );

  ///URLs in text are detected and turned into links.
  static const LINK = const DataDetectorTypes_._internal("LINK");

  ///Addresses are detected and turned into links.
  static const ADDRESS = const DataDetectorTypes_._internal("ADDRESS");

  ///Dates and times that are in the future are detected and turned into links.
  static const CALENDAR_EVENT = const DataDetectorTypes_._internal(
    "CALENDAR_EVENT",
  );

  ///Tracking numbers are detected and turned into links.
  static const TRACKING_NUMBER = const DataDetectorTypes_._internal(
    "TRACKING_NUMBER",
  );

  ///Flight numbers are detected and turned into links.
  static const FLIGHT_NUMBER = const DataDetectorTypes_._internal(
    "FLIGHT_NUMBER",
  );

  ///Lookup suggestions are detected and turned into links.
  static const LOOKUP_SUGGESTION = const DataDetectorTypes_._internal(
    "LOOKUP_SUGGESTION",
  );

  ///Spotlight suggestions are detected and turned into links.
  static const SPOTLIGHT_SUGGESTION = const DataDetectorTypes_._internal(
    "SPOTLIGHT_SUGGESTION",
  );

  ///All of the above data types are turned into links when detected. Choosing this value will automatically include any new detection type that is added.
  static const ALL = const DataDetectorTypes_._internal("ALL");
}

///An iOS-specific class used to specify a `dataDetectoryTypes` value that adds interactivity to web content that matches the value.
///
///**NOTE**: available on iOS 10.0+.
///
///Use [DataDetectorTypes] instead.
@Deprecated("Use DataDetectorTypes instead")
@ExchangeableEnum()
class IOSWKDataDetectorTypes_ {
  // ignore: unused_field
  final String _value;
  const IOSWKDataDetectorTypes_._internal(this._value);

  ///No detection is performed.
  static const NONE = const IOSWKDataDetectorTypes_._internal("NONE");

  ///Phone numbers are detected and turned into links.
  static const PHONE_NUMBER = const IOSWKDataDetectorTypes_._internal(
    "PHONE_NUMBER",
  );

  ///URLs in text are detected and turned into links.
  static const LINK = const IOSWKDataDetectorTypes_._internal("LINK");

  ///Addresses are detected and turned into links.
  static const ADDRESS = const IOSWKDataDetectorTypes_._internal("ADDRESS");

  ///Dates and times that are in the future are detected and turned into links.
  static const CALENDAR_EVENT = const IOSWKDataDetectorTypes_._internal(
    "CALENDAR_EVENT",
  );

  ///Tracking numbers are detected and turned into links.
  static const TRACKING_NUMBER = const IOSWKDataDetectorTypes_._internal(
    "TRACKING_NUMBER",
  );

  ///Flight numbers are detected and turned into links.
  static const FLIGHT_NUMBER = const IOSWKDataDetectorTypes_._internal(
    "FLIGHT_NUMBER",
  );

  ///Lookup suggestions are detected and turned into links.
  static const LOOKUP_SUGGESTION = const IOSWKDataDetectorTypes_._internal(
    "LOOKUP_SUGGESTION",
  );

  ///Spotlight suggestions are detected and turned into links.
  static const SPOTLIGHT_SUGGESTION = const IOSWKDataDetectorTypes_._internal(
    "SPOTLIGHT_SUGGESTION",
  );

  ///All of the above data types are turned into links when detected. Choosing this value will automatically include any new detection type that is added.
  static const ALL = const IOSWKDataDetectorTypes_._internal("ALL");
}
