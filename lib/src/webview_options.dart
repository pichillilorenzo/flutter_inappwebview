import 'package:flutter_inappbrowser/src/content_blocker.dart';

class WebViewOptions {
  Map<String, dynamic> toMap() {
    return {};
  }
}

class InAppWebViewOptions implements WebViewOptions {
  bool useShouldOverrideUrlLoading;
  bool useOnLoadResource;
  bool useOnDownloadStart;
  bool useOnTargetBlank;
  bool clearCache;
  String userAgent;
  bool javaScriptEnabled;
  bool javaScriptCanOpenWindowsAutomatically;
  bool mediaPlaybackRequiresUserGesture;
  int textZoom;
  bool verticalScrollBarEnabled;
  bool horizontalScrollBarEnabled;
  List<String> resourceCustomSchemes;
  List<ContentBlocker> contentBlockers;

  InAppWebViewOptions({this.useShouldOverrideUrlLoading = false, this.useOnLoadResource = false, this.useOnDownloadStart = false, this.useOnTargetBlank = false,
    this.clearCache = false, this.userAgent = "", this.javaScriptEnabled = true, this.javaScriptCanOpenWindowsAutomatically = false,
    this.mediaPlaybackRequiresUserGesture = true, this.textZoom = 100, this.verticalScrollBarEnabled = true, this.horizontalScrollBarEnabled = true, this.resourceCustomSchemes = const [],
    this.contentBlockers = const []});

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

class AndroidInAppWebViewOptions implements WebViewOptions {
  bool clearSessionCache;
  bool builtInZoomControls;
  bool displayZoomControls;
  bool supportZoom;
  bool databaseEnabled;
  bool domStorageEnabled;
  bool useWideViewPort;
  bool safeBrowsingEnabled;
  bool transparentBackground;
  String mixedContentMode;

  AndroidInAppWebViewOptions({this.clearSessionCache = false, this.builtInZoomControls = false, this.displayZoomControls = false, this.supportZoom = true, this.databaseEnabled = false,
    this.domStorageEnabled = false, this.useWideViewPort = true, this.safeBrowsingEnabled = true, this.transparentBackground = false, this.mixedContentMode = ""});

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
      "mixedContentMode": mixedContentMode,
    };
  }
}

class iOSInAppWebViewOptions implements WebViewOptions {
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

  iOSInAppWebViewOptions({this.disallowOverScroll = false, this.enableViewportScale = false, this.suppressesIncrementalRendering = false, this.allowsAirPlayForMediaPlayback = true,
    this.allowsBackForwardNavigationGestures = true, this.allowsLinkPreview = true, this.ignoresViewportScaleLimits = false, this.allowsInlineMediaPlayback = false,
    this.allowsPictureInPictureMediaPlayback = true, this.transparentBackground = false});

  @override
  Map<String, dynamic> toMap() {
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
    };
  }
}

class InAppBrowserOptions implements WebViewOptions {
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

class AndroidInAppBrowserOptions implements WebViewOptions {
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

class iOSInAppBrowserOptions implements WebViewOptions {
  bool toolbarBottom;
  String toolbarBottomBackgroundColor;
  bool toolbarBottomTranslucent;
  String closeButtonCaption;
  String closeButtonColor;
  int presentationStyle; //default fullscreen
  int transitionStyle; //default crossDissolve
  bool spinner;

  iOSInAppBrowserOptions({this.toolbarBottom = true, this.toolbarBottomBackgroundColor = "", this.toolbarBottomTranslucent = true, this.closeButtonCaption = "",
    this.closeButtonColor = "", this.presentationStyle = 0, this.transitionStyle = 0, this.spinner = true});

  @override
  Map<String, dynamic> toMap() {
    return {
      "toolbarBottom": toolbarBottom,
      "toolbarBottomBackgroundColor": toolbarBottomBackgroundColor,
      "toolbarBottomTranslucent": toolbarBottomTranslucent,
      "closeButtonCaption": closeButtonCaption,
      "closeButtonColor": closeButtonColor,
      "presentationStyle": presentationStyle,
      "transitionStyle": transitionStyle,
      "spinner": spinner,
    };
  }
}

class AndroidChromeCustomTabsOptions implements WebViewOptions {
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

class iOSChromeCustomTabsOptions implements WebViewOptions {
  bool entersReaderIfAvailable;
  bool barCollapsingEnabled;
  int dismissButtonStyle; //default done
  String preferredBarTintColor;
  String preferredControlTintColor;
  int presentationStyle; //default fullscreen
  int transitionStyle; //default crossDissolve

  iOSChromeCustomTabsOptions({this.entersReaderIfAvailable = false, this.barCollapsingEnabled = false, this.dismissButtonStyle = 0, this.preferredBarTintColor = "",
    this.preferredControlTintColor = "", this.presentationStyle = 0, this.transitionStyle = 0});

  @override
  Map<String, dynamic> toMap() {
    return {
      "entersReaderIfAvailable": entersReaderIfAvailable,
      "barCollapsingEnabled": barCollapsingEnabled,
      "dismissButtonStyle": dismissButtonStyle,
      "preferredBarTintColor": preferredBarTintColor,
      "preferredControlTintColor": preferredControlTintColor,
      "presentationStyle": presentationStyle,
      "transitionStyle": transitionStyle,
    };
  }
}