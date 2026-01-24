import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../content_blocker.dart';

part 'content_blocker_trigger_load_type.g.dart';

///Class that represents the possible load type for a [ContentBlockerTrigger].
@ExchangeableEnum()
class ContentBlockerTriggerLoadType_ {
  // ignore: unused_field
  final String _value;
  const ContentBlockerTriggerLoadType_._internal(this._value);

  ///FIRST_PARTY is triggered only if the resource has the same scheme, domain, and port as the main page resource.
  static const FIRST_PARTY = const ContentBlockerTriggerLoadType_._internal(
    'first-party',
  );

  ///THIRD_PARTY is triggered if the resource is not from the same domain as the main page resource.
  static const THIRD_PARTY = const ContentBlockerTriggerLoadType_._internal(
    'third-party',
  );
}
