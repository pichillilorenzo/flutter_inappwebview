import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../types/action_mode_menu_item.dart';
import '../types/cache_mode.dart';
import '../types/data_detector_types.dart';
import '../types/font_hinting_style.dart';
import '../types/font_subpixel_layout.dart';
import '../types/force_dark.dart';
import '../types/force_dark_strategy.dart';
import '../types/layout_algorithm.dart';
import '../types/mixed_content_mode.dart';
import '../types/over_scroll_mode.dart';
import '../types/pdf_toolbar_items.dart';
import '../types/referrer_policy.dart';
import '../types/renderer_priority_policy.dart';
import '../types/sandbox.dart';
import '../types/scrollbar_style.dart';
import '../types/scrollview_content_inset_adjustment_behavior.dart';
import '../types/scrollview_deceleration_rate.dart';
import '../types/selection_granularity.dart';
import '../types/user_preferred_content_mode.dart';
import '../types/vertical_scrollbar_position.dart';

part 'in_app_webview_settings.g.dart';

List<ContentBlocker> _deserializeContentBlockers(
  List<dynamic>? contentBlockersMapList, {
  EnumMethod? enumMethod,
}) {
  List<ContentBlocker> contentBlockers = [];
  if (contentBlockersMapList != null) {
    contentBlockersMapList.forEach((contentBlocker) {
      contentBlockers.add(
        ContentBlocker.fromMap(
          Map<dynamic, Map<dynamic, dynamic>>.from(
            Map<dynamic, dynamic>.from(contentBlocker),
          ),
          enumMethod: enumMethod,
        ),
      );
    });
  }
  return contentBlockers;
}

///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings}
///This class represents all the WebView settings available.
///{@endtemplate}
@ExchangeableObject(copyMethod: true)
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WebPlatform(requiresSameOrigin: false),
    WindowsPlatform(),
  ],
)
class InAppWebViewSettings_ {
  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event.
  ///
  ///If the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  bool? useShouldOverrideUrlLoading;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onLoadResource] event.
  ///
  ///If the [PlatformWebViewCreationParams.onLoadResource] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      LinuxPlatform(),
    ],
  )
  bool? useOnLoadResource;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onDownloadStartRequest] event.
  ///
  ///If the [PlatformWebViewCreationParams.onDownloadStartRequest] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  bool? useOnDownloadStart;

  ///Use [PlatformInAppWebViewController.clearAllCache] instead.
  @Deprecated("Use InAppWebViewController.clearAllCache instead")
  @ExchangeableObjectProperty(leaveDeprecatedInToMapMethod: true)
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  bool? clearCache;

  ///Sets the user-agent for the WebView.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setUserAgentString",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setUserAgentString(java.lang.String)",
      ),
      IOSPlatform(
        apiName: "WKWebView.customUserAgent",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/1414950-customuseragent",
      ),
      MacOSPlatform(
        apiName: "WKWebView.customUserAgent",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/1414950-customuseragent",
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2Settings2.put_UserAgent',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings2?view=webview2-1.0.2210.55#put_useragent',
      ),
    ],
  )
  String? userAgent;

  ///Append to the existing user-agent. Setting userAgent will override this.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        apiName: "WKWebViewConfiguration.applicationNameForUserAgent",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395665-applicationnameforuseragent",
      ),
      MacOSPlatform(
        apiName: "WKWebViewConfiguration.applicationNameForUserAgent",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395665-applicationnameforuseragent",
      ),
    ],
  )
  String? applicationNameForUserAgent;

  ///Set to `true` to enable JavaScript. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setJavaScriptEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setJavaScriptEnabled(boolean)",
      ),
      IOSPlatform(
        apiName: "WKWebpagePreferences.allowsContentJavaScript",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3552422-allowscontentjavascript/",
      ),
      MacOSPlatform(
        apiName: "WKWebpagePreferences.allowsContentJavaScript",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3552422-allowscontentjavascript/",
      ),
      WebPlatform(requiresSameOrigin: false),
      WindowsPlatform(
        apiName: "ICoreWebView2Settings.put_IsScriptEnabled",
        apiUrl:
            "https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2210.55#put_isscriptenabled",
      ),
    ],
  )
  bool? javaScriptEnabled;

  ///Set to `true` to allow JavaScript open windows without user interaction. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setJavaScriptCanOpenWindowsAutomatically",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setJavaScriptCanOpenWindowsAutomatically(boolean)",
      ),
      IOSPlatform(
        apiName: "WKPreferences.javaScriptCanOpenWindowsAutomatically",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/1536573-javascriptcanopenwindowsautomati/",
      ),
      MacOSPlatform(
        apiName: "WKPreferences.javaScriptCanOpenWindowsAutomatically",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/1536573-javascriptcanopenwindowsautomati/",
      ),
      WebPlatform(),
    ],
  )
  bool? javaScriptCanOpenWindowsAutomatically;

  ///Set to `true` to prevent HTML5 audio or video from autoplaying. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setMediaPlaybackRequiresUserGesture",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMediaPlaybackRequiresUserGesture(boolean)",
      ),
      IOSPlatform(
        apiName:
            "WKWebViewConfiguration.mediaTypesRequiringUserActionForPlayback",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1851524-mediatypesrequiringuseractionfor",
      ),
      MacOSPlatform(
        available: "10.12",
        apiName:
            "WKWebViewConfiguration.mediaTypesRequiringUserActionForPlayback",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1851524-mediatypesrequiringuseractionfor",
      ),
    ],
  )
  bool? mediaPlaybackRequiresUserGesture;

  ///Sets the minimum font size. The default value is `8` for Android, `0` for iOS.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setMinimumFontSize",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMinimumFontSize(int)",
      ),
      IOSPlatform(
        apiName: "WKPreferences.minimumFontSize",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/1537155-minimumfontsize/",
      ),
      MacOSPlatform(
        apiName: "WKPreferences.minimumFontSize",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/1537155-minimumfontsize/",
      ),
    ],
  )
  int? minimumFontSize;

  ///Define whether the vertical scrollbar should be drawn or not. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setVerticalScrollBarEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setVerticalScrollBarEnabled(boolean)",
      ),
      IOSPlatform(
        apiName: "UIScrollView.showsVerticalScrollIndicator",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619405-showsverticalscrollindicator/",
      ),
      WebPlatform(
        note:
            "It must have the same value of [horizontalScrollBarEnabled] to take effect.",
      ),
    ],
  )
  bool? verticalScrollBarEnabled;

  ///Define whether the horizontal scrollbar should be drawn or not. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setHorizontalScrollBarEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setHorizontalScrollBarEnabled(boolean)",
      ),
      IOSPlatform(
        apiName: "UIScrollView.showsHorizontalScrollIndicator",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619380-showshorizontalscrollindicator",
      ),
      WebPlatform(
        note:
            "It must have the same value of [verticalScrollBarEnabled] to take effect.",
      ),
    ],
  )
  bool? horizontalScrollBarEnabled;

  ///List of custom schemes that the WebView must handle. Use the [PlatformWebViewCreationParams.onLoadResourceWithCustomScheme] event to intercept resource requests with custom scheme.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(available: "11.0"),
      MacOSPlatform(available: "10.13"),
    ],
  )
  List<String>? resourceCustomSchemes;

  ///List of [ContentBlocker] that are a set of rules used to block content in the browser window.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(available: "11.0"),
      MacOSPlatform(available: "10.13"),
      LinuxPlatform(
        apiName: "WebKitUserContentFilter",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.UserContentFilter.html",
      ),
    ],
  )
  @ExchangeableObjectProperty(deserializer: _deserializeContentBlockers)
  List<ContentBlocker>? contentBlockers;

  ///Sets the content mode that the WebView needs to use when loading and rendering a webpage. The default value is [UserPreferredContentMode.RECOMMENDED].
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        available: "13.0",
        apiName: "WKWebpagePreferences.preferredContentMode",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3194426-preferredcontentmode/",
      ),
      MacOSPlatform(
        available: "10.15",
        apiName: "WKWebpagePreferences.preferredContentMode",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3194426-preferredcontentmode/",
      ),
    ],
  )
  UserPreferredContentMode_? preferredContentMode;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldInterceptAjaxRequest] event.
  ///
  ///Due to the async nature of [PlatformWebViewCreationParams.shouldInterceptAjaxRequest] event implementation,
  ///it will intercept only async `XMLHttpRequest`s ([AjaxRequest.isAsync] with `true`).
  ///To be able to intercept sync `XMLHttpRequest`s, use [InAppWebViewSettings.interceptOnlyAsyncAjaxRequests] to `false`.
  ///If necessary, you should implement your own logic using for example an [UserScript] overriding the
  ///[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) JavaScript object.
  ///
  ///If the [PlatformWebViewCreationParams.shouldInterceptAjaxRequest] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  bool? useShouldInterceptAjaxRequest;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onAjaxReadyStateChange] event.
  ///Also, [useShouldInterceptAjaxRequest] must be set to `true` to take effect.
  ///
  ///Due to the async nature of [PlatformWebViewCreationParams.onAjaxReadyStateChange] event implementation,
  ///using it could cause some issues, so, be careful when using it.
  ///In this case, you should implement your own logic using for example an [UserScript] overriding the
  ///[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) JavaScript object.
  ///
  ///If the [PlatformWebViewCreationParams.onAjaxReadyStateChange] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  bool? useOnAjaxReadyStateChange;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onAjaxProgress] event.
  ///Also, [useShouldInterceptAjaxRequest] must be set to `true` to take effect.
  ///
  ///Due to the async nature of [PlatformWebViewCreationParams.onAjaxProgress] event implementation,
  ///using it could cause some issues, so, be careful when using it.
  ///In this case, you should implement your own logic using for example an [UserScript] overriding the
  ///[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) JavaScript object.
  ///
  ///If the [PlatformWebViewCreationParams.onAjaxProgress] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  bool? useOnAjaxProgress;

  ///Set to `false` to be able to listen to also sync `XMLHttpRequest`s at the
  ///[PlatformWebViewCreationParams.shouldInterceptAjaxRequest] event.
  ///
  ///**NOTE**: Using `false` will cause the `XMLHttpRequest.send()` method for sync
  ///requests to not wait on the JavaScript code the response synchronously,
  ///as if it was an async `XMLHttpRequest`.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  bool? interceptOnlyAsyncAjaxRequests;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldInterceptFetchRequest] event.
  ///
  ///If the [PlatformWebViewCreationParams.shouldInterceptFetchRequest] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  bool? useShouldInterceptFetchRequest;

  ///Set to `true` to open a browser window with incognito mode. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """setting this to `true`, it will clear all the cookies of all WebView instances, 
