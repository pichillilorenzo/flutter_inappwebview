import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_uri.dart';
import 'web_notification.dart';
import 'enum_method.dart';

part 'notification_received_request.g.dart';

///Class that represents the request used by the [PlatformWebViewCreationParams.onNotificationReceived] event.
@ExchangeableObject()
class NotificationReceivedRequest_ {
  ///The origin of the web content that sends the notification.
  WebUri? senderOrigin;

  ///The notification that was received.
  WebNotification_ notification;

  NotificationReceivedRequest_({
    this.senderOrigin,
    required this.notification,
  });
}
