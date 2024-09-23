import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'media_capture_state.g.dart';

///Class that describes whether a media device, like a camera or microphone, is currently capturing audio or video.
@ExchangeableEnum()
class MediaCaptureState_ {
  // ignore: unused_field
  final int _value;
  const MediaCaptureState_._internal(this._value);

  ///The media device is off.
  static const NONE = const MediaCaptureState_._internal(0);

  ///The media device is actively capturing audio or video.
  static const ACTIVE = const MediaCaptureState_._internal(1);

  ///The media device is muted, and not actively capturing audio or video.
  static const MUTED = const MediaCaptureState_._internal(2);
}