because there isn't any way to make the website data store non-persistent for the specific WebView instance such as on iOS.""",
      ),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(
        apiName: "ICoreWebView2ControllerOptions.put_IsInPrivateModeEnabled",
        apiUrl:
            "https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controlleroptions?view=webview2-1.0.2792.45#put_isinprivatemodeenabled",
      ),
      LinuxPlatform(
        apiName: "webkit_network_session_new_ephemeral",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/ctor.NetworkSession.new_ephemeral.html",
      ),
    ],
  )
  bool? incognito;

  ///Sets whether WebView should use browser caching. The default value is `true`.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  bool? cacheEnabled;

  ///Set to `true` to make the background of the WebView transparent. If your app has a dark theme, this can prevent a white flash on initialization. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(available: "12.0"),
      WindowsPlatform(
        available: '1.0.774.44',
        apiName: 'ICoreWebView2Controller2.put_DefaultBackgroundColor',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controller2?view=webview2-1.0.2210.55#put_defaultbackgroundcolor',
      ),
    ],
  )
  bool? transparentBackground;

  ///Set to `true` to disable vertical scroll. The default value is `false`.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), WebPlatform()],
  )
  bool? disableVerticalScroll;

  ///Set to `true` to disable horizontal scroll. The default value is `false`.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), WebPlatform()],
  )
  bool? disableHorizontalScroll;

  ///Set to `true` to disable context menu. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      WebPlatform(),
      WindowsPlatform(
        apiName: "ICoreWebView2Settings.put_AreDefaultContextMenusEnabled",
        apiUrl:
            "https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2210.55#put_aredefaultcontextmenusenabled",
      ),
    ],
  )
  bool? disableContextMenu;

  ///Set to `false` if the WebView should not support zooming using its on-screen zoom controls and gestures. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setSupportZoom",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSupportZoom(boolean)",
      ),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(
        apiName: "ICoreWebView2Settings.put_IsZoomControlEnabled",
        apiUrl:
            "https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2210.55#put_iszoomcontrolenabled",
      ),
    ],
  )
  bool? supportZoom;

  ///Sets whether cross-origin requests in the context of a file scheme URL should be allowed to access content from other file scheme URLs.
  ///Note that some accesses such as image HTML elements don't follow same-origin rules and aren't affected by this setting.
  ///
  ///Don't enable this setting if you open files that may be created or altered by external sources.
  ///Enabling this setting allows malicious scripts loaded in a `file://` context to access arbitrary local files including WebView cookies and app private data.
  ///
  ///Note that the value of this setting is ignored if the value of [allowUniversalAccessFromFileURLs] is `true`.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setAllowFileAccessFromFileURLs",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowFileAccessFromFileURLs(boolean)",
      ),
      IOSPlatform(),
      MacOSPlatform(),
      LinuxPlatform(
        available: "2.10",
        apiName: "WebKitSettings.allow-file-access-from-file-urls",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.allow-file-access-from-file-urls.html",
      ),
    ],
  )
  bool? allowFileAccessFromFileURLs;

  ///Sets whether cross-origin requests in the context of a file scheme URL should be allowed to access content from any origin.
  ///This includes access to content from other file scheme URLs or web contexts.
  ///Note that some access such as image HTML elements doesn't follow same-origin rules and isn't affected by this setting.
  ///
  ///Don't enable this setting if you open files that may be created or altered by external sources.
  ///Enabling this setting allows malicious scripts loaded in a `file://` context to launch cross-site scripting attacks,
  ///either accessing arbitrary local files including WebView cookies, app private data or even credentials used on arbitrary web sites.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setAllowUniversalAccessFromFileURLs",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowUniversalAccessFromFileURLs(boolean)",
      ),
      IOSPlatform(),
      MacOSPlatform(),
      LinuxPlatform(
        available: "2.14",
        apiName: "WebKitSettings.allow-universal-access-from-file-urls",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.allow-universal-access-from-file-urls.html",
      ),
    ],
  )
  bool? allowUniversalAccessFromFileURLs;

  ///Set to `true` to allow audio playing when the app goes in background or the screen is locked or another app is opened.
  ///However, there will be no controls in the notification bar or on the lockscreen.
  ///Also, make sure to not call [PlatformInAppWebViewController.pause], otherwise it will stop audio playing.
  ///The default value is `false`.
  ///
  ///**IMPORTANT NOTE**: if you use this setting, your app could be rejected by the Google Play Store.
  ///For example, if you allow background playing of YouTube videos, which is a violation of the YouTube API Terms of Service.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool? allowBackgroundAudioPlaying;

  ///Use a [WebViewAssetLoader] instance to load local files including application's static assets and resources using http(s):// URLs.
  ///Loading local files using web-like URLs instead of `file://` is desirable as it is compatible with the Same-Origin policy.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  WebViewAssetLoader_? webViewAssetLoader;

  ///Sets the text zoom of the page in percent. The default value is `100`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setTextZoom",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setTextZoom(int)",
      ),
    ],
  )
  int? textZoom;

  ///Use [PlatformCookieManager.removeSessionCookies] instead.
  @Deprecated("Use CookieManager.removeSessionCookies instead")
  @ExchangeableObjectProperty(leaveDeprecatedInToMapMethod: true)
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool? clearSessionCache;

  ///Set to `true` if the WebView should use its built-in zoom mechanisms. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setBuiltInZoomControls",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setBuiltInZoomControls(boolean)",
      ),
    ],
  )
  bool? builtInZoomControls;

  ///Set to `true` if the WebView should display on-screen zoom controls when using the built-in zoom mechanisms. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setDisplayZoomControls",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDisplayZoomControls(boolean)",
      ),
    ],
  )
  bool? displayZoomControls;

  ///Set to `true` if you want the database storage API is enabled. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setDatabaseEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDatabaseEnabled(boolean)",
      ),
      LinuxPlatform(
        apiName: "WebKitSettings.enable-html5-database",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-html5-database.html",
      ),
    ],
  )
  bool? databaseEnabled;

  ///Set to `true` if you want the DOM storage API is enabled. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setDomStorageEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDomStorageEnabled(boolean)",
      ),
      LinuxPlatform(
        apiName: "WebKitSettings.enable-html5-local-storage",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-html5-local-storage.html",
      ),
    ],
  )
  bool? domStorageEnabled;

  ///Set to `true` if the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport.
  ///When the value of the setting is false, the layout width is always set to the width of the WebView control in device-independent (CSS) pixels.
  ///When the value is true and the page contains the viewport meta tag, the value of the width specified in the tag is used.
  ///If the page does not contain the tag or does not provide a width, then a wide viewport will be used. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setUseWideViewPort",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setUseWideViewPort(boolean)",
      ),
    ],
  )
  bool? useWideViewPort;

  ///Sets whether Safe Browsing is enabled. Safe Browsing allows WebView to protect against malware and phishing attacks by verifying the links.
  ///Safe Browsing is enabled by default for devices which support it.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "26",
        apiName: "WebSettings.setSafeBrowsingEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSafeBrowsingEnabled(boolean)",
      ),
    ],
  )
  bool? safeBrowsingEnabled;

  ///Configures the WebView's behavior when a secure origin attempts to load a resource from an insecure origin.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "21",
        apiName: "WebSettings.setMixedContentMode",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMixedContentMode(int)",
      ),
    ],
  )
  MixedContentMode_? mixedContentMode;

  ///Enables or disables content URL access within WebView. Content URL access allows WebView to load content from a content provider installed in the system. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setAllowContentAccess",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowContentAccess(boolean)",
      ),
    ],
  )
  bool? allowContentAccess;

  ///Enables or disables file access within WebView. Note that this enables or disables file system access only.
  ///Assets and resources are still accessible using `file:///android_asset` and `file:///android_res`. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setAllowFileAccess",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowFileAccess(boolean)",
      ),
    ],
  )
  bool? allowFileAccess;

  ///Sets the path to the Application Caches files. In order for the Application Caches API to be enabled, this option must be set a path to which the application can write.
  ///This option is used one time: repeated calls are ignored.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(apiName: "WebSettings.setAppCachePath")],
  )
  String? appCachePath;

  ///Sets whether the WebView should not load image resources from the network (resources accessed via http and https URI schemes). The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setBlockNetworkImage",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setBlockNetworkImage(boolean)",
      ),
    ],
  )
  bool? blockNetworkImage;

  ///Sets whether the WebView should not load resources from the network. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setBlockNetworkLoads",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setBlockNetworkLoads(boolean)",
      ),
    ],
  )
  bool? blockNetworkLoads;

  ///Overrides the way the cache is used. The way the cache is used is based on the navigation type. For a normal page load, the cache is checked and content is re-validated as needed.
  ///When navigating back, content is not revalidated, instead the content is just retrieved from the cache. The default value is [CacheMode.LOAD_DEFAULT].
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setCacheMode",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setCacheMode(int)",
      ),
    ],
  )
  CacheMode_? cacheMode;

  ///Sets the cursive font family name. The default value is `"cursive"`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setCursiveFontFamily",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setCursiveFontFamily(java.lang.String)",
      ),
      LinuxPlatform(
        apiName: "WebKitSettings.cursive-font-family",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.cursive-font-family.html",
      ),
    ],
  )
  String? cursiveFontFamily;

  ///Sets the default fixed font size. The default value is `16`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setDefaultFixedFontSize",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setDefaultFixedFontSize(int)",
      ),
      LinuxPlatform(
        apiName: "WebKitSettings.default-monospace-font-size",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.default-monospace-font-size.html",
      ),
    ],
  )
  int? defaultFixedFontSize;

  ///Sets the default font size. The default value is `16`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setDefaultFontSize",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setDefaultFontSize(int)",
      ),
      LinuxPlatform(
        apiName: "WebKitSettings.default-font-size",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.default-font-size.html",
      ),
    ],
  )
  int? defaultFontSize;

  ///Sets the default text encoding name to use when decoding html pages. The default value is `"UTF-8"`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setDefaultTextEncodingName",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setDefaultTextEncodingName(java.lang.String)",
      ),
      LinuxPlatform(
        apiName: "WebKitSettings.default-charset",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.default-charset.html",
      ),
    ],
  )
  String? defaultTextEncodingName;

  ///Disables the action mode menu items according to menuItems flag.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "24",
        apiName: "WebSettings.setDisabledActionModeMenuItems",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setDisabledActionModeMenuItems(int)",
      ),
    ],
  )
  ActionModeMenuItem_? disabledActionModeMenuItems;

  ///Sets the fantasy font family name. The default value is `"fantasy"`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setFantasyFontFamily",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setFantasyFontFamily(java.lang.String)",
      ),
      LinuxPlatform(
        apiName: "WebKitSettings.fantasy-font-family",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.fantasy-font-family.html",
      ),
    ],
  )
  String? fantasyFontFamily;

  ///Sets the fixed font family name. The default value is `"monospace"`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setFixedFontFamily",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setFixedFontFamily(java.lang.String)",
      ),
      LinuxPlatform(
        apiName: "WebKitSettings.monospace-font-family",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.monospace-font-family.html",
      ),
    ],
  )
  String? fixedFontFamily;

  ///Use [algorithmicDarkeningAllowed] instead.
  ///
  ///Set the force dark mode for this WebView. The default value is [ForceDark.OFF].
  ///
  ///Deprecated - The "force dark" model previously implemented by WebView was complex and didn't
  ///interoperate well with current Web standards for `prefers-color-scheme` and `color-scheme`.
  ///In apps with `targetSdkVersion` ≥ `android.os.Build.VERSION_CODES.TIRAMISU` this API is a no-op and
  ///WebView will always use the dark style defined by web content authors if the app's theme is dark.
  ///To customize the behavior, refer to [algorithmicDarkeningAllowed].
  @Deprecated("Use algorithmicDarkeningAllowed instead")
  @ExchangeableObjectProperty(leaveDeprecatedInToMapMethod: true)
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "29",
        apiName: "WebSettings.setForceDark",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setForceDark(int)",
      ),
    ],
  )
  ForceDark_? forceDark;

  ///Use [algorithmicDarkeningAllowed] instead.
  ///
  ///Set how WebView content should be darkened.
  ///The default value is [ForceDarkStrategy.PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING].
  ///
  ///Deprecated - The "force dark" model previously implemented by WebView was complex and didn't
  ///interoperate well with current Web standards for `prefers-color-scheme` and `color-scheme`.
  ///In apps with `targetSdkVersion` ≥ `android.os.Build.VERSION_CODES.TIRAMISU` this API is a no-op and
  ///WebView will always use the dark style defined by web content authors if the app's theme is dark.
  ///To customize the behavior, refer to [algorithmicDarkeningAllowed].
  @Deprecated("Use algorithmicDarkeningAllowed instead")
  @ExchangeableObjectProperty(leaveDeprecatedInToMapMethod: true)
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettingsCompat.setForceDarkStrategy",
        apiUrl:
            "https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setForceDarkStrategy(android.webkit.WebSettings,int)",
        note:
            "it will take effect only if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.FORCE_DARK_STRATEGY].",
      ),
    ],
  )
  ForceDarkStrategy_? forceDarkStrategy;

  ///Sets whether Geolocation is enabled. The default is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setGeolocationEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setGeolocationEnabled(boolean)",
        note:
            """Please note that in order for the Geolocation API to be usable by a page in the WebView, the following requirements must be met:
- an application must have permission to access the device location, see [Manifest.permission.ACCESS_COARSE_LOCATION](https://developer.android.com/reference/android/Manifest.permission#ACCESS_COARSE_LOCATION), [Manifest.permission.ACCESS_FINE_LOCATION](https://developer.android.com/reference/android/Manifest.permission#ACCESS_FINE_LOCATION);
- an application must provide an implementation of the [PlatformWebViewCreationParams.onGeolocationPermissionsShowPrompt] callback to receive notifications that a page is requesting access to location via the JavaScript Geolocation API.""",
      ),
    ],
  )
  bool? geolocationEnabled;

  ///Sets the underlying layout algorithm. This will cause a re-layout of the WebView.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setLayoutAlgorithm",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLayoutAlgorithm(android.webkit.WebSettings.LayoutAlgorithm)",
      ),
    ],
  )
  LayoutAlgorithm_? layoutAlgorithm;

  ///Sets whether the WebView loads pages in overview mode, that is, zooms out the content to fit on screen by width.
  ///This setting is taken into account when the content width is greater than the width of the WebView control, for example, when [useWideViewPort] is enabled.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setLoadWithOverviewMode",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLoadWithOverviewMode(boolean)",
      ),
    ],
  )
  bool? loadWithOverviewMode;

  ///Sets whether the WebView should load image resources. Note that this method controls loading of all images, including those embedded using the data URI scheme.
  ///Note that if the value of this setting is changed from false to true, all images resources referenced by content currently displayed by the WebView are loaded automatically.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setLoadsImagesAutomatically",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLoadsImagesAutomatically(boolean)",
      ),
      LinuxPlatform(
        apiName: "WebKitSettings.auto-load-images",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.auto-load-images.html",
      ),
    ],
  )
  bool? loadsImagesAutomatically;

  ///Sets the minimum logical font size. The default is `8`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setMinimumLogicalFontSize",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMinimumLogicalFontSize(int)",
      ),
    ],
  )
  int? minimumLogicalFontSize;

  ///Sets the initial scale for this WebView. 0 means default. The behavior for the default scale depends on the state of [useWideViewPort] and [loadWithOverviewMode].
  ///If the content fits into the WebView control by width, then the zoom is set to 100%. For wide content, the behavior depends on the state of [loadWithOverviewMode].
  ///If its value is true, the content will be zoomed out to be fit by width into the WebView control, otherwise not.
  ///If initial scale is greater than 0, WebView starts with this value as initial scale.
  ///Please note that unlike the scale properties in the viewport meta tag, this method doesn't take the screen density into account.
  ///The default is `0`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebView.setInitialScale",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebView#setInitialScale(int)",
      ),
    ],
  )
  int? initialScale;

  ///Tells the WebView whether it needs to set a node. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setNeedInitialFocus",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setNeedInitialFocus(boolean)",
      ),
    ],
  )
  bool? needInitialFocus;

  ///Sets whether this WebView should raster tiles when it is offscreen but attached to a window.
  ///Turning this on can avoid rendering artifacts when animating an offscreen WebView on-screen.
  ///Offscreen WebViews in this mode use more memory. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "23",
        apiName: "WebSettings.setOffscreenPreRaster",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setOffscreenPreRaster(boolean)",
      ),
    ],
  )
  bool? offscreenPreRaster;

  ///Sets the sans-serif font family name. The default value is `"sans-serif"`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setSansSerifFontFamily",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSansSerifFontFamily(java.lang.String)",
      ),
      LinuxPlatform(
        apiName: "WebKitSettings.sans-serif-font-family",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.sans-serif-font-family.html",
      ),
    ],
  )
  String? sansSerifFontFamily;

  ///Sets the serif font family name. The default value is `"sans-serif"`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setSerifFontFamily",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSerifFontFamily(java.lang.String)",
      ),
      LinuxPlatform(
        apiName: "WebKitSettings.serif-font-family",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.serif-font-family.html",
      ),
    ],
  )
  String? serifFontFamily;

  ///Sets the standard font family name. The default value is `"sans-serif"`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setStandardFontFamily",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setStandardFontFamily(java.lang.String)",
      ),
      LinuxPlatform(
        apiName: "WebKitSettings.default-font-family",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.default-font-family.html",
      ),
    ],
  )
  String? standardFontFamily;

  ///Sets whether the WebView should save form data. In Android O, the platform has implemented a fully functional Autofill feature to store form data.
  ///Therefore, the Webview form data save feature is disabled. Note that the feature will continue to be supported on older versions of Android as before.
  ///The default value is `true`.
  @Deprecated('')
  @ExchangeableObjectProperty(
    leaveDeprecatedInToMapMethod: true,
    leaveDeprecatedInFromMapMethod: true,
  )
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setSaveFormData",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSaveFormData(boolean)",
      ),
    ],
  )
  bool? saveFormData;

  ///Boolean value to enable third party cookies in the WebView.
  ///Used on Android Lollipop and above only as third party cookies are enabled by default on Android Kitkat and below and on iOS.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "21",
        apiName: "CookieManager.setAcceptThirdPartyCookies",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/CookieManager#setAcceptThirdPartyCookies(android.webkit.WebView,%20boolean)",
      ),
    ],
  )
  bool? thirdPartyCookiesEnabled;

  ///Boolean value to enable Hardware Acceleration in the WebView.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebView.setLayerType",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebView#setLayerType(int,%20android.graphics.Paint)",
      ),
    ],
  )
  bool? hardwareAcceleration;

  ///Sets whether the WebView supports multiple windows.
  ///If set to `true`, [PlatformWebViewCreationParams.onCreateWindow] event must be implemented by the host application. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setSupportMultipleWindows",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSupportMultipleWindows(boolean)",
      ),
    ],
  )
  bool? supportMultipleWindows;

  ///Regular expression used on native side by the [PlatformWebViewCreationParams.shouldOverrideUrlLoading]
  ///event to cancel navigation requests for frames that are not the main frame.
  ///If the url request of a sub-frame matches the regular expression, then the request of that sub-frame is canceled.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  String? regexToCancelSubFramesLoading;

  ///Regular expression used on native side by the [PlatformWebViewCreationParams.shouldOverrideUrlLoading]
  ///event to allow navigation requests synchronously.
  ///If the url request match the regular expression, then the request is allowed automatically,
  ///and the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event will not be fired.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  String? regexToAllowSyncUrlLoading;

  ///Set to `false` to disable Flutter Hybrid Composition. The default value is `true`.
  ///Hybrid Composition is supported starting with Flutter v1.20+.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """It is recommended to use Hybrid Composition only on Android 10+ for a release app,
