import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [LinuxHttpAuthCredentialDatabase].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformHttpAuthCredentialDatabaseCreationParams] for
/// more information.
@immutable
class LinuxHttpAuthCredentialDatabaseCreationParams
    extends PlatformHttpAuthCredentialDatabaseCreationParams {
  /// Creates a new [LinuxHttpAuthCredentialDatabaseCreationParams] instance.
  const LinuxHttpAuthCredentialDatabaseCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) : super();

  /// Creates a [LinuxHttpAuthCredentialDatabaseCreationParams] instance based on [PlatformHttpAuthCredentialDatabaseCreationParams].
  factory LinuxHttpAuthCredentialDatabaseCreationParams.fromPlatformHttpAuthCredentialDatabaseCreationParams(
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) {
    return LinuxHttpAuthCredentialDatabaseCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase}
///
/// This implementation delegates to native C++ code which uses libsecret for secure storage.
/// Passwords are stored in the system keyring (gnome-keyring, KDE Wallet, etc.).
/// A JSON index file at ~/.local/share/flutter_inappwebview/<appId>/credential_index.json
/// is used to enumerate stored credentials (contains only usernames, not passwords).
///
/// The native `appId` is resolved from `GApplication.application_id` when available.
/// If it is null/empty, it falls back to the executable filename (from `/proc/self/exe`), sanitized.
class LinuxHttpAuthCredentialDatabase
    extends PlatformHttpAuthCredentialDatabase {
  static const MethodChannel _channel = MethodChannel(
    'com.pichillilorenzo/flutter_inappwebview_credential_database',
  );

  /// Creates a new [LinuxHttpAuthCredentialDatabase].
  LinuxHttpAuthCredentialDatabase(
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) : super.implementation(
        params is LinuxHttpAuthCredentialDatabaseCreationParams
            ? params
            : LinuxHttpAuthCredentialDatabaseCreationParams.fromPlatformHttpAuthCredentialDatabaseCreationParams(
                params,
              ),
      );

  static LinuxHttpAuthCredentialDatabase? _instance;

  /// Gets the database shared instance.
  static LinuxHttpAuthCredentialDatabase instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static LinuxHttpAuthCredentialDatabase _init() {
    _instance = LinuxHttpAuthCredentialDatabase(
      LinuxHttpAuthCredentialDatabaseCreationParams(
        const PlatformHttpAuthCredentialDatabaseCreationParams(),
      ),
    );
    return _instance!;
  }

  static final LinuxHttpAuthCredentialDatabase _staticValue =
      LinuxHttpAuthCredentialDatabase(
        LinuxHttpAuthCredentialDatabaseCreationParams(
          const PlatformHttpAuthCredentialDatabaseCreationParams(),
        ),
      );

  factory LinuxHttpAuthCredentialDatabase.static() {
    return _staticValue;
  }

  @override
  Future<List<URLProtectionSpaceHttpAuthCredentials>>
  getAllAuthCredentials() async {
    final List<dynamic> allCredentials =
        await _channel.invokeMethod<List>('getAllAuthCredentials', {}) ?? [];

    List<URLProtectionSpaceHttpAuthCredentials> result = [];

    for (final Map<dynamic, dynamic> map in allCredentials) {
      final element = URLProtectionSpaceHttpAuthCredentials.fromMap(
        map.cast<String, dynamic>(),
      );
      if (element != null) {
        result.add(element);
      }
    }
    return result;
  }

  @override
  Future<List<URLCredential>> getHttpAuthCredentials({
    required URLProtectionSpace protectionSpace,
  }) async {
    final Map<String, dynamic> args = {
      'host': protectionSpace.host,
      'protocol': protectionSpace.protocol,
      'realm': protectionSpace.realm,
      'port': protectionSpace.port,
    };

    final List<dynamic> credentialList =
        await _channel.invokeMethod<List>('getHttpAuthCredentials', args) ?? [];

    List<URLCredential> credentials = [];
    for (final Map<dynamic, dynamic> map in credentialList) {
      final credential = URLCredential.fromMap(map.cast<String, dynamic>());
      if (credential != null) {
        credentials.add(credential);
      }
    }
    return credentials;
  }

  @override
  Future<void> setHttpAuthCredential({
    required URLProtectionSpace protectionSpace,
    required URLCredential credential,
  }) async {
    final Map<String, dynamic> args = {
      'host': protectionSpace.host,
      'protocol': protectionSpace.protocol,
      'realm': protectionSpace.realm,
      'port': protectionSpace.port,
      'username': credential.username,
      'password': credential.password,
    };
    await _channel.invokeMethod('setHttpAuthCredential', args);
  }

  @override
  Future<void> removeHttpAuthCredential({
    required URLProtectionSpace protectionSpace,
    required URLCredential credential,
  }) async {
    final Map<String, dynamic> args = {
      'host': protectionSpace.host,
      'protocol': protectionSpace.protocol,
      'realm': protectionSpace.realm,
      'port': protectionSpace.port,
      'username': credential.username,
      'password': credential.password,
    };
    await _channel.invokeMethod('removeHttpAuthCredential', args);
  }

  @override
  Future<void> removeHttpAuthCredentials({
    required URLProtectionSpace protectionSpace,
  }) async {
    final Map<String, dynamic> args = {
      'host': protectionSpace.host,
      'protocol': protectionSpace.protocol,
      'realm': protectionSpace.realm,
      'port': protectionSpace.port,
    };
    await _channel.invokeMethod('removeHttpAuthCredentials', args);
  }

  @override
  Future<void> clearAllAuthCredentials() async {
    await _channel.invokeMethod('clearAllAuthCredentials', {});
  }

  /// Disposes of any resources used by this database.
  /// Nothing to dispose - native side manages its own lifecycle.
  void dispose() {
    // Nothing to dispose
  }
}
