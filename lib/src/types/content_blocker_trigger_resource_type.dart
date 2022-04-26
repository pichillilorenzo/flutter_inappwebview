import '../content_blocker.dart';

///Class that represents the possible resource type defined for a [ContentBlockerTrigger].
class ContentBlockerTriggerResourceType {
  final String _value;

  const ContentBlockerTriggerResourceType._internal(this._value);

  ///Set of all values of [ContentBlockerTriggerResourceType].
  static final Set<ContentBlockerTriggerResourceType> values = [
    ContentBlockerTriggerResourceType.DOCUMENT,
    ContentBlockerTriggerResourceType.IMAGE,
    ContentBlockerTriggerResourceType.STYLE_SHEET,
    ContentBlockerTriggerResourceType.SCRIPT,
    ContentBlockerTriggerResourceType.FONT,
    ContentBlockerTriggerResourceType.MEDIA,
    ContentBlockerTriggerResourceType.SVG_DOCUMENT,
    ContentBlockerTriggerResourceType.RAW,
  ].toSet();

  ///Gets a possible [ContentBlockerTriggerResourceType] instance from a [String] value.
  static ContentBlockerTriggerResourceType? fromValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerTriggerResourceType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  @override
  String toString() => _value;

  static const DOCUMENT =
  const ContentBlockerTriggerResourceType._internal('document');
  static const IMAGE =
  const ContentBlockerTriggerResourceType._internal('image');
  static const STYLE_SHEET =
  const ContentBlockerTriggerResourceType._internal('style-sheet');
  static const SCRIPT =
  const ContentBlockerTriggerResourceType._internal('script');
  static const FONT = const ContentBlockerTriggerResourceType._internal('font');
  static const MEDIA =
  const ContentBlockerTriggerResourceType._internal('media');
  static const SVG_DOCUMENT =
  const ContentBlockerTriggerResourceType._internal('svg-document');

  ///Any untyped load
  static const RAW = const ContentBlockerTriggerResourceType._internal('raw');

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}