// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_webview_hit_test_result_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the [InAppWebViewHitTestResult] type.
class InAppWebViewHitTestResultType {
  final int _value;
  final int _nativeValue;
  const InAppWebViewHitTestResultType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory InAppWebViewHitTestResultType._internalMultiPlatform(
          int value, Function nativeValue) =>
      InAppWebViewHitTestResultType._internal(value, nativeValue());

  ///[InAppWebViewHitTestResult] for hitting an edit text area.
  static const EDIT_TEXT_TYPE = InAppWebViewHitTestResultType._internal(9, 9);

  ///[InAppWebViewHitTestResult] for hitting an email address.
  static const EMAIL_TYPE = InAppWebViewHitTestResultType._internal(4, 4);

  ///[InAppWebViewHitTestResult] for hitting a map address.
  static const GEO_TYPE = InAppWebViewHitTestResultType._internal(3, 3);

  ///[InAppWebViewHitTestResult] for hitting an HTML::img tag.
  static const IMAGE_TYPE = InAppWebViewHitTestResultType._internal(5, 5);

  ///[InAppWebViewHitTestResult] for hitting a phone number.
  static const PHONE_TYPE = InAppWebViewHitTestResultType._internal(2, 2);

  ///[InAppWebViewHitTestResult] for hitting a HTML::a tag with src=http.
  static const SRC_ANCHOR_TYPE = InAppWebViewHitTestResultType._internal(7, 7);

  ///[InAppWebViewHitTestResult] for hitting a HTML::a tag with src=http + HTML::img.
  static const SRC_IMAGE_ANCHOR_TYPE =
      InAppWebViewHitTestResultType._internal(8, 8);

  ///Default [InAppWebViewHitTestResult], where the target is unknown.
  static const UNKNOWN_TYPE = InAppWebViewHitTestResultType._internal(0, 0);

  ///Set of all values of [InAppWebViewHitTestResultType].
  static final Set<InAppWebViewHitTestResultType> values = [
    InAppWebViewHitTestResultType.EDIT_TEXT_TYPE,
    InAppWebViewHitTestResultType.EMAIL_TYPE,
    InAppWebViewHitTestResultType.GEO_TYPE,
    InAppWebViewHitTestResultType.IMAGE_TYPE,
    InAppWebViewHitTestResultType.PHONE_TYPE,
    InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.UNKNOWN_TYPE,
  ].toSet();

  ///Gets a possible [InAppWebViewHitTestResultType] instance from [int] value.
  static InAppWebViewHitTestResultType? fromValue(int? value) {
    if (value != null) {
      try {
        return InAppWebViewHitTestResultType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [InAppWebViewHitTestResultType] instance from a native value.
  static InAppWebViewHitTestResultType? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return InAppWebViewHitTestResultType.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [InAppWebViewHitTestResultType] instance value with name [name].
  ///
  /// Goes through [InAppWebViewHitTestResultType.values] looking for a value with
  /// name [name], as reported by [InAppWebViewHitTestResultType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static InAppWebViewHitTestResultType? byName(String? name) {
    if (name != null) {
      try {
        return InAppWebViewHitTestResultType.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [InAppWebViewHitTestResultType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, InAppWebViewHitTestResultType> asNameMap() =>
      <String, InAppWebViewHitTestResultType>{
        for (final value in InAppWebViewHitTestResultType.values)
          value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 9:
        return 'EDIT_TEXT_TYPE';
      case 4:
        return 'EMAIL_TYPE';
      case 3:
        return 'GEO_TYPE';
      case 5:
        return 'IMAGE_TYPE';
      case 2:
        return 'PHONE_TYPE';
      case 7:
        return 'SRC_ANCHOR_TYPE';
      case 8:
        return 'SRC_IMAGE_ANCHOR_TYPE';
      case 0:
        return 'UNKNOWN_TYPE';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return name();
  }
}
