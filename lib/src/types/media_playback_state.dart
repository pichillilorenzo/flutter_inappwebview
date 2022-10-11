import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'media_playback_state.g.dart';

///Class that describes whether an audio or video presentation is playing, paused, or suspended.
@ExchangeableEnum()
class MediaPlaybackState_ {
  // ignore: unused_field
  final int _value;
  const MediaPlaybackState_._internal(this._value);

  ///There is no media to play back.
  static const NONE = const MediaPlaybackState_._internal(0);

  ///The media is playing.
  static const PLAYING = const MediaPlaybackState_._internal(1);

  ///The media playback is paused.
  static const PAUSED = const MediaPlaybackState_._internal(2);

  ///The media is not playing, and cannot be resumed until the user revokes the suspension.
  static const SUSPENDED = const MediaPlaybackState_._internal(3);
}
