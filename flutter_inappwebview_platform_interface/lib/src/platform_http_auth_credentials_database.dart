import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inappwebview_platform.dart';
import 'types/main.dart';

/// Object specifying creation parameters for creating a [PlatformHttpAuthCredentialDatabase].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformHttpAuthCredentialDatabaseCreationParams {
  /// Used by the platform implementation to create a new [PlatformHttpAuthCredentialDatabase].
  const PlatformHttpAuthCredentialDatabaseCreationParams();
}

///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase}
///Class that implements a singleton object (shared instance) which manages the shared HTTP auth credentials cache.
///On iOS and MacOS, this class uses the [URLCredentialStorage](https://developer.apple.com/documentation/foundation/urlcredentialstorage) class.
///On Android, this class has a custom implementation using `android.database.sqlite.SQLiteDatabase` because
///[WebViewDatabase](https://developer.android.com/reference/android/webkit/WebViewDatabase)
///doesn't offer the same functionalities as iOS `URLCredentialStorage`.
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
///{@endtemplate}
abstract class PlatformHttpAuthCredentialDatabase extends PlatformInterface {
  /// Creates a new [PlatformHttpAuthCredentialDatabase]
  factory PlatformHttpAuthCredentialDatabase(
      PlatformHttpAuthCredentialDatabaseCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformHttpAuthCredentialDatabase cookieManager =
        InAppWebViewPlatform.instance!
            .createPlatformHttpAuthCredentialDatabase(params);
    PlatformInterface.verify(cookieManager, _token);
    return cookieManager;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformHttpAuthCredentialDatabase].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformHttpAuthCredentialDatabase.implementation(this.params)
      : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformHttpAuthCredentialDatabase].
  final PlatformHttpAuthCredentialDatabaseCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.getAllAuthCredentials}
  ///Gets a map list of all HTTP auth credentials saved.
  ///Each map contains the key `protectionSpace` of type [URLProtectionSpace]
  ///and the key `credentials` of type List<[URLCredential]> that contains all the HTTP auth credentials saved for that `protectionSpace`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - URLCredentialStorage.allCredentials](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1413859-allcredentials))
  ///- MacOS ([Official API - URLCredentialStorage.allCredentials](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1413859-allcredentials))
  ///{@endtemplate}
  Future<List<URLProtectionSpaceHttpAuthCredentials>> getAllAuthCredentials() {
    throw UnimplementedError(
        'getAllAuthCredentials is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.getHttpAuthCredentials}
  ///Gets all the HTTP auth credentials saved for that [protectionSpace].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<List<URLCredential>> getHttpAuthCredentials(
      {required URLProtectionSpace protectionSpace}) {
    throw UnimplementedError(
        'getHttpAuthCredentials is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.setHttpAuthCredential}
  ///Saves an HTTP auth [credential] for that [protectionSpace].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - URLCredentialStorage.set](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1407227-set))
  ///- MacOS ([Official API - URLCredentialStorage.set](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1407227-set))
  ///{@endtemplate}
  Future<void> setHttpAuthCredential(
      {required URLProtectionSpace protectionSpace,
      required URLCredential credential}) {
    throw UnimplementedError(
        'setHttpAuthCredential is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredential}
  ///Removes an HTTP auth [credential] for that [protectionSpace].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - URLCredentialStorage.remove](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1408664-remove))
  ///- MacOS ([Official API - URLCredentialStorage.remove](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1408664-remove))
  ///{@endtemplate}
  Future<void> removeHttpAuthCredential(
      {required URLProtectionSpace protectionSpace,
      required URLCredential credential}) {
    throw UnimplementedError(
        'removeHttpAuthCredential is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredentials}
  ///Removes all the HTTP auth credentials saved for that [protectionSpace].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<void> removeHttpAuthCredentials(
      {required URLProtectionSpace protectionSpace}) {
    throw UnimplementedError(
        'removeHttpAuthCredentials is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.clearAllAuthCredentials}
  ///Removes all the HTTP auth credentials saved in the database.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<void> clearAllAuthCredentials() {
    throw UnimplementedError(
        'clearAllAuthCredentials is not implemented on the current platform');
  }
}
