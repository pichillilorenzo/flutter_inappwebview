// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_capture_state.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that describes whether a media device, like a camera or microphone, is currently capturing audio or video.
class MediaCaptureState {
  final int _value;
  final int _nativeValue;
  const MediaCaptureState._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory MediaCaptureState._internalMultiPlatform(
          int value, Function nativeValue) =>
      MediaCaptureState._internal(value, nativeValue());

  ///The media device is actively capturing audio or video.
  static const ACTIVE = MediaCaptureState._internal(1, 1);

  ///The media device is muted, and not actively capturing audio or video.
  static const MUTED = MediaCaptureState._internal(2, 2);

  ///The media device is off.
  static const NONE = MediaCaptureState._internal(0, 0);

  ///Set of all values of [MediaCaptureState].
  static final Set<MediaCaptureState> values = [
    MediaCaptureState.ACTIVE,
    MediaCaptureState.MUTED,
    MediaCaptureState.NONE,
  ].toSet();

  ///Gets a possible [MediaCaptureState] instance from [int] value.
  static MediaCaptureState? fromValue(int? value) {
    if (value != null) {
      try {
        return MediaCaptureState.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [MediaCaptureState] instance from a native value.
  static MediaCaptureState? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return MediaCaptureState.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return 'ACTIVE';
      case 2:
        return 'MUTED';
      case 0:
        return 'NONE';
    }
    return _value.toString();
  }
}
