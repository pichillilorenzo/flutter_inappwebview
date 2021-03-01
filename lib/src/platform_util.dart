import 'package:flutter/services.dart';

class PlatformUtil {
  static PlatformUtil? _instance;
  static const MethodChannel _channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_platformutil');

  static PlatformUtil instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static PlatformUtil _init() {
    _channel.setMethodCallHandler(_handleMethod);
    _instance = PlatformUtil();
    return _instance!;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {}

  String? _cachedSystemVersion;
  Future<String> getSystemVersion() async {
    if (_cachedSystemVersion != null) {
      return _cachedSystemVersion!;
    }
    Map<String, dynamic> args = <String, dynamic>{};
    _cachedSystemVersion =
        await _channel.invokeMethod('getSystemVersion', args);
    return _cachedSystemVersion!;
  }

  Future<String> formatDate(
      {required DateTime date,
      required String format,
      String locale = "en_US",
      String timezone = "UTC"}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('date', () => date.millisecondsSinceEpoch);
    args.putIfAbsent('format', () => format);
    args.putIfAbsent('locale', () => locale);
    args.putIfAbsent('timezone', () => timezone);
    return await _channel.invokeMethod('formatDate', args);
  }
}
