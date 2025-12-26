import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract mixin class PlatformUtilListener {
  void onWindowMove() {}
  void onWindowStartMove() {}
  void onWindowEndMove() {}
}

///Platform native utilities
class PlatformUtil {
  static PlatformUtil? _instance;
  static const MethodChannel _channel =
      MethodChannel('com.pichillilorenzo/flutter_inappwebview_platformutil');

  static final ObserverList<PlatformUtilListener> _listeners =
      ObserverList<PlatformUtilListener>();

  PlatformUtil._();

  ///Get [PlatformUtil] instance.
  static PlatformUtil instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static PlatformUtil _init() {
    _channel.setMethodCallHandler((call) async {
      try {
        return await _handleMethod(call);
      } on Error catch (e) {
        print(e);
        print(e.stackTrace);
      }
    });
    _instance = PlatformUtil._();
    return _instance!;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
    if (call.method == 'onEvent') {
      String eventName = call.arguments['eventName'];
      for (final listener in _listeners) {
        switch (eventName) {
          case 'onWindowMove':
            listener.onWindowMove();
            break;
          case 'onWindowStartMove':
            listener.onWindowStartMove();
            break;
          case 'onWindowEndMove':
            listener.onWindowEndMove();
            break;
        }
      }
    }
  }

  /// Add a listener to the window.
  void addListener(PlatformUtilListener listener) {
    _listeners.add(listener);
  }

  /// Remove a listener from the window.
  void removeListener(PlatformUtilListener listener) {
    _listeners.remove(listener);
  }
}
