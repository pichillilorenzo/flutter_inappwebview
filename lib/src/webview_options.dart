import 'dart:io';

import 'package:flutter_inappbrowser/src/content_blocker.dart';

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

class InAppWebViewOptions implements WebViewOptions, BrowserOptions {
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

  InAppWebViewOptions({this.useShouldOverrideUrlLoading = false, this.useOnLoadResource = false, this.useOnDownloadStart = false, this.useOnTargetBlank = false,
    this.clearCache = false, this.userAgent = "", this.javaScriptEnabled = true, this.debuggingEnabled = false, this.javaScriptCanOpenWindowsAutomatically = false,
    this.mediaPlaybackRequiresUserGesture = true, this.textZoom = 100, this.minimumFontSize, this.verticalScrollBarEnabled = true, this.horizontalScrollBarEnabled = true,
    this.resourceCustomSchemes = const [], this.contentBlockers = const []}) {
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
    };
  }
}

class AndroidInAppWebViewCacheMode {
  final int _value;
  const AndroidInAppWebViewCacheMode._internal(this._value);
  toValue() => _value;

  static const LOAD_DEFAULT = const AndroidInAppWebViewCacheMode._internal(-1);
  static const LOAD_CACHE_ELSE_NETWORK = const AndroidInAppWebViewCacheMode._internal(1);
  static const LOAD_NO_CACHE = const AndroidInAppWebViewCacheMode._internal(2);
  static const LOAD_CACHE_ONLY = const AndroidInAppWebViewCacheMode._internal(3);
}

class AndroidInAppWebViewModeMenuItem {
  final int _value;
  const AndroidInAppWebViewModeMenuItem._internal(this._value);
  toValue() => _value;

  static const MENU_ITEM_NONE = const AndroidInAppWebViewModeMenuItem._internal(0);
  static const MENU_ITEM_SHARE = const AndroidInAppWebViewModeMenuItem._internal(1);
  static const MENU_ITEM_WEB_SEARCH = const AndroidInAppWebViewModeMenuItem._internal(2);
  static const MENU_ITEM_PROCESS_TEXT = const AndroidInAppWebViewModeMenuItem._internal(4);
}

class AndroidInAppWebViewForceDark {
  final int _value;
  const AndroidInAppWebViewForceDark._internal(this._value);
  toValue() => _value;

  static const FORCE_DARK_OFF = const AndroidInAppWebViewForceDark._internal(0);
  static const FORCE_DARK_AUTO = const AndroidInAppWebViewForceDark._internal(1);
  static const FORCE_DARK_ON = const AndroidInAppWebViewForceDark._internal(2);
}

class AndroidInAppWebViewLayoutAlgorithm {
  final String _value;
  const AndroidInAppWebViewLayoutAlgorithm._internal(this._value);
  toValue() => _value;

  static const NORMAL = const AndroidInAppWebViewLayoutAlgorithm._internal("NORMAL");
  static const TEXT_AUTOSIZING = const AndroidInAppWebViewLayoutAlgorithm._internal("TEXT_AUTOSIZING");
}

class AndroidInAppWebViewMixedContentMode {
  final int _value;
  const AndroidInAppWebViewMixedContentMode._internal(this._value);
  toValue() => _value;

  static const MIXED_CONTENT_ALWAYS_ALLOW = const AndroidInAppWebViewMixedContentMode._internal(0);
  static const MIXED_CONTENT_NEVER_ALLOW = const AndroidInAppWebViewMixedContentMode._internal(1);
  static const MIXED_CONTENT_COMPATIBILITY_MODE = const AndroidInAppWebViewMixedContentMode._internal(2);
}

class AndroidInAppWebViewOptions implements WebViewOptions, BrowserOptions {
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

class iOSInAppWebViewSelectionGranularity {
  final int _value;
  const iOSInAppWebViewSelectionGranularity._internal(this._value);
  toValue() => _value;

