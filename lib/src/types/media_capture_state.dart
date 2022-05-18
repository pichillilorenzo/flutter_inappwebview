///Class that describes whether a media device, like a camera or microphone, is currently capturing audio or video.
class MediaCaptureState {
  final int _value;

  const MediaCaptureState._internal(this._value);

  ///Set of all values of [MediaCaptureState].
  static final Set<MediaCaptureState> values = [
    MediaCaptureState.NONE,
    MediaCaptureState.ACTIVE,
    MediaCaptureState.MUTED,
  ].toSet();

  ///Gets a possible [MediaCaptureState] instance from an [int] value.
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

  ///Gets [int] value.
  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "ACTIVE";
      case 2:
        return "MUTED";
      case 0:
      default:
        return "NONE";
    }
  }

  ///The media device is off.
  static const NONE = const MediaCaptureState._internal(0);

  ///The media device is actively capturing audio or video.
  static const ACTIVE = const MediaCaptureState._internal(1);

  ///The media device is muted, and not actively capturing audio or video.
  static const MUTED = const MediaCaptureState._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}