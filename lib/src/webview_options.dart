import 'dart:io';

import 'types.dart';
import 'package:flutter_inappbrowser/src/content_blocker.dart';

class AndroidOptions {}
class IosOptions {}

class WebViewOptions {
  Map<String, dynamic> toMap() {
    return {};
  }

  static WebViewOptions fromMap(Map<String, dynamic> map) {
    return null;
  }
}

class BrowserOptions {
  Map<String, dynamic> toMap() {
    return {};
  }

  static BrowserOptions fromMap(Map<String, dynamic> map) {
    return null;
  }
}

class ChromeSafariBrowserOptions {
  Map<String, dynamic> toMap() {
    return {};
  }

  static ChromeSafariBrowserOptions fromMap(Map<String, dynamic> map) {
    return null;
  }
}

class InAppWebViewOptions implements WebViewOptions, BrowserOptions, AndroidOptions, IosOptions {
  bool useShouldOverrideUrlLoading;
  bool useOnLoadResource;
  bool useOnDownloadStart;
  bool useOnTargetBlank;
  bool clearCache;
  String userAgent;
  String applicationNameForUserAgent;
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
  bool useShouldInterceptAjaxRequest;
  bool useShouldInterceptFetchRequest;
  bool incognito;
  bool cacheEnabled;
  bool transparentBackground;

