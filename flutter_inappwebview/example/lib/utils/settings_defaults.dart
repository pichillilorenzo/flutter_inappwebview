import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Map<String, dynamic> defaultWebViewEnvironmentSettingsMap() {
  return {};
}

MixedContentMode? parseMixedContentMode(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    return MixedContentMode.fromNativeValue(value);
  }
  return null;
}

CacheMode? parseCacheMode(dynamic value) {
  if (value == null) return CacheMode.LOAD_DEFAULT;
  if (value is int) {
    return CacheMode.fromNativeValue(value);
  }
  return CacheMode.LOAD_DEFAULT;
}

Map<String, dynamic> defaultInAppWebViewSettingsMap({
  TargetPlatform? platform,
}) {
  final resolvedPlatform = platform ?? defaultTargetPlatform;

  return {
    // General Settings
    'javaScriptEnabled': true,
    'userAgent': '',
    'applicationNameForUserAgent': '',
    'cacheEnabled': true,
    'incognito': false,
    'supportZoom': true,

    // Layout Settings
    'useWideViewPort': true,
    'loadWithOverviewMode': true,
    'minimumFontSize': resolvedPlatform == TargetPlatform.android ? 8 : 0,
    'defaultFontSize': 16,
    'defaultTextEncodingName': 'UTF-8',

    // Content Settings
    'allowContentAccess': true,
    'allowFileAccess': true,
    'allowFileAccessFromFileURLs': false,
    'allowUniversalAccessFromFileURLs': false,
    'blockNetworkImage': false,
    'blockNetworkLoads': false,

    // Media Settings
    'mediaPlaybackRequiresUserGesture': true,
    'allowsInlineMediaPlayback': false,
    'allowsAirPlayForMediaPlayback': true,
    'allowsPictureInPictureMediaPlayback': true,
    'automaticallyAdjustsScrollIndicatorInsets': false,

    // JavaScript Settings
    'javaScriptCanOpenWindowsAutomatically': false,
    'javaScriptBridgeEnabled': true,
    'javaScriptBridgeForMainFrameOnly': false,

    // Security Settings
    'mixedContentMode': null,
    'useShouldInterceptRequest': false,
    'useShouldOverrideUrlLoading': false,
    'useOnLoadResource': false,

    // Cache Settings
    'cacheMode': CacheMode.LOAD_DEFAULT.toNativeValue(),

    // Appearance Settings
    'transparentBackground': false,
    'verticalScrollBarEnabled': true,
    'horizontalScrollBarEnabled': true,
    'scrollbarFadingEnabled': true,
    'disableVerticalScroll': false,
    'disableHorizontalScroll': false,
    'disableContextMenu': false,

    // iOS/macOS Specific
    'allowsBackForwardNavigationGestures': true,
    'isFraudulentWebsiteWarningEnabled': true,
    'suppressesIncrementalRendering': false,
    'ignoresViewportScaleLimits': false,
    'allowsLinkPreview': true,
    'selectionGranularity': SelectionGranularity.DYNAMIC.toNativeValue(),

    // Android Specific
    'hardwareAcceleration': true,
    'useHybridComposition': true,
    'thirdPartyCookiesEnabled': true,
    'domStorageEnabled': true,
    'databaseEnabled': true,
    'geolocationEnabled': true,
    'safeBrowsingEnabled': true,
    'builtInZoomControls': true,
    'displayZoomControls': false,

    // Windows Specific
    'generalAutofillEnabled': true,
    'passwordAutosaveEnabled': false,
    'pinchZoomEnabled': true,
    'statusBarEnabled': true,
    'browserAcceleratorKeysEnabled': true,
    'isInspectable': false,
  };
}