as it can cause framerate drops on animations in Android 9 and lower (see [Hybrid-Composition#performance](https://github.com/flutter/flutter/wiki/Hybrid-Composition#performance)).""",
      ),
    ],
  )
  bool? useHybridComposition;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldInterceptRequest] event.
  ///
  ///If the [PlatformWebViewCreationParams.shouldInterceptRequest] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool? useShouldInterceptRequest;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onRenderProcessGone] event.
  ///
  ///If the [PlatformWebViewCreationParams.onRenderProcessGone] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool? useOnRenderProcessGone;

  ///Sets the WebView's over-scroll mode.
  ///Setting the over-scroll mode of a WebView will have an effect only if the WebView is capable of scrolling.
  ///The default value is [OverScrollMode.IF_CONTENT_SCROLLS].
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setOverScrollMode",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setOverScrollMode(int)",
      ),
    ],
  )
  OverScrollMode_? overScrollMode;

  ///Informs WebView of the network state.
  ///This is used to set the JavaScript property `window.navigator.isOnline` and generates the online/offline event as specified in HTML5, sec. 5.7.7.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebView.setNetworkAvailable",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebView#setNetworkAvailable(boolean)",
      ),
    ],
  )
  bool? networkAvailable;

  ///Specifies the style of the scrollbars. The scrollbars can be overlaid or inset.
  ///When inset, they add to the padding of the view. And the scrollbars can be drawn inside the padding area or on the edge of the view.
  ///For example, if a view has a background drawable and you want to draw the scrollbars inside the padding specified by the drawable,
  ///you can use SCROLLBARS_INSIDE_OVERLAY or SCROLLBARS_INSIDE_INSET. If you want them to appear at the edge of the view, ignoring the padding,
  ///then you can use SCROLLBARS_OUTSIDE_OVERLAY or SCROLLBARS_OUTSIDE_INSET.
  ///The default value is [ScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY].
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebView.setScrollBarStyle",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebView#setScrollBarStyle(int)",
      ),
    ],
  )
  ScrollBarStyle_? scrollBarStyle;

  ///Sets the position of the vertical scroll bar.
  ///The default value is [VerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT].
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setVerticalScrollbarPosition",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setVerticalScrollbarPosition(int)",
      ),
    ],
  )
  VerticalScrollbarPosition_? verticalScrollbarPosition;

  ///Defines the delay in milliseconds that a scrollbar waits before fade out.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setScrollBarDefaultDelayBeforeFade",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setScrollBarDefaultDelayBeforeFade(int)",
      ),
    ],
  )
  int? scrollBarDefaultDelayBeforeFade;

  ///Defines whether scrollbars will fade when the view is not scrolling.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setScrollbarFadingEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setScrollbarFadingEnabled(boolean)",
      ),
    ],
  )
  bool? scrollbarFadingEnabled;

  ///Defines the scrollbar fade duration in milliseconds.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setScrollBarFadeDuration",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setScrollBarFadeDuration(int)",
      ),
    ],
  )
  int? scrollBarFadeDuration;

  ///Sets the renderer priority policy for this WebView.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebView.setRendererPriorityPolicy",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebView#setRendererPriorityPolicy(int,%20boolean)",
      ),
    ],
  )
  RendererPriorityPolicy_? rendererPriorityPolicy;

  ///Sets whether the default Android WebView’s internal error page should be suppressed or displayed for bad navigations.
  ///`true` means suppressed (not shown), `false` means it will be displayed. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      WindowsPlatform(
        apiName: "ICoreWebView2Settings.put_IsBuiltInErrorPageEnabled",
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2849.39#put_isbuiltinerrorpageenabled',
      ),
    ],
  )
  bool? disableDefaultErrorPage;

  ///Sets the vertical scrollbar thumb color.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "29",
        apiName: "View.setVerticalScrollbarThumbDrawable",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setVerticalScrollbarThumbDrawable(android.graphics.drawable.Drawable)",
      ),
    ],
  )
  Color_? verticalScrollbarThumbColor;

  ///Sets the vertical scrollbar track color.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "29",
        apiName: "View.setVerticalScrollbarTrackDrawable",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setVerticalScrollbarTrackDrawable(android.graphics.drawable.Drawable)",
      ),
    ],
  )
  Color_? verticalScrollbarTrackColor;

  ///Sets the horizontal scrollbar thumb color.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "29",
        apiName: "View.setHorizontalScrollbarThumbDrawable",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setHorizontalScrollbarThumbDrawable(android.graphics.drawable.Drawable)",
      ),
    ],
  )
  Color_? horizontalScrollbarThumbColor;

  ///Sets the horizontal scrollbar track color.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "29",
        apiName: "View.setHorizontalScrollbarTrackDrawable",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setHorizontalScrollbarTrackDrawable(android.graphics.drawable.Drawable)",
      ),
    ],
  )
  Color_? horizontalScrollbarTrackColor;

  ///Control whether algorithmic darkening is allowed.
  ///
  ///WebView always sets the media query `prefers-color-scheme` according to the app's theme attribute `isLightTheme`,
  ///i.e. `prefers-color-scheme` is light if `isLightTheme` is `true` or not specified, otherwise it is `dark`.
  ///This means that the web content's light or dark style will be applied automatically to match the app's theme if the content supports it.
  ///
  ///Algorithmic darkening is disallowed by default.
  ///
  ///If the app's theme is dark and it allows algorithmic darkening,
  ///WebView will attempt to darken web content using an algorithm,
  ///if the content doesn't define its own dark styles and doesn't explicitly disable darkening.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "29",
        apiName: "WebSettingsCompat.setAlgorithmicDarkeningAllowed",
        apiUrl:
            "https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setAlgorithmicDarkeningAllowed(android.webkit.WebSettings,boolean)",
        note:
            "available on Android only if [WebViewFeature.ALGORITHMIC_DARKENING] feature is supported.",
      ),
    ],
  )
  bool? algorithmicDarkeningAllowed;

  ///Sets whether EnterpriseAuthenticationAppLinkPolicy if set by admin is allowed to have any
  ///effect on WebView.
  ///
  ///EnterpriseAuthenticationAppLinkPolicy in WebView allows admins to specify authentication
  ///urls. When WebView is redirected to authentication url, and an app on the device has
  ///registered as the default handler for the url, that app is launched.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            "available on Android only if [WebViewFeature.ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY] feature is supported.",
      ),
    ],
  )
  bool? enterpriseAuthenticationAppLinkPolicyEnabled;

  ///When not playing, video elements are represented by a 'poster' image.
  ///The image to use can be specified by the poster attribute of the video tag in HTML.
  ///If the attribute is absent, then a default poster will be used.
  ///This property allows the WebView to provide that default image.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  Uint8List? defaultVideoPoster;

  ///Set an allow-list of origins to receive the X-Requested-With HTTP header from the WebView owning the passed [InAppWebViewSettings].
  ///
  ///Historically, this header was sent on all requests from WebView, containing the app package name of the embedding app. Depending on the version of installed WebView, this may no longer be the case, as the header was deprecated in late 2022, and its use discontinued.
  ///
  ///Apps can use this method to restore the legacy behavior for servers that still rely on the deprecated header, but it should not be used to identify the webview to first-party servers under the control of the app developer.
  ///
  ///The format of the strings in the allow-list follows the origin rules of [PlatformInAppWebViewController.addWebMessageListener].
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettingsCompat.setRequestedWithHeaderOriginAllowList",
        apiUrl:
            "https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setRequestedWithHeaderOriginAllowList(android.webkit.WebSettings,java.util.Set%3Cjava.lang.String%3E)",
        note:
            "available on Android only if [WebViewFeature.REQUESTED_WITH_HEADER_ALLOW_LIST] feature is supported.",
      ),
    ],
  )
  Set<String>? requestedWithHeaderOriginAllowList;

  ///Set to `true` to disable the bouncing of the WebView when the scrolling has reached an edge of the content. The default value is `false`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? disallowOverScroll;

  ///Set to `true` to allow a viewport meta tag to either disable or restrict the range of user scaling. The default value is `false`.
  @SupportedPlatforms(platforms: [IOSPlatform(), MacOSPlatform()])
  bool? enableViewportScale;

  ///Set to `true` if you want the WebView suppresses content rendering until it is fully loaded into memory. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebViewConfiguration.suppressesIncrementalRendering",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395663-suppressesincrementalrendering",
      ),
      MacOSPlatform(
        apiName: "WKWebViewConfiguration.suppressesIncrementalRendering",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395663-suppressesincrementalrendering",
      ),
    ],
  )
  bool? suppressesIncrementalRendering;

  ///Set to `true` to allow AirPlay. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebViewConfiguration.allowsAirPlayForMediaPlayback",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395673-allowsairplayformediaplayback",
      ),
      MacOSPlatform(
        apiName: "WKWebViewConfiguration.allowsAirPlayForMediaPlayback",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395673-allowsairplayformediaplayback",
      ),
    ],
  )
  bool? allowsAirPlayForMediaPlayback;

  ///Set to `true` to allow the horizontal swipe gestures trigger back-forward list navigations.
  ///
  ///**NOTE for Windows**: Swiping down to refresh is off by default and not exposed via API currently,
  ///it requires the "--pull-to-refresh" option to be included in
  ///the additional browser arguments to be configured.
  ///(See [WebViewEnvironmentSettings.additionalBrowserArguments].).
  ///When set to `false`, the end user cannot swipe to navigate or pull to refresh.
  ///This API only affects the overscrolling navigation functionality and has
  ///no effect on the scrolling interaction used to explore the web content shown in WebView2.
  ///Disabling/Enabling [allowsBackForwardNavigationGestures] takes effect after the next navigation.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebView.allowsBackForwardNavigationGestures",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/1414995-allowsbackforwardnavigationgestu",
      ),
      MacOSPlatform(
        apiName: "WKWebView.allowsBackForwardNavigationGestures",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/1414995-allowsbackforwardnavigationgestu",
      ),
      WindowsPlatform(
        available: "1.0.992.28",
        apiName: "ICoreWebView2Settings6.put_IsSwipeNavigationEnabled",
        apiUrl:
            "https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings6?view=webview2-1.0.2849.39#put_isswipenavigationenabled",
      ),
    ],
  )
  bool? allowsBackForwardNavigationGestures;

  ///Set to `true` to allow that pressing on a link displays a preview of the destination for the link. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebView.allowsLinkPreview",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/1415000-allowslinkpreview",
      ),
      MacOSPlatform(
        apiName: "WKWebView.allowsLinkPreview",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/1415000-allowslinkpreview",
      ),
    ],
  )
  bool? allowsLinkPreview;

  ///Set to `true` if you want that the WebView should always allow scaling of the webpage, regardless of the author's intent.
  ///The ignoresViewportScaleLimits property overrides the `user-scalable` HTML property in a webpage. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebViewConfiguration.ignoresViewportScaleLimits",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/2274633-ignoresviewportscalelimits",
      ),
    ],
  )
  bool? ignoresViewportScaleLimits;

  ///Set to `true` to allow HTML5 media playback to appear inline within the screen layout, using browser-supplied controls rather than native controls.
  ///For this to work, add the `webkit-playsinline` attribute to any `<video>` elements. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebViewConfiguration.allowsInlineMediaPlayback",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614793-allowsinlinemediaplayback",
      ),
      LinuxPlatform(
        apiName: "WebKitSettings.media-playback-allows-inline",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.media-playback-allows-inline.html",
      ),
    ],
  )
  bool? allowsInlineMediaPlayback;

  ///Set to `true` to allow HTML5 videos play picture-in-picture. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebViewConfiguration.allowsPictureInPictureMediaPlayback",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614792-allowspictureinpicturemediaplayb",
      ),
    ],
  )
  bool? allowsPictureInPictureMediaPlayback;

  ///A Boolean value indicating whether warnings should be shown for suspected fraudulent content such as phishing or malware.
  ///According to the official documentation, this feature is currently available in the following region: China.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "13.0",
        apiName: "WKPreferences.isFraudulentWebsiteWarningEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/3335219-isfraudulentwebsitewarningenable",
      ),
      MacOSPlatform(
        available: "10.15",
        apiName: "WKPreferences.isFraudulentWebsiteWarningEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/3335219-isfraudulentwebsitewarningenable",
      ),
    ],
  )
  bool? isFraudulentWebsiteWarningEnabled;

  ///The level of granularity with which the user can interactively select content in the web view.
  ///The default value is [SelectionGranularity.DYNAMIC].
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebViewConfiguration.selectionGranularity",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614756-selectiongranularity",
      ),
    ],
  )
  SelectionGranularity_? selectionGranularity;

  ///Specifying a dataDetectoryTypes value adds interactivity to web content that matches the value.
  ///For example, Safari adds a link to “apple.com” in the text “Visit apple.com” if the dataDetectorTypes property is set to [DataDetectorTypes.LINK].
  ///The default value is [DataDetectorTypes.NONE].
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "10",
        apiName: "WKWebViewConfiguration.dataDetectorTypes",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1641937-datadetectortypes",
      ),
    ],
  )
  List<DataDetectorTypes_>? dataDetectorTypes;

  ///Set `true` if shared cookies from `HTTPCookieStorage.shared` should used for every load request in the WebView.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(available: "11.0"),
      MacOSPlatform(available: "10.13"),
    ],
  )
  bool? sharedCookiesEnabled;

  ///Configures whether the scroll indicator insets are automatically adjusted by the system.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "13.0",
        apiName: "UIScrollView.automaticallyAdjustsScrollIndicatorInsets",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/3198043-automaticallyadjustsscrollindica",
      ),
    ],
  )
  bool? automaticallyAdjustsScrollIndicatorInsets;

  ///A Boolean value indicating whether the WebView ignores an accessibility request to invert its colors.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "11.0",
        apiName: "UIView.accessibilityIgnoresInvertColors",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiview/2865843-accessibilityignoresinvertcolors",
      ),
    ],
  )
  bool? accessibilityIgnoresInvertColors;

  ///A [ScrollViewDecelerationRate] value that determines the rate of deceleration after the user lifts their finger.
  ///The default value is [ScrollViewDecelerationRate.NORMAL].
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.decelerationRate",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619438-decelerationrate",
      ),
    ],
  )
  ScrollViewDecelerationRate_? decelerationRate;

  ///A Boolean value that determines whether bouncing always occurs when vertical scrolling reaches the end of the content.
  ///If this property is set to `true` and [InAppWebViewSettings.disallowOverScroll] is `false`,
  ///vertical dragging is allowed even if the content is smaller than the bounds of the scroll view.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.alwaysBounceVertical",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619383-alwaysbouncevertical",
      ),
    ],
  )
  bool? alwaysBounceVertical;

  ///A Boolean value that determines whether bouncing always occurs when horizontal scrolling reaches the end of the content view.
  ///If this property is set to `true` and [InAppWebViewSettings.disallowOverScroll] is `false`,
  ///horizontal dragging is allowed even if the content is smaller than the bounds of the scroll view.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.alwaysBounceHorizontal",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619393-alwaysbouncehorizontal",
      ),
    ],
  )
  bool? alwaysBounceHorizontal;

  ///A Boolean value that controls whether the scroll-to-top gesture is enabled.
  ///The scroll-to-top gesture is a tap on the status bar. When a user makes this gesture,
  ///the system asks the scroll view closest to the status bar to scroll to the top.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.scrollsToTop",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619421-scrollstotop",
      ),
    ],
  )
  bool? scrollsToTop;

  ///A Boolean value that determines whether paging is enabled for the scroll view.
  ///If the value of this property is true, the scroll view stops on multiples of the scroll view’s bounds when the user scrolls.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.isPagingEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619432-ispagingenabled",
      ),
    ],
  )
  bool? isPagingEnabled;

  ///A floating-point value that specifies the maximum scale factor that can be applied to the scroll view's content.
  ///This value determines how large the content can be scaled.
  ///It must be greater than the minimum zoom scale for zooming to be enabled.
  ///The default value is `1.0`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.maximumZoomScale",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619408-maximumzoomscale",
      ),
    ],
  )
  double? maximumZoomScale;

  ///A floating-point value that specifies the minimum scale factor that can be applied to the scroll view's content.
  ///This value determines how small the content can be scaled.
  ///The default value is `1.0`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.minimumZoomScale",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619428-minimumzoomscale",
      ),
    ],
  )
  double? minimumZoomScale;

  ///Configures how safe area insets are added to the adjusted content inset.
  ///The default value is [ScrollViewContentInsetAdjustmentBehavior.NEVER].
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "11.0",
        apiName: "UIScrollView.contentInsetAdjustmentBehavior",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/2902261-contentinsetadjustmentbehavior",
      ),
    ],
  )
  ScrollViewContentInsetAdjustmentBehavior_? contentInsetAdjustmentBehavior;

  ///A Boolean value that determines whether scrolling is disabled in a particular direction.
  ///If this property is `false`, scrolling is permitted in both horizontal and vertical directions.
  ///If this property is `true` and the user begins dragging in one general direction (horizontally or vertically),
  ///the scroll view disables scrolling in the other direction.
  ///If the drag direction is diagonal, then scrolling will not be locked and the user can drag in any direction until the drag completes.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.isDirectionalLockEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619390-isdirectionallockenabled",
      ),
    ],
  )
  bool? isDirectionalLockEnabled;

  ///The media type for the contents of the web view.
  ///When the value of this property is `null`, the web view derives the current media type from the CSS media property of its content.
  ///If you assign a value other than `null` to this property, the web view uses the value you provide instead.
  ///The default value of this property is `null`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "14.0",
        apiName: "WKWebView.mediaType",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/3516410-mediatype",
      ),
      MacOSPlatform(
        available: "11.0",
        apiName: "WKWebView.mediaType",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/3516410-mediatype",
      ),
    ],
  )
  String? mediaType;

  ///The scale factor by which the web view scales content relative to its bounds.
  ///The default value of this property is `1.0`, which displays the content without any scaling.
  ///Changing the value of this property is equivalent to setting the CSS `zoom` property on all page content.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "14.0",
        apiName: "WKWebView.pageZoom",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/3516411-pagezoom",
      ),
      MacOSPlatform(
        available: "11.0",
        apiName: "WKWebView.pageZoom",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/3516411-pagezoom",
      ),
    ],
  )
  double? pageZoom;

  ///A Boolean value that indicates whether the web view limits navigation to pages within the app’s domain.
  ///Check [App-Bound Domains](https://webkit.org/blog/10882/app-bound-domains/) for more details.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "14.0",
        apiName: "WKWebViewConfiguration.limitsNavigationsToAppBoundDomains",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3585117-limitsnavigationstoappbounddomai",
      ),
      MacOSPlatform(
        available: "11.0",
        apiName: "WKWebViewConfiguration.limitsNavigationsToAppBoundDomains",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3585117-limitsnavigationstoappbounddomai",
      ),
    ],
  )
  bool? limitsNavigationsToAppBoundDomains;

  ///Set to `true` to be able to listen to the [PlatformWebViewCreationParams.onNavigationResponse] event.
  ///
  ///If the [PlatformWebViewCreationParams.onNavigationResponse] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(platforms: [IOSPlatform(), MacOSPlatform()])
  bool? useOnNavigationResponse;

  ///Set to `true` to enable Apple Pay API for the `WebView` at its first page load or on the next page load (using [PlatformInAppWebViewController.setOptions]). The default value is `false`.
  ///
  ///**IMPORTANT NOTE**: As written in the official [Safari 13 Release Notes](https://developer.apple.com/documentation/safari-release-notes/safari-13-release-notes#Payment-Request-API),
  ///it won't work if any script injection APIs are used (such as [PlatformInAppWebViewController.evaluateJavascript] or [UserScript]).
  ///So, when this attribute is `true`, all the methods, options, and events implemented using JavaScript won't be called or won't do anything and the result will always be `null`.
  ///
  ///Methods affected:
  ///- [PlatformInAppWebViewController.addUserScript]
  ///- [PlatformInAppWebViewController.addUserScripts]
  ///- [PlatformInAppWebViewController.removeUserScript]
  ///- [PlatformInAppWebViewController.removeUserScripts]
  ///- [PlatformInAppWebViewController.removeAllUserScripts]
  ///- [PlatformInAppWebViewController.evaluateJavascript]
  ///- [PlatformInAppWebViewController.callAsyncJavaScript]
  ///- [PlatformInAppWebViewController.injectJavascriptFileFromUrl]
  ///- [PlatformInAppWebViewController.injectJavascriptFileFromAsset]
  ///- [PlatformInAppWebViewController.injectCSSCode]
  ///- [PlatformInAppWebViewController.injectCSSFileFromUrl]
  ///- [PlatformInAppWebViewController.injectCSSFileFromAsset]
  ///- [PlatformInAppWebViewController.findAllAsync]
  ///- [PlatformInAppWebViewController.findNext]
  ///- [PlatformInAppWebViewController.clearMatches]
  ///- [PlatformInAppWebViewController.pauseTimers]
  ///- [PlatformInAppWebViewController.getSelectedText]
  ///- [PlatformInAppWebViewController.getHitTestResult]
  ///- [PlatformInAppWebViewController.requestFocusNodeHref]
  ///- [PlatformInAppWebViewController.requestImageRef]
  ///- [PlatformInAppWebViewController.postWebMessage]
  ///- [PlatformInAppWebViewController.createWebMessageChannel]
  ///- [PlatformInAppWebViewController.addWebMessageListener]
  ///
  ///Settings affected:
  ///- [PlatformWebViewCreationParams.initialUserScripts]
  ///- [InAppWebViewSettings.supportZoom]
  ///- [InAppWebViewSettings.useOnLoadResource]
  ///- [InAppWebViewSettings.useShouldInterceptAjaxRequest]
  ///- [InAppWebViewSettings.useShouldInterceptFetchRequest]
  ///- [InAppWebViewSettings.enableViewportScale]
  ///
  ///Events affected:
  ///- the `hitTestResult` argument of [PlatformWebViewCreationParams.onLongPressHitTestResult] will be empty
  ///- the `hitTestResult` argument of [ContextMenu.onCreateContextMenu] will be empty
  ///- [PlatformWebViewCreationParams.onLoadResource]
  ///- [PlatformWebViewCreationParams.shouldInterceptAjaxRequest]
  ///- [PlatformWebViewCreationParams.onAjaxReadyStateChange]
  ///- [PlatformWebViewCreationParams.onAjaxProgress]
  ///- [PlatformWebViewCreationParams.shouldInterceptFetchRequest]
  ///- [PlatformWebViewCreationParams.onConsoleMessage]
  ///- [PlatformWebViewCreationParams.onPrintRequest]
  ///- [PlatformWebViewCreationParams.onWindowFocus]
  ///- [PlatformWebViewCreationParams.onWindowBlur]
  ///- [PlatformWebViewCreationParams.onFindResultReceived]
  ///- [FindInteractionController.onFindResultReceived]
  @SupportedPlatforms(platforms: [IOSPlatform(available: "13.0")])
  bool? applePayAPIEnabled;

  ///Used in combination with [PlatformWebViewCreationParams.initialUrlRequest] or [PlatformWebViewCreationParams.initialData] (using the `file://` scheme), it represents the URL from which to read the web content.
  ///This URL must be a file-based URL (using the `file://` scheme).
  ///Specify the same value as the [URLRequest.url] if you are using it with the [PlatformWebViewCreationParams.initialUrlRequest] parameter or
  ///the [InAppWebViewInitialData.baseUrl] if you are using it with the [PlatformWebViewCreationParams.initialData] parameter to prevent WebView from reading any other content.
  ///Specify a directory to give WebView permission to read additional files in the specified directory.
  @SupportedPlatforms(platforms: [IOSPlatform(), MacOSPlatform()])
  WebUri? allowingReadAccessTo;

  ///Set to `true` to disable the context menu (copy, select, etc.) that is shown when the user emits a long press event on a HTML link.
  ///This is implemented using also JavaScript, so it must be enabled or it won't work.
  ///The default value is `false`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? disableLongPressContextMenuOnLinks;

  ///Set to `true` to disable the [inputAccessoryView](https://developer.apple.com/documentation/uikit/uiresponder/1621119-inputaccessoryview) above system keyboard.
  ///The default value is `false`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? disableInputAccessoryView;

  ///The color the web view displays behind the active page, visible when the user scrolls beyond the bounds of the page.
  ///
  ///The web view derives the default value of this property from the content of the page,
  ///using the background colors of the `<html>` and `<body>` elements with the background color of the web view.
  ///To override the default color, set this property to a new color.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "15.0",
        apiName: "WKWebView.underPageBackgroundColor",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/3850574-underpagebackgroundcolor",
      ),
      MacOSPlatform(
        available: "12.0",
        apiName: "WKWebView.underPageBackgroundColor",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/3850574-underpagebackgroundcolor",
      ),
    ],
  )
  Color_? underPageBackgroundColor;

  ///A Boolean value indicating whether text interaction is enabled or not.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "15.0",
        apiName: "WKPreferences.isTextInteractionEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/3727362-istextinteractionenabled",
      ),
      MacOSPlatform(
        available: "11.3",
        apiName: "WKPreferences.isTextInteractionEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/3727362-istextinteractionenabled",
      ),
    ],
  )
  bool? isTextInteractionEnabled;

  ///A Boolean value indicating whether WebKit will apply built-in workarounds (quirks)
  ///to improve compatibility with certain known websites. You can disable site-specific quirks
  ///to help test your website without these workarounds. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "15.4",
        apiName: "WKPreferences.isSiteSpecificQuirksModeEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/3916069-issitespecificquirksmodeenabled",
      ),
      MacOSPlatform(
        available: "12.3",
        apiName: "WKPreferences.isSiteSpecificQuirksModeEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/3916069-issitespecificquirksmodeenabled",
      ),
    ],
  )
  bool? isSiteSpecificQuirksModeEnabled;

  ///A Boolean value indicating whether HTTP requests to servers known to support HTTPS should be automatically upgraded to HTTPS requests.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "15.0",
        apiName: "WKWebViewConfiguration.upgradeKnownHostsToHTTPS",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3752243-upgradeknownhoststohttps",
      ),
      MacOSPlatform(
        available: "11.3",
        apiName: "WKWebViewConfiguration.upgradeKnownHostsToHTTPS",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3752243-upgradeknownhoststohttps",
      ),
    ],
  )
  bool? upgradeKnownHostsToHTTPS;

  ///Sets whether fullscreen API is enabled or not.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "15.4",
        apiName: "WKPreferences.isElementFullscreenEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/3917769-iselementfullscreenenabled",
      ),
      MacOSPlatform(
        available: "12.3",
        apiName: "WKPreferences.isElementFullscreenEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/3917769-iselementfullscreenenabled",
      ),
      LinuxPlatform(
        apiName: "WebKitSettings.enable-fullscreen",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-fullscreen.html",
      ),
    ],
  )
  bool? isElementFullscreenEnabled;

  ///Sets whether the web view's built-in find interaction native UI is enabled or not.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "16.0",
        apiName: "WKWebView.isFindInteractionEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/4002044-isfindinteractionenabled/",
      ),
    ],
  )
  bool? isFindInteractionEnabled;

  ///Set minimum viewport inset to the smallest inset a webpage may experience in your app's maximally collapsed UI configuration.
  ///Values must be either zero or positive. It must be smaller than [maximumViewportInset].
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "15.5",
        apiName: "WKWebView.setMinimumViewportInset",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/3974127-setminimumviewportinset/",
      ),
    ],
  )
  EdgeInsets? minimumViewportInset;

  ///Set maximum viewport inset to the largest inset a webpage may experience in your app's maximally expanded UI configuration.
  ///Values must be either zero or positive. It must be larger than [minimumViewportInset].
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "15.5",
        apiName: "WKWebView.setMinimumViewportInset",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/3974127-setminimumviewportinset/",
      ),
    ],
  )
  EdgeInsets? maximumViewportInset;

  ///Controls whether this WebView is inspectable in Web Inspector.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "16.4",
        apiName: "WKWebView.isInspectable",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/4111163-isinspectable",
      ),
      MacOSPlatform(
        available: "13.3",
        apiName: "WKWebView.isInspectable",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/4111163-isinspectable",
      ),
      WindowsPlatform(
        apiName: "ICoreWebView2Settings.put_AreDevToolsEnabled",
        apiUrl:
            "https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2210.55#put_aredevtoolsenabled",
      ),
    ],
  )
  bool? isInspectable;

  ///A Boolean value that indicates whether to include any background color or graphics when printing content.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "16.4",
        apiName: "WKWebView.shouldPrintBackgrounds",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/4104043-shouldprintbackgrounds",
      ),
      MacOSPlatform(
        available: "13.3",
        apiName: "WKWebView.shouldPrintBackgrounds",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/4104043-shouldprintbackgrounds",
      ),
    ],
  )
  bool? shouldPrintBackgrounds;

  ///A [Set] of Regular Expression Patterns that will be used on native side to match the allowed origins
  ///that are able to execute the JavaScript Handlers defined for the current WebView.
  ///This will affect also the internal JavaScript Handlers used by the plugin itself.
  ///
  ///An empty [Set] will block every origin.
  ///
  ///The default value is `null` and will allow every origin.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      WebPlatform(),
    ],
  )
  Set<String>? javaScriptHandlersOriginAllowList;

  ///Set to `true` to allow to execute the JavaScript Handlers only on the main frame.
  ///This will affect also the internal JavaScript Handlers used by the plugin itself.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  bool? javaScriptHandlersForMainFrameOnly;

  ///Set to `false` to disable the JavaScript Bridge completely.
  ///This will affect also all the internal plugin [UserScript]s
  ///that are using the JavaScript Bridge to work.
  ///
  ///**NOTE**: setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      WebPlatform(),
    ],
  )
  bool? javaScriptBridgeEnabled;

  ///A [Set] of patterns that will be used to match the allowed origins where
  ///the JavaScript Bridge could be used.
  ///If [pluginScriptsOriginAllowList] is present, then this value will override
  ///it only for the JavaScript Bridge internal plugin.
  ///Adding `'*'` as an allowed origin or setting this to `null`, it means it will allow every origin.
  ///Instead, an empty [Set] will block every origin and, in this case,
  ///it will force the behaviour of the [javaScriptBridgeEnabled] parameter,
  ///as it was set to `false`.
  ///
  ///**NOTE**: setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///**NOTE for Android**: each origin pattern MUST follow the table rule of [PlatformInAppWebViewController.addWebMessageListener].
  ///
  ///**NOTE for iOS, macOS, Windows**: each origin pattern will be used as a
  ///Regular Expression Pattern that will be used on JavaScript side using [RegExp](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp).
  ///
  ///The default value is `null` and will allow every origin.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      WebPlatform(),
    ],
  )
  Set<String>? javaScriptBridgeOriginAllowList;

  ///Set to `true` to allow the JavaScript Bridge only on the main frame.
  ///If [pluginScriptsForMainFrameOnly] is present, then this value will override
  ///it only for the JavaScript Bridge internal plugin.
  ///
  ///**NOTE**: setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  bool? javaScriptBridgeForMainFrameOnly;

  ///A [Set] of patterns that will be used to match the allowed origins
  ///that are able to load all the internal plugin [UserScript]s used by the plugin itself.
  ///Adding `'*'` as an allowed origin or setting this to `null`, it means it will allow every origin.
  ///Instead, an empty [Set] will block every origin.
  ///
  ///**NOTE**: If [javaScriptBridgeOriginAllowList] is not present, this value will affect also the JavaScript Bridge internal plugin.
  ///Also, setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///**NOTE for Android**: each origin pattern MUST follow the table rule of [PlatformInAppWebViewController.addWebMessageListener].
  ///
  ///**NOTE for iOS, macOS, Windows**: each origin pattern will be used as a
  ///Regular Expression Pattern that will be used on JavaScript side using [RegExp](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp).
  ///
  ///The default value is `null` and will allow every origin.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  Set<String>? pluginScriptsOriginAllowList;

  ///Set to `true` to allow internal plugin [UserScript]s only on the main frame.
  ///
  ///**NOTE**: If [javaScriptBridgeForMainFrameOnly] is not present, this value will affect also the JavaScript Bridge internal plugin.
  ///Also, setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  bool? pluginScriptsForMainFrameOnly;

  ///The multiplier applied to the scroll amount for the WebView.
  ///
  ///This value determines how much the content will scroll in response to user input.
  ///A higher value means faster scrolling, while a lower value means slower scrolling.
  ///
  ///The default value is `1`.
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  int? scrollMultiplier;

  ///Specifies whether the status bar is displayed.
  ///
  ///The status bar is usually displayed in the lower left of the WebView and
  ///shows things such as the URI of a link when the user hovers over it and other information.
  ///The status bar UI can be altered by web content and should not be considered secure.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: "ICoreWebView2Settings.put_IsStatusBarEnabled",
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2849.39#put_isstatusbarenabled',
      ),
    ],
  )
  bool? statusBarEnabled;

  ///When this setting is set to `false`, it disables all accelerator keys
  ///that access features specific to a web browser, including but not limited to:
  ///- Ctrl-F and F3 for Find on Page
  ///- Ctrl-P for Print
  ///- Ctrl-R and F5 for Reload
  ///- Ctrl-Plus and Ctrl-Minus for zooming
  ///- Ctrl-Shift-C and F12 for DevTools
  ///Special keys for browser functions, such as Back, Forward, and Search
  ///It does not disable accelerator keys related to movement and text editing, such as:
  ///- Home, End, Page Up, and Page Down
  ///- Ctrl-X, Ctrl-C, Ctrl-V
  ///- Ctrl-A for Select All
  ///- Ctrl-Z for Undo
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        available: '1.0.864.35',
        apiName: "ICoreWebView2Settings3.put_IsBuiltInErrorPageEnabled",
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings3?view=webview2-1.0.2849.39#put_arebrowseracceleratorkeysenabled',
      ),
    ],
  )
  bool? browserAcceleratorKeysEnabled;

  ///Specifies whether autofill for information like names, street and email addresses, phone numbers, and arbitrary input is enabled.
  ///
  ///This excludes password and credit card information.
  ///When [generalAutofillEnabled] is `false`, no suggestions appear, and no new information is saved.
  ///When [generalAutofillEnabled] is `true`, information is saved, suggestions appear
  ///and clicking on one will populate the form fields.
  ///It will take effect immediately after setting.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        available: '1.0.902.49',
        apiName: "ICoreWebView2Settings4.put_IsGeneralAutofillEnabled",
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings4?view=webview2-1.0.2849.39#put_isgeneralautofillenabled',
      ),
    ],
  )
  bool? generalAutofillEnabled;

  ///Specifies whether autosave for password information is enabled.
  ///
  ///The [passwordAutosaveEnabled] property behaves independently of the IsGeneralAutofillEnabled property.
  ///When [passwordAutosaveEnabled] is `false`, no new password data is saved and no Save/Update Password prompts are displayed.
  ///However, if there was password data already saved before disabling this setting, then that password
  ///information is auto-populated, suggestions are shown and clicking on one will populate the fields.
  ///When [passwordAutosaveEnabled] is `true`, password information is auto-populated,
  ///suggestions are shown and clicking on one will populate the fields,
  ///new data is saved, and a Save/Update Password prompt is displayed.
  ///It will take effect immediately after setting.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        available: '1.0.902.49',
        apiName: "ICoreWebView2Settings4.put_IsPasswordAutosaveEnabled",
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings4?view=webview2-1.0.2849.39#put_ispasswordautosaveenabled',
      ),
    ],
  )
  bool? passwordAutosaveEnabled;

  ///Pinch-zoom, referred to as "Page Scale" zoom, is performed as a post-rendering step,
  ///it changes the page scale factor property and scales the surface the web page
  ///is rendered onto when user performs a pinch zooming action.
  ///
  ///It does not change the layout but rather changes the viewport and clips the
  ///web content, the content outside of the viewport isn't visible onscreen and users can't reach this content using mouse.
  ///
  ///The [pinchZoomEnabled] property enables or disables the ability of the end user
  ///to use a pinching motion on touch input enabled devices to scale the web content in the WebView2.
  ///When set to `false`, the end user cannot pinch zoom after the next navigation.
  ///Disabling/Enabling [pinchZoomEnabled] only affects the end user's ability to
  ///use pinch motions and does not change the page scale factor.
  ///This API only affects the Page Scale zoom and has no effect on the existing
  ///browser zoom properties or other end user mechanisms for zooming.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        available: '1.0.902.49',
        apiName: "ICoreWebView2Settings5.put_IsPinchZoomEnabled",
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings5?view=webview2-1.0.2849.39#put_ispinchzoomenabled',
      ),
    ],
  )
  bool? pinchZoomEnabled;

  ///This property is used to customize the PDF toolbar items.
  ///
  ///By default, it is [PdfToolbarItems.NONE] and so it displays all of the items.
  ///Changes to this property apply to all CoreWebView2s in the same environment and using the same profile.
  ///Changes to this setting apply only after the next navigation.
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        available: '1.0.1185.39',
        apiName: "ICoreWebView2Settings7.put_HiddenPdfToolbarItems",
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings7?view=webview2-1.0.2849.39#put_hiddenpdftoolbaritems',
      ),
    ],
  )
  PdfToolbarItems_? hiddenPdfToolbarItems;

  ///[reputationCheckingRequired] is used to control whether SmartScreen enabled or not.
  ///
  ///SmartScreen helps webviews identify reported phishing and malware websites and also helps users make informed decisions about downloads.
  ///SmartScreen is enabled or disabled for all CoreWebView2s using the same user data folder.
  ///If [reputationCheckingRequired] is true for any CoreWebView2 using the same user data folder, then SmartScreen is enabled.
  ///If [reputationCheckingRequired] is false for all CoreWebView2 using the same user data folder, then SmartScreen is disabled.
  ///When it is changed, the change will be applied to all WebViews using the same user data folder on the next navigation or download.
  ///If the newly created CoreWebview2 does not set SmartScreen to `false`,
  ///when navigating(Such as Navigate(), LoadDataUrl(), ExecuteScript(), etc.), the default value will be applied to all CoreWebview2 using the same user data folder.
  ///SmartScreen of WebView2 apps can be controlled by Windows system setting "SmartScreen for Microsoft Edge", specially,
  ///for WebView2 in Windows Store apps, SmartScreen is controlled by another Windows system setting "SmartScreen for Microsoft Store apps".
  ///When the Windows setting is enabled, the SmartScreen operates under the control of the [reputationCheckingRequired].
  ///When the Windows setting is disabled, the SmartScreen will be disabled regardless of the [reputationCheckingRequired] value set in WebView2 apps.
  ///In other words, under this circumstance the value of [reputationCheckingRequired] will be saved but overridden by system setting.
  ///Upon re-enabling the Windows setting, the CoreWebview2 will reference the [reputationCheckingRequired] to determine the SmartScreen status.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        available: '1.0.1722.45',
        apiName: "ICoreWebView2Settings8.put_IsReputationCheckingRequired",
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings8?view=webview2-1.0.2849.39#put_isreputationcheckingrequired',
      ),
    ],
  )
  bool? reputationCheckingRequired;

  ///Enables web pages to use the `app-region` CSS style.
  ///
  ///Disabling/Enabling the [nonClientRegionSupportEnabled] takes effect after the next navigation.
  ///
  ///When this property is `true`, then all the non-client region features will be enabled:
  ///Draggable Regions will be enabled, they are regions on a webpage that are marked with the CSS attribute `app-region: drag/no-drag`.
  ///When set to drag, these regions will be treated like the window's title bar,
  ///supporting dragging of the entire WebView and its host app window;
  ///the system menu shows upon right click, and a double click will trigger maximizing/restoration of the window size.
  ///
  ///When set to `false`, all non-client region support will be disabled.
  ///The `app-region` CSS style will be ignored on web pages.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        available: '1.0.2420.47',
        apiName: "ICoreWebView2Settings9.put_IsNonClientRegionSupportEnabled",
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings9?view=webview2-1.0.2849.39#put_isnonclientregionsupportenabled',
      ),
    ],
  )
  bool? nonClientRegionSupportEnabled;

  ///A Boolean value that determines whether user events are ignored and removed from the event queue.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        apiName: "UIView.isUserInteractionEnabled",
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiview/1622577-isuserinteractionenabled',
      ),
    ],
  )
  bool? isUserInteractionEnabled;

  ///A Boolean value that determines whether to listen and handle the
  ///[PlatformWebViewCreationParams.onAcceleratorKeyPressed] event.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  bool? handleAcceleratorKeyPressed;

  ///The view’s alpha value. The value of this property is a floating-point number
  ///in the range 0.0 to 1.0, where 0.0 represents totally transparent and 1.0 represents totally opaque.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setAlpha",
        apiUrl:
            'https://developer.android.com/reference/android/view/View#setAlpha(float)',
      ),
      IOSPlatform(
        apiName: "UIView.alpha",
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiview/1622417-alpha',
      ),
      MacOSPlatform(
        apiName: "NSView.alphaValue",
        apiUrl:
            'https://developer.apple.com/documentation/appkit/nsview/1483560-alphavalue',
      ),
    ],
  )
  double? alpha;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onShowFileChooser] event.
  ///
  ///If the [PlatformWebViewCreationParams.onShowFileChooser] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool? useOnShowFileChooser;

  ///Specifies a feature policy for the `<iframe>`.
  ///The policy defines what features are available to the `<iframe>` based on the origin of the request
  ///(e.g. access to the microphone, camera, battery, web-share API, etc.).
  @SupportedPlatforms(
    platforms: [
      WebPlatform(
        requiresSameOrigin: false,
        apiName: "iframe.allow",
        apiUrl:
            "https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-allow",
      ),
    ],
  )
  String? iframeAllow;

  ///Set to true if the `<iframe>` can activate fullscreen mode by calling the `requestFullscreen()` method.
  @SupportedPlatforms(
    platforms: [
      WebPlatform(
        requiresSameOrigin: false,
        apiName: "iframe.allowfullscreen",
        apiUrl:
            "https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-allowfullscreen",
      ),
    ],
  )
  bool? iframeAllowFullscreen;

  ///Applies extra restrictions to the content in the frame.
  @SupportedPlatforms(
    platforms: [
      WebPlatform(
        requiresSameOrigin: false,
        apiName: "iframe.sandbox",
        apiUrl:
            "https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-sandbox",
      ),
    ],
  )
  Set<Sandbox_>? iframeSandbox;

  ///A string that reflects the `referrerpolicy` HTML attribute indicating which referrer to use when fetching the linked resource.
  @SupportedPlatforms(
    platforms: [
      WebPlatform(
        requiresSameOrigin: false,
        apiName: "iframe.referrerpolicy",
        apiUrl:
            "https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-referrerpolicy",
      ),
    ],
  )
  ReferrerPolicy_? iframeReferrerPolicy;

  ///A string that reflects the `name` HTML attribute, containing a name by which to refer to the frame.
  @SupportedPlatforms(
    platforms: [
      WebPlatform(
        requiresSameOrigin: false,
        apiName: "iframe.name",
        apiUrl:
            "https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-name",
      ),
    ],
  )
  String? iframeName;

  ///A Content Security Policy enforced for the embedded resource.
  @SupportedPlatforms(
    platforms: [
      WebPlatform(
        requiresSameOrigin: false,
        apiName: "iframe.csp",
        apiUrl:
            "https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-csp",
      ),
    ],
  )
  String? iframeCsp;

  ///A string that reflects the `role` HTML attribute, containing a WAI-ARIA role for the element.
  @SupportedPlatforms(
    platforms: [
      WebPlatform(
        requiresSameOrigin: false,
        apiName: "iframe.role",
        apiUrl:
            "https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Roles",
      ),
    ],
  )
  String? iframeRole;

  ///A string that reflects the `aria-hidden` HTML attribute, indicating whether the element is exposed to an accessibility API.
  @SupportedPlatforms(
    platforms: [
      WebPlatform(
        requiresSameOrigin: false,
        apiName: "iframe.ariaHidden",
        apiUrl:
            "https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-hidden",
      ),
    ],
  )
  String? iframeAriaHidden;

  ///Sets whether console messages are written to stdout.
  ///When enabled, console messages from the web page will be written to the standard output.
  ///This is useful for debugging purposes.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WebKitSettings.enable-write-console-messages-to-stdout",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-write-console-messages-to-stdout.html",
      ),
    ],
  )
  bool? enableWriteConsoleMessagesToStdout;

  ///Sets whether smooth scrolling is enabled.
  ///When enabled, scrolling animations are smooth instead of jumping instantly.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WebKitSettings.enable-smooth-scrolling",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-smooth-scrolling.html",
      ),
    ],
  )
  bool? enableSmoothScrolling;

  ///Sets whether caret browsing mode is enabled.
  ///Caret browsing mode allows users to navigate through web pages using the keyboard,
  ///with a visible caret (text cursor) that can be moved through the content.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WebKitSettings.enable-caret-browsing",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-caret-browsing.html",
      ),
    ],
  )
  bool? enableCaretBrowsing;

  ///Sets whether the page cache is enabled.
  ///The page cache allows for faster back/forward navigation by keeping pages in memory.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WebKitSettings.enable-page-cache",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-page-cache.html",
      ),
    ],
  )
  bool? enablePageCache;

  ///Sets whether compositing indicators are drawn.
  ///When enabled, visual indicators are shown for compositing layers.
  ///This is primarily useful for debugging rendering performance.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WebKitSettings.draw-compositing-indicators",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.draw-compositing-indicators.html",
      ),
    ],
  )
  bool? drawCompositingIndicators;

  ///Sets whether text areas are resizable.
  ///When enabled, text areas can be resized by the user.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WebKitSettings.enable-resizable-text-areas",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-resizable-text-areas.html",
      ),
    ],
  )
  bool? enableResizableTextAreas;

  ///Sets whether tab key can be used to navigate to links.
  ///When enabled, pressing Tab will focus on links in the page.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WebKitSettings.enable-tabs-to-links",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-tabs-to-links.html",
      ),
    ],
  )
  bool? enableTabsToLinks;

  ///Sets whether spatial navigation is enabled.
  ///Spatial navigation allows users to navigate between focusable elements
  ///using arrow keys instead of Tab.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WebKitSettings.enable-spatial-navigation",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-spatial-navigation.html",
      ),
    ],
  )
  bool? enableSpatialNavigation;

  ///Sets the pictograph font family name.
  ///The pictograph font family is used for rendering pictograph characters (emoji).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WebKitSettings.pictograph-font-family",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.pictograph-font-family.html",
      ),
    ],
  )
  String? pictographFontFamily;

  ///Sets the CORS allowlist for this WebView.
  ///
  ///URI patterns must be of the form `[protocol]://[host]:[port]`, where each
  ///component may contain the wildcard character (`*`) to match zero or more
  ///characters. All three components are required.
  ///
  ///Disabling CORS checks permits resources from other origins to load
  ///allowlisted resources. It does NOT permit the allowlisted resources
  ///to load resources from other origins.
  ///
  ///Setting to `null` or an empty list clears the allowlist.
  ///
  ///Example patterns:
  ///- `https://example.com:*` - All ports on example.com over HTTPS
  ///- `*://api.myservice.com:*` - Any protocol on api.myservice.com
  ///- `https://*.example.com:443` - HTTPS port 443 on any subdomain
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        available: "2.34",
        apiName: "webkit_web_view_set_cors_allowlist",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.set_cors_allowlist.html",
        note:
            "Pattern format: [protocol]://[host]:[port]. All three components are required.",
      ),
    ],
  )
  List<String>? corsAllowlist;

  ///Sets whether Intelligent Tracking Prevention (ITP) is enabled.
  ///
  ///When ITP is enabled, resource load statistics are collected and used to decide
  ///whether to allow or block third-party cookies and prevent user tracking.
  ///This is similar to Safari's tracking prevention feature.
  ///
  ///**IMPORTANT NOTE**: When ITP is enabled, the cookie accept policy
  ///`WEBKIT_COOKIE_POLICY_ACCEPT_NO_THIRD_PARTY` is ignored and
  ///`WEBKIT_COOKIE_POLICY_ACCEPT_ALWAYS` is used instead.
  ///
  ///This is a session-level setting that should be set during WebView initialization.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        available: "2.40",
        apiName: "webkit_network_session_set_itp_enabled",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.NetworkSession.set_itp_enabled.html",
        note:
            "This is a session-level setting. When enabled, ACCEPT_NO_THIRD_PARTY cookie policy is overridden to ACCEPT_ALWAYS.",
      ),
    ],
  )
  bool? itpEnabled;

  ///Sets whether dark mode is enabled for web content.
  ///When enabled, websites that support the `prefers-color-scheme: dark` CSS media query
  ///will render in dark mode.
  ///
  ///This is a WPE Platform setting that affects the entire display.
  ///
  ///The default value is `null` (follows system default).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WPESettings.dark-mode",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-platform-2.0/class.Settings.html",
        note:
            "This is a WPE Platform display-level setting that affects all WebViews.",
      ),
    ],
  )
  bool? darkMode;

  ///Sets whether animations are disabled for accessibility.
  ///When enabled, CSS animations and transitions may be reduced or disabled
  ///for users with motion sensitivity.
  ///
  ///This is a WPE Platform setting that affects the entire display.
  ///
  ///The default value is `null` (follows system default).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WPESettings.disable-animations",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-platform-2.0/class.Settings.html",
        note: "This is a WPE Platform display-level setting for accessibility.",
      ),
    ],
  )
  bool? disableAnimations;

  ///Sets whether font antialiasing is enabled.
  ///When enabled, fonts are rendered with antialiasing for smoother edges.
  ///
  ///This is a WPE Platform setting that affects the entire display.
  ///
  ///The default value is `null` (follows system default).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WPESettings.font-antialias",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-platform-2.0/class.Settings.html",
        note:
            "This is a WPE Platform display-level setting for font rendering.",
      ),
    ],
  )
  bool? fontAntialias;

  ///Sets the font hinting style.
  ///Hinting adjusts font outlines to improve rendering at small sizes.
  ///
  ///This is a WPE Platform setting that affects the entire display.
  ///
  ///The default value is `null` (follows system default).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WPESettings.font-hinting-style",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-platform-2.0/class.Settings.html",
        note:
            "This is a WPE Platform display-level setting for font rendering.",
      ),
    ],
  )
  FontHintingStyle_? fontHintingStyle;

  ///Sets the font subpixel layout for LCD rendering.
  ///This determines how subpixel rendering is performed based on the
  ///physical arrangement of the display's RGB subpixels.
  ///
  ///This is a WPE Platform setting that affects the entire display.
  ///
  ///The default value is `null` (follows system default).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WPESettings.font-subpixel-layout",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-platform-2.0/class.Settings.html",
        note:
            "This is a WPE Platform display-level setting for font rendering.",
      ),
    ],
  )
  FontSubpixelLayout_? fontSubpixelLayout;

  ///Sets the font DPI (dots per inch) for text rendering.
  ///This affects the size at which fonts are rendered.
  ///
  ///This is a WPE Platform setting that affects the entire display.
  ///
  ///The default value is `null` (uses system default, typically 96.0).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WPESettings.font-dpi",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-platform-2.0/class.Settings.html",
        note:
            "This is a WPE Platform display-level setting. Default is typically 96.0 DPI.",
      ),
    ],
  )
  double? fontDPI;

  ///Sets the cursor blink time in milliseconds.
  ///This controls how frequently the text cursor blinks in input fields.
  ///
  ///This is a WPE Platform setting that affects the entire display.
  ///
  ///The default value is `null` (uses system default, typically 1200ms).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WPESettings.cursor-blink-time",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-platform-2.0/class.Settings.html",
        note:
            "This is a WPE Platform display-level setting. Value is in milliseconds.",
      ),
    ],
  )
  int? cursorBlinkTime;

  ///Sets the double-click distance threshold in pixels.
  ///Two clicks within this distance are considered a double-click.
  ///
  ///This is a WPE Platform setting that affects the entire display.
  ///
  ///The default value is `null` (uses system default, typically 5 pixels).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WPESettings.double-click-distance",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-platform-2.0/class.Settings.html",
        note:
            "This is a WPE Platform display-level setting. Value is in pixels.",
      ),
    ],
  )
  int? doubleClickDistance;

  ///Sets the double-click time threshold in milliseconds.
  ///Two clicks within this time are considered a double-click.
  ///
  ///This is a WPE Platform setting that affects the entire display.
  ///
  ///The default value is `null` (uses system default, typically 400ms).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WPESettings.double-click-time",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-platform-2.0/class.Settings.html",
        note:
            "This is a WPE Platform display-level setting. Value is in milliseconds.",
      ),
    ],
  )
  int? doubleClickTime;

  ///Sets the drag threshold in pixels.
  ///The pointer must move at least this many pixels to start a drag operation.
  ///
  ///This is a WPE Platform setting that affects the entire display.
  ///
  ///The default value is `null` (uses system default, typically 8 pixels).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WPESettings.drag-threshold",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-platform-2.0/class.Settings.html",
        note:
            "This is a WPE Platform display-level setting. Value is in pixels.",
      ),
    ],
  )
  int? dragThreshold;

  ///Sets the key repeat delay in milliseconds.
  ///This is the time a key must be held before it starts repeating.
  ///
  ///This is a WPE Platform setting that affects the entire display.
  ///
  ///The default value is `null` (uses system default, typically 400ms).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WPESettings.key-repeat-delay",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-platform-2.0/class.Settings.html",
        note:
            "This is a WPE Platform display-level setting. Value is in milliseconds.",
      ),
    ],
  )
  int? keyRepeatDelay;

  ///Sets the key repeat interval in milliseconds.
  ///This is the time between repeated key events when a key is held down.
  ///
  ///This is a WPE Platform setting that affects the entire display.
  ///
  ///The default value is `null` (uses system default, typically 80ms).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WPESettings.key-repeat-interval",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-platform-2.0/class.Settings.html",
        note:
            "This is a WPE Platform display-level setting. Value is in milliseconds.",
      ),
    ],
  )
  int? keyRepeatInterval;

  ///Sets whether JavaScript can access the clipboard.
  ///When enabled, JavaScript can read from and write to the system clipboard.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WebKitSettings.javascript-can-access-clipboard",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.javascript-can-access-clipboard.html",
      ),
    ],
  )
  bool? javaScriptCanAccessClipboard;

  ///Sets whether modal dialogs are allowed.
  ///When enabled, modal dialogs (such as `window.showModalDialog()`) are allowed.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: "WebKitSettings.allow-modal-dialogs",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.allow-modal-dialogs.html",
      ),
    ],
  )
  bool? allowModalDialogs;

  ///Disables web security. When disabled, same-origin policy is not enforced.
  ///
  ///**NOTE**: Setting this to `true` is extremely dangerous and should only be used for testing.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        available: "2.40",
        apiName: "WebKitSettings.disable-web-security",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.disable-web-security.html",
        note: "Requires WPE WebKit 2.40 or later",
      ),
    ],
  )
  bool? disableWebSecurity;

  ///Enables WebRTC support for real-time communication features.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        available: "2.38",
        apiName: "WebKitSettings.enable-webrtc",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-webrtc.html",
        note: "Requires WPE WebKit 2.38 or later",
      ),
    ],
  )
  bool? enableWebRTC;

  ///Sets the range of UDP ports for WebRTC connections.
  ///
  ///The format is "minPort:maxPort", for example "10000:10100".
  ///
  ///The default value is `null` (uses system default).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        available: "2.48",
        apiName: "WebKitSettings.webrtc-udp-ports-range",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.webrtc-udp-ports-range.html",
        note: "Requires WPE WebKit 2.48 or later. Format: 'minPort:maxPort'",
      ),
    ],
  )
  String? webRTCUdpPortsRange;

  ///Sets whether media (audio/video) is enabled.
  ///When disabled, media elements will not be able to play.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        available: "2.26",
        apiName: "WebKitSettings.enable-media",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-media.html",
        note: "Requires WPE WebKit 2.26 or later",
      ),
    ],
  )
  bool? enableMedia;

  ///Sets whether Encrypted Media Extensions (EME) are enabled.
  ///EME provides APIs for playing protected (DRM) content.
  ///
  ///The default value is `true` (since WPE WebKit 2.38).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        available: "2.20",
        apiName: "WebKitSettings.enable-encrypted-media",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-encrypted-media.html",
        note: "Requires WPE WebKit 2.20 or later",
      ),
    ],
  )
  bool? enableEncryptedMedia;

  ///Sets whether the Media Capabilities API is enabled.
  ///The Media Capabilities API provides information about the decoding abilities of the device.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        available: "2.22",
        apiName: "WebKitSettings.enable-media-capabilities",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-media-capabilities.html",
        note: "Requires WPE WebKit 2.22 or later",
      ),
    ],
  )
  bool? enableMediaCapabilities;

  ///Sets whether mock capture devices are enabled.
  ///When enabled, the browser will use mock devices for getUserMedia() instead of real hardware.
  ///This is useful for testing.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        available: "2.24",
        apiName: "WebKitSettings.enable-mock-capture-devices",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-mock-capture-devices.html",
        note: "Requires WPE WebKit 2.24 or later",
      ),
    ],
  )
  bool? enableMockCaptureDevices;

  ///Sets the media content types that require hardware support.
  ///This is a comma-separated list of media content types.
  ///
  ///The default value is `null` (uses system default).
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        available: "2.30",
        apiName:
            "WebKitSettings.media-content-types-requiring-hardware-support",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.media-content-types-requiring-hardware-support.html",
        note: "Requires WPE WebKit 2.30 or later",
      ),
    ],
  )
  String? mediaContentTypesRequiringHardwareSupport;

  ///Sets whether JavaScript markup (<script> tags) is enabled.
  ///When disabled, scripts embedded in HTML will not be executed.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        available: "2.24",
        apiName: "WebKitSettings.enable-javascript-markup",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-javascript-markup.html",
        note: "Requires WPE WebKit 2.24 or later",
      ),
    ],
  )
  bool? enableJavaScriptMarkup;

  ///Sets whether 2D canvas hardware acceleration is enabled.
  ///When enabled, 2D canvas operations are accelerated using the GPU.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        available: "2.46",
        apiName: "WebKitSettings.enable-2d-canvas-acceleration",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.enable-2d-canvas-acceleration.html",
        note: "Requires WPE WebKit 2.46 or later",
      ),
    ],
  )
  bool? enable2DCanvasAcceleration;

  ///Sets whether top-level navigation to data: URLs is allowed.
  ///When disabled, navigating to data: URLs in the top frame is blocked.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        available: "2.28",
        apiName: "WebKitSettings.allow-top-navigation-to-data-urls",
        apiUrl:
            "https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.Settings.allow-top-navigation-to-data-urls.html",
        note: "Requires WPE WebKit 2.28 or later",
      ),
    ],
  )
  bool? allowTopNavigationToDataUrls;

  @ExchangeableObjectConstructor()
  InAppWebViewSettings_({
    this.useShouldOverrideUrlLoading,
    this.useOnLoadResource,
    this.useOnDownloadStart,
    @Deprecated("Use InAppWebViewController.clearAllCache instead")
    this.clearCache = false,
    this.userAgent = "",
    this.applicationNameForUserAgent = "",
    this.javaScriptEnabled = true,
    this.javaScriptCanOpenWindowsAutomatically = false,
    this.mediaPlaybackRequiresUserGesture = true,
    this.minimumFontSize,
    this.verticalScrollBarEnabled = true,
    this.horizontalScrollBarEnabled = true,
    this.resourceCustomSchemes = const [],
    this.contentBlockers = const [],
    this.preferredContentMode = UserPreferredContentMode_.RECOMMENDED,
    this.useShouldInterceptAjaxRequest,
    this.useOnAjaxReadyStateChange,
    this.useOnAjaxProgress,
    this.interceptOnlyAsyncAjaxRequests = true,
    this.useShouldInterceptFetchRequest,
    this.incognito = false,
    this.cacheEnabled = true,
    this.transparentBackground = false,
    this.disableVerticalScroll = false,
    this.disableHorizontalScroll = false,
    this.disableContextMenu = false,
    this.supportZoom = true,
    this.allowFileAccessFromFileURLs = false,
    this.allowUniversalAccessFromFileURLs = false,
    this.textZoom,
    @Deprecated("Use CookieManager.removeSessionCookies instead")
    this.clearSessionCache = false,
    this.builtInZoomControls = true,
    this.displayZoomControls = false,
    this.databaseEnabled = true,
    this.domStorageEnabled = true,
    this.useWideViewPort = true,
    this.safeBrowsingEnabled = true,
    this.mixedContentMode,
    this.allowContentAccess = true,
    this.allowFileAccess = true,
    this.appCachePath,
    this.blockNetworkImage = false,
    this.blockNetworkLoads = false,
    this.cacheMode = CacheMode_.LOAD_DEFAULT,
    this.cursiveFontFamily = "cursive",
    this.defaultFixedFontSize = 16,
    this.defaultFontSize = 16,
    this.defaultTextEncodingName = "UTF-8",
    this.disabledActionModeMenuItems,
    this.fantasyFontFamily = "fantasy",
    this.fixedFontFamily = "monospace",
    @Deprecated("Use algorithmicDarkeningAllowed instead") this.forceDark,
    @Deprecated("Use algorithmicDarkeningAllowed instead")
    this.forceDarkStrategy,
    this.geolocationEnabled = true,
    this.layoutAlgorithm,
    this.loadWithOverviewMode = true,
    this.loadsImagesAutomatically = true,
    this.minimumLogicalFontSize = 8,
    this.needInitialFocus = true,
    this.offscreenPreRaster = false,
    this.sansSerifFontFamily = "sans-serif",
    this.serifFontFamily = "sans-serif",
    this.standardFontFamily = "sans-serif",
    @Deprecated('') this.saveFormData = true,
    this.thirdPartyCookiesEnabled = true,
    this.hardwareAcceleration = true,
    this.initialScale = 0,
    this.supportMultipleWindows = false,
    this.regexToCancelSubFramesLoading,
    this.regexToAllowSyncUrlLoading,
    this.useHybridComposition = true,
    this.useShouldInterceptRequest,
    this.useOnRenderProcessGone,
    this.overScrollMode = OverScrollMode_.IF_CONTENT_SCROLLS,
    this.networkAvailable,
    this.scrollBarStyle = ScrollBarStyle_.SCROLLBARS_INSIDE_OVERLAY,
    this.verticalScrollbarPosition =
        VerticalScrollbarPosition_.SCROLLBAR_POSITION_DEFAULT,
    this.scrollBarDefaultDelayBeforeFade,
    this.scrollbarFadingEnabled = true,
    this.scrollBarFadeDuration,
    this.rendererPriorityPolicy,
    this.disableDefaultErrorPage = false,
    this.verticalScrollbarThumbColor,
    this.verticalScrollbarTrackColor,
    this.horizontalScrollbarThumbColor,
    this.horizontalScrollbarTrackColor,
    this.algorithmicDarkeningAllowed = false,
    this.enterpriseAuthenticationAppLinkPolicyEnabled = true,
    this.defaultVideoPoster,
    this.requestedWithHeaderOriginAllowList,
    this.disallowOverScroll = false,
    this.enableViewportScale = false,
    this.suppressesIncrementalRendering = false,
    this.allowsAirPlayForMediaPlayback = true,
    this.allowsBackForwardNavigationGestures = true,
    this.allowsLinkPreview = true,
    this.ignoresViewportScaleLimits = false,
    this.allowsInlineMediaPlayback = false,
    this.allowsPictureInPictureMediaPlayback = true,
    this.isFraudulentWebsiteWarningEnabled = true,
    this.selectionGranularity = SelectionGranularity_.DYNAMIC,
    this.dataDetectorTypes = const [DataDetectorTypes_.NONE],
    this.sharedCookiesEnabled = false,
    this.automaticallyAdjustsScrollIndicatorInsets = false,
    this.accessibilityIgnoresInvertColors = false,
    this.decelerationRate = ScrollViewDecelerationRate_.NORMAL,
    this.alwaysBounceVertical = false,
    this.alwaysBounceHorizontal = false,
    this.scrollsToTop = true,
    this.isPagingEnabled = false,
    this.maximumZoomScale = 1.0,
    this.minimumZoomScale = 1.0,
    this.contentInsetAdjustmentBehavior =
        ScrollViewContentInsetAdjustmentBehavior_.NEVER,
    this.isDirectionalLockEnabled = false,
    this.mediaType,
    this.pageZoom = 1.0,
    this.limitsNavigationsToAppBoundDomains = false,
    this.useOnNavigationResponse,
    this.applePayAPIEnabled = false,
    this.allowingReadAccessTo,
    this.disableLongPressContextMenuOnLinks = false,
    this.disableInputAccessoryView = false,
    this.underPageBackgroundColor,
    this.isTextInteractionEnabled = true,
    this.isSiteSpecificQuirksModeEnabled = true,
    this.upgradeKnownHostsToHTTPS = true,
    this.isElementFullscreenEnabled = true,
    this.isFindInteractionEnabled = false,
    this.minimumViewportInset,
    this.maximumViewportInset,
    this.isInspectable = false,
    this.shouldPrintBackgrounds = false,
    this.allowBackgroundAudioPlaying = false,
    this.webViewAssetLoader,
    this.javaScriptHandlersOriginAllowList,
    this.javaScriptHandlersForMainFrameOnly,
    this.javaScriptBridgeEnabled = true,
    this.javaScriptBridgeOriginAllowList,
    this.javaScriptBridgeForMainFrameOnly,
    this.pluginScriptsOriginAllowList,
    this.pluginScriptsForMainFrameOnly = false,
    this.scrollMultiplier = 1,
    this.statusBarEnabled = true,
    this.browserAcceleratorKeysEnabled = true,
    this.generalAutofillEnabled = true,
    this.passwordAutosaveEnabled = false,
    this.pinchZoomEnabled = true,
    this.hiddenPdfToolbarItems = PdfToolbarItems_.NONE,
    this.reputationCheckingRequired = true,
    this.nonClientRegionSupportEnabled = false,
    this.isUserInteractionEnabled = true,
    this.handleAcceleratorKeyPressed = false,
    this.alpha,
    this.useOnShowFileChooser,
    this.iframeAllow,
    this.iframeAllowFullscreen,
    this.iframeSandbox,
    this.iframeReferrerPolicy,
    this.iframeName,
    this.iframeCsp,
    this.iframeRole,
    this.iframeAriaHidden,
    this.enableWriteConsoleMessagesToStdout = false,
    this.enableSmoothScrolling = true,
    this.enableCaretBrowsing = false,
    this.enablePageCache = true,
    this.drawCompositingIndicators = false,
    this.enableResizableTextAreas = true,
    this.enableTabsToLinks = true,
    this.enableSpatialNavigation = false,
    this.pictographFontFamily,
    this.corsAllowlist,
    this.itpEnabled = false,
    this.darkMode,
    this.disableAnimations,
    this.fontAntialias,
    this.fontHintingStyle,
    this.fontSubpixelLayout,
    this.fontDPI,
    this.cursorBlinkTime,
    this.doubleClickDistance,
    this.doubleClickTime,
    this.dragThreshold,
    this.keyRepeatDelay,
    this.keyRepeatInterval,
    this.javaScriptCanAccessClipboard = false,
    this.allowModalDialogs = false,
    this.disableWebSecurity = false,
    this.enableWebRTC = true,
    this.webRTCUdpPortsRange,
    this.enableMedia = true,
    this.enableEncryptedMedia = true,
    this.enableMediaCapabilities = true,
    this.enableMockCaptureDevices = false,
    this.mediaContentTypesRequiringHardwareSupport,
    this.enableJavaScriptMarkup = true,
    this.enable2DCanvasAcceleration = false,
    this.allowTopNavigationToDataUrls = false,
  }) {
    if (this.minimumFontSize == null)
      this.minimumFontSize = Util.isAndroid ? 8 : 0;
    assert(
      this.resourceCustomSchemes == null ||
          (this.resourceCustomSchemes != null &&
              !this.resourceCustomSchemes!.contains("http") &&
              !this.resourceCustomSchemes!.contains("https")),
    );
    assert(
      allowingReadAccessTo == null || allowingReadAccessTo!.isScheme("file"),
    );
    assert(
      (minimumViewportInset == null && maximumViewportInset == null) ||
          minimumViewportInset != null &&
              maximumViewportInset != null &&
              minimumViewportInset!.isNonNegative &&
              maximumViewportInset!.isNonNegative &&
              minimumViewportInset!.vertical <=
                  maximumViewportInset!.vertical &&
              minimumViewportInset!.horizontal <=
                  maximumViewportInset!.horizontal,
      "minimumViewportInset cannot be larger than maximumViewportInset",
    );
  }

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    InAppWebViewSettingsProperty property, {
    TargetPlatform? platform,
  }) => _InAppWebViewSettingsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );
}

