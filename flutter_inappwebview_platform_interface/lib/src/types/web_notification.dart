import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_uri.dart';
import 'text_direction_kind.dart';
import 'enum_method.dart';

part 'web_notification.g.dart';

///Class that represents the data of a web notification.
///
///This corresponds to the properties of the [ICoreWebView2Notification](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2notification?view=webview2-1.0.3595.46) interface.
@ExchangeableObject()
class WebNotification_ {
  ///The title of the notification.
  String? title;

  ///The body text of the notification.
  String? body;

  ///The text direction.
  TextDirectionKind_? direction;

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

  ///The vibration pattern for devices with vibration hardware to emit.
  ///
  ///The vibration pattern can be represented by an array of 64-bit unsigned integers
  ///describing a pattern of vibrations and pauses. See [Vibration API](https://developer.mozilla.org/docs/Web/API/Vibration_API) for more information.
  ///This corresponds to [Notification.vibrate](https://developer.mozilla.org/docs/Web/API/Notification/vibrate) DOM API.
  ///An empty list is returned if no vibration patterns are specified.
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
