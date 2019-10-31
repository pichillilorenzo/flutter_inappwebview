import 'dart:io';

import 'types.dart';
import 'package:flutter_inappbrowser/src/content_blocker.dart';

class AndroidOptions {}
class iOSOptions {}

class WebViewOptions {
  Map<String, dynamic> toMap() {
    return {};
  }
}

class BrowserOptions {
  Map<String, dynamic> toMap() {
    return {};
  }
}

class InAppWebViewOptions implements WebViewOptions, BrowserOptions, AndroidOptions, iOSOptions {
  bool useShouldOverrideUrlLoading;
  bool useOnLoadResource;
  bool useOnDownloadStart;
  bool useOnTargetBlank;
  bool clearCache;
  String userAgent;
  bool javaScriptEnabled;
  bool debuggingEnabled;
  bool javaScriptCanOpenWindowsAutomatically;
  bool mediaPlaybackRequiresUserGesture;
  int textZoom;
  int minimumFontSize;
  bool verticalScrollBarEnabled;
  bool horizontalScrollBarEnabled;
  List<String> resourceCustomSchemes;
  List<ContentBlocker> contentBlockers;
  InAppWebViewUserPreferredContentMode preferredContentMode;

  InAppWebViewOptions({this.useShouldOverrideUrlLoading = false, this.useOnLoadResource = false, this.useOnDownloadStart = false, this.useOnTargetBlank = false,
    this.clearCache = false, this.userAgent = "", this.javaScriptEnabled = true, this.debuggingEnabled = false, this.javaScriptCanOpenWindowsAutomatically = false,
    this.mediaPlaybackRequiresUserGesture = true, this.textZoom = 100, this.minimumFontSize, this.verticalScrollBarEnabled = true, this.horizontalScrollBarEnabled = true,
    this.resourceCustomSchemes = const [], this.contentBlockers = const [], this.preferredContentMode = InAppWebViewUserPreferredContentMode.RECOMMENDED}) {
      if (this.minimumFontSize == null)
        this.minimumFontSize = Platform.isAndroid ? 8 : 0;
    }

  @override
  Map<String, dynamic> toMap() {
    List<Map<String, Map<String, dynamic>>> contentBlockersMapList = [];
    contentBlockers.forEach((contentBlocker) {
      contentBlockersMapList.add(contentBlocker.toMap());
    });

    return {
      "useShouldOverrideUrlLoading": useShouldOverrideUrlLoading,
      "useOnLoadResource": useOnLoadResource,
      "useOnDownloadStart": useOnDownloadStart,
      "useOnTargetBlank": useOnTargetBlank,
      "clearCache": clearCache,
      "userAgent": userAgent,
      "javaScriptEnabled": javaScriptEnabled,
      "javaScriptCanOpenWindowsAutomatically": javaScriptCanOpenWindowsAutomatically,
      "mediaPlaybackRequiresUserGesture": mediaPlaybackRequiresUserGesture,
      "textZoom": textZoom,
      "verticalScrollBarEnabled": verticalScrollBarEnabled,
      "horizontalScrollBarEnabled": horizontalScrollBarEnabled,
      "resourceCustomSchemes": resourceCustomSchemes,
      "contentBlockers": contentBlockersMapList,
      "preferredContentMode": preferredContentMode?.toValue()
    };
  }
}

class AndroidInAppWebViewOptions implements WebViewOptions, BrowserOptions, AndroidOptions {
  bool clearSessionCache;
  bool builtInZoomControls;
  bool displayZoomControls;
  bool supportZoom;
  bool databaseEnabled;
  bool domStorageEnabled;
  bool useWideViewPort;
  bool safeBrowsingEnabled;
  bool transparentBackground;
  AndroidInAppWebViewMixedContentMode mixedContentMode;
  bool allowContentAccess;
  bool allowFileAccess;
  bool allowFileAccessFromFileURLs;
  bool allowUniversalAccessFromFileURLs;
  bool appCacheEnabled;
  String appCachePath;
  bool blockNetworkImage;
  bool blockNetworkLoads;
  AndroidInAppWebViewCacheMode cacheMode;
  String cursiveFontFamily;
  int defaultFixedFontSize;
  int defaultFontSize;
  String defaultTextEncodingName;
  AndroidInAppWebViewModeMenuItem disabledActionModeMenuItems;
  String fantasyFontFamily;
  String fixedFontFamily;
  AndroidInAppWebViewForceDark forceDark;
  bool geolocationEnabled;
  AndroidInAppWebViewLayoutAlgorithm layoutAlgorithm;
  bool loadWithOverviewMode;
  bool loadsImagesAutomatically;
  int minimumLogicalFontSize;
  bool needInitialFocus;
  bool offscreenPreRaster;
  String sansSerifFontFamily;
  String serifFontFamily;
  String standardFontFamily;

