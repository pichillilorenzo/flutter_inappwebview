// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracing_mode.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Constants that describe the results summary the find panel UI includes.
class TracingMode {
  final int _value;
  final int _nativeValue;
  const TracingMode._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory TracingMode._internalMultiPlatform(int value, Function nativeValue) =>
      TracingMode._internal(value, nativeValue());

  ///Record trace events continuously using an internal ring buffer.
  ///Default tracing mode.
  ///Overwrites old events if they exceed buffer capacity.
  ///Uses less memory than the [RECORD_UNTIL_FULL] mode.
  ///Depending on the implementation typically allows up to 64k events to be stored.
  static const RECORD_CONTINUOUSLY = TracingMode._internal(1, 1);

  ///Record trace events until the internal tracing buffer is full.
  ///Typically the buffer memory usage is larger than [RECORD_CONTINUOUSLY].
  ///Depending on the implementation typically allows up to 256k events to be stored.
  static const RECORD_UNTIL_FULL = TracingMode._internal(0, 0);

  ///Set of all values of [TracingMode].
  static final Set<TracingMode> values = [
    TracingMode.RECORD_CONTINUOUSLY,
    TracingMode.RECORD_UNTIL_FULL,
  ].toSet();

  ///Gets a possible [TracingMode] instance from [int] value.
  static TracingMode? fromValue(int? value) {
    if (value != null) {
      try {
        return TracingMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [TracingMode] instance from a native value.
  static TracingMode? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return TracingMode.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return 'RECORD_CONTINUOUSLY';
      case 0:
        return 'RECORD_UNTIL_FULL';
    }
    return _value.toString();
  }
}
