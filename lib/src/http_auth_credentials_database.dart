import 'dart:async';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

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
class HttpAuthCredentialDatabase {
  /// Constructs a [HttpAuthCredentialDatabase].
  ///
  /// See [HttpAuthCredentialDatabase.fromPlatformCreationParams] for setting
  /// parameters for a specific platform.
  HttpAuthCredentialDatabase()
      : this.fromPlatformCreationParams(
          const PlatformHttpAuthCredentialDatabaseCreationParams(),
        );

  /// Constructs a [HttpAuthCredentialDatabase] from creation params for a specific
  /// platform.
  HttpAuthCredentialDatabase.fromPlatformCreationParams(
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) : this.fromPlatform(PlatformHttpAuthCredentialDatabase(params));

  /// Constructs a [HttpAuthCredentialDatabase] from a specific platform
  /// implementation.
  HttpAuthCredentialDatabase.fromPlatform(this.platform);

  /// Implementation of [PlatformWebViewHttpAuthCredentialDatabase] for the current platform.
  final PlatformHttpAuthCredentialDatabase platform;

  static HttpAuthCredentialDatabase? _instance;

  ///Gets the [HttpAuthCredentialDatabase] shared instance.
  static HttpAuthCredentialDatabase instance() {
    if (_instance == null) {
      _instance = HttpAuthCredentialDatabase();
    }
    return _instance!;
  }

  ///Gets a map list of all HTTP auth credentials saved.
  ///Each map contains the key `protectionSpace` of type [URLProtectionSpace]
  ///and the key `credentials` of type List<[URLCredential]> that contains all the HTTP auth credentials saved for that `protectionSpace`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - URLCredentialStorage.allCredentials](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1413859-allcredentials))
  ///- MacOS ([Official API - URLCredentialStorage.allCredentials](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1413859-allcredentials))
  Future<List<URLProtectionSpaceHttpAuthCredentials>> getAllAuthCredentials() =>
      platform.getAllAuthCredentials();

  ///Gets all the HTTP auth credentials saved for that [protectionSpace].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<List<URLCredential>> getHttpAuthCredentials(
          {required URLProtectionSpace protectionSpace}) =>
      platform.getHttpAuthCredentials(protectionSpace: protectionSpace);

  ///Saves an HTTP auth [credential] for that [protectionSpace].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - URLCredentialStorage.set](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1407227-set))
  ///- MacOS ([Official API - URLCredentialStorage.set](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1407227-set))
  Future<void> setHttpAuthCredential(
          {required URLProtectionSpace protectionSpace,
          required URLCredential credential}) =>
      platform.setHttpAuthCredential(
          protectionSpace: protectionSpace, credential: credential);

  ///Removes an HTTP auth [credential] for that [protectionSpace].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - URLCredentialStorage.remove](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1408664-remove))
  ///- MacOS ([Official API - URLCredentialStorage.remove](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1408664-remove))
  Future<void> removeHttpAuthCredential(
          {required URLProtectionSpace protectionSpace,
          required URLCredential credential}) =>
      platform.removeHttpAuthCredential(
          protectionSpace: protectionSpace, credential: credential);

  ///Removes all the HTTP auth credentials saved for that [protectionSpace].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> removeHttpAuthCredentials(
          {required URLProtectionSpace protectionSpace}) =>
      platform.removeHttpAuthCredentials(protectionSpace: protectionSpace);

  ///Removes all the HTTP auth credentials saved in the database.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> clearAllAuthCredentials() => platform.clearAllAuthCredentials();
}
