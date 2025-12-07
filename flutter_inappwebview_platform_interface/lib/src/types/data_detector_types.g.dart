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

  /// Gets a possible [DataDetectorTypes] instance value with name [name].
  ///
  /// Goes through [DataDetectorTypes.values] looking for a value with
  /// name [name], as reported by [DataDetectorTypes.name].
  /// Returns the first value with the given name, otherwise `null`.
  static DataDetectorTypes? byName(String? name) {
    if (name != null) {
      try {
        return DataDetectorTypes.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [DataDetectorTypes] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, DataDetectorTypes> asNameMap() =>
      <String, DataDetectorTypes>{
        for (final value in DataDetectorTypes.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'ADDRESS':
        return 'ADDRESS';
      case 'ALL':
        return 'ALL';
      case 'CALENDAR_EVENT':
        return 'CALENDAR_EVENT';
      case 'FLIGHT_NUMBER':
        return 'FLIGHT_NUMBER';
      case 'LINK':
        return 'LINK';
      case 'LOOKUP_SUGGESTION':
        return 'LOOKUP_SUGGESTION';
      case 'NONE':
        return 'NONE';
      case 'PHONE_NUMBER':
        return 'PHONE_NUMBER';
      case 'SPOTLIGHT_SUGGESTION':
        return 'SPOTLIGHT_SUGGESTION';
      case 'TRACKING_NUMBER':
        return 'TRACKING_NUMBER';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return true;
  }

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

  /// Gets a possible [IOSWKDataDetectorTypes] instance value with name [name].
  ///
  /// Goes through [IOSWKDataDetectorTypes.values] looking for a value with
  /// name [name], as reported by [IOSWKDataDetectorTypes.name].
  /// Returns the first value with the given name, otherwise `null`.
  static IOSWKDataDetectorTypes? byName(String? name) {
    if (name != null) {
      try {
        return IOSWKDataDetectorTypes.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [IOSWKDataDetectorTypes] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, IOSWKDataDetectorTypes> asNameMap() =>
      <String, IOSWKDataDetectorTypes>{
        for (final value in IOSWKDataDetectorTypes.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'ADDRESS':
        return 'ADDRESS';
      case 'ALL':
        return 'ALL';
      case 'CALENDAR_EVENT':
        return 'CALENDAR_EVENT';
      case 'FLIGHT_NUMBER':
        return 'FLIGHT_NUMBER';
      case 'LINK':
        return 'LINK';
      case 'LOOKUP_SUGGESTION':
        return 'LOOKUP_SUGGESTION';
      case 'NONE':
        return 'NONE';
      case 'PHONE_NUMBER':
        return 'PHONE_NUMBER';
      case 'SPOTLIGHT_SUGGESTION':
        return 'SPOTLIGHT_SUGGESTION';
      case 'TRACKING_NUMBER':
        return 'TRACKING_NUMBER';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return true;
  }

  @override
  String toString() {
    return _value;
  }
}
