import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';

part 'notification_received_response.g.dart';

///Class that represents the response used by the [PlatformWebViewCreationParams.onNotificationReceived] event.
@ExchangeableObject()
class NotificationReceivedResponse_ {
  ///Set to `true` to indicate the notification has been handled by the host.
  bool handled;

  NotificationReceivedResponse_({required this.handled});
}
