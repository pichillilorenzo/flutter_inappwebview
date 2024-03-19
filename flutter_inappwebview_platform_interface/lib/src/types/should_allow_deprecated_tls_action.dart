import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import '../in_app_webview/platform_webview.dart';
part 'should_allow_deprecated_tls_action.g.dart';

///Class that is used by [PlatformWebViewCreationParams.shouldAllowDeprecatedTLS] event.
///It represents the policy to pass back to the decision handler.
@ExchangeableEnum()
class ShouldAllowDeprecatedTLSAction_ {
  // ignore: unused_field
  final int _value;
  const ShouldAllowDeprecatedTLSAction_._internal(this._value);

  ///Cancel the navigation.
  static const CANCEL = const ShouldAllowDeprecatedTLSAction_._internal(0);

  ///Allow the navigation to continue.
  static const ALLOW = const ShouldAllowDeprecatedTLSAction_._internal(1);
}

///Class that is used by [PlatformWebViewCreationParams.shouldAllowDeprecatedTLS] event.
///It represents the policy to pass back to the decision handler.
///Use [ShouldAllowDeprecatedTLSAction] instead.
@Deprecated("Use ShouldAllowDeprecatedTLSAction instead")
@ExchangeableEnum()
class IOSShouldAllowDeprecatedTLSAction_ {
  // ignore: unused_field
  final int _value;
  const IOSShouldAllowDeprecatedTLSAction_._internal(this._value);

  ///Cancel the navigation.
  static const CANCEL = const IOSShouldAllowDeprecatedTLSAction_._internal(0);

  ///Allow the navigation to continue.
  static const ALLOW = const IOSShouldAllowDeprecatedTLSAction_._internal(1);
}