  InAppWebViewOptions({this.useShouldOverrideUrlLoading = false, this.useOnLoadResource = false, this.useOnDownloadStart = false, this.useOnTargetBlank = false,
    this.clearCache = false, this.userAgent = "", this.applicationNameForUserAgent = "", this.javaScriptEnabled = true, this.debuggingEnabled = false, this.javaScriptCanOpenWindowsAutomatically = false,
    this.mediaPlaybackRequiresUserGesture = true, this.textZoom = 100, this.minimumFontSize, this.verticalScrollBarEnabled = true, this.horizontalScrollBarEnabled = true,
    this.resourceCustomSchemes = const [], this.contentBlockers = const [], this.preferredContentMode = InAppWebViewUserPreferredContentMode.RECOMMENDED,
    this.useShouldInterceptAjaxRequest = false, this.useShouldInterceptFetchRequest = false, this.incognito = false, this.cacheEnabled = true, this.transparentBackground = false}) {
      if (this.minimumFontSize == null)
        this.minimumFontSize = Platform.isAndroid ? 8 : 0;
      assert(!this.resourceCustomSchemes.contains("http") && !this.resourceCustomSchemes.contains("https"));
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
      "applicationNameForUserAgent": applicationNameForUserAgent,
      "javaScriptEnabled": javaScriptEnabled,
      "debuggingEnabled": debuggingEnabled,
      "javaScriptCanOpenWindowsAutomatically": javaScriptCanOpenWindowsAutomatically,
      "mediaPlaybackRequiresUserGesture": mediaPlaybackRequiresUserGesture,
      "textZoom": textZoom,
      "verticalScrollBarEnabled": verticalScrollBarEnabled,
      "horizontalScrollBarEnabled": horizontalScrollBarEnabled,
      "resourceCustomSchemes": resourceCustomSchemes,
      "contentBlockers": contentBlockersMapList,
      "preferredContentMode": preferredContentMode?.toValue(),
      "useShouldInterceptAjaxRequest": useShouldInterceptAjaxRequest,
      "useShouldInterceptFetchRequest": useShouldInterceptFetchRequest,
      "incognito": incognito,
      "cacheEnabled": cacheEnabled,
      "transparentBackground": transparentBackground
    };
  }

  @override
  static InAppWebViewOptions fromMap(Map<String, dynamic> map) {
    List<ContentBlocker> contentBlockers = [];
    List<dynamic> contentBlockersMapList = map["contentBlockers"];
    if (contentBlockersMapList != null) {
      contentBlockersMapList.forEach((contentBlocker) {
        contentBlockers.add(ContentBlocker.fromMap(
            Map<dynamic, Map<dynamic, dynamic>>.from(Map<dynamic, dynamic>.from(contentBlocker))
        ));
      });
    }

    InAppWebViewOptions options = new InAppWebViewOptions();
    options.useShouldOverrideUrlLoading = map["useShouldOverrideUrlLoading"];
    options.useOnLoadResource = map["useOnLoadResource"];
    options.useOnDownloadStart = map["useOnDownloadStart"];
    options.useOnTargetBlank = map["useOnTargetBlank"];
    options.clearCache = map["clearCache"];
    options.userAgent = map["userAgent"];
    options.applicationNameForUserAgent = map["applicationNameForUserAgent"];
    options.javaScriptEnabled = map["javaScriptEnabled"];
    options.debuggingEnabled = map["debuggingEnabled"];
    options.javaScriptCanOpenWindowsAutomatically = map["javaScriptCanOpenWindowsAutomatically"];
    options.mediaPlaybackRequiresUserGesture = map["mediaPlaybackRequiresUserGesture"];
    options.textZoom = map["textZoom"];
    options.verticalScrollBarEnabled = map["verticalScrollBarEnabled"];
    options.horizontalScrollBarEnabled = map["horizontalScrollBarEnabled"];
    options.resourceCustomSchemes = List<String>.from(map["resourceCustomSchemes"] ?? []);
    options.contentBlockers = contentBlockers;
    options.preferredContentMode = InAppWebViewUserPreferredContentMode.fromValue(map["preferredContentMode"]);
    options.useShouldInterceptAjaxRequest = map["useShouldInterceptAjaxRequest"];
    options.useShouldInterceptFetchRequest = map["useShouldInterceptFetchRequest"];
    options.incognito = map["incognito"];
    options.cacheEnabled = map["cacheEnabled"];
    options.transparentBackground = map["transparentBackground"];
    return options;
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
  AndroidInAppWebViewMixedContentMode mixedContentMode;
  bool allowContentAccess;
  bool allowFileAccess;
  bool allowFileAccessFromFileURLs;
  bool allowUniversalAccessFromFileURLs;
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
  bool saveFormData;
  bool thirdPartyCookiesEnabled;
  bool hardwareAcceleration;

  AndroidInAppWebViewOptions({this.clearSessionCache = false, this.builtInZoomControls = false, this.displayZoomControls = false, this.supportZoom = true, this.databaseEnabled = false,
    this.domStorageEnabled = false, this.useWideViewPort = true, this.safeBrowsingEnabled = true, this.mixedContentMode,
    this.allowContentAccess = true, this.allowFileAccess = true, this.allowFileAccessFromFileURLs = true, this.allowUniversalAccessFromFileURLs = true,
    this.appCachePath, this.blockNetworkImage = false, this.blockNetworkLoads = false, this.cacheMode = AndroidInAppWebViewCacheMode.LOAD_DEFAULT,
    this.cursiveFontFamily = "cursive", this.defaultFixedFontSize = 16, this.defaultFontSize = 16, this.defaultTextEncodingName = "UTF-8",
    this.disabledActionModeMenuItems, this.fantasyFontFamily = "fantasy", this.fixedFontFamily = "monospace", this.forceDark = AndroidInAppWebViewForceDark.FORCE_DARK_OFF,
    this.geolocationEnabled = true, this.layoutAlgorithm, this.loadWithOverviewMode = true, this.loadsImagesAutomatically = true,
    this.minimumLogicalFontSize = 8, this.needInitialFocus = true, this.offscreenPreRaster = false, this.sansSerifFontFamily = "sans-serif", this.serifFontFamily = "sans-serif",
    this.standardFontFamily = "sans-serif", this.saveFormData = true, this.thirdPartyCookiesEnabled = true, this.hardwareAcceleration = true
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
      "mixedContentMode": mixedContentMode?.toValue(),
      "allowContentAccess": allowContentAccess,
      "allowFileAccess": allowFileAccess,
      "allowFileAccessFromFileURLs": allowFileAccessFromFileURLs,
      "allowUniversalAccessFromFileURLs": allowUniversalAccessFromFileURLs,
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
      "standardFontFamily": standardFontFamily,
      "saveFormData": saveFormData,
      "thirdPartyCookiesEnabled": thirdPartyCookiesEnabled,
      "hardwareAcceleration": hardwareAcceleration
    };
  }

  @override
  static AndroidInAppWebViewOptions fromMap(Map<String, dynamic> map) {
    AndroidInAppWebViewOptions options = new AndroidInAppWebViewOptions();
    options.clearSessionCache = map["clearSessionCache"];
    options.builtInZoomControls = map["builtInZoomControls"];
    options.displayZoomControls = map["displayZoomControls"];
    options.supportZoom = map["supportZoom"];
    options.databaseEnabled = map["databaseEnabled"];
    options.domStorageEnabled = map["domStorageEnabled"];
    options.useWideViewPort = map["useWideViewPort"];
    options.safeBrowsingEnabled = map["safeBrowsingEnabled"];
    options.mixedContentMode = AndroidInAppWebViewMixedContentMode.fromValue(map["mixedContentMode"]);
    options.allowContentAccess = map["allowContentAccess"];
    options.allowFileAccess = map["allowFileAccess"];
    options.allowFileAccessFromFileURLs = map["allowFileAccessFromFileURLs"];
    options.allowUniversalAccessFromFileURLs = map["allowUniversalAccessFromFileURLs"];
    options.appCachePath = map["appCachePath"];
    options.blockNetworkImage = map["blockNetworkImage"];
    options.blockNetworkLoads = map["blockNetworkLoads"];
    options.cacheMode = AndroidInAppWebViewCacheMode.fromValue(map["cacheMode"]);
    options.cursiveFontFamily = map["cursiveFontFamily"];
    options.defaultFixedFontSize = map["defaultFixedFontSize"];
    options.defaultFontSize = map["defaultFontSize"];
    options.defaultTextEncodingName = map["defaultTextEncodingName"];
    options.disabledActionModeMenuItems = AndroidInAppWebViewModeMenuItem.fromValue(map["disabledActionModeMenuItems"]);
    options.fantasyFontFamily = map["fantasyFontFamily"];
    options.fixedFontFamily = map["fixedFontFamily"];
    options.forceDark = AndroidInAppWebViewForceDark.fromValue(map["forceDark"]);
    options.geolocationEnabled = map["geolocationEnabled"];
    options.layoutAlgorithm = AndroidInAppWebViewLayoutAlgorithm.fromValue(map["layoutAlgorithm"]);
    options.loadWithOverviewMode = map["loadWithOverviewMode"];
    options.loadsImagesAutomatically = map["loadsImagesAutomatically"];
    options.minimumLogicalFontSize = map["minimumLogicalFontSize"];
    options.needInitialFocus = map["needInitialFocus"];
    options.offscreenPreRaster = map["offscreenPreRaster"];
    options.sansSerifFontFamily = map["sansSerifFontFamily"];
    options.serifFontFamily = map["serifFontFamily"];
    options.standardFontFamily = map["standardFontFamily"];
    options.saveFormData = map["saveFormData"];
    options.thirdPartyCookiesEnabled = map["thirdPartyCookiesEnabled"];
    options.hardwareAcceleration = map["hardwareAcceleration"];
    return options;
  }
}

