import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../content_blocker.dart';

part 'content_blocker_trigger_resource_type.g.dart';

///Class that represents the possible resource type defined for a [ContentBlockerTrigger].
@ExchangeableEnum()
class ContentBlockerTriggerResourceType_ {
  // ignore: unused_field
  final String _value;
  const ContentBlockerTriggerResourceType_._internal(this._value);

  static const DOCUMENT = const ContentBlockerTriggerResourceType_._internal(
    'document',
  );
  static const IMAGE = const ContentBlockerTriggerResourceType_._internal(
    'image',
  );
  static const STYLE_SHEET = const ContentBlockerTriggerResourceType_._internal(
    'style-sheet',
  );
  static const SCRIPT = const ContentBlockerTriggerResourceType_._internal(
    'script',
  );
  static const FONT = const ContentBlockerTriggerResourceType_._internal(
    'font',
  );
  static const MEDIA = const ContentBlockerTriggerResourceType_._internal(
    'media',
  );
  static const SVG_DOCUMENT =
      const ContentBlockerTriggerResourceType_._internal('svg-document');

  ///Any untyped load
  static const RAW = const ContentBlockerTriggerResourceType_._internal('raw');
}
