import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase}
///
///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.supported_platforms}
class HttpAuthCredentialDatabase {
  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase}
  ///
  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.supported_platforms}
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
    _instance ??= HttpAuthCredentialDatabase();
    return _instance!;
  }

  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.getAllAuthCredentials}
  ///
  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.getAllAuthCredentials.supported_platforms}
  Future<List<URLProtectionSpaceHttpAuthCredentials>> getAllAuthCredentials() =>
      platform.getAllAuthCredentials();

  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.getHttpAuthCredentials}
  ///
  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.getHttpAuthCredentials.supported_platforms}
  Future<List<URLCredential>> getHttpAuthCredentials({
    required URLProtectionSpace protectionSpace,
  }) => platform.getHttpAuthCredentials(protectionSpace: protectionSpace);

  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.setHttpAuthCredential}
  ///
  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.setHttpAuthCredential.supported_platforms}
  Future<void> setHttpAuthCredential({
    required URLProtectionSpace protectionSpace,
    required URLCredential credential,
  }) => platform.setHttpAuthCredential(
    protectionSpace: protectionSpace,
    credential: credential,
  );

  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredential}
  ///
  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredential.supported_platforms}
  Future<void> removeHttpAuthCredential({
    required URLProtectionSpace protectionSpace,
    required URLCredential credential,
  }) => platform.removeHttpAuthCredential(
    protectionSpace: protectionSpace,
    credential: credential,
  );

  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredentials}
  ///
  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.removeHttpAuthCredentials.supported_platforms}
  Future<void> removeHttpAuthCredentials({
    required URLProtectionSpace protectionSpace,
  }) => platform.removeHttpAuthCredentials(protectionSpace: protectionSpace);

  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.clearAllAuthCredentials}
  ///
  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.clearAllAuthCredentials.supported_platforms}
  Future<void> clearAllAuthCredentials() => platform.clearAllAuthCredentials();

  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabaseCreationParams.isClassSupported}
  ///
  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabaseCreationParams.isClassSupported.supported_platforms}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformHttpAuthCredentialDatabase.static().isClassSupported(
        platform: platform,
      );

  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.isMethodSupported}
  ///
  ///{@macro drago_inappwebview.PlatformHttpAuthCredentialDatabase.isMethodSupported.supported_platforms}
  static bool isMethodSupported(
    PlatformHttpAuthCredentialDatabaseMethod method, {
    TargetPlatform? platform,
  }) => PlatformHttpAuthCredentialDatabase.static().isMethodSupported(
    method,
    platform: platform,
  );
}
