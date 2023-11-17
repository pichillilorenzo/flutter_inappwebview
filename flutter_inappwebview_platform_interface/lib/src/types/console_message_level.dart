import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'console_message_level.g.dart';

///Class representing the level of a console message.
@ExchangeableEnum()
class ConsoleMessageLevel_ {
  // ignore: unused_field
  final int _value;
  const ConsoleMessageLevel_._internal(this._value);

  ///Console TIP level
  static const TIP = const ConsoleMessageLevel_._internal(0);

  ///Console LOG level
  static const LOG = const ConsoleMessageLevel_._internal(1);

  ///Console WARNING level
  static const WARNING = const ConsoleMessageLevel_._internal(2);

  ///Console ERROR level
  static const ERROR = const ConsoleMessageLevel_._internal(3);

  ///Console DEBUG level
  static const DEBUG = const ConsoleMessageLevel_._internal(4);
}
