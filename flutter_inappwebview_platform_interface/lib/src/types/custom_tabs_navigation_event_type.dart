import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import '../chrome_safari_browser/platform_chrome_safari_browser.dart';

part 'custom_tabs_navigation_event_type.g.dart';

///The type corresponding to the navigation event of [PlatformChromeSafariBrowserEvents.onNavigationEvent].
@ExchangeableEnum()
class CustomTabsNavigationEventType_ {
  // ignore: unused_field
  final int _value;

  // ignore: unused_field
  final int? _nativeValue = null;

  const CustomTabsNavigationEventType_._internal(this._value);

  ///Sent when the tab has started loading a page.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 1)])
  static const STARTED = const CustomTabsNavigationEventType_._internal(1);

  ///Sent when the tab has finished loading a page.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 2)])
  static const FINISHED = const CustomTabsNavigationEventType_._internal(2);

  ///Sent when the tab couldn't finish loading due to a failure.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 3)])
  static const FAILED = const CustomTabsNavigationEventType_._internal(3);

  ///Sent when loading was aborted by a user action before it finishes like clicking on a link or refreshing the page.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 4)])
  static const ABORTED = const CustomTabsNavigationEventType_._internal(4);

  ///Sent when the tab becomes visible.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 5)])
  static const TAB_SHOWN = const CustomTabsNavigationEventType_._internal(5);

  ///Sent when the tab becomes hidden.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 6)])
  static const TAB_HIDDEN = const CustomTabsNavigationEventType_._internal(6);
}
