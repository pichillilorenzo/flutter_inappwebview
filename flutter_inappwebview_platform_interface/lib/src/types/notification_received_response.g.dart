// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_received_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [PlatformWebViewCreationParams.onNotificationReceived] event.
class NotificationReceivedResponse {
  ///Set to `true` to indicate the notification has been handled by the host.
  bool handled;
  NotificationReceivedResponse({required this.handled});

  ///Gets a possible [NotificationReceivedResponse] instance from a [Map] value.
  static NotificationReceivedResponse? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = NotificationReceivedResponse(handled: map['handled']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {"handled": handled};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'NotificationReceivedResponse{handled: $handled}';
  }
}
