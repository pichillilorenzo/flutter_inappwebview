import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'frame_info.dart';
import 'enum_method.dart';

part 'screen_capture_starting_request.g.dart';

///Class that represents the request used by the [PlatformWebViewCreationParams.onScreenCaptureStarting] event.
@ExchangeableObject()
class ScreenCaptureStartingRequest_ {
  ///The frame that requests screen capture.
  FrameInfo_? frame;

  ///Whether to cancel the screen capture.
  bool? cancel;

  ///Whether the event has been handled.
  bool? handled;

  ScreenCaptureStartingRequest_({this.frame, this.cancel, this.handled});
}
