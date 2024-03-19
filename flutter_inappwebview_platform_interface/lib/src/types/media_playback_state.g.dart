// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_playback_state.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that describes whether an audio or video presentation is playing, paused, or suspended.
class MediaPlaybackState {
  final int _value;
  final int _nativeValue;
  const MediaPlaybackState._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory MediaPlaybackState._internalMultiPlatform(
          int value, Function nativeValue) =>
      MediaPlaybackState._internal(value, nativeValue());

  ///There is no media to play back.
  static const NONE = MediaPlaybackState._internal(0, 0);

  ///The media playback is paused.
  static const PAUSED = MediaPlaybackState._internal(2, 2);

  ///The media is playing.
  static const PLAYING = MediaPlaybackState._internal(1, 1);

  ///The media is not playing, and cannot be resumed until the user revokes the suspension.
  static const SUSPENDED = MediaPlaybackState._internal(3, 3);

  ///Set of all values of [MediaPlaybackState].
  static final Set<MediaPlaybackState> values = [
    MediaPlaybackState.NONE,
    MediaPlaybackState.PAUSED,
    MediaPlaybackState.PLAYING,
    MediaPlaybackState.SUSPENDED,
  ].toSet();

  ///Gets a possible [MediaPlaybackState] instance from [int] value.
  static MediaPlaybackState? fromValue(int? value) {
    if (value != null) {
      try {
        return MediaPlaybackState.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [MediaPlaybackState] instance from a native value.
  static MediaPlaybackState? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return MediaPlaybackState.values
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
      case 0:
        return 'NONE';
      case 2:
        return 'PAUSED';
      case 1:
        return 'PLAYING';
      case 3:
        return 'SUSPENDED';
    }
    return _value.toString();
  }
}
