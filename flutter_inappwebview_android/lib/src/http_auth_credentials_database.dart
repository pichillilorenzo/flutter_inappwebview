import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [AndroidHttpAuthCredentialDatabase].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformHttpAuthCredentialDatabaseCreationParams] for
/// more information.
@immutable
class AndroidHttpAuthCredentialDatabaseCreationParams
    extends PlatformHttpAuthCredentialDatabaseCreationParams {
  /// Creates a new [AndroidHttpAuthCredentialDatabaseCreationParams] instance.
  const AndroidHttpAuthCredentialDatabaseCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) : super();

  /// Creates a [AndroidHttpAuthCredentialDatabaseCreationParams] instance based on [PlatformHttpAuthCredentialDatabaseCreationParams].
  factory AndroidHttpAuthCredentialDatabaseCreationParams.fromPlatformHttpAuthCredentialDatabaseCreationParams(
      PlatformHttpAuthCredentialDatabaseCreationParams params) {
    return AndroidHttpAuthCredentialDatabaseCreationParams(params);
  }
}

///Class that implements a singleton object (shared instance) which manages the shared HTTP auth credentials cache.
///On iOS and MacOS, this class uses the [URLCredentialStorage](https://developer.apple.com/documentation/foundation/urlcredentialstorage) class.
///On Android, this class has a custom implementation using `android.database.sqlite.SQLiteDatabase` because
///[WebViewDatabase](https://developer.android.com/reference/android/webkit/WebViewDatabase)
///doesn't offer the same functionalities as iOS `URLCredentialStorage`.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class AndroidHttpAuthCredentialDatabase
    extends PlatformHttpAuthCredentialDatabase with ChannelController {
  /// Creates a new [AndroidHttpAuthCredentialDatabase].
  AndroidHttpAuthCredentialDatabase(
      PlatformHttpAuthCredentialDatabaseCreationParams params)
      : super.implementation(
          params is AndroidHttpAuthCredentialDatabaseCreationParams
              ? params
              : AndroidHttpAuthCredentialDatabaseCreationParams
                  .fromPlatformHttpAuthCredentialDatabaseCreationParams(params),
        ) {
    channel = const MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_credential_database');
    handler = handleMethod;
    initMethodCallHandler();
  }

  static AndroidHttpAuthCredentialDatabase? _instance;

  ///Gets the database shared instance.
  static AndroidHttpAuthCredentialDatabase instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidHttpAuthCredentialDatabase _init() {
    _instance = AndroidHttpAuthCredentialDatabase(
        AndroidHttpAuthCredentialDatabaseCreationParams(
            const PlatformHttpAuthCredentialDatabaseCreationParams()));
    return _instance!;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {}

  ///Gets a map list of all HTTP auth credentials saved.
  ///Each map contains the key `protectionSpace` of type [URLProtectionSpace]
  ///and the key `credentials` of type List<[URLCredential]> that contains all the HTTP auth credentials saved for that `protectionSpace`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - URLCredentialStorage.allCredentials](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1413859-allcredentials))
  ///- MacOS ([Official API - URLCredentialStorage.allCredentials](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1413859-allcredentials))
  Future<List<URLProtectionSpaceHttpAuthCredentials>>
      getAllAuthCredentials() async {
    Map<String, dynamic> args = <String, dynamic>{};
    List<dynamic> allCredentials =
        await channel?.invokeMethod<List>('getAllAuthCredentials', args) ?? [];

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
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<List<URLCredential>> getHttpAuthCredentials(
      {required URLProtectionSpace protectionSpace}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("host", () => protectionSpace.host);
    args.putIfAbsent("protocol", () => protectionSpace.protocol);
    args.putIfAbsent("realm", () => protectionSpace.realm);
    args.putIfAbsent("port", () => protectionSpace.port);
    List<dynamic> credentialList =
        await channel?.invokeMethod<List>('getHttpAuthCredentials', args) ?? [];
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
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - URLCredentialStorage.set](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1407227-set))
  ///- MacOS ([Official API - URLCredentialStorage.set](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1407227-set))
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
    await channel?.invokeMethod('setHttpAuthCredential', args);
  }

  ///Removes an HTTP auth [credential] for that [protectionSpace].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - URLCredentialStorage.remove](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1408664-remove))
  ///- MacOS ([Official API - URLCredentialStorage.remove](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1408664-remove))
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
    await channel?.invokeMethod('removeHttpAuthCredential', args);
  }

  ///Removes all the HTTP auth credentials saved for that [protectionSpace].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> removeHttpAuthCredentials(
      {required URLProtectionSpace protectionSpace}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("host", () => protectionSpace.host);
    args.putIfAbsent("protocol", () => protectionSpace.protocol);
    args.putIfAbsent("realm", () => protectionSpace.realm);
    args.putIfAbsent("port", () => protectionSpace.port);
    await channel?.invokeMethod('removeHttpAuthCredentials', args);
  }

  ///Removes all the HTTP auth credentials saved in the database.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> clearAllAuthCredentials() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('clearAllAuthCredentials', args);
  }

  @override
  void dispose() {
    // empty
  }
}

extension InternalHttpAuthCredentialDatabase
    on AndroidHttpAuthCredentialDatabase {
  get handleMethod => _handleMethod;
}
