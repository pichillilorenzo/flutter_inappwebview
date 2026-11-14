import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import '../content_blocker.dart';

part 'content_blocker_trigger_resource_type.g.dart';

///Class that represents the possible resource type defined for a [ContentBlockerTrigger].
@ExchangeableEnum()
class ContentBlockerTriggerResourceType_ {
  // ignore: unused_field
  final String _value;
  const ContentBlockerTriggerResourceType_._internal(this._value);

  static const DOCUMENT = ContentBlockerTriggerResourceType_._internal(
    'document',
  );
  static const IMAGE = ContentBlockerTriggerResourceType_._internal(
    'image',
  );
  static const STYLE_SHEET = ContentBlockerTriggerResourceType_._internal(
    'style-sheet',
  );
  static const SCRIPT = ContentBlockerTriggerResourceType_._internal(
    'script',
  );
  static const FONT = ContentBlockerTriggerResourceType_._internal(
    'font',
  );
  static const MEDIA = ContentBlockerTriggerResourceType_._internal(
    'media',
  );
  static const SVG_DOCUMENT =
      ContentBlockerTriggerResourceType_._internal('svg-document');

  ///Any untyped load
  static const RAW = ContentBlockerTriggerResourceType_._internal('raw');
}
