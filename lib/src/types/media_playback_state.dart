///Class that describes whether an audio or video presentation is playing, paused, or suspended.
class MediaPlaybackState {
  final int _value;

  const MediaPlaybackState._internal(this._value);

  ///Set of all values of [MediaPlaybackState].
  static final Set<MediaPlaybackState> values = [
    MediaPlaybackState.NONE,
    MediaPlaybackState.PLAYING,
    MediaPlaybackState.PAUSED,
    MediaPlaybackState.SUSPENDED,
  ].toSet();

  ///Gets a possible [MediaPlaybackState] instance from an [int] value.
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

  ///Gets [int] value.
  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "PLAYING";
      case 2:
        return "PAUSED";
      case 3:
        return "SUSPENDED";
      case 0:
      default:
        return "NONE";
    }
  }

  ///There is no media to play back.
  static const NONE = const MediaPlaybackState._internal(0);

  ///The media is playing.
  static const PLAYING = const MediaPlaybackState._internal(1);

  ///The media playback is paused.
  static const PAUSED = const MediaPlaybackState._internal(2);

  ///The media is not playing, and cannot be resumed until the user revokes the suspension.
  static const SUSPENDED = const MediaPlaybackState._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}