import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'url_request.dart';

part 'url_request_attribution.g.dart';

///Class that represents the constants used to indicate the entities that can make a network request.
@ExchangeableEnum()
class URLRequestAttribution_ {
  // ignore: unused_field
  final int _value;
  const URLRequestAttribution_._internal(this._value);

  ///A developer-initiated network request.
  ///
  ///Use this value for the attribution parameter of a [URLRequest] that your app makes for any purpose other than when the user explicitly accesses a link.
  ///This includes requests that your app makes to get user data. This is the default value.
  ///
  ///For cases where the user enters a URL, like in the navigation bar of a web browser, or taps or clicks a URL to load the content it represents, use the [URLRequestAttribution.USER] value instead.
  static const DEVELOPER = const URLRequestAttribution_._internal(0);

  ///Use this value for the attribution parameter of a [URLRequest] that satisfies a user request to access an explicit, unmodified URL.
  ///In all other cases, use the [URLRequestAttribution.DEVELOPER] value instead.
  static const USER = const URLRequestAttribution_._internal(1);
}
