// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracing_category.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Constants that describe the results summary the find panel UI includes.
class TracingCategory {
  final int _value;
  final int _nativeValue;
  const TracingCategory._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory TracingCategory._internalMultiPlatform(
          int value, Function nativeValue) =>
      TracingCategory._internal(value, nativeValue());

  ///Predefined set of categories, includes all categories enabled by default in chromium.
  ///Use with caution: this setting may produce large trace output.
  static const CATEGORIES_ALL = TracingCategory._internal(1, 1);

  ///Predefined set of categories typically useful for analyzing WebViews.
  ///Typically includes "android_webview" and "Java" categories.
  static const CATEGORIES_ANDROID_WEBVIEW = TracingCategory._internal(2, 2);

  ///Predefined set of categories for studying difficult rendering performance problems.
  ///Typically includes "blink", "compositor", "gpu", "renderer.scheduler", "v8"
  ///and some other compositor categories which are disabled by default.
  static const CATEGORIES_FRAME_VIEWER = TracingCategory._internal(64, 64);

  ///Predefined set of categories for analyzing input latency issues.
  ///Typically includes "input", "renderer.scheduler" categories.
  static const CATEGORIES_INPUT_LATENCY = TracingCategory._internal(8, 8);

  ///Predefined set of categories for analyzing javascript and rendering issues.
  ///Typically includes "blink", "compositor", "gpu", "renderer.scheduler" and "v8" categories.
  static const CATEGORIES_JAVASCRIPT_AND_RENDERING =
      TracingCategory._internal(32, 32);

  ///Indicates that there are no predefined categories.
  static const CATEGORIES_NONE = TracingCategory._internal(0, 0);

  ///Predefined set of categories for analyzing rendering issues.
  ///Typically includes "blink", "compositor" and "gpu" categories.
  static const CATEGORIES_RENDERING = TracingCategory._internal(16, 16);

  ///Predefined set of categories typically useful for web developers.
  ///Typically includes "blink", "compositor", "renderer.scheduler" and "v8" categories.
  static const CATEGORIES_WEB_DEVELOPER = TracingCategory._internal(4, 4);

  ///Set of all values of [TracingCategory].
  static final Set<TracingCategory> values = [
    TracingCategory.CATEGORIES_ALL,
    TracingCategory.CATEGORIES_ANDROID_WEBVIEW,
    TracingCategory.CATEGORIES_FRAME_VIEWER,
    TracingCategory.CATEGORIES_INPUT_LATENCY,
    TracingCategory.CATEGORIES_JAVASCRIPT_AND_RENDERING,
    TracingCategory.CATEGORIES_NONE,
    TracingCategory.CATEGORIES_RENDERING,
    TracingCategory.CATEGORIES_WEB_DEVELOPER,
  ].toSet();

  ///Gets a possible [TracingCategory] instance from [int] value.
  static TracingCategory? fromValue(int? value) {
    if (value != null) {
      try {
        return TracingCategory.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [TracingCategory] instance from a native value.
  static TracingCategory? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return TracingCategory.values
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
        return 'CATEGORIES_ALL';
      case 2:
        return 'CATEGORIES_ANDROID_WEBVIEW';
      case 64:
        return 'CATEGORIES_FRAME_VIEWER';
      case 8:
        return 'CATEGORIES_INPUT_LATENCY';
      case 32:
        return 'CATEGORIES_JAVASCRIPT_AND_RENDERING';
      case 0:
        return 'CATEGORIES_NONE';
      case 16:
        return 'CATEGORIES_RENDERING';
      case 4:
        return 'CATEGORIES_WEB_DEVELOPER';
    }
    return _value.toString();
  }
}
