import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'url_request.dart';
import 'navigation_type.dart';
import 'frame_info.dart';
import 'enum_method.dart';

part 'navigation_action.g.dart';

///An object that contains information about an action that causes navigation to occur.
@ExchangeableObject()
class NavigationAction_ {
  ///The URL request object associated with the navigation action.
  ///
  ///**NOTE for Android**: If the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event
  ///and the window has been created using JavaScript, [request.url] will be `null`,
  ///the [request.method] is always `GET`, and [request.headers] value is always `null`.
  ///Also, on Android < 21, the [request.method]  is always `GET` and [request.headers] value is always `null`.
  URLRequest_ request;

  ///Indicates whether the request was made for the main frame.
  ///
  ///**NOTE for Android and Windows**: If the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event, this is always `true`.
  ///Also, on Android < 21, this is always `true`.
  bool isForMainFrame;

  ///Use [hasGesture] instead.
  @Deprecated('Use hasGesture instead')
  bool? androidHasGesture;

  ///Gets whether a gesture (such as a click) was associated with the request.
  ///For security reasons in certain situations this method may return `false` even though
  ///the sequence of events which caused the request to be created was initiated by a user
  ///gesture.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "21",
        apiName: "WebResourceRequest.hasGesture",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebResourceRequest#hasGesture()",
        note: "On Android < 21, this is always `false`",
      ),
      WindowsPlatform(
        note:
            "Available only if the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event",
      ),
    ],
  )
  bool? hasGesture;

  ///Use [isRedirect] instead.
  @Deprecated('Use isRedirect instead')
  bool? androidIsRedirect;

  ///Gets whether the request was a result of a server-side redirect.
  ///
  ///**NOTE**: If the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event, this is always `false`.
  ///Also, on Android < 21, this is always `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "21",
        apiName: "WebResourceRequest.isRedirect",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebResourceRequest#isRedirect()",
      ),
      WindowsPlatform(),
    ],
  )
  bool? isRedirect;

  ///Use [navigationType] instead.
  @Deprecated("Use navigationType instead")
  IOSWKNavigationType_? iosWKNavigationType;

  ///The type of action triggering the navigation.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKNavigationAction.navigationType",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/1401914-navigationtype",
      ),
      MacOSPlatform(
        apiName: "WKNavigationAction.navigationType",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/1401914-navigationtype",
      ),
      WindowsPlatform(),
    ],
  )
  NavigationType_? navigationType;

  ///Use [sourceFrame] instead.
  @Deprecated("Use sourceFrame instead")
  IOSWKFrameInfo_? iosSourceFrame;

  ///The frame that requested the navigation.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKNavigationAction.sourceFrame",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/1401926-sourceframe",
      ),
      MacOSPlatform(
        apiName: "WKNavigationAction.sourceFrame",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/1401926-sourceframe",
      ),
    ],
  )
  FrameInfo_? sourceFrame;

  ///Use [targetFrame] instead.
  @Deprecated("Use targetFrame instead")
  IOSWKFrameInfo_? iosTargetFrame;

  ///The frame in which to display the new content.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKNavigationAction.targetFrame",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/1401918-targetframe",
      ),
      MacOSPlatform(
        apiName: "WKNavigationAction.targetFrame",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/1401918-targetframe",
      ),
    ],
  )
  FrameInfo_? targetFrame;

  ///A value indicating whether the web content used a download attribute to indicate that this should be downloaded.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "14.5",
        apiName: "WKNavigationAction.shouldPerformDownload",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/3727357-shouldperformdownload",
      ),
      MacOSPlatform(
        available: "11.3",
        apiName: "WKNavigationAction.shouldPerformDownload",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/3727357-shouldperformdownload",
      ),
    ],
  )
  bool? shouldPerformDownload;

  NavigationAction_({
    required this.request,
    required this.isForMainFrame,
    @Deprecated('Use hasGesture instead') this.androidHasGesture,
    this.hasGesture,
    @Deprecated('Use isRedirect instead') this.androidIsRedirect,
    this.isRedirect,
    @Deprecated("Use navigationType instead") this.iosWKNavigationType,
    this.navigationType,
    @Deprecated("Use sourceFrame instead") this.iosSourceFrame,
    this.sourceFrame,
    @Deprecated("Use targetFrame instead") this.iosTargetFrame,
    this.targetFrame,
    this.shouldPerformDownload,
  });
}