class IosInAppWebViewOptions implements WebViewOptions, BrowserOptions, IosOptions {
  bool disallowOverScroll;
  bool enableViewportScale;
  bool suppressesIncrementalRendering;
  bool allowsAirPlayForMediaPlayback;
  bool allowsBackForwardNavigationGestures;
  bool allowsLinkPreview;
  bool ignoresViewportScaleLimits;
  bool allowsInlineMediaPlayback;
  bool allowsPictureInPictureMediaPlayback;
  bool isFraudulentWebsiteWarningEnabled;
  IosInAppWebViewSelectionGranularity selectionGranularity;
  List<IosInAppWebViewDataDetectorTypes> dataDetectorTypes;
  bool sharedCookiesEnabled;

  IosInAppWebViewOptions({this.disallowOverScroll = false, this.enableViewportScale = false, this.suppressesIncrementalRendering = false, this.allowsAirPlayForMediaPlayback = true,
    this.allowsBackForwardNavigationGestures = true, this.allowsLinkPreview = true, this.ignoresViewportScaleLimits = false, this.allowsInlineMediaPlayback = false,
    this.allowsPictureInPictureMediaPlayback = true, this.isFraudulentWebsiteWarningEnabled = true,
    this.selectionGranularity = IosInAppWebViewSelectionGranularity.DYNAMIC, this.dataDetectorTypes = const [IosInAppWebViewDataDetectorTypes.NONE], this.sharedCookiesEnabled = false
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
      "isFraudulentWebsiteWarningEnabled": isFraudulentWebsiteWarningEnabled,
      "selectionGranularity": selectionGranularity.toValue(),
      "dataDetectorTypes": dataDetectorTypesList,
      "sharedCookiesEnabled": sharedCookiesEnabled
    };
  }

