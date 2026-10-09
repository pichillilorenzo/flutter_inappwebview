// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_capture_starting_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [PlatformWebViewCreationParams.onScreenCaptureStarting] event.
class ScreenCaptureStartingResponse {
  ///Whether to cancel the screen capture.
  bool? cancel;

  ///Whether the event has been handled.
  bool? handled;
  ScreenCaptureStartingResponse({this.cancel, this.handled});

  ///Gets a possible [ScreenCaptureStartingResponse] instance from a [Map] value.
  static ScreenCaptureStartingResponse? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = ScreenCaptureStartingResponse(
      cancel: map['cancel'],
      handled: map['handled'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {"cancel": cancel, "handled": handled};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ScreenCaptureStartingResponse{cancel: $cancel, handled: $handled}';
  }
}
