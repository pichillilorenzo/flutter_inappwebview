// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ajax_request_event_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [AjaxRequestEvent] class.
class AjaxRequestEventType {
  final String _value;
  final String _nativeValue;
  const AjaxRequestEventType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory AjaxRequestEventType._internalMultiPlatform(
          String value, Function nativeValue) =>
      AjaxRequestEventType._internal(value, nativeValue());

  ///The ABORT event is fired when a request has been aborted.
  static const ABORT = AjaxRequestEventType._internal('abort', 'abort');

  ///The ERROR event is fired when the request encountered an error.
  static const ERROR = AjaxRequestEventType._internal('error', 'error');

  ///The LOAD event is fired when an `XMLHttpRequest` transaction completes successfully.
  static const LOAD = AjaxRequestEventType._internal('load', 'load');

  ///The LOADEND event is fired when a request has completed, whether successfully (after [AjaxRequestEventType.LOAD]) or
  ///unsuccessfully (after [AjaxRequestEventType.ABORT] or [AjaxRequestEventType.ERROR]).
  static const LOADEND = AjaxRequestEventType._internal('loadend', 'loadend');

  ///The LOADSTART event is fired when a request has started to load data.
  static const LOADSTART =
      AjaxRequestEventType._internal('loadstart', 'loadstart');

  ///The PROGRESS event is fired periodically when a request receives more data.
  static const PROGRESS =
      AjaxRequestEventType._internal('progress', 'progress');

  ///The TIMEOUT event is fired when progression is terminated due to preset time expiring.
  static const TIMEOUT = AjaxRequestEventType._internal('timeout', 'timeout');

  ///Set of all values of [AjaxRequestEventType].
  static final Set<AjaxRequestEventType> values = [
    AjaxRequestEventType.ABORT,
    AjaxRequestEventType.ERROR,
    AjaxRequestEventType.LOAD,
    AjaxRequestEventType.LOADEND,
    AjaxRequestEventType.LOADSTART,
    AjaxRequestEventType.PROGRESS,
    AjaxRequestEventType.TIMEOUT,
  ].toSet();

  ///Gets a possible [AjaxRequestEventType] instance from [String] value.
  static AjaxRequestEventType? fromValue(String? value) {
    if (value != null) {
      try {
        return AjaxRequestEventType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AjaxRequestEventType] instance from a native value.
  static AjaxRequestEventType? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return AjaxRequestEventType.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [AjaxRequestEventType] instance value with name [name].
  ///
  /// Goes through [AjaxRequestEventType.values] looking for a value with
  /// name [name], as reported by [AjaxRequestEventType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static AjaxRequestEventType? byName(String? name) {
    if (name != null) {
      try {
        return AjaxRequestEventType.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [AjaxRequestEventType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, AjaxRequestEventType> asNameMap() =>
      <String, AjaxRequestEventType>{
        for (final value in AjaxRequestEventType.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'abort':
        return 'ABORT';
      case 'error':
        return 'ERROR';
      case 'load':
        return 'LOAD';
      case 'loadend':
        return 'LOADEND';
      case 'loadstart':
        return 'LOADSTART';
      case 'progress':
        return 'PROGRESS';
      case 'timeout':
        return 'TIMEOUT';
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