  @override
  static IosInAppWebViewOptions fromMap(Map<String, dynamic> map) {
    List<IosInAppWebViewDataDetectorTypes> dataDetectorTypes = [];
    List<String> dataDetectorTypesList = List<String>.from(map["dataDetectorTypes"] ?? []);
    dataDetectorTypesList.forEach((dataDetectorType) {
      dataDetectorTypes.add(IosInAppWebViewDataDetectorTypes.fromValue(dataDetectorType));
    });

    IosInAppWebViewOptions options = new IosInAppWebViewOptions();
    options.disallowOverScroll = map["disallowOverScroll"];
    options.enableViewportScale = map["enableViewportScale"];
    options.suppressesIncrementalRendering = map["suppressesIncrementalRendering"];
    options.allowsAirPlayForMediaPlayback = map["allowsAirPlayForMediaPlayback"];
    options.allowsBackForwardNavigationGestures = map["allowsBackForwardNavigationGestures"];
    options.allowsLinkPreview = map["allowsLinkPreview"];
    options.ignoresViewportScaleLimits = map["ignoresViewportScaleLimits"];
    options.allowsInlineMediaPlayback = map["allowsInlineMediaPlayback"];
    options.allowsPictureInPictureMediaPlayback = map["allowsPictureInPictureMediaPlayback"];
    options.isFraudulentWebsiteWarningEnabled = map["isFraudulentWebsiteWarningEnabled"];
    options.selectionGranularity = IosInAppWebViewSelectionGranularity.fromValue(map["selectionGranularity"]);
    options.dataDetectorTypes = dataDetectorTypes;
    options.sharedCookiesEnabled = map["sharedCookiesEnabled"];
    return options;
  }
}

class InAppBrowserOptions implements BrowserOptions, AndroidOptions, IosOptions {
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
      "hideUrlBar": hideUrlBar
    };
  }

  @override
  static InAppBrowserOptions fromMap(Map<String, dynamic> map) {
    InAppBrowserOptions options = new InAppBrowserOptions();
    options.hidden = map["hidden"];
    options.toolbarTop = map["toolbarTop"];
    options.toolbarTopBackgroundColor = map["toolbarTopBackgroundColor"];
    options.toolbarTopFixedTitle = map["toolbarTopFixedTitle"];
    options.hideUrlBar = map["hideUrlBar"];
    return options;
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

  @override
  static AndroidInAppBrowserOptions fromMap(Map<String, dynamic> map) {
    AndroidInAppBrowserOptions options = new AndroidInAppBrowserOptions();
    options.hideTitleBar = map["hideTitleBar"];
    options.closeOnCannotGoBack = map["closeOnCannotGoBack"];
    options.progressBar = map["progressBar"];
    return options;
  }
}

class IosInAppBrowserOptions implements BrowserOptions, IosOptions {
  bool toolbarBottom;
  String toolbarBottomBackgroundColor;
  bool toolbarBottomTranslucent;
  String closeButtonCaption;
  String closeButtonColor;
  IosWebViewOptionsPresentationStyle presentationStyle;
  IosWebViewOptionsTransitionStyle transitionStyle;
  bool spinner;