  AndroidInAppWebViewOptions({this.clearSessionCache = false, this.builtInZoomControls = false, this.displayZoomControls = false, this.supportZoom = true, this.databaseEnabled = false,
    this.domStorageEnabled = false, this.useWideViewPort = true, this.safeBrowsingEnabled = true, this.transparentBackground = false, this.mixedContentMode,
    this.allowContentAccess = true, this.allowFileAccess = true, this.allowFileAccessFromFileURLs = true, this.allowUniversalAccessFromFileURLs = true,
    this.appCacheEnabled = true, this.appCachePath, this.blockNetworkImage = false, this.blockNetworkLoads = false, this.cacheMode = AndroidInAppWebViewCacheMode.LOAD_DEFAULT,
    this.cursiveFontFamily = "cursive", this.defaultFixedFontSize = 16, this.defaultFontSize = 16, this.defaultTextEncodingName = "UTF-8",
    this.disabledActionModeMenuItems, this.fantasyFontFamily = "fantasy", this.fixedFontFamily = "monospace", this.forceDark = AndroidInAppWebViewForceDark.FORCE_DARK_OFF,
    this.geolocationEnabled = true, this.layoutAlgorithm, this.loadWithOverviewMode = true, this.loadsImagesAutomatically = true,
    this.minimumLogicalFontSize = 8, this.needInitialFocus = true, this.offscreenPreRaster = false, this.sansSerifFontFamily = "sans-serif", this.serifFontFamily = "sans-serif",
    this.standardFontFamily = "sans-serif"
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "clearSessionCache": clearSessionCache,
      "builtInZoomControls": builtInZoomControls,
      "displayZoomControls": displayZoomControls,
      "supportZoom": supportZoom,
      "databaseEnabled": databaseEnabled,
      "domStorageEnabled": domStorageEnabled,
      "useWideViewPort": useWideViewPort,
      "safeBrowsingEnabled": safeBrowsingEnabled,
      "transparentBackground": transparentBackground,
      "mixedContentMode": mixedContentMode?.toValue(),
      "allowContentAccess": allowContentAccess,
      "allowFileAccess": allowFileAccess,
      "allowFileAccessFromFileURLs": allowFileAccessFromFileURLs,
      "allowUniversalAccessFromFileURLs": allowUniversalAccessFromFileURLs,
      "appCacheEnabled": appCacheEnabled,
      "appCachePath": appCachePath,
      "blockNetworkImage": blockNetworkImage,
      "blockNetworkLoads": blockNetworkLoads,
      "cacheMode": cacheMode?.toValue(),
      "cursiveFontFamily": cursiveFontFamily,
      "defaultFixedFontSize": defaultFixedFontSize,
      "defaultFontSize": defaultFontSize,
      "defaultTextEncodingName": defaultTextEncodingName,
      "disabledActionModeMenuItems": disabledActionModeMenuItems?.toValue(),
      "fantasyFontFamily": fantasyFontFamily,
      "fixedFontFamily": fixedFontFamily,
      "forceDark": forceDark?.toValue(),
      "geolocationEnabled": geolocationEnabled,
      "layoutAlgorithm": layoutAlgorithm?.toValue(),
      "loadWithOverviewMode": loadWithOverviewMode,
      "loadsImagesAutomatically": loadsImagesAutomatically,
      "minimumLogicalFontSize": minimumLogicalFontSize,
      "needInitialFocus": needInitialFocus,
      "offscreenPreRaster": offscreenPreRaster,
      "sansSerifFontFamily": sansSerifFontFamily,
      "serifFontFamily": serifFontFamily,
      "standardFontFamily": standardFontFamily
    };
  }
}