///Class that represents the options that can be used for a `WebView`.
///Use [InAppWebViewSettings] instead.
@Deprecated('Use InAppWebViewSettings instead')
class InAppWebViewGroupOptions {
  ///Cross-platform options.
  late InAppWebViewOptions crossPlatform;

  ///Android-specific options.
  late AndroidInAppWebViewOptions android;

  ///iOS-specific options.
  late IOSInAppWebViewOptions ios;

  InAppWebViewGroupOptions({
    InAppWebViewOptions? crossPlatform,
    AndroidInAppWebViewOptions? android,
    IOSInAppWebViewOptions? ios,
  }) {
    this.crossPlatform = crossPlatform ?? InAppWebViewOptions();
    this.android = android ?? AndroidInAppWebViewOptions();
    this.ios = ios ?? IOSInAppWebViewOptions();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> options = {};
    options.addAll(this.crossPlatform.toMap());
    if (Util.isAndroid)
      options.addAll(this.android.toMap());
    else if (Util.isIOS)
      options.addAll(this.ios.toMap());

    return options;
  }

  static InAppWebViewGroupOptions fromMap(Map<String, dynamic> options) {
    InAppWebViewGroupOptions inAppWebViewGroupOptions =
        InAppWebViewGroupOptions();

    inAppWebViewGroupOptions.crossPlatform = InAppWebViewOptions.fromMap(
      options,
    );
    if (Util.isAndroid)
      inAppWebViewGroupOptions.android = AndroidInAppWebViewOptions.fromMap(
        options,
      );
    else if (Util.isIOS)
      inAppWebViewGroupOptions.ios = IOSInAppWebViewOptions.fromMap(options);

    return inAppWebViewGroupOptions;
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }

