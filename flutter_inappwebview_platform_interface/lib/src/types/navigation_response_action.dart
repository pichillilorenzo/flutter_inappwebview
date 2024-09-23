import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import '../in_app_webview/platform_webview.dart';
part 'navigation_response_action.g.dart';

///Class that is used by [PlatformWebViewCreationParams.onNavigationResponse] event.
///It represents the policy to pass back to the decision handler.
@ExchangeableEnum()
class NavigationResponseAction_ {
  // ignore: unused_field
  final int _value;
  const NavigationResponseAction_._internal(this._value);

  ///Cancel the navigation.
  static const CANCEL = const NavigationResponseAction_._internal(0);

  ///Allow the navigation to continue.
  static const ALLOW = const NavigationResponseAction_._internal(1);

  ///Turn the navigation into a download.
  ///
  ///**NOTE**: available only on iOS 14.5+. It will fallback to [CANCEL].
  static const DOWNLOAD = const NavigationResponseAction_._internal(2);
}

///Class that is used by [PlatformWebViewCreationParams.onNavigationResponse] event.
///It represents the policy to pass back to the decision handler.
///Use [NavigationResponseAction] instead.
@Deprecated("Use NavigationResponseAction instead")
@ExchangeableEnum()
class IOSNavigationResponseAction_ {
  // ignore: unused_field
  final int _value;
  const IOSNavigationResponseAction_._internal(this._value);

  ///Cancel the navigation.
  static const CANCEL = const IOSNavigationResponseAction_._internal(0);

  ///Allow the navigation to continue.
  static const ALLOW = const IOSNavigationResponseAction_._internal(1);
}
