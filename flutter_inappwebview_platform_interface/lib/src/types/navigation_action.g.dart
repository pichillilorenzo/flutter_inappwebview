// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_action.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///An object that contains information about an action that causes navigation to occur.
class NavigationAction {
  ///Use [hasGesture] instead.
  @Deprecated('Use hasGesture instead')
  bool? androidHasGesture;

  ///Use [isRedirect] instead.
  @Deprecated('Use isRedirect instead')
  bool? androidIsRedirect;

  ///Gets whether a gesture (such as a click) was associated with the request.
  ///For security reasons in certain situations this method may return `false` even though
  ///the sequence of events which caused the request to be created was initiated by a user
  ///gesture.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - WebResourceRequest.hasGesture](https://developer.android.com/reference/android/webkit/WebResourceRequest#hasGesture())):
  ///    - On Android < 21, this is always `false`
  ///- Windows WebView2:
  ///    - Available only if the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event
  bool? hasGesture;

  ///Use [sourceFrame] instead.
  @Deprecated('Use sourceFrame instead')
  IOSWKFrameInfo? iosSourceFrame;

  ///Use [targetFrame] instead.
  @Deprecated('Use targetFrame instead')
  IOSWKFrameInfo? iosTargetFrame;

  ///Use [navigationType] instead.
  @Deprecated('Use navigationType instead')
  IOSWKNavigationType? iosWKNavigationType;

  ///Indicates whether the request was made for the main frame.
  ///
  ///**NOTE for Android and Windows**: If the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event, this is always `true`.
  ///Also, on Android < 21, this is always `true`.
  bool isForMainFrame;

  ///Gets whether the request was a result of a server-side redirect.
  ///
  ///**NOTE**: If the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event, this is always `false`.
  ///Also, on Android < 21, this is always `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - WebResourceRequest.isRedirect](https://developer.android.com/reference/android/webkit/WebResourceRequest#isRedirect()))
  ///- Windows WebView2
  bool? isRedirect;

  ///The type of action triggering the navigation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKNavigationAction.navigationType](https://developer.apple.com/documentation/webkit/wknavigationaction/1401914-navigationtype))
  ///- macOS WKWebView ([Official API - WKNavigationAction.navigationType](https://developer.apple.com/documentation/webkit/wknavigationaction/1401914-navigationtype))
  ///- Windows WebView2
  NavigationType? navigationType;

  ///The URL request object associated with the navigation action.
  ///
  ///**NOTE for Android**: If the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event
  ///and the window has been created using JavaScript, [request.url] will be `null`,
  ///the [request.method] is always `GET`, and [request.headers] value is always `null`.
  ///Also, on Android < 21, the [request.method]  is always `GET` and [request.headers] value is always `null`.
  URLRequest request;

  ///A value indicating whether the web content used a download attribute to indicate that this should be downloaded.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.5+ ([Official API - WKNavigationAction.shouldPerformDownload](https://developer.apple.com/documentation/webkit/wknavigationaction/3727357-shouldperformdownload))
  ///- macOS WKWebView 11.3+ ([Official API - WKNavigationAction.shouldPerformDownload](https://developer.apple.com/documentation/webkit/wknavigationaction/3727357-shouldperformdownload))
  bool? shouldPerformDownload;

  ///The frame that requested the navigation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKNavigationAction.sourceFrame](https://developer.apple.com/documentation/webkit/wknavigationaction/1401926-sourceframe))
  ///- macOS WKWebView ([Official API - WKNavigationAction.sourceFrame](https://developer.apple.com/documentation/webkit/wknavigationaction/1401926-sourceframe))
  FrameInfo? sourceFrame;

  ///The frame in which to display the new content.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKNavigationAction.targetFrame](https://developer.apple.com/documentation/webkit/wknavigationaction/1401918-targetframe))
  ///- macOS WKWebView ([Official API - WKNavigationAction.targetFrame](https://developer.apple.com/documentation/webkit/wknavigationaction/1401918-targetframe))
  FrameInfo? targetFrame;
  NavigationAction(
      {@Deprecated('Use hasGesture instead') this.androidHasGesture,
      @Deprecated('Use isRedirect instead') this.androidIsRedirect,
      this.hasGesture,
      @Deprecated('Use sourceFrame instead') this.iosSourceFrame,
      @Deprecated('Use targetFrame instead') this.iosTargetFrame,
      @Deprecated('Use navigationType instead') this.iosWKNavigationType,
      required this.isForMainFrame,
      this.isRedirect,
      this.navigationType,
      required this.request,
      this.shouldPerformDownload,
      this.sourceFrame,
      this.targetFrame}) {
    hasGesture = hasGesture ?? androidHasGesture;
    isRedirect = isRedirect ?? androidIsRedirect;
    sourceFrame = sourceFrame ?? FrameInfo.fromMap(iosSourceFrame?.toMap());
    targetFrame = targetFrame ?? FrameInfo.fromMap(iosTargetFrame?.toMap());
    navigationType = navigationType ??
        NavigationType.fromNativeValue(iosWKNavigationType?.toNativeValue());
  }

  ///Gets a possible [NavigationAction] instance from a [Map] value.
  static NavigationAction? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = NavigationAction(
      androidHasGesture: map['hasGesture'],
      androidIsRedirect: map['isRedirect'],
      hasGesture: map['hasGesture'],
      iosSourceFrame: IOSWKFrameInfo.fromMap(
          map['sourceFrame']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      iosTargetFrame: IOSWKFrameInfo.fromMap(
          map['targetFrame']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      iosWKNavigationType: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          IOSWKNavigationType.fromNativeValue(map['navigationType']),
        EnumMethod.value =>
          IOSWKNavigationType.fromValue(map['navigationType']),
        EnumMethod.name => IOSWKNavigationType.byName(map['navigationType'])
      },
      isForMainFrame: map['isForMainFrame'],
      isRedirect: map['isRedirect'],
      navigationType: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          NavigationType.fromNativeValue(map['navigationType']),
        EnumMethod.value => NavigationType.fromValue(map['navigationType']),
        EnumMethod.name => NavigationType.byName(map['navigationType'])
      },
      request: URLRequest.fromMap(map['request']?.cast<String, dynamic>(),
          enumMethod: enumMethod)!,
      shouldPerformDownload: map['shouldPerformDownload'],
      sourceFrame: FrameInfo.fromMap(
          map['sourceFrame']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      targetFrame: FrameInfo.fromMap(
          map['targetFrame']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "hasGesture": hasGesture,
      "isForMainFrame": isForMainFrame,
      "isRedirect": isRedirect,
      "navigationType": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => navigationType?.toNativeValue(),
        EnumMethod.value => navigationType?.toValue(),
        EnumMethod.name => navigationType?.name()
      },
      "request": request.toMap(enumMethod: enumMethod),
      "shouldPerformDownload": shouldPerformDownload,
      "sourceFrame": sourceFrame?.toMap(enumMethod: enumMethod),
      "targetFrame": targetFrame?.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'NavigationAction{hasGesture: $hasGesture, isForMainFrame: $isForMainFrame, isRedirect: $isRedirect, navigationType: $navigationType, request: $request, shouldPerformDownload: $shouldPerformDownload, sourceFrame: $sourceFrame, targetFrame: $targetFrame}';
  }
}