class iOSInAppWebViewOptions implements WebViewOptions, BrowserOptions, iOSOptions {
  bool disallowOverScroll;
  bool enableViewportScale;
  bool suppressesIncrementalRendering;
  bool allowsAirPlayForMediaPlayback;
  bool allowsBackForwardNavigationGestures;
  bool allowsLinkPreview;
  bool ignoresViewportScaleLimits;
  bool allowsInlineMediaPlayback;
  bool allowsPictureInPictureMediaPlayback;
  bool transparentBackground;
  String applicationNameForUserAgent;
  bool isFraudulentWebsiteWarningEnabled;
  iOSInAppWebViewSelectionGranularity selectionGranularity;
  List<iOSInAppWebViewDataDetectorTypes> dataDetectorTypes;

  iOSInAppWebViewOptions({this.disallowOverScroll = false, this.enableViewportScale = false, this.suppressesIncrementalRendering = false, this.allowsAirPlayForMediaPlayback = true,
    this.allowsBackForwardNavigationGestures = true, this.allowsLinkPreview = true, this.ignoresViewportScaleLimits = false, this.allowsInlineMediaPlayback = false,
    this.allowsPictureInPictureMediaPlayback = true, this.transparentBackground = false, this.applicationNameForUserAgent = "", this.isFraudulentWebsiteWarningEnabled = true,
    this.selectionGranularity = iOSInAppWebViewSelectionGranularity.DYNAMIC, this.dataDetectorTypes = const [iOSInAppWebViewDataDetectorTypes.NONE]
  });

  @override
  Map<String, dynamic> toMap() {
    List<String> dataDetectorTypesList = [];
    dataDetectorTypes.forEach((dataDetectorType) {
      dataDetectorTypesList.add(dataDetectorType.toValue());
    });

    return {
      "disallowOverScroll": disallowOverScroll,
      "enableViewportScale": enableViewportScale,
      "suppressesIncrementalRendering": suppressesIncrementalRendering,
      "allowsAirPlayForMediaPlayback": allowsAirPlayForMediaPlayback,
      "allowsBackForwardNavigationGestures": allowsBackForwardNavigationGestures,
      "allowsLinkPreview": allowsLinkPreview,
      "ignoresViewportScaleLimits": ignoresViewportScaleLimits,
      "allowsInlineMediaPlayback": allowsInlineMediaPlayback,
      "allowsPictureInPictureMediaPlayback": allowsPictureInPictureMediaPlayback,
      "transparentBackground": transparentBackground,
      "applicationNameForUserAgent": applicationNameForUserAgent,
      "isFraudulentWebsiteWarningEnabled": isFraudulentWebsiteWarningEnabled,
      "selectionGranularity": selectionGranularity.toValue(),
      "dataDetectorTypes": dataDetectorTypesList
    };
  }
}

class InAppBrowserOptions implements BrowserOptions, AndroidOptions, iOSOptions {
  bool hidden;
  bool toolbarTop;
  String toolbarTopBackgroundColor;
  String toolbarTopFixedTitle;
  bool hideUrlBar;

  InAppBrowserOptions({this.hidden = false, this.toolbarTop = true, this.toolbarTopBackgroundColor = "", this.toolbarTopFixedTitle = "", this.hideUrlBar = false});

  @override
  Map<String, dynamic> toMap() {
    return {
      "hidden": hidden,
      "toolbarTop": toolbarTop,
      "toolbarTopBackgroundColor": toolbarTopBackgroundColor,
      "toolbarTopFixedTitle": toolbarTopFixedTitle,
      "hideUrlBar": hideUrlBar,
    };
  }
}

class AndroidInAppBrowserOptions implements BrowserOptions, AndroidOptions {
  bool hideTitleBar;
  bool closeOnCannotGoBack;
  bool progressBar;

