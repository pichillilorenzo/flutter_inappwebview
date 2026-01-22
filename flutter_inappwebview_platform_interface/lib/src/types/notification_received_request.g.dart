// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_received_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the request used by the [PlatformWebViewCreationParams.onNotificationReceived] event.
class NotificationReceivedRequest {
  ///The notification that was received.
  WebNotification notification;

  ///The origin of the web content that sends the notification.
  WebUri? senderOrigin;
  NotificationReceivedRequest({required this.notification, this.senderOrigin});

  ///Gets a possible [NotificationReceivedRequest] instance from a [Map] value.
  static NotificationReceivedRequest? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = NotificationReceivedRequest(
      notification: WebNotification.fromMap(
        map['notification']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      )!,
      senderOrigin: map['senderOrigin'] != null
          ? WebUri(map['senderOrigin'])
          : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "notification": notification.toMap(enumMethod: enumMethod),
      "senderOrigin": senderOrigin?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'NotificationReceivedRequest{notification: $notification, senderOrigin: $senderOrigin}';
  }
}
