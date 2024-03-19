// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_detector_types.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to specify a `dataDetectoryTypes` value that adds interactivity to web content that matches the value.
class DataDetectorTypes {
  final String _value;
  final String _nativeValue;
  const DataDetectorTypes._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory DataDetectorTypes._internalMultiPlatform(
          String value, Function nativeValue) =>
      DataDetectorTypes._internal(value, nativeValue());

  ///Addresses are detected and turned into links.
  static const ADDRESS = DataDetectorTypes._internal('ADDRESS', 'ADDRESS');

  ///All of the above data types are turned into links when detected. Choosing this value will automatically include any new detection type that is added.
  static const ALL = DataDetectorTypes._internal('ALL', 'ALL');

  ///Dates and times that are in the future are detected and turned into links.
  static const CALENDAR_EVENT =
      DataDetectorTypes._internal('CALENDAR_EVENT', 'CALENDAR_EVENT');

  ///Flight numbers are detected and turned into links.
  static const FLIGHT_NUMBER =
      DataDetectorTypes._internal('FLIGHT_NUMBER', 'FLIGHT_NUMBER');

  ///URLs in text are detected and turned into links.
  static const LINK = DataDetectorTypes._internal('LINK', 'LINK');

  ///Lookup suggestions are detected and turned into links.
  static const LOOKUP_SUGGESTION =
      DataDetectorTypes._internal('LOOKUP_SUGGESTION', 'LOOKUP_SUGGESTION');

  ///No detection is performed.
  static const NONE = DataDetectorTypes._internal('NONE', 'NONE');

  ///Phone numbers are detected and turned into links.
  static const PHONE_NUMBER =
      DataDetectorTypes._internal('PHONE_NUMBER', 'PHONE_NUMBER');

  ///Spotlight suggestions are detected and turned into links.
  static const SPOTLIGHT_SUGGESTION = DataDetectorTypes._internal(
      'SPOTLIGHT_SUGGESTION', 'SPOTLIGHT_SUGGESTION');

  ///Tracking numbers are detected and turned into links.
  static const TRACKING_NUMBER =
      DataDetectorTypes._internal('TRACKING_NUMBER', 'TRACKING_NUMBER');

  ///Set of all values of [DataDetectorTypes].
  static final Set<DataDetectorTypes> values = [
    DataDetectorTypes.ADDRESS,
    DataDetectorTypes.ALL,
    DataDetectorTypes.CALENDAR_EVENT,
    DataDetectorTypes.FLIGHT_NUMBER,
    DataDetectorTypes.LINK,
    DataDetectorTypes.LOOKUP_SUGGESTION,
    DataDetectorTypes.NONE,
    DataDetectorTypes.PHONE_NUMBER,
    DataDetectorTypes.SPOTLIGHT_SUGGESTION,
    DataDetectorTypes.TRACKING_NUMBER,
  ].toSet();

  ///Gets a possible [DataDetectorTypes] instance from [String] value.
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

  ///Gets a possible [DataDetectorTypes] instance from a native value.
  static DataDetectorTypes? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return DataDetectorTypes.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}

///An iOS-specific class used to specify a `dataDetectoryTypes` value that adds interactivity to web content that matches the value.
///
///**NOTE**: available on iOS 10.0+.
///
///Use [DataDetectorTypes] instead.
@Deprecated('Use DataDetectorTypes instead')
class IOSWKDataDetectorTypes {
  final String _value;
  final String _nativeValue;
  const IOSWKDataDetectorTypes._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory IOSWKDataDetectorTypes._internalMultiPlatform(
          String value, Function nativeValue) =>
      IOSWKDataDetectorTypes._internal(value, nativeValue());

  ///Addresses are detected and turned into links.
  static const ADDRESS = IOSWKDataDetectorTypes._internal('ADDRESS', 'ADDRESS');

  ///All of the above data types are turned into links when detected. Choosing this value will automatically include any new detection type that is added.
  static const ALL = IOSWKDataDetectorTypes._internal('ALL', 'ALL');

  ///Dates and times that are in the future are detected and turned into links.
  static const CALENDAR_EVENT =
      IOSWKDataDetectorTypes._internal('CALENDAR_EVENT', 'CALENDAR_EVENT');

  ///Flight numbers are detected and turned into links.
  static const FLIGHT_NUMBER =
      IOSWKDataDetectorTypes._internal('FLIGHT_NUMBER', 'FLIGHT_NUMBER');

  ///URLs in text are detected and turned into links.
  static const LINK = IOSWKDataDetectorTypes._internal('LINK', 'LINK');

  ///Lookup suggestions are detected and turned into links.
  static const LOOKUP_SUGGESTION = IOSWKDataDetectorTypes._internal(
      'LOOKUP_SUGGESTION', 'LOOKUP_SUGGESTION');

  ///No detection is performed.
  static const NONE = IOSWKDataDetectorTypes._internal('NONE', 'NONE');

  ///Phone numbers are detected and turned into links.
  static const PHONE_NUMBER =
      IOSWKDataDetectorTypes._internal('PHONE_NUMBER', 'PHONE_NUMBER');

  ///Spotlight suggestions are detected and turned into links.
  static const SPOTLIGHT_SUGGESTION = IOSWKDataDetectorTypes._internal(
      'SPOTLIGHT_SUGGESTION', 'SPOTLIGHT_SUGGESTION');

  ///Tracking numbers are detected and turned into links.
  static const TRACKING_NUMBER =
      IOSWKDataDetectorTypes._internal('TRACKING_NUMBER', 'TRACKING_NUMBER');

  ///Set of all values of [IOSWKDataDetectorTypes].
  static final Set<IOSWKDataDetectorTypes> values = [
    IOSWKDataDetectorTypes.ADDRESS,
    IOSWKDataDetectorTypes.ALL,
    IOSWKDataDetectorTypes.CALENDAR_EVENT,
    IOSWKDataDetectorTypes.FLIGHT_NUMBER,
    IOSWKDataDetectorTypes.LINK,
    IOSWKDataDetectorTypes.LOOKUP_SUGGESTION,
    IOSWKDataDetectorTypes.NONE,
    IOSWKDataDetectorTypes.PHONE_NUMBER,
    IOSWKDataDetectorTypes.SPOTLIGHT_SUGGESTION,
    IOSWKDataDetectorTypes.TRACKING_NUMBER,
  ].toSet();

  ///Gets a possible [IOSWKDataDetectorTypes] instance from [String] value.
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

  ///Gets a possible [IOSWKDataDetectorTypes] instance from a native value.
  static IOSWKDataDetectorTypes? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return IOSWKDataDetectorTypes.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
