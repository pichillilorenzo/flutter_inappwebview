// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_capture_starting_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the request used by the [PlatformWebViewCreationParams.onScreenCaptureStarting] event.
class ScreenCaptureStartingRequest {
  ///Whether to cancel the screen capture.
  bool? cancel;

  ///The frame that requests screen capture.
  FrameInfo? frame;

  ///Whether the event has been handled.
  bool? handled;
  ScreenCaptureStartingRequest({this.cancel, this.frame, this.handled});

  ///Gets a possible [ScreenCaptureStartingRequest] instance from a [Map] value.
  static ScreenCaptureStartingRequest? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = ScreenCaptureStartingRequest(
      cancel: map['cancel'],
      frame: FrameInfo.fromMap(
        map['frame']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      handled: map['handled'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "cancel": cancel,
      "frame": frame?.toMap(enumMethod: enumMethod),
      "handled": handled,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ScreenCaptureStartingRequest{cancel: $cancel, frame: $frame, handled: $handled}';
  }
}
