// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_http_auth_credentials_database.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformHttpAuthCredentialDatabaseCreationParamsClassSupported
    on PlatformHttpAuthCredentialDatabaseCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabaseCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformHttpAuthCredentialDatabaseCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
            .contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformHttpAuthCredentialDatabaseClassSupported
    on PlatformHttpAuthCredentialDatabase {
  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - It has a custom implementation using `android.database.sqlite.SQLiteDatabase` because [WebViewDatabase](https://developer.android.com/reference/android/webkit/WebViewDatabase) doesn't offer the same functionalities as iOS/macOS `URLCredentialStorage`.
  ///- iOS WKWebView:
  ///    - It is implemented using the [URLCredentialStorage](https://developer.apple.com/documentation/foundation/urlcredentialstorage) class.
  ///- macOS WKWebView:
  ///    - It is implemented using the [URLCredentialStorage](https://developer.apple.com/documentation/foundation/urlcredentialstorage) class.
  ///
  ///Use the [PlatformHttpAuthCredentialDatabase.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
            .contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformHttpAuthCredentialDatabase]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformHttpAuthCredentialDatabaseMethod {
  ///Can be used to check if the [PlatformHttpAuthCredentialDatabase.clearAllAuthCredentials] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.clearAllAuthCredentials.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformHttpAuthCredentialDatabase.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clearAllAuthCredentials,

  ///Can be used to check if the [PlatformHttpAuthCredentialDatabase.getAllAuthCredentials] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.getAllAuthCredentials.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - URLCredentialStorage.allCredentials](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1413859-allcredentials))
  ///- macOS WKWebView ([Official API - URLCredentialStorage.allCredentials](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1413859-allcredentials))
  ///
  ///Use the [PlatformHttpAuthCredentialDatabase.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getAllAuthCredentials,

  ///Can be used to check if the [PlatformHttpAuthCredentialDatabase.getHttpAuthCredentials] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.getHttpAuthCredentials.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [protectionSpace]: all platforms
  ///
  ///Use the [PlatformHttpAuthCredentialDatabase.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getHttpAuthCredentials,

  ///Can be used to check if the [PlatformHttpAuthCredentialDatabase.removeHttpAuthCredential] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredential.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - URLCredentialStorage.remove](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1408664-remove))
  ///- macOS WKWebView ([Official API - URLCredentialStorage.remove](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1408664-remove))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [protectionSpace]: all platforms
  ///- [credential]: all platforms
  ///
  ///Use the [PlatformHttpAuthCredentialDatabase.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  removeHttpAuthCredential,

  ///Can be used to check if the [PlatformHttpAuthCredentialDatabase.removeHttpAuthCredentials] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredentials.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [protectionSpace]: all platforms
  ///
  ///Use the [PlatformHttpAuthCredentialDatabase.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  removeHttpAuthCredentials,

  ///Can be used to check if the [PlatformHttpAuthCredentialDatabase.setHttpAuthCredential] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.setHttpAuthCredential.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - URLCredentialStorage.set](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1407227-set))
  ///- macOS WKWebView ([Official API - URLCredentialStorage.set](https://developer.apple.com/documentation/foundation/urlcredentialstorage/1407227-set))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [protectionSpace]: all platforms
  ///- [credential]: all platforms
  ///
  ///Use the [PlatformHttpAuthCredentialDatabase.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setHttpAuthCredential,
}

extension _PlatformHttpAuthCredentialDatabaseMethodSupported
    on PlatformHttpAuthCredentialDatabase {
  static bool isMethodSupported(PlatformHttpAuthCredentialDatabaseMethod method,
      {TargetPlatform? platform}) {
    switch (method) {
      case PlatformHttpAuthCredentialDatabaseMethod.clearAllAuthCredentials:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformHttpAuthCredentialDatabaseMethod.getAllAuthCredentials:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformHttpAuthCredentialDatabaseMethod.getHttpAuthCredentials:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformHttpAuthCredentialDatabaseMethod.removeHttpAuthCredential:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformHttpAuthCredentialDatabaseMethod.removeHttpAuthCredentials:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformHttpAuthCredentialDatabaseMethod.setHttpAuthCredential:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}