  AndroidInAppBrowserOptions({this.hideTitleBar = true, this.closeOnCannotGoBack = true, this.progressBar = true});

  @override
  Map<String, dynamic> toMap() {
    return {
      "hideTitleBar": hideTitleBar,
      "closeOnCannotGoBack": closeOnCannotGoBack,
      "progressBar": progressBar,
    };
  }
}

class iOSInAppBrowserOptions implements BrowserOptions, iOSOptions {
  bool toolbarBottom;
  String toolbarBottomBackgroundColor;
  bool toolbarBottomTranslucent;
  String closeButtonCaption;
  String closeButtonColor;
  iOSWebViewOptionsPresentationStyle presentationStyle;
  iOSWebViewOptionsTransitionStyle transitionStyle;
  bool spinner;

  iOSInAppBrowserOptions({this.toolbarBottom = true, this.toolbarBottomBackgroundColor = "", this.toolbarBottomTranslucent = true, this.closeButtonCaption = "",
    this.closeButtonColor = "", this.presentationStyle = iOSWebViewOptionsPresentationStyle.FULL_SCREEN,
    this.transitionStyle = iOSWebViewOptionsTransitionStyle.COVER_VERTICAL, this.spinner = true});

  @override
  Map<String, dynamic> toMap() {
    return {
      "toolbarBottom": toolbarBottom,
      "toolbarBottomBackgroundColor": toolbarBottomBackgroundColor,
      "toolbarBottomTranslucent": toolbarBottomTranslucent,
      "closeButtonCaption": closeButtonCaption,
      "closeButtonColor": closeButtonColor,
      "presentationStyle": presentationStyle.toValue(),
      "transitionStyle": transitionStyle.toValue(),
      "spinner": spinner,
    };
  }
}

class ChromeSafariBrowserOptions {
  Map<String, dynamic> toMap() {
    return {};
  }
}

class AndroidChromeCustomTabsOptions implements ChromeSafariBrowserOptions, AndroidOptions {
  bool addShareButton;
  bool showTitle;
  String toolbarBackgroundColor;
  bool enableUrlBarHiding;
  bool instantAppsEnabled;

  AndroidChromeCustomTabsOptions({this.addShareButton = true, this.showTitle = true, this.toolbarBackgroundColor = "", this.enableUrlBarHiding = false, this.instantAppsEnabled = false});

  @override
  Map<String, dynamic> toMap() {
    return {
      "addShareButton": addShareButton,
      "showTitle": showTitle,
      "toolbarBackgroundColor": toolbarBackgroundColor,
      "enableUrlBarHiding": enableUrlBarHiding,
      "instantAppsEnabled": instantAppsEnabled,
    };
  }
}

class iOSSafariOptions implements ChromeSafariBrowserOptions, iOSOptions {
  bool entersReaderIfAvailable;
  bool barCollapsingEnabled;
  iOSSafariOptionsDismissButtonStyle dismissButtonStyle;
  String preferredBarTintColor;
  String preferredControlTintColor;
  iOSWebViewOptionsPresentationStyle presentationStyle;
  iOSWebViewOptionsTransitionStyle transitionStyle;

  iOSSafariOptions({this.entersReaderIfAvailable = false, this.barCollapsingEnabled = false, this.dismissButtonStyle = iOSSafariOptionsDismissButtonStyle.DONE,
    this.preferredBarTintColor = "", this.preferredControlTintColor = "", this.presentationStyle = iOSWebViewOptionsPresentationStyle.FULL_SCREEN,
    this.transitionStyle = iOSWebViewOptionsTransitionStyle.COVER_VERTICAL});

  @override
  Map<String, dynamic> toMap() {
    return {
      "entersReaderIfAvailable": entersReaderIfAvailable,
      "barCollapsingEnabled": barCollapsingEnabled,
      "dismissButtonStyle": dismissButtonStyle.toValue(),
      "preferredBarTintColor": preferredBarTintColor,
      "preferredControlTintColor": preferredControlTintColor,
      "presentationStyle": presentationStyle.toValue(),
      "transitionStyle": transitionStyle.toValue(),
    };
  }
}