import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'custom_tabs_relation_type.g.dart';

///Custom Tabs relation for which the result is available.
@ExchangeableEnum()
class CustomTabsRelationType_ {
  // ignore: unused_field
  final int _value;

  // ignore: unused_field
  final int? _nativeValue = null;

  const CustomTabsRelationType_._internal(this._value);

  ///For App -> Web transitions, requests the app to use the declared origin to be used as origin for the client app in the web APIs context.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 1)])
  static const USE_AS_ORIGIN = const CustomTabsRelationType_._internal(1);

  ///Requests the ability to handle all URLs from a given origin.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 2)])
  static const HANDLE_ALL_URLS = const CustomTabsRelationType_._internal(2);
}
