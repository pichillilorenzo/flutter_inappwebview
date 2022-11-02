import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'tracing_category.g.dart';

///Constants that describe the results summary the find panel UI includes.
@ExchangeableEnum()
class TracingCategory_ {
  // ignore: unused_field
  final int _value;
  const TracingCategory_._internal(this._value);

  ///Predefined set of categories, includes all categories enabled by default in chromium.
  ///Use with caution: this setting may produce large trace output.
  static const CATEGORIES_ALL = const TracingCategory_._internal(1);

  ///Predefined set of categories typically useful for analyzing WebViews.
  ///Typically includes "android_webview" and "Java" categories.
  static const CATEGORIES_ANDROID_WEBVIEW = const TracingCategory_._internal(2);

  ///Predefined set of categories for studying difficult rendering performance problems.
  ///Typically includes "blink", "compositor", "gpu", "renderer.scheduler", "v8"
  ///and some other compositor categories which are disabled by default.
  static const CATEGORIES_FRAME_VIEWER = const TracingCategory_._internal(64);

  ///Predefined set of categories for analyzing input latency issues.
  ///Typically includes "input", "renderer.scheduler" categories.
  static const CATEGORIES_INPUT_LATENCY = const TracingCategory_._internal(8);

  ///Predefined set of categories for analyzing javascript and rendering issues.
  ///Typically includes "blink", "compositor", "gpu", "renderer.scheduler" and "v8" categories.
  static const CATEGORIES_JAVASCRIPT_AND_RENDERING =
      const TracingCategory_._internal(32);

  ///Indicates that there are no predefined categories.
  static const CATEGORIES_NONE = const TracingCategory_._internal(0);

  ///Predefined set of categories for analyzing rendering issues.
  ///Typically includes "blink", "compositor" and "gpu" categories.
  static const CATEGORIES_RENDERING = const TracingCategory_._internal(16);

  ///Predefined set of categories typically useful for web developers.
  ///Typically includes "blink", "compositor", "renderer.scheduler" and "v8" categories.
  static const CATEGORIES_WEB_DEVELOPER = const TracingCategory_._internal(4);
}
