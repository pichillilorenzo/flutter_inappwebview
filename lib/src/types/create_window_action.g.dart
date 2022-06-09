// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_window_action.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the navigation request used by the [WebView.onCreateWindow] event.
class CreateWindowAction extends NavigationAction {
  ///The window id. Used by [WebView] to create a new WebView.
  int windowId;

  ///Use [isDialog] instead.
  @Deprecated('Use isDialog instead')
  bool? androidIsDialog;

  ///Indicates if the new window should be a dialog, rather than a full-size window.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  bool? isDialog;

  ///Use [windowFeatures] instead.
  @Deprecated('Use windowFeatures instead')
  IOSWKWindowFeatures? iosWindowFeatures;

  ///Window features requested by the webpage.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWindowFeatures](https://developer.apple.com/documentation/webkit/wkwindowfeatures))
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
      bool? hasGesture,
      @Deprecated('Use isRedirect instead')
          bool? androidIsRedirect,
      bool? isRedirect,
      @Deprecated('Use navigationType instead')
          IOSWKNavigationType? iosWKNavigationType,
      NavigationType? navigationType,
      @Deprecated('Use sourceFrame instead')
          IOSWKFrameInfo? iosSourceFrame,
      FrameInfo? sourceFrame,
      @Deprecated('Use targetFrame instead')
          IOSWKFrameInfo? iosTargetFrame,
      FrameInfo? targetFrame,
      bool? shouldPerformDownload})
      : super(
            request: request,
            isForMainFrame: isForMainFrame,
            androidHasGesture: androidHasGesture,
            hasGesture: hasGesture,
            androidIsRedirect: androidIsRedirect,
            isRedirect: isRedirect,
            iosWKNavigationType: iosWKNavigationType,
            navigationType: navigationType,
            iosSourceFrame: iosSourceFrame,
            sourceFrame: sourceFrame,
            iosTargetFrame: iosTargetFrame,
            targetFrame: targetFrame,
            shouldPerformDownload: shouldPerformDownload) {
    isDialog = isDialog ?? androidIsDialog;
    windowFeatures =
        windowFeatures ?? WindowFeatures.fromMap(iosWindowFeatures?.toMap());
  }

  ///Gets a possible [CreateWindowAction] instance from a [Map] value.
  static CreateWindowAction? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = CreateWindowAction(
      request: URLRequest.fromMap(map['request']?.cast<String, dynamic>())!,
      isForMainFrame: map['isForMainFrame'],
      windowId: map['windowId'],
      androidIsDialog: map['isDialog'],
      isDialog: map['isDialog'],
      iosWindowFeatures: IOSWKWindowFeatures.fromMap(
          map['windowFeatures']?.cast<String, dynamic>()),
      windowFeatures: WindowFeatures.fromMap(
          map['windowFeatures']?.cast<String, dynamic>()),
    );
    instance.androidHasGesture = map['hasGesture'];
    instance.hasGesture = map['hasGesture'];
    instance.androidIsRedirect = map['isRedirect'];
    instance.isRedirect = map['isRedirect'];
    instance.iosWKNavigationType =
        IOSWKNavigationType.fromNativeValue(map['navigationType']);
    instance.navigationType =
        NavigationType.fromNativeValue(map['navigationType']);
    instance.iosSourceFrame =
        IOSWKFrameInfo.fromMap(map['sourceFrame']?.cast<String, dynamic>());
    instance.sourceFrame =
        FrameInfo.fromMap(map['sourceFrame']?.cast<String, dynamic>());
    instance.iosTargetFrame =
        IOSWKFrameInfo.fromMap(map['targetFrame']?.cast<String, dynamic>());
    instance.targetFrame =
        FrameInfo.fromMap(map['targetFrame']?.cast<String, dynamic>());
    instance.shouldPerformDownload = map['shouldPerformDownload'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "request": request.toMap(),
      "isForMainFrame": isForMainFrame,
      "hasGesture": hasGesture,
      "isRedirect": isRedirect,
      "navigationType": navigationType?.toNativeValue(),
      "sourceFrame": sourceFrame?.toMap(),
      "targetFrame": targetFrame?.toMap(),
      "shouldPerformDownload": shouldPerformDownload,
      "windowId": windowId,
      "isDialog": isDialog,
      "windowFeatures": windowFeatures?.toMap(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'CreateWindowAction{request: $request, isForMainFrame: $isForMainFrame, hasGesture: $hasGesture, isRedirect: $isRedirect, navigationType: $navigationType, sourceFrame: $sourceFrame, targetFrame: $targetFrame, shouldPerformDownload: $shouldPerformDownload, windowId: $windowId, isDialog: $isDialog, windowFeatures: $windowFeatures}';
  }
}
