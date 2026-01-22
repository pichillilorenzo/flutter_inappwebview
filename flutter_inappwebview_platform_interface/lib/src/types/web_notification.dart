import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_uri.dart';
import 'notification_direction.dart';
import 'enum_method.dart';

part 'web_notification.g.dart';

///Class that represents a web notification.
@ExchangeableObject()
class WebNotification_ {
  ///The title of the notification.
  String? title;

  ///The body text of the notification.
  String? body;

  ///The text direction.
  NotificationDirection_? direction;

  ///The language of the notification.
  String? language;

  ///The tag of the notification.
  String? tag;

  ///The icon URI.
  WebUri? iconUri;

  ///The badge URI.
  WebUri? badgeUri;

  ///The body image URI.
  WebUri? bodyImageUri;

  ///Whether the notification should renotify.
  bool? shouldRenotify;

  ///Whether the notification requires interaction.
  bool? requiresInteraction;

  ///Whether the notification is silent.
  bool? isSilent;

  ///The timestamp of the notification, in milliseconds since UNIX epoch.
  double? timestamp;

  ///The vibration pattern, if any.
  List<int>? vibrationPattern;

  WebNotification_({
    this.title,
    this.body,
    this.direction,
    this.language,
    this.tag,
    this.iconUri,
    this.badgeUri,
    this.bodyImageUri,
    this.shouldRenotify,
    this.requiresInteraction,
    this.isSilent,
    this.timestamp,
    this.vibrationPattern,
  });
}
