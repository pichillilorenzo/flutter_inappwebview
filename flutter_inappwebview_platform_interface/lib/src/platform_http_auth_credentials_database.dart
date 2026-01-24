import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inappwebview_platform.dart';
import 'types/main.dart';

part 'platform_http_auth_credentials_database.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabaseCreationParams}
/// Object specifying creation parameters for creating a [PlatformHttpAuthCredentialDatabase].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabaseCreationParams.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    LinuxPlatform(),
  ],
)
@immutable
class PlatformHttpAuthCredentialDatabaseCreationParams {
  /// Used by the platform implementation to create a new [PlatformHttpAuthCredentialDatabase].
  const PlatformHttpAuthCredentialDatabaseCreationParams();

  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabaseCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformHttpAuthCredentialDatabaseCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
}

///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase}
///Class that implements a singleton object (shared instance) which manages the shared HTTP auth credentials cache.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(
      note:
          'It has a custom implementation using `android.database.sqlite.SQLiteDatabase` because [WebViewDatabase](https://developer.android.com/reference/android/webkit/WebViewDatabase) doesn\'t offer the same functionalities as iOS/macOS `URLCredentialStorage`.',
    ),
    IOSPlatform(
      note:
          'It is implemented using the [URLCredentialStorage](https://developer.apple.com/documentation/foundation/urlcredentialstorage) class.',
    ),
    MacOSPlatform(
      note:
          'It is implemented using the [URLCredentialStorage](https://developer.apple.com/documentation/foundation/urlcredentialstorage) class.',
    ),
    LinuxPlatform(
      note:
          'Implemented using libsecret for secure credential storage in the system keyring (gnome-keyring, KDE Wallet, etc.).',
    ),
  ],
)
abstract class PlatformHttpAuthCredentialDatabase extends PlatformInterface {
  /// Creates a new [PlatformHttpAuthCredentialDatabase]
  factory PlatformHttpAuthCredentialDatabase(
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformHttpAuthCredentialDatabase cookieManager =
        InAppWebViewPlatform.instance!.createPlatformHttpAuthCredentialDatabase(
          params,
        );
    PlatformInterface.verify(cookieManager, _token);
    return cookieManager;
  }

  /// Creates a new [PlatformHttpAuthCredentialDatabase] to access static methods.
  factory PlatformHttpAuthCredentialDatabase.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformHttpAuthCredentialDatabase httpAuthCredentialDatabaseStatic =
        InAppWebViewPlatform.instance!
            .createPlatformHttpAuthCredentialDatabaseStatic();
    PlatformInterface.verify(httpAuthCredentialDatabaseStatic, _token);
    return httpAuthCredentialDatabaseStatic;
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.getAllAuthCredentials.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        apiName: 'URLCredentialStorage.allCredentials',
        apiUrl:
            'https://developer.apple.com/documentation/foundation/urlcredentialstorage/1413859-allcredentials',
      ),
      MacOSPlatform(
        apiName: 'URLCredentialStorage.allCredentials',
        apiUrl:
            'https://developer.apple.com/documentation/foundation/urlcredentialstorage/1413859-allcredentials',
      ),
      LinuxPlatform(note: 'Implemented using libsecret for secure storage.'),
    ],
  )
  Future<List<URLProtectionSpaceHttpAuthCredentials>> getAllAuthCredentials() {
    throw UnimplementedError(
      'getAllAuthCredentials is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.getHttpAuthCredentials}
  ///Gets all the HTTP auth credentials saved for that [protectionSpace].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.getHttpAuthCredentials.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<List<URLCredential>> getHttpAuthCredentials({
    required URLProtectionSpace protectionSpace,
  }) {
    throw UnimplementedError(
      'getHttpAuthCredentials is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.setHttpAuthCredential}
  ///Saves an HTTP auth [credential] for that [protectionSpace].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.setHttpAuthCredential.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        apiName: 'URLCredentialStorage.set',
        apiUrl:
            'https://developer.apple.com/documentation/foundation/urlcredentialstorage/1407227-set',
      ),
      MacOSPlatform(
        apiName: 'URLCredentialStorage.set',
        apiUrl:
            'https://developer.apple.com/documentation/foundation/urlcredentialstorage/1407227-set',
      ),
      LinuxPlatform(note: 'Implemented using libsecret for secure storage.'),
    ],
  )
  Future<void> setHttpAuthCredential({
    required URLProtectionSpace protectionSpace,
    required URLCredential credential,
  }) {
    throw UnimplementedError(
      'setHttpAuthCredential is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredential}
  ///Removes an HTTP auth [credential] for that [protectionSpace].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredential.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        apiName: 'URLCredentialStorage.remove',
        apiUrl:
            'https://developer.apple.com/documentation/foundation/urlcredentialstorage/1408664-remove',
      ),
      MacOSPlatform(
        apiName: 'URLCredentialStorage.remove',
        apiUrl:
            'https://developer.apple.com/documentation/foundation/urlcredentialstorage/1408664-remove',
      ),
      LinuxPlatform(note: 'Implemented using libsecret for secure storage.'),
    ],
  )
  Future<void> removeHttpAuthCredential({
    required URLProtectionSpace protectionSpace,
    required URLCredential credential,
  }) {
    throw UnimplementedError(
      'removeHttpAuthCredential is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredentials}
  ///Removes all the HTTP auth credentials saved for that [protectionSpace].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredentials.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> removeHttpAuthCredentials({
    required URLProtectionSpace protectionSpace,
  }) {
    throw UnimplementedError(
      'removeHttpAuthCredentials is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.clearAllAuthCredentials}
  ///Removes all the HTTP auth credentials saved in the database.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.clearAllAuthCredentials.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> clearAllAuthCredentials() {
    throw UnimplementedError(
      'clearAllAuthCredentials is not implemented on the current platform',
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabaseCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformHttpAuthCredentialDatabaseMethod method, {
    TargetPlatform? platform,
  }) => _PlatformHttpAuthCredentialDatabaseMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}
