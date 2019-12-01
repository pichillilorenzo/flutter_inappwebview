import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';

import 'types.dart' show ListenerCallback;

class ChannelManager {
  static const MethodChannel channel =
      const MethodChannel('com.pichillilorenzo/flutter_inappbrowser');
  static bool initialized = false;
  static final listeners = HashMap<String, ListenerCallback>();

  static Future<dynamic> _handleMethod(MethodCall call) async {
    String uuid = call.arguments["uuid"];
    return await listeners[uuid](call);
  }

  static void addListener(String key, ListenerCallback callback) {
    if (!initialized) init();
    listeners.putIfAbsent(key, () => callback);
  }

  static void init() {
    channel.setMethodCallHandler(_handleMethod);
    initialized = true;
  }
}
