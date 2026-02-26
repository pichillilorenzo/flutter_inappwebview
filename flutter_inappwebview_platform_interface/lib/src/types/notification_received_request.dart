import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_notification/platform_web_notification_controller.dart';
import '../web_uri.dart';
import 'enum_method.dart';

part 'notification_received_request.g.dart';

///Class that represents the request used by the [PlatformWebViewCreationParams.onNotificationReceived] event.
///
///This class bundles the [senderOrigin] and the [notificationController] that can be used
///to interact with the web notification (report shown, clicked, closed, etc.).
@ExchangeableObject(fromMapFactory: false)
class NotificationReceivedRequest_ {
  ///The origin of the web content that sends the notification.
  WebUri? senderOrigin;

  ///The notification controller that provides methods to interact with the notification.
  ///
  ///Use this controller to:
  ///- Report when the notification is shown via [PlatformWebNotificationController.reportShown]
  ///- Report when the notification is clicked via [PlatformWebNotificationController.reportClicked]
  ///- Report when the notification is closed via [PlatformWebNotificationController.reportClosed]
  ///- Listen for the close event via [PlatformWebNotificationController.onClose]
  ///- Access the notification data via [PlatformWebNotificationController.notification]
  PlatformWebNotificationController? notificationController;

  NotificationReceivedRequest_({
    this.senderOrigin,
    this.notificationController,
  });
}
