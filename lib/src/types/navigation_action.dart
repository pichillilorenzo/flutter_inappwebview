import '../in_app_webview/webview.dart';
import 'url_request.dart';
import 'navigation_type.dart';
import 'frame_info.dart';

///An object that contains information about an action that causes navigation to occur.
class NavigationAction {
  ///The URL request object associated with the navigation action.
  ///
  ///**NOTE for Android**: If the request is associated to the [WebView.onCreateWindow] event
  ///and the window has been created using JavaScript, [request.url] will be `null`,
  ///the [request.method] is always `GET`, and [request.headers] value is always `null`.
  ///Also, on Android < 21, the [request.method]  is always `GET` and [request.headers] value is always `null`.
  URLRequest request;

  ///Indicates whether the request was made for the main frame.
  ///
  ///**NOTE for Android**: If the request is associated to the [WebView.onCreateWindow] event, this is always `true`.
  ///Also, on Android < 21, this is always `true`.
  bool isForMainFrame;

  ///Use [hasGesture] instead.
  @Deprecated('Use hasGesture instead')
  bool? androidHasGesture;

  ///Gets whether a gesture (such as a click) was associated with the request.
  ///For security reasons in certain situations this method may return `false` even though
  ///the sequence of events which caused the request to be created was initiated by a user
  ///gesture.
  ///
  ///**NOTE**: available only on Android. On Android < 24, this is always `false`.
  bool? hasGesture;

  ///Use [isRedirect] instead.
  @Deprecated('Use isRedirect instead')
  bool? androidIsRedirect;

  ///Gets whether the request was a result of a server-side redirect.
  ///
  ///**NOTE**: available only on Android.
  ///If the request is associated to the [WebView.onCreateWindow] event, this is always `false`.
  ///Also, on Android < 21, this is always `false`.
  bool? isRedirect;

  ///Use [navigationType] instead.
  @Deprecated("Use navigationType instead")
  IOSWKNavigationType? iosWKNavigationType;

  ///The type of action triggering the navigation.
  ///
  ///**NOTE**: available only on iOS.
  NavigationType? navigationType;

  ///Use [sourceFrame] instead.
  @Deprecated("Use sourceFrame instead")
  IOSWKFrameInfo? iosSourceFrame;

  ///The frame that requested the navigation.
  ///
  ///**NOTE**: available only on iOS.
  FrameInfo? sourceFrame;

  ///Use [targetFrame] instead.
  @Deprecated("Use targetFrame instead")
  IOSWKFrameInfo? iosTargetFrame;

  ///The frame in which to display the new content.
  ///
  ///**NOTE**: available only on iOS.
  FrameInfo? targetFrame;

  ///A value indicating whether the web content used a download attribute to indicate that this should be downloaded.
  ///
  ///**NOTE**: available only on iOS.
  bool? shouldPerformDownload;

  NavigationAction(
      {required this.request,
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
        this.shouldPerformDownload}) {
    // ignore: deprecated_member_use_from_same_package
    this.hasGesture = this.hasGesture ?? this.androidHasGesture;
    // ignore: deprecated_member_use_from_same_package
    this.isRedirect = this.isRedirect ?? this.androidIsRedirect;
    this.navigationType = this.navigationType ??
        // ignore: deprecated_member_use_from_same_package
        NavigationType.fromValue(this.iosWKNavigationType?.toValue());
    this.sourceFrame =
    // ignore: deprecated_member_use_from_same_package
    this.sourceFrame ?? FrameInfo.fromMap(this.iosSourceFrame?.toMap());
    this.targetFrame =
    // ignore: deprecated_member_use_from_same_package
    this.targetFrame ?? FrameInfo.fromMap(this.iosTargetFrame?.toMap());
  }

  ///Gets a possible [NavigationAction] instance from a [Map] value.
  static NavigationAction? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return NavigationAction(
        request: URLRequest.fromMap(map["request"].cast<String, dynamic>())!,
        isForMainFrame: map["isForMainFrame"],
        // ignore: deprecated_member_use_from_same_package
        androidHasGesture: map["hasGesture"] ?? map["androidHasGesture"],
        hasGesture: map["hasGesture"],
        // ignore: deprecated_member_use_from_same_package
        androidIsRedirect: map["isRedirect"] ?? map["androidIsRedirect"],
        isRedirect: map["isRedirect"],
        // ignore: deprecated_member_use_from_same_package
        iosWKNavigationType:
        // ignore: deprecated_member_use_from_same_package
        IOSWKNavigationType.fromValue(map["navigationType"]),
        navigationType: NavigationType.fromValue(map["navigationType"]),
        // ignore: deprecated_member_use_from_same_package
        iosSourceFrame:
        // ignore: deprecated_member_use_from_same_package
        IOSWKFrameInfo.fromMap(map["sourceFrame"]?.cast<String, dynamic>()),
        sourceFrame:
        FrameInfo.fromMap(map["sourceFrame"]?.cast<String, dynamic>()),
        // ignore: deprecated_member_use_from_same_package
        iosTargetFrame:
        // ignore: deprecated_member_use_from_same_package
        IOSWKFrameInfo.fromMap(map["targetFrame"]?.cast<String, dynamic>()),
        targetFrame:
        FrameInfo.fromMap(map["targetFrame"]?.cast<String, dynamic>()),
        shouldPerformDownload: map["shouldPerformDownload"]);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "request": request.toMap(),
      "isForMainFrame": isForMainFrame,
      // ignore: deprecated_member_use_from_same_package
      "androidHasGesture": hasGesture ?? androidHasGesture,
      // ignore: deprecated_member_use_from_same_package
      "hasGesture": hasGesture ?? androidHasGesture,
      // ignore: deprecated_member_use_from_same_package
      "isRedirect": isRedirect ?? androidIsRedirect,
      // ignore: deprecated_member_use_from_same_package
      "androidIsRedirect": isRedirect ?? androidIsRedirect,
      "iosWKNavigationType":
      // ignore: deprecated_member_use_from_same_package
      navigationType?.toValue() ?? iosWKNavigationType?.toValue(),
      "navigationType":
      // ignore: deprecated_member_use_from_same_package
      navigationType?.toValue() ?? iosWKNavigationType?.toValue(),
      // ignore: deprecated_member_use_from_same_package
      "iosSourceFrame": sourceFrame?.toMap() ?? iosSourceFrame?.toMap(),
      // ignore: deprecated_member_use_from_same_package
      "sourceFrame": sourceFrame?.toMap() ?? iosSourceFrame?.toMap(),
      // ignore: deprecated_member_use_from_same_package
      "iosTargetFrame": targetFrame?.toMap() ?? iosTargetFrame?.toMap(),
      // ignore: deprecated_member_use_from_same_package
      "targetFrame": targetFrame?.toMap() ?? iosTargetFrame?.toMap(),
      "shouldPerformDownload": shouldPerformDownload
    };
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