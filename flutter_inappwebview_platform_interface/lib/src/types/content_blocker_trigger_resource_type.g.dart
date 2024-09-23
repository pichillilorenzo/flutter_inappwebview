// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_blocker_trigger_resource_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the possible resource type defined for a [ContentBlockerTrigger].
class ContentBlockerTriggerResourceType {
  final String _value;
  final String _nativeValue;
  const ContentBlockerTriggerResourceType._internal(
      this._value, this._nativeValue);
// ignore: unused_element
  factory ContentBlockerTriggerResourceType._internalMultiPlatform(
          String value, Function nativeValue) =>
      ContentBlockerTriggerResourceType._internal(value, nativeValue());
  static const DOCUMENT =
      ContentBlockerTriggerResourceType._internal('document', 'document');
  static const FONT =
      ContentBlockerTriggerResourceType._internal('font', 'font');
  static const IMAGE =
      ContentBlockerTriggerResourceType._internal('image', 'image');
  static const MEDIA =
      ContentBlockerTriggerResourceType._internal('media', 'media');

  ///Any untyped load
  static const RAW = ContentBlockerTriggerResourceType._internal('raw', 'raw');
  static const SCRIPT =
      ContentBlockerTriggerResourceType._internal('script', 'script');
  static const STYLE_SHEET =
      ContentBlockerTriggerResourceType._internal('style-sheet', 'style-sheet');
  static const SVG_DOCUMENT = ContentBlockerTriggerResourceType._internal(
      'svg-document', 'svg-document');

  ///Set of all values of [ContentBlockerTriggerResourceType].
  static final Set<ContentBlockerTriggerResourceType> values = [
    ContentBlockerTriggerResourceType.DOCUMENT,
    ContentBlockerTriggerResourceType.FONT,
    ContentBlockerTriggerResourceType.IMAGE,
    ContentBlockerTriggerResourceType.MEDIA,
    ContentBlockerTriggerResourceType.RAW,
    ContentBlockerTriggerResourceType.SCRIPT,
    ContentBlockerTriggerResourceType.STYLE_SHEET,
    ContentBlockerTriggerResourceType.SVG_DOCUMENT,
  ].toSet();

  ///Gets a possible [ContentBlockerTriggerResourceType] instance from [String] value.
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

  ///Gets a possible [ContentBlockerTriggerResourceType] instance from a native value.
  static ContentBlockerTriggerResourceType? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerTriggerResourceType.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
