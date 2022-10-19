import 'dart:async';

import 'package:flutter/services.dart';

import '_static_channel.dart';
import 'android/web_storage_manager.dart';
import 'ios/web_storage_manager.dart';

///Class that implements a singleton object (shared instance) which manages the web storage used by WebView instances.
///On Android, it is implemented using [WebStorage](https://developer.android.com/reference/android/webkit/WebStorage.html).
///On iOS, it is implemented using [WKWebsiteDataStore.default()](https://developer.apple.com/documentation/webkit/wkwebsitedatastore).
///
///**NOTE for iOS**: available from iOS 9.0+.
class WebStorageManager {
  static WebStorageManager? _instance;
  static const MethodChannel _staticChannel = WEB_STORAGE_STATIC_CHANNEL;

  AndroidWebStorageManager android = AndroidWebStorageManager();
  IOSWebStorageManager ios = IOSWebStorageManager();

  WebStorageManager._();

  ///Gets the WebStorage manager shared instance.
  static WebStorageManager instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static WebStorageManager _init() {
    _staticChannel.setMethodCallHandler(_handleMethod);
    _instance = new WebStorageManager._();
    return _instance!;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {}
}
