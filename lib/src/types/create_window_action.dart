import '../in_app_webview/webview.dart';
import 'navigation_action.dart';
import 'window_features.dart';
import 'url_request.dart';
import 'frame_info.dart';
import 'navigation_type.dart';

///Class that represents the navigation request used by the [WebView.onCreateWindow] event.
class CreateWindowAction extends NavigationAction {
  ///The window id. Used by [WebView] to create a new WebView.
  int windowId;

  ///Use [isDialog] instead.
  @Deprecated("Use isDialog instead")
  bool? androidIsDialog;

  ///Indicates if the new window should be a dialog, rather than a full-size window.
  ///
  ///**NOTE**: available only on Android.
  bool? isDialog;

  ///Use [windowFeatures] instead.
  @Deprecated("Use windowFeatures instead")
  IOSWKWindowFeatures? iosWindowFeatures;

  ///Window features requested by the webpage.
  ///
  ///**NOTE**: available only on iOS.
  WindowFeatures? windowFeatures;

  CreateWindowAction(
      {required this.windowId,
        @Deprecated('Use isDialog instead')
        this.androidIsDialog,
        this.isDialog,
        @Deprecated('Use windowFeatures instead')
        this.iosWindowFeatures,
        this.windowFeatures,
        required URLRequest request,
        required bool isForMainFrame,
        @Deprecated('Use hasGesture instead')
        bool? androidHasGesture,
        @Deprecated('Use isRedirect instead')
        bool? androidIsRedirect,
        bool? hasGesture,
        bool? isRedirect,
        @Deprecated('Use navigationType instead')
        // ignore: deprecated_member_use_from_same_package
        IOSWKNavigationType? iosWKNavigationType,
        NavigationType? navigationType,
        @Deprecated('Use sourceFrame instead')
        // ignore: deprecated_member_use_from_same_package
        IOSWKFrameInfo? iosSourceFrame,
        FrameInfo? sourceFrame,
        @Deprecated('Use targetFrame instead')
        // ignore: deprecated_member_use_from_same_package
        IOSWKFrameInfo? iosTargetFrame,
        FrameInfo? targetFrame})
      : super(
      request: request,
      isForMainFrame: isForMainFrame,
      // ignore: deprecated_member_use_from_same_package
      androidHasGesture: hasGesture ?? androidHasGesture,
      hasGesture: hasGesture ?? androidHasGesture,
      // ignore: deprecated_member_use_from_same_package
      androidIsRedirect: isRedirect ?? androidIsRedirect,
      isRedirect: isRedirect ?? androidIsRedirect,
      // ignore: deprecated_member_use_from_same_package
      iosWKNavigationType:
      // ignore: deprecated_member_use_from_same_package
      IOSWKNavigationType.fromValue(navigationType?.toValue()) ??
          iosWKNavigationType,
      navigationType: navigationType ??
          NavigationType.fromValue(iosWKNavigationType?.toValue()),
      // ignore: deprecated_member_use_from_same_package
      iosSourceFrame:
      // ignore: deprecated_member_use_from_same_package
      IOSWKFrameInfo.fromMap(sourceFrame?.toMap()) ?? iosSourceFrame,
      sourceFrame:
      sourceFrame ?? FrameInfo.fromMap(iosSourceFrame?.toMap()),
      // ignore: deprecated_member_use_from_same_package
      iosTargetFrame:
      // ignore: deprecated_member_use_from_same_package
      IOSWKFrameInfo.fromMap(targetFrame?.toMap()) ?? iosTargetFrame,
      targetFrame:
      targetFrame ?? FrameInfo.fromMap(iosTargetFrame?.toMap())) {
    // ignore: deprecated_member_use_from_same_package
    this.isDialog = this.isDialog ?? this.androidIsDialog;
    this.windowFeatures = this.windowFeatures ??
        // ignore: deprecated_member_use_from_same_package
        WindowFeatures.fromMap(this.iosWindowFeatures?.toMap());
  }

  ///Gets a possible [CreateWindowAction] instance from a [Map] value.
  static CreateWindowAction? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return CreateWindowAction(
        windowId: map["windowId"],
        // ignore: deprecated_member_use_from_same_package
        androidIsDialog: map["isDialog"] ?? map["androidIsDialog"],
        isDialog: map["isDialog"] ?? map["androidIsDialog"],
        // ignore: deprecated_member_use_from_same_package
        iosWindowFeatures: IOSWKWindowFeatures.fromMap(
            map["windowFeatures"]?.cast<String, dynamic>()),
        windowFeatures: WindowFeatures.fromMap(
            map["windowFeatures"]?.cast<String, dynamic>()),
        request: URLRequest.fromMap(map["request"].cast<String, dynamic>())!,
        isForMainFrame: map["isForMainFrame"],
        // ignore: deprecated_member_use_from_same_package
        androidHasGesture: map["hasGesture"],
        hasGesture: map["hasGesture"],
        // ignore: deprecated_member_use_from_same_package
        androidIsRedirect: map["isRedirect"],
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
        FrameInfo.fromMap(map["targetFrame"]?.cast<String, dynamic>()));
  }

  @override
  Map<String, dynamic> toMap() {
    var createWindowActionMap = super.toMap();
    createWindowActionMap.addAll({
      "windowId": windowId,
      // ignore: deprecated_member_use_from_same_package
      "androidIsDialog": isDialog ?? androidIsDialog,
      // ignore: deprecated_member_use_from_same_package
      "isDialog": isDialog ?? androidIsDialog,
      "iosWindowFeatures":
      // ignore: deprecated_member_use_from_same_package
      windowFeatures?.toMap() ?? iosWindowFeatures?.toMap(),
      // ignore: deprecated_member_use_from_same_package
      "windowFeatures": windowFeatures?.toMap() ?? iosWindowFeatures?.toMap(),
    });
    return createWindowActionMap;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}