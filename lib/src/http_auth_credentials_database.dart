import 'dart:async';

import 'types.dart';
import 'package:flutter/services.dart';

///Class that implements a singleton object (shared instance) which manages the shared HTTP auth credentials cache.
///On iOS, this class uses the [URLCredentialStorage](https://developer.apple.com/documentation/foundation/urlcredentialstorage) class.
///On Android, this class has a custom implementation using `android.database.sqlite.SQLiteDatabase` because
///[WebViewDatabase](https://developer.android.com/reference/android/webkit/WebViewDatabase)
///doesn't offer the same functionalities as iOS `URLCredentialStorage`.
class HttpAuthCredentialDatabase {
  static HttpAuthCredentialDatabase? _instance;
  static const MethodChannel _channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_credential_database');

  ///Gets the database shared instance.
  static HttpAuthCredentialDatabase instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static HttpAuthCredentialDatabase _init() {
    _channel.setMethodCallHandler(_handleMethod);
    _instance = HttpAuthCredentialDatabase();
    return _instance!;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {}

  ///Gets a map list of all HTTP auth credentials saved.
  ///Each map contains the key `protectionSpace` of type [URLProtectionSpace]
  ///and the key `credentials` of type `List<URLCredential>` that contains all the HTTP auth credentials saved for that `protectionSpace`.
  Future<List<URLProtectionSpaceHttpAuthCredentials>>
      getAllAuthCredentials() async {
    Map<String, dynamic> args = <String, dynamic>{};
    List<dynamic> allCredentials =
        await _channel.invokeMethod('getAllAuthCredentials', args);

    List<URLProtectionSpaceHttpAuthCredentials> result = [];

    for (Map<dynamic, dynamic> map in allCredentials) {
      var element = URLProtectionSpaceHttpAuthCredentials.fromMap(
          map.cast<String, dynamic>());
      if (element != null) {
        result.add(element);
      }
    }
    return result;
  }

  ///Gets all the HTTP auth credentials saved for that [protectionSpace].
  Future<List<URLCredential>> getHttpAuthCredentials(
      {required URLProtectionSpace protectionSpace}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("host", () => protectionSpace.host);
    args.putIfAbsent("protocol", () => protectionSpace.protocol);
    args.putIfAbsent("realm", () => protectionSpace.realm);
    args.putIfAbsent("port", () => protectionSpace.port);
    List<dynamic> credentialList =
        await _channel.invokeMethod('getHttpAuthCredentials', args);
    List<URLCredential> credentials = [];
    for (Map<dynamic, dynamic> map in credentialList) {
      var credential = URLCredential.fromMap(map.cast<String, dynamic>());
      if (credential != null) {
        credentials.add(credential);
      }
    }
    return credentials;
  }

  ///Saves an HTTP auth [credential] for that [protectionSpace].
  Future<void> setHttpAuthCredential(
      {required URLProtectionSpace protectionSpace,
      required URLCredential credential}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("host", () => protectionSpace.host);
    args.putIfAbsent("protocol", () => protectionSpace.protocol);
    args.putIfAbsent("realm", () => protectionSpace.realm);
    args.putIfAbsent("port", () => protectionSpace.port);
    args.putIfAbsent("username", () => credential.username);
    args.putIfAbsent("password", () => credential.password);
    await _channel.invokeMethod('setHttpAuthCredential', args);
  }

  ///Removes an HTTP auth [credential] for that [protectionSpace].
  Future<void> removeHttpAuthCredential(
      {required URLProtectionSpace protectionSpace,
      required URLCredential credential}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("host", () => protectionSpace.host);
    args.putIfAbsent("protocol", () => protectionSpace.protocol);
    args.putIfAbsent("realm", () => protectionSpace.realm);
    args.putIfAbsent("port", () => protectionSpace.port);
    args.putIfAbsent("username", () => credential.username);
    args.putIfAbsent("password", () => credential.password);
    await _channel.invokeMethod('removeHttpAuthCredential', args);
  }

  ///Removes all the HTTP auth credentials saved for that [protectionSpace].
  Future<void> removeHttpAuthCredentials(
      {required URLProtectionSpace protectionSpace}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("host", () => protectionSpace.host);
    args.putIfAbsent("protocol", () => protectionSpace.protocol);
    args.putIfAbsent("realm", () => protectionSpace.realm);
    args.putIfAbsent("port", () => protectionSpace.port);
    await _channel.invokeMethod('removeHttpAuthCredentials', args);
  }

  ///Removes all the HTTP auth credentials saved in the database.
  Future<void> clearAllAuthCredentials() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('clearAllAuthCredentials', args);
  }
}
