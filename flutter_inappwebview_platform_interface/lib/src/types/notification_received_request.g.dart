// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_received_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the request used by the [PlatformWebViewCreationParams.onNotificationReceived] event.
///
///This class bundles the [senderOrigin] and the [notificationController] that can be used
///to interact with the web notification (report shown, clicked, closed, etc.).
class NotificationReceivedRequest {
  ///The notification controller that provides methods to interact with the notification.
  ///
  ///Use this controller to:
  ///- Report when the notification is shown via [PlatformWebNotificationController.reportShown]
  ///- Report when the notification is clicked via [PlatformWebNotificationController.reportClicked]
  ///- Report when the notification is closed via [PlatformWebNotificationController.reportClosed]
  ///- Listen for the close event via [PlatformWebNotificationController.onClose]
  ///- Access the notification data via [PlatformWebNotificationController.notification]
  PlatformWebNotificationController? notificationController;

  ///The origin of the web content that sends the notification.
  WebUri? senderOrigin;
  NotificationReceivedRequest({this.notificationController, this.senderOrigin});

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "notificationController": notificationController,
      "senderOrigin": senderOrigin?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'NotificationReceivedRequest{notificationController: $notificationController, senderOrigin: $senderOrigin}';
  }
}
