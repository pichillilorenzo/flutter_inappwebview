// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_package_info.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a [WebView] package info.
class WebViewPackageInfo {
  ///The version name of this WebView package.
  String? versionName;

  ///The name of this WebView package.
  String? packageName;
  WebViewPackageInfo({this.versionName, this.packageName});

  ///Gets a possible [WebViewPackageInfo] instance from a [Map] value.
  static WebViewPackageInfo? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = WebViewPackageInfo(
      versionName: map['versionName'],
      packageName: map['packageName'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "versionName": versionName,
      "packageName": packageName,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebViewPackageInfo{versionName: $versionName, packageName: $packageName}';
  }
}

///Class that represents an Android [WebView] package info.
///Use [WebViewPackageInfo] instead.
@Deprecated('Use WebViewPackageInfo instead')
class AndroidWebViewPackageInfo {
  ///The version name of this WebView package.
  String? versionName;

  ///The name of this WebView package.
  String? packageName;
  AndroidWebViewPackageInfo({this.versionName, this.packageName});

  ///Gets a possible [AndroidWebViewPackageInfo] instance from a [Map] value.
  static AndroidWebViewPackageInfo? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = AndroidWebViewPackageInfo(
      versionName: map['versionName'],
      packageName: map['packageName'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "versionName": versionName,
      "packageName": packageName,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'AndroidWebViewPackageInfo{versionName: $versionName, packageName: $packageName}';
  }
}
