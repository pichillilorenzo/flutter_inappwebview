import '../in_app_webview/webview.dart';

///Class that represents a [WebView] package info.
class WebViewPackageInfo {
  ///The version name of this WebView package.
  String? versionName;

  ///The name of this WebView package.
  String? packageName;

  WebViewPackageInfo({this.versionName, this.packageName});

  ///Gets a possible [WebViewPackageInfo] instance from a [Map] value.
  static WebViewPackageInfo? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? WebViewPackageInfo(
        versionName: map["versionName"], packageName: map["packageName"])
        : null;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"versionName": versionName, "packageName": packageName};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents an Android [WebView] package info.
///Use [WebViewPackageInfo] instead.
@Deprecated("Use WebViewPackageInfo instead")
class AndroidWebViewPackageInfo {
  ///The version name of this WebView package.
  String? versionName;

  ///The name of this WebView package.
  String? packageName;

  AndroidWebViewPackageInfo({this.versionName, this.packageName});

  ///Gets a possible [AndroidWebViewPackageInfo] instance from a [Map] value.
  static AndroidWebViewPackageInfo? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? AndroidWebViewPackageInfo(
        versionName: map["versionName"], packageName: map["packageName"])
        : null;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"versionName": versionName, "packageName": packageName};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}