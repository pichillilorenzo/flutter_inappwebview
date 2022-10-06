// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_to_refresh_size.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the size of the refresh indicator.
class PullToRefreshSize {
  final int _value;
  final int _nativeValue;
  const PullToRefreshSize._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory PullToRefreshSize._internalMultiPlatform(
          int value, Function nativeValue) =>
      PullToRefreshSize._internal(value, nativeValue());

  ///Default size.
  static const DEFAULT = PullToRefreshSize._internal(1, 1);

  ///Large size.
  static const LARGE = PullToRefreshSize._internal(0, 0);

  ///Set of all values of [PullToRefreshSize].
  static final Set<PullToRefreshSize> values = [
    PullToRefreshSize.DEFAULT,
    PullToRefreshSize.LARGE,
  ].toSet();

  ///Gets a possible [PullToRefreshSize] instance from [int] value.
  static PullToRefreshSize? fromValue(int? value) {
    if (value != null) {
      try {
        return PullToRefreshSize.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PullToRefreshSize] instance from a native value.
  static PullToRefreshSize? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return PullToRefreshSize.values
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
        return 'DEFAULT';
      case 0:
        return 'LARGE';
    }
    return _value.toString();
  }
}

///Android-specific class representing the size of the refresh indicator.
///Use [PullToRefreshSize] instead.
@Deprecated('Use PullToRefreshSize instead')
class AndroidPullToRefreshSize {
  final int _value;
  final int _nativeValue;
  const AndroidPullToRefreshSize._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory AndroidPullToRefreshSize._internalMultiPlatform(
          int value, Function nativeValue) =>
      AndroidPullToRefreshSize._internal(value, nativeValue());

  ///Default size.
  static const DEFAULT = AndroidPullToRefreshSize._internal(1, 1);

  ///Large size.
  static const LARGE = AndroidPullToRefreshSize._internal(0, 0);

  ///Set of all values of [AndroidPullToRefreshSize].
  static final Set<AndroidPullToRefreshSize> values = [
    AndroidPullToRefreshSize.DEFAULT,
    AndroidPullToRefreshSize.LARGE,
  ].toSet();

  ///Gets a possible [AndroidPullToRefreshSize] instance from [int] value.
  static AndroidPullToRefreshSize? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidPullToRefreshSize.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AndroidPullToRefreshSize] instance from a native value.
  static AndroidPullToRefreshSize? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return AndroidPullToRefreshSize.values
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
        return 'DEFAULT';
      case 0:
        return 'LARGE';
    }
    return _value.toString();
  }
}