  InAppWebViewGroupOptions copy() {
    return InAppWebViewGroupOptions.fromMap(this.toMap());
  }
}

class WebViewOptions {
  Map<String, dynamic> toMap() {
    return {};
  }

  static WebViewOptions fromMap(Map<String, dynamic> map) {
    return WebViewOptions();
  }

  WebViewOptions copy() {
    return WebViewOptions.fromMap(this.toMap());
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Use [InAppWebViewSettings] instead.
@Deprecated('Use InAppWebViewSettings instead')
class InAppWebViewOptions
    implements WebViewOptions, BrowserOptions, AndroidOptions, IosOptions {
  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event. The default value is `false`.
  bool useShouldOverrideUrlLoading;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onLoadResource] event. The default value is `false`.
  bool useOnLoadResource;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onDownloadStart] event. The default value is `false`.
  bool useOnDownloadStart;

  ///Set to `true` to have all the browser's cache cleared before the new WebView is opened. The default value is `false`.
  bool clearCache;

  ///Sets the user-agent for the WebView.
  ///
  ///**NOTE**: available on iOS 9.0+.
  String userAgent;

  ///Append to the existing user-agent. Setting userAgent will override this.
  ///
  ///**NOTE**: available on Android 17+ and on iOS 9.0+.
  String applicationNameForUserAgent;

