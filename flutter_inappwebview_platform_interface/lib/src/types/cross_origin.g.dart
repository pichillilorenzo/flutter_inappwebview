// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cross_origin.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the `crossorigin` content attribute on media elements, which is a CORS settings attribute.
///It could be used with [ScriptHtmlTagAttributes] and [CSSLinkHtmlTagAttributes]
///when fetching a resource `<link>` or a `<script>` (or resources fetched by the `<script>`).
class CrossOrigin {
  final String _value;
  final String _nativeValue;
  const CrossOrigin._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory CrossOrigin._internalMultiPlatform(
          String value, Function nativeValue) =>
      CrossOrigin._internal(value, nativeValue());

  ///CORS requests for this element will have the credentials flag set to 'same-origin'.
  static const ANONYMOUS = CrossOrigin._internal('anonymous', 'anonymous');

  ///CORS requests for this element will have the credentials flag set to 'include'.
  static const USE_CREDENTIALS =
      CrossOrigin._internal('use-credentials', 'use-credentials');

  ///Set of all values of [CrossOrigin].
  static final Set<CrossOrigin> values = [
    CrossOrigin.ANONYMOUS,
    CrossOrigin.USE_CREDENTIALS,
  ].toSet();

  ///Gets a possible [CrossOrigin] instance from [String] value.
  static CrossOrigin? fromValue(String? value) {
    if (value != null) {
      try {
        return CrossOrigin.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [CrossOrigin] instance from a native value.
  static CrossOrigin? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return CrossOrigin.values
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
