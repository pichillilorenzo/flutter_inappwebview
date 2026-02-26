import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase}
///
///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.supported_platforms}
class HttpAuthCredentialDatabase {
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.supported_platforms}
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

  /// Implementation of [PlatformHttpAuthCredentialDatabase] for the current platform.
  final PlatformHttpAuthCredentialDatabase platform;

  static HttpAuthCredentialDatabase? _instance;

  ///Gets the [HttpAuthCredentialDatabase] shared instance.
  static HttpAuthCredentialDatabase instance() {
    if (_instance == null) {
      _instance = HttpAuthCredentialDatabase();
    }
    return _instance!;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.getAllAuthCredentials}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.getAllAuthCredentials.supported_platforms}
  Future<List<URLProtectionSpaceHttpAuthCredentials>> getAllAuthCredentials() =>
      platform.getAllAuthCredentials();

  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.getHttpAuthCredentials}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.getHttpAuthCredentials.supported_platforms}
  Future<List<URLCredential>> getHttpAuthCredentials({
    required URLProtectionSpace protectionSpace,
  }) => platform.getHttpAuthCredentials(protectionSpace: protectionSpace);

  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.setHttpAuthCredential}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.setHttpAuthCredential.supported_platforms}
  Future<void> setHttpAuthCredential({
    required URLProtectionSpace protectionSpace,
    required URLCredential credential,
  }) => platform.setHttpAuthCredential(
    protectionSpace: protectionSpace,
    credential: credential,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredential}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredential.supported_platforms}
  Future<void> removeHttpAuthCredential({
    required URLProtectionSpace protectionSpace,
    required URLCredential credential,
  }) => platform.removeHttpAuthCredential(
    protectionSpace: protectionSpace,
    credential: credential,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredentials}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredentials.supported_platforms}
  Future<void> removeHttpAuthCredentials({
    required URLProtectionSpace protectionSpace,
  }) => platform.removeHttpAuthCredentials(protectionSpace: protectionSpace);

  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.clearAllAuthCredentials}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.clearAllAuthCredentials.supported_platforms}
  Future<void> clearAllAuthCredentials() => platform.clearAllAuthCredentials();

  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabaseCreationParams.isClassSupported}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabaseCreationParams.isClassSupported.supported_platforms}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformHttpAuthCredentialDatabase.static().isClassSupported(
        platform: platform,
      );

  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.isMethodSupported}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase.isMethodSupported.supported_platforms}
  static bool isMethodSupported(
    PlatformHttpAuthCredentialDatabaseMethod method, {
    TargetPlatform? platform,
  }) => PlatformHttpAuthCredentialDatabase.static().isMethodSupported(
    method,
    platform: platform,
  );
}
