import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'notification_direction.g.dart';

///Constants that describe the notification text direction.
@ExchangeableEnum()
class NotificationDirection_ {
  // ignore: unused_field
  final int _value;
  const NotificationDirection_._internal(this._value);

  ///Default text direction.
  static const DEFAULT = NotificationDirection_._internal(0);

  ///Left-to-right text direction.
  static const LEFT_TO_RIGHT = NotificationDirection_._internal(1);

  ///Right-to-left text direction.
  static const RIGHT_TO_LEFT = NotificationDirection_._internal(2);
}
