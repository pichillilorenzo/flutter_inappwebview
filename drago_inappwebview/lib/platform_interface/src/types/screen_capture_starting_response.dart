import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import 'enum_method.dart';

part 'screen_capture_starting_response.g.dart';

///Class that represents the response used by the [PlatformWebViewCreationParams.onScreenCaptureStarting] event.
@ExchangeableObject()
class ScreenCaptureStartingResponse_ {
  ///Whether to cancel the screen capture.
  bool? cancel;

  ///Whether the event has been handled.
  bool? handled;

  ScreenCaptureStartingResponse_({this.cancel, this.handled});
}
