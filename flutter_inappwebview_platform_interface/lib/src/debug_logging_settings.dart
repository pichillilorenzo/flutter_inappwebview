import 'package:flutter/foundation.dart';

///Class that represents the debug logging settings.
class DebugLoggingSettings {
  ///Enables debug logging info.
  ///
  ///The default value is the same value of [kDebugMode],
  ///so it is enabled by default when the application is compiled in debug mode
  ///and disabled when it is not.
  bool enabled;

  ///Filters used to exclude some logs from logging.
  List<RegExp> excludeFilter;

  ///Max length of the log message.
  ///Set to `-1` to indicate that the log message needs to display the full content.
  ///
  ///The default value is `-1`.
  int maxLogMessageLength;

  ///Use [print] instead of `developer.log` to log messages.
  bool usePrint;

  DebugLoggingSettings({
    this.enabled = kDebugMode,
    this.excludeFilter = const [],
    this.maxLogMessageLength = -1,
    this.usePrint = false,
  });
}
