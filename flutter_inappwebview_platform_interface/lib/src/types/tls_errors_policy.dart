import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'tls_errors_policy.g.dart';

///TLS errors policy for WebKitWebContext.
///
///Determines how TLS certificate errors are handled.
@ExchangeableEnum()
class TLSErrorsPolicy_ {
  // ignore: unused_field
  final int _value;
  const TLSErrorsPolicy_._internal(this._value);

  ///Ignore TLS errors and continue to load resources.
  ///This policy is less secure but may be useful for development purposes.
  @EnumSupportedPlatforms(
    platforms: [
      EnumLinuxPlatform(
        apiName: 'WEBKIT_TLS_ERRORS_POLICY_IGNORE',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/enum.TLSErrorsPolicy.html',
        value: 0,
      ),
    ],
  )
  static const IGNORE = TLSErrorsPolicy_._internal(0);

  ///Fail on TLS errors, preventing resources with certificate errors from loading.
  ///This is the default and recommended policy for secure applications.
  @EnumSupportedPlatforms(
    platforms: [
      EnumLinuxPlatform(
        apiName: 'WEBKIT_TLS_ERRORS_POLICY_FAIL',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/enum.TLSErrorsPolicy.html',
        value: 1,
      ),
    ],
  )
  static const FAIL = TLSErrorsPolicy_._internal(1);
}