  IosInAppBrowserOptions({this.toolbarBottom = true, this.toolbarBottomBackgroundColor = "", this.toolbarBottomTranslucent = true, this.closeButtonCaption = "",
    this.closeButtonColor = "", this.presentationStyle = IosWebViewOptionsPresentationStyle.FULL_SCREEN,
    this.transitionStyle = IosWebViewOptionsTransitionStyle.COVER_VERTICAL, this.spinner = true});

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
      "spinner": spinner
    };
  }

  @override
  static IosInAppBrowserOptions fromMap(Map<String, dynamic> map) {
    IosInAppBrowserOptions options = new IosInAppBrowserOptions();
    options.toolbarBottom = map["toolbarBottom"];
    options.toolbarBottomBackgroundColor = map["toolbarBottomBackgroundColor"];
    options.toolbarBottomTranslucent = map["toolbarBottomTranslucent"];
    options.closeButtonCaption = map["closeButtonCaption"];
    options.closeButtonColor = map["closeButtonColor"];
    options.presentationStyle = IosWebViewOptionsPresentationStyle.fromValue(map["presentationStyle"]);
    options.transitionStyle = IosWebViewOptionsTransitionStyle.fromValue(map["transitionStyle"]);
    options.spinner = map["spinner"];
    return options;
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
      "instantAppsEnabled": instantAppsEnabled
    };
  }

  @override
  static AndroidChromeCustomTabsOptions fromMap(Map<String, dynamic> map) {
    AndroidChromeCustomTabsOptions options = new AndroidChromeCustomTabsOptions();
    options.addShareButton = map["addShareButton"];
    options.showTitle = map["showTitle"];
    options.toolbarBackgroundColor = map["toolbarBackgroundColor"];
    options.enableUrlBarHiding = map["enableUrlBarHiding"];
    options.instantAppsEnabled = map["instantAppsEnabled"];
    return options;
  }
}

class IosSafariOptions implements ChromeSafariBrowserOptions, IosOptions {
  bool entersReaderIfAvailable;
  bool barCollapsingEnabled;
  IosSafariOptionsDismissButtonStyle dismissButtonStyle;
  String preferredBarTintColor;
  String preferredControlTintColor;
  IosWebViewOptionsPresentationStyle presentationStyle;
  IosWebViewOptionsTransitionStyle transitionStyle;

  IosSafariOptions({this.entersReaderIfAvailable = false, this.barCollapsingEnabled = false, this.dismissButtonStyle = IosSafariOptionsDismissButtonStyle.DONE,
    this.preferredBarTintColor = "", this.preferredControlTintColor = "", this.presentationStyle = IosWebViewOptionsPresentationStyle.FULL_SCREEN,
    this.transitionStyle = IosWebViewOptionsTransitionStyle.COVER_VERTICAL});

  @override
  Map<String, dynamic> toMap() {
    return {
      "entersReaderIfAvailable": entersReaderIfAvailable,
      "barCollapsingEnabled": barCollapsingEnabled,
      "dismissButtonStyle": dismissButtonStyle.toValue(),
      "preferredBarTintColor": preferredBarTintColor,
      "preferredControlTintColor": preferredControlTintColor,
      "presentationStyle": presentationStyle.toValue(),
      "transitionStyle": transitionStyle.toValue()
    };
  }

  @override
  static IosSafariOptions fromMap(Map<String, dynamic> map) {
    IosSafariOptions options = new IosSafariOptions();
    options.entersReaderIfAvailable = map["entersReaderIfAvailable"];
    options.barCollapsingEnabled = map["barCollapsingEnabled"];
    options.dismissButtonStyle = IosSafariOptionsDismissButtonStyle.fromValue(map["dismissButtonStyle"]);
    options.preferredBarTintColor = map["preferredBarTintColor"];
    options.preferredControlTintColor = map["preferredControlTintColor"];
    options.presentationStyle = IosWebViewOptionsPresentationStyle.fromValue(map["presentationStyle"]);
    options.transitionStyle = IosWebViewOptionsTransitionStyle.fromValue(map["transitionStyle"]);
    return options;
  }
}