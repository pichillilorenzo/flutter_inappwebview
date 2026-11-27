// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_web_storage.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformWebStorageCreationParamsClassSupported
    on PlatformWebStorageCreationParams {
  ///{@template drago_inappwebview.PlatformWebStorageCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformWebStorageCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return kIsWeb && platform == null
        ? true
        : ((kIsWeb && platform != null) || !kIsWeb) &&
              [
                TargetPlatform.android,
                TargetPlatform.iOS,
                TargetPlatform.macOS,
                TargetPlatform.windows,
                TargetPlatform.linux,
              ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformWebStorageCreationParams]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformWebStorageCreationParamsProperty {
  ///Can be used to check if the [PlatformWebStorageCreationParams.localStorage] property is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformWebStorageCreationParams.localStorage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformWebStorageCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  localStorage,

  ///Can be used to check if the [PlatformWebStorageCreationParams.sessionStorage] property is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformWebStorageCreationParams.sessionStorage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformWebStorageCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  sessionStorage,
}

extension _PlatformWebStorageCreationParamsPropertySupported
    on PlatformWebStorageCreationParams {
  static bool isPropertySupported(
    PlatformWebStorageCreationParamsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case PlatformWebStorageCreationParamsProperty.localStorage:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebStorageCreationParamsProperty.sessionStorage:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _PlatformWebStorageClassSupported on PlatformWebStorage {
  ///{@template drago_inappwebview.PlatformWebStorage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformWebStorage.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return kIsWeb && platform == null
        ? true
        : ((kIsWeb && platform != null) || !kIsWeb) &&
              [
                TargetPlatform.android,
                TargetPlatform.iOS,
                TargetPlatform.macOS,
                TargetPlatform.windows,
                TargetPlatform.linux,
              ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformWebStorage]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformWebStorageProperty {
  ///Can be used to check if the [PlatformWebStorage.localStorage] property is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformWebStorage.localStorage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformWebStorage.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  localStorage,

  ///Can be used to check if the [PlatformWebStorage.sessionStorage] property is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformWebStorage.sessionStorage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformWebStorage.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  sessionStorage,
}

extension _PlatformWebStoragePropertySupported on PlatformWebStorage {
  static bool isPropertySupported(
    PlatformWebStorageProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case PlatformWebStorageProperty.localStorage:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebStorageProperty.sessionStorage:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

///List of [PlatformWebStorage]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformWebStorageMethod {
  ///Can be used to check if the [PlatformWebStorage.dispose] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformWebStorage.dispose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformWebStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dispose,
}

extension _PlatformWebStorageMethodSupported on PlatformWebStorage {
  static bool isMethodSupported(
    PlatformWebStorageMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformWebStorageMethod.dispose:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _PlatformStorageCreationParamsClassSupported
    on PlatformStorageCreationParams {
  ///{@template drago_inappwebview.PlatformStorageCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformStorageCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return kIsWeb && platform == null
        ? true
        : ((kIsWeb && platform != null) || !kIsWeb) &&
              [
                TargetPlatform.android,
                TargetPlatform.iOS,
                TargetPlatform.macOS,
                TargetPlatform.windows,
                TargetPlatform.linux,
              ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformStorageCreationParams]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformStorageCreationParamsProperty {
  ///Can be used to check if the [PlatformStorageCreationParams.controller] property is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformStorageCreationParams.controller.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformStorageCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  controller,

  ///Can be used to check if the [PlatformStorageCreationParams.webStorageType] property is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformStorageCreationParams.webStorageType.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformStorageCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  webStorageType,
}

extension _PlatformStorageCreationParamsPropertySupported
    on PlatformStorageCreationParams {
  static bool isPropertySupported(
    PlatformStorageCreationParamsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case PlatformStorageCreationParamsProperty.controller:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformStorageCreationParamsProperty.webStorageType:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _PlatformLocalStorageCreationParamsClassSupported
    on PlatformLocalStorageCreationParams {
  ///{@template drago_inappwebview.PlatformLocalStorageCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformLocalStorageCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return kIsWeb && platform == null
        ? true
        : ((kIsWeb && platform != null) || !kIsWeb) &&
              [
                TargetPlatform.android,
                TargetPlatform.iOS,
                TargetPlatform.macOS,
                TargetPlatform.windows,
                TargetPlatform.linux,
              ].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformLocalStorageClassSupported on PlatformLocalStorage {
  ///{@template drago_inappwebview.PlatformLocalStorage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformLocalStorage.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return kIsWeb && platform == null
        ? true
        : ((kIsWeb && platform != null) || !kIsWeb) &&
              [
                TargetPlatform.android,
                TargetPlatform.iOS,
                TargetPlatform.macOS,
                TargetPlatform.windows,
                TargetPlatform.linux,
              ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformLocalStorage]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformLocalStorageMethod {
  ///Can be used to check if the [PlatformLocalStorage.clear] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformLocalStorage.clear.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformLocalStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clear,

  ///Can be used to check if the [PlatformLocalStorage.dispose] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformLocalStorage.dispose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformLocalStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dispose,

  ///Can be used to check if the [PlatformLocalStorage.getItem] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformLocalStorage.getItem.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [key]: all platforms
  ///
  ///Use the [PlatformLocalStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getItem,

  ///Can be used to check if the [PlatformLocalStorage.getItems] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformLocalStorage.getItems.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformLocalStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getItems,

  ///Can be used to check if the [PlatformLocalStorage.key] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformLocalStorage.key.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [index]: all platforms
  ///
  ///Use the [PlatformLocalStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  key,

  ///Can be used to check if the [PlatformLocalStorage.length] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformLocalStorage.length.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformLocalStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  length,

  ///Can be used to check if the [PlatformLocalStorage.removeItem] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformLocalStorage.removeItem.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [key]: all platforms
  ///
  ///Use the [PlatformLocalStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  removeItem,

  ///Can be used to check if the [PlatformLocalStorage.setItem] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformLocalStorage.setItem.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [key]: all platforms
  ///- [value]: all platforms
  ///
  ///Use the [PlatformLocalStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setItem,
}

extension _PlatformLocalStorageMethodSupported on PlatformLocalStorage {
  static bool isMethodSupported(
    PlatformLocalStorageMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformLocalStorageMethod.clear:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformLocalStorageMethod.dispose:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformLocalStorageMethod.getItem:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformLocalStorageMethod.getItems:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformLocalStorageMethod.key:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformLocalStorageMethod.length:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformLocalStorageMethod.removeItem:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformLocalStorageMethod.setItem:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _PlatformSessionStorageCreationParamsClassSupported
    on PlatformSessionStorageCreationParams {
  ///{@template drago_inappwebview.PlatformSessionStorageCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformSessionStorageCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return kIsWeb && platform == null
        ? true
        : ((kIsWeb && platform != null) || !kIsWeb) &&
              [
                TargetPlatform.android,
                TargetPlatform.iOS,
                TargetPlatform.macOS,
                TargetPlatform.windows,
                TargetPlatform.linux,
              ].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformSessionStorageClassSupported on PlatformSessionStorage {
  ///{@template drago_inappwebview.PlatformSessionStorage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformSessionStorage.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return kIsWeb && platform == null
        ? true
        : ((kIsWeb && platform != null) || !kIsWeb) &&
              [
                TargetPlatform.android,
                TargetPlatform.iOS,
                TargetPlatform.macOS,
                TargetPlatform.windows,
                TargetPlatform.linux,
              ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformSessionStorage]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformSessionStorageMethod {
  ///Can be used to check if the [PlatformSessionStorage.clear] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformSessionStorage.clear.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformSessionStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clear,

  ///Can be used to check if the [PlatformSessionStorage.dispose] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformSessionStorage.dispose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformSessionStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dispose,

  ///Can be used to check if the [PlatformSessionStorage.getItem] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformSessionStorage.getItem.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [key]: all platforms
  ///
  ///Use the [PlatformSessionStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getItem,

  ///Can be used to check if the [PlatformSessionStorage.getItems] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformSessionStorage.getItems.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformSessionStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getItems,

  ///Can be used to check if the [PlatformSessionStorage.key] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformSessionStorage.key.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [index]: all platforms
  ///
  ///Use the [PlatformSessionStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  key,

  ///Can be used to check if the [PlatformSessionStorage.length] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformSessionStorage.length.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformSessionStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  length,

  ///Can be used to check if the [PlatformSessionStorage.removeItem] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformSessionStorage.removeItem.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [key]: all platforms
  ///
  ///Use the [PlatformSessionStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  removeItem,

  ///Can be used to check if the [PlatformSessionStorage.setItem] method is supported at runtime.
  ///
  ///{@template drago_inappwebview.PlatformSessionStorage.setItem.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [key]: all platforms
  ///- [value]: all platforms
  ///
  ///Use the [PlatformSessionStorage.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setItem,
}

extension _PlatformSessionStorageMethodSupported on PlatformSessionStorage {
  static bool isMethodSupported(
    PlatformSessionStorageMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformSessionStorageMethod.clear:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformSessionStorageMethod.dispose:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformSessionStorageMethod.getItem:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformSessionStorageMethod.getItems:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformSessionStorageMethod.key:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformSessionStorageMethod.length:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformSessionStorageMethod.removeItem:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformSessionStorageMethod.setItem:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
