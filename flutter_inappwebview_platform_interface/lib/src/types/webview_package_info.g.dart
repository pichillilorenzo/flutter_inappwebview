// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_package_info.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a `WebView` package info.
class WebViewPackageInfo {
  ///The name of this WebView package.
  String? packageName;

  ///The version name of this WebView package.
  String? versionName;
  WebViewPackageInfo({this.packageName, this.versionName});

  ///Gets a possible [WebViewPackageInfo] instance from a [Map] value.
  static WebViewPackageInfo? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = WebViewPackageInfo(
      packageName: map['packageName'],
      versionName: map['versionName'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "packageName": packageName,
      "versionName": versionName,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebViewPackageInfo{packageName: $packageName, versionName: $versionName}';
  }
}

///Class that represents an Android `WebView` package info.
///Use [WebViewPackageInfo] instead.
@Deprecated('Use WebViewPackageInfo instead')
class AndroidWebViewPackageInfo {
  ///The name of this WebView package.
  String? packageName;

  ///The version name of this WebView package.
  String? versionName;
  AndroidWebViewPackageInfo({this.packageName, this.versionName});

  ///Gets a possible [AndroidWebViewPackageInfo] instance from a [Map] value.
  static AndroidWebViewPackageInfo? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = AndroidWebViewPackageInfo(
      packageName: map['packageName'],
      versionName: map['versionName'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "packageName": packageName,
      "versionName": versionName,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'AndroidWebViewPackageInfo{packageName: $packageName, versionName: $versionName}';
  }
}
