import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'window_type.g.dart';

///Class that represents how a browser window should be added to the main window.
@ExchangeableEnum()
class WindowType_ {
  // ignore: unused_field
  final String _value;

  const WindowType_._internal(this._value);

  ///Adds the new browser window as a separate new window from the main window.
  @EnumSupportedPlatforms(
    platforms: [
      EnumMacOSPlatform(value: 'WINDOW'),
      EnumWindowsPlatform(value: 'WINDOW'),
    ],
  )
  static const WINDOW = const WindowType_._internal('WINDOW');

  ///Adds the new browser window as a child window of the main window.
  @EnumSupportedPlatforms(
    platforms: [
      EnumMacOSPlatform(value: 'CHILD'),
      EnumWindowsPlatform(value: 'CHILD'),
    ],
  )
  static const CHILD = const WindowType_._internal('CHILD');

  ///Adds the new browser window as a new tab in a tabbed window of the main window.
  @EnumSupportedPlatforms(
    platforms: [EnumMacOSPlatform(value: 'TABBED', available: "10.12+")],
  )
  static const TABBED = const WindowType_._internal('TABBED');
}