  static const CHARACTER = const iOSInAppWebViewSelectionGranularity._internal(0);
  static const DYNAMIC = const iOSInAppWebViewSelectionGranularity._internal(1);
}

class iOSInAppWebViewDataDetectorTypes {
  final String _value;
  const iOSInAppWebViewDataDetectorTypes._internal(this._value);
  toValue() => _value;

  static const NONE = const iOSInAppWebViewDataDetectorTypes._internal("NONE");
  static const PHONE_NUMBER = const iOSInAppWebViewDataDetectorTypes._internal("PHONE_NUMBER");
  static const LINK = const iOSInAppWebViewDataDetectorTypes._internal("LINK");
  static const ADDRESS = const iOSInAppWebViewDataDetectorTypes._internal("ADDRESS");
  static const CALENDAR_EVENT = const iOSInAppWebViewDataDetectorTypes._internal("CALENDAR_EVENT");
  static const TRACKING_NUMBER = const iOSInAppWebViewDataDetectorTypes._internal("TRACKING_NUMBER");
  static const FLIGHT_NUMBER = const iOSInAppWebViewDataDetectorTypes._internal("FLIGHT_NUMBER");
  static const LOOKUP_SUGGESTION = const iOSInAppWebViewDataDetectorTypes._internal("LOOKUP_SUGGESTION");
  static const SPOTLIGHT_SUGGESTION = const iOSInAppWebViewDataDetectorTypes._internal("SPOTLIGHT_SUGGESTION");
  static const ALL = const iOSInAppWebViewDataDetectorTypes._internal("ALL");
}

class iOSInAppWebViewUserPreferredContentMode {
  final int _value;
  const iOSInAppWebViewUserPreferredContentMode._internal(this._value);
  toValue() => _value;

  static const RECOMMENDED = const iOSInAppWebViewUserPreferredContentMode._internal(0);
  static const MOBILE = const iOSInAppWebViewUserPreferredContentMode._internal(1);
  static const DESKTOP = const iOSInAppWebViewUserPreferredContentMode._internal(2);
}

class iOSInAppWebViewOptions implements WebViewOptions, BrowserOptions {
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
  iOSInAppWebViewUserPreferredContentMode preferredContentMode;

  iOSInAppWebViewOptions({this.disallowOverScroll = false, this.enableViewportScale = false, this.suppressesIncrementalRendering = false, this.allowsAirPlayForMediaPlayback = true,
    this.allowsBackForwardNavigationGestures = true, this.allowsLinkPreview = true, this.ignoresViewportScaleLimits = false, this.allowsInlineMediaPlayback = false,
    this.allowsPictureInPictureMediaPlayback = true, this.transparentBackground = false, this.applicationNameForUserAgent = "", this.isFraudulentWebsiteWarningEnabled = true,
    this.selectionGranularity = iOSInAppWebViewSelectionGranularity.DYNAMIC, this.dataDetectorTypes = const [iOSInAppWebViewDataDetectorTypes.NONE],
    this.preferredContentMode = iOSInAppWebViewUserPreferredContentMode.RECOMMENDED
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
      "dataDetectorTypes": dataDetectorTypesList,
      "preferredContentMode": preferredContentMode.toValue(),
    };
  }
}

class InAppBrowserOptions implements BrowserOptions {
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

class AndroidInAppBrowserOptions implements BrowserOptions {
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

class iOSInAppBrowserOptionsPresentationStyle {
  final int _value;
  const iOSInAppBrowserOptionsPresentationStyle._internal(this._value);
  toValue() => _value;