  ///Set to `true` to enable JavaScript. The default value is `true`.
  bool javaScriptEnabled;

  ///Set to `true` to allow JavaScript open windows without user interaction. The default value is `false`.
  bool javaScriptCanOpenWindowsAutomatically;

  ///Set to `true` to prevent HTML5 audio or video from autoplaying. The default value is `true`.
  ///
  ///**NOTE**: available on iOS 10.0+.
  bool mediaPlaybackRequiresUserGesture;

  ///Sets the minimum font size. The default value is `8` for Android, `0` for iOS.
  int? minimumFontSize;

  ///Define whether the vertical scrollbar should be drawn or not. The default value is `true`.
  bool verticalScrollBarEnabled;

  ///Define whether the horizontal scrollbar should be drawn or not. The default value is `true`.
  bool horizontalScrollBarEnabled;

  ///List of custom schemes that the WebView must handle. Use the [PlatformWebViewCreationParams.onLoadResourceCustomScheme] event to intercept resource requests with custom scheme.
  ///
  ///**NOTE**: available on iOS 11.0+.
  List<String> resourceCustomSchemes;

  ///List of [ContentBlocker] that are a set of rules used to block content in the browser window.
  ///
  ///**NOTE**: available on iOS 11.0+.
  List<ContentBlocker> contentBlockers;

