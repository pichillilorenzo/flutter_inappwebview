import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../content_blocker.dart';

part 'content_blocker_action_type.g.dart';

///Class that represents the kind of action that can be used with a [ContentBlockerTrigger].
@ExchangeableEnum()
class ContentBlockerActionType_ {
  // ignore: unused_field
  final String _value;
  const ContentBlockerActionType_._internal(this._value);

  ///Stops loading of the resource. If the resource was cached, the cache is ignored.
  static const BLOCK = const ContentBlockerActionType_._internal('block');

  ///Hides elements of the page based on a CSS selector. A selector field contains the selector list. Any matching element has its display property set to none, which hides it.
  ///
  ///**NOTE**: on Android, JavaScript must be enabled.
  static const CSS_DISPLAY_NONE =
      const ContentBlockerActionType_._internal('css-display-none');

  ///Changes a URL from http to https. URLs with a specified (nondefault) port and links using other protocols are unaffected.
  static const MAKE_HTTPS =
      const ContentBlockerActionType_._internal('make-https');
}