  static const FULL_SCREEN = const iOSInAppBrowserOptionsPresentationStyle._internal(0);
  static const PAGE_SHEET = const iOSInAppBrowserOptionsPresentationStyle._internal(1);
  static const FORM_SHEET = const iOSInAppBrowserOptionsPresentationStyle._internal(2);
  static const CURRENT_CONTEXT = const iOSInAppBrowserOptionsPresentationStyle._internal(3);
  static const CUSTOM = const iOSInAppBrowserOptionsPresentationStyle._internal(4);
  static const OVER_FULL_SCREEN = const iOSInAppBrowserOptionsPresentationStyle._internal(5);
  static const OVER_CURRENT_CONTEXT = const iOSInAppBrowserOptionsPresentationStyle._internal(6);
  static const POPOVER = const iOSInAppBrowserOptionsPresentationStyle._internal(7);
  static const NONE = const iOSInAppBrowserOptionsPresentationStyle._internal(8);
  static const AUTOMATIC = const iOSInAppBrowserOptionsPresentationStyle._internal(9);
}

class iOSInAppBrowserOptionsTransitionStyle {
  final int _value;
  const iOSInAppBrowserOptionsTransitionStyle._internal(this._value);
  toValue() => _value;

  static const COVER_VERTICAL = const iOSInAppBrowserOptionsTransitionStyle._internal(0);
  static const FLIP_HORIZONTAL = const iOSInAppBrowserOptionsTransitionStyle._internal(1);
  static const CROSS_DISSOLVE = const iOSInAppBrowserOptionsTransitionStyle._internal(2);
  static const PARTIAL_CURL = const iOSInAppBrowserOptionsTransitionStyle._internal(3);
}

class iOSInAppBrowserOptions implements BrowserOptions {
  bool toolbarBottom;
  String toolbarBottomBackgroundColor;
  bool toolbarBottomTranslucent;
  String closeButtonCaption;
  String closeButtonColor;
  iOSInAppBrowserOptionsPresentationStyle presentationStyle;
  iOSInAppBrowserOptionsTransitionStyle transitionStyle;
  bool spinner;

  iOSInAppBrowserOptions({this.toolbarBottom = true, this.toolbarBottomBackgroundColor = "", this.toolbarBottomTranslucent = true, this.closeButtonCaption = "",
    this.closeButtonColor = "", this.presentationStyle = iOSInAppBrowserOptionsPresentationStyle.FULL_SCREEN,
    this.transitionStyle = iOSInAppBrowserOptionsTransitionStyle.COVER_VERTICAL, this.spinner = true});

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

class ChromeCustomTabsOptions {
  Map<String, dynamic> toMap() {
    return {};
  }
}

class AndroidChromeCustomTabsOptions implements ChromeCustomTabsOptions {
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

class iOSChromeCustomTabsOptionsDismissButtonStyle {
  final int _value;
  const iOSChromeCustomTabsOptionsDismissButtonStyle._internal(this._value);
  toValue() => _value;

  static const DONE = const iOSChromeCustomTabsOptionsDismissButtonStyle._internal(0);
  static const CLOSE = const iOSChromeCustomTabsOptionsDismissButtonStyle._internal(1);
  static const CANCEL = const iOSChromeCustomTabsOptionsDismissButtonStyle._internal(2);
}

class iOSChromeCustomTabsOptions implements ChromeCustomTabsOptions {
  bool entersReaderIfAvailable;
  bool barCollapsingEnabled;
  iOSChromeCustomTabsOptionsDismissButtonStyle dismissButtonStyle;
  String preferredBarTintColor;
  String preferredControlTintColor;
  iOSInAppBrowserOptionsPresentationStyle presentationStyle;
  iOSInAppBrowserOptionsTransitionStyle transitionStyle;

  iOSChromeCustomTabsOptions({this.entersReaderIfAvailable = false, this.barCollapsingEnabled = false, this.dismissButtonStyle = iOSChromeCustomTabsOptionsDismissButtonStyle.DONE,
    this.preferredBarTintColor = "", this.preferredControlTintColor = "", this.presentationStyle = iOSInAppBrowserOptionsPresentationStyle.FULL_SCREEN,
    this.transitionStyle = iOSInAppBrowserOptionsTransitionStyle.COVER_VERTICAL});

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