  ///Sets the content mode that the WebView needs to use when loading and rendering a webpage. The default value is [UserPreferredContentMode.RECOMMENDED].
  ///
  ///**NOTE**: available on iOS 13.0+.
  UserPreferredContentMode? preferredContentMode;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldInterceptAjaxRequest] event. The default value is `false`.
  bool useShouldInterceptAjaxRequest;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldInterceptFetchRequest] event. The default value is `false`.
  bool useShouldInterceptFetchRequest;

  ///Set to `true` to open a browser window with incognito mode. The default value is `false`.
  ///
  ///**NOTE**: available on iOS 9.0+.
  ///On Android, by setting this option to `true`, it will clear all the cookies of all WebView instances,
  ///because there isn't any way to make the website data store non-persistent for the specific WebView instance such as on iOS.
  bool incognito;

  ///Sets whether WebView should use browser caching. The default value is `true`.
  ///
  ///**NOTE**: available on iOS 9.0+.
  bool cacheEnabled;

  ///Set to `true` to make the background of the WebView transparent. If your app has a dark theme, this can prevent a white flash on initialization. The default value is `false`.
  bool transparentBackground;

  ///Set to `true` to disable vertical scroll. The default value is `false`.
  bool disableVerticalScroll;

  ///Set to `true` to disable horizontal scroll. The default value is `false`.
  bool disableHorizontalScroll;

  ///Set to `true` to disable context menu. The default value is `false`.
  bool disableContextMenu;

  ///Set to `false` if the WebView should not support zooming using its on-screen zoom controls and gestures. The default value is `true`.
  bool supportZoom;

  ///Sets whether cross-origin requests in the context of a file scheme URL should be allowed to access content from other file scheme URLs.
  ///Note that some accesses such as image HTML elements don't follow same-origin rules and aren't affected by this setting.
  ///
  ///Don't enable this setting if you open files that may be created or altered by external sources.
  ///Enabling this setting allows malicious scripts loaded in a `file://` context to access arbitrary local files including WebView cookies and app private data.
  ///
  ///Note that the value of this setting is ignored if the value of [allowUniversalAccessFromFileURLs] is `true`.
  ///
  ///The default value is `false`.
  bool allowFileAccessFromFileURLs;

  ///Sets whether cross-origin requests in the context of a file scheme URL should be allowed to access content from any origin.
  ///This includes access to content from other file scheme URLs or web contexts.
  ///Note that some access such as image HTML elements doesn't follow same-origin rules and isn't affected by this setting.
  ///
  ///Don't enable this setting if you open files that may be created or altered by external sources.
  ///Enabling this setting allows malicious scripts loaded in a `file://` context to launch cross-site scripting attacks,
  ///either accessing arbitrary local files including WebView cookies, app private data or even credentials used on arbitrary web sites.
  ///
  ///The default value is `false`.
  bool allowUniversalAccessFromFileURLs;

  InAppWebViewOptions({
    this.useShouldOverrideUrlLoading = false,
    this.useOnLoadResource = false,
    this.useOnDownloadStart = false,
    this.clearCache = false,
    this.userAgent = "",
    this.applicationNameForUserAgent = "",
    this.javaScriptEnabled = true,
    this.javaScriptCanOpenWindowsAutomatically = false,
    this.mediaPlaybackRequiresUserGesture = true,
    this.minimumFontSize,
    this.verticalScrollBarEnabled = true,
    this.horizontalScrollBarEnabled = true,
    this.resourceCustomSchemes = const [],
    this.contentBlockers = const [],
    this.preferredContentMode = UserPreferredContentMode.RECOMMENDED,
    this.useShouldInterceptAjaxRequest = false,
    this.useShouldInterceptFetchRequest = false,
    this.incognito = false,
    this.cacheEnabled = true,
    this.transparentBackground = false,
    this.disableVerticalScroll = false,
    this.disableHorizontalScroll = false,
    this.disableContextMenu = false,
    this.supportZoom = true,
    this.allowFileAccessFromFileURLs = false,
    this.allowUniversalAccessFromFileURLs = false,
  }) {
    if (this.minimumFontSize == null)
      this.minimumFontSize = Util.isAndroid ? 8 : 0;
    assert(
      !this.resourceCustomSchemes.contains("http") &&
          !this.resourceCustomSchemes.contains("https"),
    );
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
      "clearCache": clearCache,
      "userAgent": userAgent,
      "applicationNameForUserAgent": applicationNameForUserAgent,
      "javaScriptEnabled": javaScriptEnabled,
      "javaScriptCanOpenWindowsAutomatically":
          javaScriptCanOpenWindowsAutomatically,
      "mediaPlaybackRequiresUserGesture": mediaPlaybackRequiresUserGesture,
      "verticalScrollBarEnabled": verticalScrollBarEnabled,
      "horizontalScrollBarEnabled": horizontalScrollBarEnabled,
      "resourceCustomSchemes": resourceCustomSchemes,
      "contentBlockers": contentBlockersMapList,
      "preferredContentMode": preferredContentMode?.toNativeValue(),
      "useShouldInterceptAjaxRequest": useShouldInterceptAjaxRequest,
      "useShouldInterceptFetchRequest": useShouldInterceptFetchRequest,
      "incognito": incognito,
      "cacheEnabled": cacheEnabled,
      "transparentBackground": transparentBackground,
      "disableVerticalScroll": disableVerticalScroll,
      "disableHorizontalScroll": disableHorizontalScroll,
      "disableContextMenu": disableContextMenu,
      "supportZoom": supportZoom,
      "allowFileAccessFromFileURLs": allowFileAccessFromFileURLs,
      "allowUniversalAccessFromFileURLs": allowUniversalAccessFromFileURLs,
    };
  }

  static InAppWebViewOptions fromMap(Map<String, dynamic> map) {
    List<ContentBlocker> contentBlockers = [];
    List<dynamic>? contentBlockersMapList = map["contentBlockers"];
    if (contentBlockersMapList != null) {
      contentBlockersMapList.forEach((contentBlocker) {
        contentBlockers.add(
          ContentBlocker.fromMap(
            Map<String, Map<String, dynamic>>.from(
              Map<String, dynamic>.from(contentBlocker),
            ),
          ),
        );
      });
    }

    var instance = InAppWebViewOptions();
    instance.useShouldOverrideUrlLoading = map["useShouldOverrideUrlLoading"];
    instance.useOnLoadResource = map["useOnLoadResource"];
    instance.useOnDownloadStart = map["useOnDownloadStart"];
    instance.clearCache = map["clearCache"];
    instance.userAgent = map["userAgent"];
    instance.applicationNameForUserAgent = map["applicationNameForUserAgent"];
    instance.javaScriptEnabled = map["javaScriptEnabled"];
    instance.javaScriptCanOpenWindowsAutomatically =
        map["javaScriptCanOpenWindowsAutomatically"];
    instance.mediaPlaybackRequiresUserGesture =
        map["mediaPlaybackRequiresUserGesture"];
    instance.verticalScrollBarEnabled = map["verticalScrollBarEnabled"];
    instance.horizontalScrollBarEnabled = map["horizontalScrollBarEnabled"];
    instance.resourceCustomSchemes = List<String>.from(
      map["resourceCustomSchemes"] ?? [],
    );
    instance.contentBlockers = contentBlockers;
    instance.preferredContentMode = UserPreferredContentMode.fromNativeValue(
      map["preferredContentMode"],
    );
    instance.useShouldInterceptAjaxRequest =
        map["useShouldInterceptAjaxRequest"];
    instance.useShouldInterceptFetchRequest =
        map["useShouldInterceptFetchRequest"];
    instance.incognito = map["incognito"];
    instance.cacheEnabled = map["cacheEnabled"];
    instance.transparentBackground = map["transparentBackground"];
    instance.disableVerticalScroll = map["disableVerticalScroll"];
    instance.disableHorizontalScroll = map["disableHorizontalScroll"];
    instance.disableContextMenu = map["disableContextMenu"];
    instance.supportZoom = map["supportZoom"];
    instance.allowFileAccessFromFileURLs = map["allowFileAccessFromFileURLs"];
    instance.allowUniversalAccessFromFileURLs =
        map["allowUniversalAccessFromFileURLs"];
    return instance;
  }

  @override
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  InAppWebViewOptions copy() {
    return InAppWebViewOptions.fromMap(this.toMap());
  }
}
