import 'dart:async';

import 'types.dart';
import 'package:flutter/services.dart';

///
class HttpAuthCredentialDatabase {
  static HttpAuthCredentialDatabase _instance;
  static const MethodChannel _channel = const MethodChannel('com.pichillilorenzo/flutter_inappbrowser_credential_database');

  ///
  static HttpAuthCredentialDatabase instance() {
    return (_instance != null) ? _instance : _init();
  }

  static HttpAuthCredentialDatabase _init() {
    _channel.setMethodCallHandler(_handleMethod);
    _instance = new HttpAuthCredentialDatabase();
    return _instance;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
  }

  ///
  Future<List<Map<String, dynamic>>> getAllAuthCredentials() async {
    Map<String, dynamic> args = <String, dynamic>{};
    List<dynamic> allCredentials = await _channel.invokeMethod('getAllAuthCredentials', args);
    List<Map<String, dynamic>> result = [];
    for (Map<dynamic, dynamic> map in allCredentials) {
      Map<dynamic, dynamic> protectionSpace = map["protectionSpace"];
      List<dynamic> credentials = map["credentials"];
      result.add({
        "protectionSpace": ProtectionSpace(host: protectionSpace["host"], protocol: protectionSpace["protocol"], realm: protectionSpace["realm"], port: protectionSpace["port"]),
        "credentials": credentials.map((credential) => HttpAuthCredential(username: credential["username"], password: credential["password"])).toList()
      });
    }
    return result;
  }

  ///
  Future<List<HttpAuthCredential>> getHttpAuthCredentials(ProtectionSpace protectionSpace) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("host", () => protectionSpace.host);
    args.putIfAbsent("protocol", () => protectionSpace.protocol);
    args.putIfAbsent("realm", () => protectionSpace.realm);
    args.putIfAbsent("port", () => protectionSpace.port);
    List<dynamic> credentialList = await _channel.invokeMethod('getHttpAuthCredentials', args);
    List<HttpAuthCredential> credentials = [];
    for (Map<dynamic, dynamic> credential in credentialList) {
      credentials.add(HttpAuthCredential(username: credential["username"], password: credential["password"]));
    }
    return credentials;
  }

  ///
  Future<void> setHttpAuthCredential(ProtectionSpace protectionSpace, HttpAuthCredential credential) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("host", () => protectionSpace.host);
    args.putIfAbsent("protocol", () => protectionSpace.protocol);
    args.putIfAbsent("realm", () => protectionSpace.realm);
    args.putIfAbsent("port", () => protectionSpace.port);
    args.putIfAbsent("username", () => credential.username);
    args.putIfAbsent("password", () => credential.password);
    await _channel.invokeMethod('setHttpAuthCredential', args);
  }

  ///
  Future<void> removeHttpAuthCredential(ProtectionSpace protectionSpace, HttpAuthCredential credential) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("host", () => protectionSpace.host);
    args.putIfAbsent("protocol", () => protectionSpace.protocol);
    args.putIfAbsent("realm", () => protectionSpace.realm);
    args.putIfAbsent("port", () => protectionSpace.port);
    args.putIfAbsent("username", () => credential.username);
    args.putIfAbsent("password", () => credential.password);
    await _channel.invokeMethod('removeHttpAuthCredential', args);
  }

  ///
  Future<void> removeHttpAuthCredentials(ProtectionSpace protectionSpace) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("host", () => protectionSpace.host);
    args.putIfAbsent("protocol", () => protectionSpace.protocol);
    args.putIfAbsent("realm", () => protectionSpace.realm);
    args.putIfAbsent("port", () => protectionSpace.port);
    await _channel.invokeMethod('removeHttpAuthCredentials', args);
  }

  ///
  Future<void> clearAllAuthCredentials() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('clearAllAuthCredentials', args);
  }
}