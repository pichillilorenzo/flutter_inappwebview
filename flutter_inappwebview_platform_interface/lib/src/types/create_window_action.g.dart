// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_window_action.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the navigation request used by the [PlatformWebViewCreationParams.onCreateWindow] event.
class CreateWindowAction extends NavigationAction {
  ///Use [isDialog] instead.
  @Deprecated('Use isDialog instead')
  bool? androidIsDialog;

  ///Use [windowFeatures] instead.
  @Deprecated('Use windowFeatures instead')
  IOSWKWindowFeatures? iosWindowFeatures;

  ///Indicates if the new window should be a dialog, rather than a full-size window.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool? isDialog;

  ///Window features requested by the webpage.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWindowFeatures](https://developer.apple.com/documentation/webkit/wkwindowfeatures))
  ///- macOS WKWebView ([Official API - WKWindowFeatures](https://developer.apple.com/documentation/webkit/wkwindowfeatures))
  ///- Windows WebView2 ([Official API - ICoreWebView2WindowFeatures](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2windowfeatures?view=webview2-1.0.2210.55))
  WindowFeatures? windowFeatures;

  ///The window id. Used by `WebView` to create a new WebView.
  int windowId;
  CreateWindowAction({
    @Deprecated('Use isDialog instead') this.androidIsDialog,
    @Deprecated('Use windowFeatures instead') this.iosWindowFeatures,
    this.isDialog,
    this.windowFeatures,
    required this.windowId,
    required URLRequest request,
    required bool isForMainFrame,
    @Deprecated('Use hasGesture instead') bool? androidHasGesture,
    bool? hasGesture,
    @Deprecated('Use isRedirect instead') bool? androidIsRedirect,
    bool? isRedirect,
    @Deprecated('Use navigationType instead')
    IOSWKNavigationType? iosWKNavigationType,
    NavigationType? navigationType,
    @Deprecated('Use sourceFrame instead') IOSWKFrameInfo? iosSourceFrame,
    FrameInfo? sourceFrame,
    @Deprecated('Use targetFrame instead') IOSWKFrameInfo? iosTargetFrame,
    FrameInfo? targetFrame,
    bool? shouldPerformDownload,
  }) : super(
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
         shouldPerformDownload: shouldPerformDownload,
       ) {
    isDialog = isDialog ?? androidIsDialog;
    windowFeatures =
        windowFeatures ?? WindowFeatures.fromMap(iosWindowFeatures?.toMap());
  }

  ///Gets a possible [CreateWindowAction] instance from a [Map] value.
  static CreateWindowAction? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = CreateWindowAction(
      request: URLRequest.fromMap(
        map['request']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      )!,
      isForMainFrame: map['isForMainFrame'],
      androidIsDialog: map['isDialog'],
      iosWindowFeatures: IOSWKWindowFeatures.fromMap(
        map['windowFeatures']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      isDialog: map['isDialog'],
      windowFeatures: WindowFeatures.fromMap(
        map['windowFeatures']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      windowId: map['windowId'],
    );
    instance.androidHasGesture = map['hasGesture'];
    instance.hasGesture = map['hasGesture'];
    instance.androidIsRedirect = map['isRedirect'];
    instance.isRedirect = map['isRedirect'];
    instance.iosWKNavigationType = switch (enumMethod ??
        EnumMethod.nativeValue) {
      EnumMethod.nativeValue => IOSWKNavigationType.fromNativeValue(
        map['navigationType'],
      ),
      EnumMethod.value => IOSWKNavigationType.fromValue(map['navigationType']),
      EnumMethod.name => IOSWKNavigationType.byName(map['navigationType']),
    };
    instance.navigationType = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue => NavigationType.fromNativeValue(
        map['navigationType'],
      ),
      EnumMethod.value => NavigationType.fromValue(map['navigationType']),
      EnumMethod.name => NavigationType.byName(map['navigationType']),
    };
    instance.iosSourceFrame = IOSWKFrameInfo.fromMap(
      map['sourceFrame']?.cast<String, dynamic>(),
      enumMethod: enumMethod,
    );
    instance.sourceFrame = FrameInfo.fromMap(
      map['sourceFrame']?.cast<String, dynamic>(),
      enumMethod: enumMethod,
    );
    instance.iosTargetFrame = IOSWKFrameInfo.fromMap(
      map['targetFrame']?.cast<String, dynamic>(),
      enumMethod: enumMethod,
    );
    instance.targetFrame = FrameInfo.fromMap(
      map['targetFrame']?.cast<String, dynamic>(),
      enumMethod: enumMethod,
    );
    instance.shouldPerformDownload = map['shouldPerformDownload'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "request": request.toMap(enumMethod: enumMethod),
      "isForMainFrame": isForMainFrame,
      "hasGesture": hasGesture,
      "isRedirect": isRedirect,
      "navigationType": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => navigationType?.toNativeValue(),
        EnumMethod.value => navigationType?.toValue(),
        EnumMethod.name => navigationType?.name(),
      },
      "sourceFrame": sourceFrame?.toMap(enumMethod: enumMethod),
      "targetFrame": targetFrame?.toMap(enumMethod: enumMethod),
      "shouldPerformDownload": shouldPerformDownload,
      "isDialog": isDialog,
      "windowFeatures": windowFeatures?.toMap(enumMethod: enumMethod),
      "windowId": windowId,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'CreateWindowAction{request: $request, isForMainFrame: $isForMainFrame, hasGesture: $hasGesture, isRedirect: $isRedirect, navigationType: $navigationType, sourceFrame: $sourceFrame, targetFrame: $targetFrame, shouldPerformDownload: $shouldPerformDownload, isDialog: $isDialog, windowFeatures: $windowFeatures, windowId: $windowId}';
  }
}
