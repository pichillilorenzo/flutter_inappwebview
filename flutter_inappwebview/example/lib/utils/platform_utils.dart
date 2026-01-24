import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';

/// Utility class for platform detection and information.
class PlatformUtils {
  /// Gets the name of the current platform.
  static String getPlatformName() {
    if (kIsWeb) {
      return 'Web';
    }
    if (Platform.isAndroid) {
      return 'Android';
    }
    if (Platform.isIOS) {
      return 'iOS';
    }
    if (Platform.isMacOS) {
      return 'macOS';
    }
    if (Platform.isWindows) {
      return 'Windows';
    }
    if (Platform.isLinux) {
      return 'Linux';
    }
    return 'Unknown';
  }

  /// Gets the current platform as a [SupportedPlatform] enum value.
  /// Returns null if the current platform is not recognized.
  static SupportedPlatform? getCurrentPlatform() {
    if (kIsWeb) {
      return SupportedPlatform.web;
    }
    if (Platform.isAndroid) {
      return SupportedPlatform.android;
    }
    if (Platform.isIOS) {
      return SupportedPlatform.ios;
    }
    if (Platform.isMacOS) {
      return SupportedPlatform.macos;
    }
    if (Platform.isWindows) {
      return SupportedPlatform.windows;
    }
    if (Platform.isLinux) {
      return SupportedPlatform.linux;
    }
    return null;
  }

  /// Gets the Flutter SDK version.
  /// Note: This is a placeholder. In production, you might use
  /// package_info_plus or similar to get actual version info.
  static String getFlutterVersion() {
    return FlutterVersion.version != null
        ? FlutterVersion.version! + ' (' + (FlutterVersion.channel ?? '') + ')'
        : 'Flutter SDK';
  }

  /// Gets the Dart SDK version.
  static String getDartVersion() {
    return FlutterVersion.dartVersion ??
        (!kIsWeb ? Platform.version : 'Dart SDK');
  }

  /// Returns true if running on web platform.
  static bool isWebPlatform() {
    return kIsWeb;
  }

  /// Returns true if running on mobile platform (Android or iOS).
  static bool isMobilePlatform() {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Returns true if running on desktop platform (Windows, macOS, or Linux).
  static bool isDesktopPlatform() {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// Gets an appropriate icon for the current platform.
  static IconData getPlatformIcon() {
    if (kIsWeb) {
      return Icons.language;
    }
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        return Icons.android;
      }
      if (Platform.isIOS) {
        return Icons.phone_iphone;
      }
      if (Platform.isMacOS) {
        return Icons.laptop_mac;
      }
      if (Platform.isWindows) {
        return Icons.desktop_windows;
      }
      if (Platform.isLinux) {
        return Icons.computer;
      }
    }
    return Icons.devices;
  }

  /// Gets a short platform identifier (lowercase).
  static String getPlatformIdentifier() {
    return getPlatformName().toLowerCase();
  }
}
