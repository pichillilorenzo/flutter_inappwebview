import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import '../test/test_class_2.dart';
import 'test_enum.dart';

part 'test_class.g.dart';

///Custom docs
// @ExchangeableObject()
@SupportedPlatforms(platforms: [
  AndroidPlatform(
      apiName: "TestClass",
      available: "24",
      note: "[test1] is always `null`."
  ),
  IOSPlatform(
      apiName: "TestClass",
      available: "15.0",
      note: "[test2] is always `null`."
  ),
  WebPlatform(),
])
class TestClass_ extends TestClass3_ {
  ///Docs 1
  String test1;
  ///Docs 2
  List<TestClass2_> test2;

  List<Color?>? colors;

  Function? onLoad;

  ///Docs 3
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName: "WebSettings.setDisabledActionModeMenuItems",
        apiUrl: "https://developer.android.com/reference/android/webkit/WebSettings#setDisabledActionModeMenuItems(int)",
        available: "24"
    )
  ])
  List<ActionModeMenuItem_?> actionModeMenuItem;

  @ExchangeableObjectProperty(
    serializer: Util.serializeTest,
    deserializer: Util.deserializeTest
  )
  int test = 0;

  DateTime? validNotAfterDate;

  TestClass_({required String asd, this.test1 = "asdasd", required this.test2,
    this.actionModeMenuItem = const [ActionModeMenuItem_.MENU_ITEM_NONE]}) : super(asd: asd);

}

@ExchangeableObject()
class TestClass3_ {
  String asd;

  Function? onLoad;
  TestClass3_({required this.asd});
}

///Class that represents the navigation request used by the [WebView.onCreateWindow] event.
@ExchangeableObject()
class CreateWindowAction_ extends NavigationAction_ {
  ///The window id. Used by [WebView] to create a new WebView.
  int windowId;

  ///Use [isDialog] instead.
  @Deprecated("Use isDialog instead")
  bool? androidIsDialog;

  ///Indicates if the new window should be a dialog, rather than a full-size window.
  @SupportedPlatforms(
      platforms: [
        AndroidPlatform()
      ]
  )
  bool? isDialog;

  CreateWindowAction_(
      {required this.windowId,
        @Deprecated('Use isDialog instead')
        this.androidIsDialog,
        this.isDialog,
        required bool isForMainFrame,
        @Deprecated('Use hasGesture instead')
        bool? androidHasGesture,
        @Deprecated('Use isRedirect instead')
        bool? androidIsRedirect,
        bool? hasGesture,
        bool? isRedirect,
        @Deprecated('Use navigationType instead')
        // ignore: deprecated_member_use_from_same_package
        TestClass3_? iosWKNavigationType,
        TestClass3_? navigationType}) : super(
      isForMainFrame: isForMainFrame,
    hasGesture: hasGesture,
    isRedirect: isRedirect,
    navigationType: navigationType
  );
}

///An object that contains information about an action that causes navigation to occur.
@ExchangeableObject()
class NavigationAction_ {
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
  @SupportedPlatforms(
      platforms: [
        AndroidPlatform(
            available: "21",
            apiName: "WebResourceRequest.hasGesture",
            apiUrl: "https://developer.android.com/reference/android/webkit/WebResourceRequest#hasGesture()",
            note: "On Android < 21, this is always `false`"
        )
      ]
  )
  bool? hasGesture;

  ///Use [isRedirect] instead.
  @Deprecated('Use isRedirect instead')
  bool? androidIsRedirect;

  ///Gets whether the request was a result of a server-side redirect.
  ///
  ///**NOTE**: If the request is associated to the [WebView.onCreateWindow] event, this is always `false`.
  ///Also, on Android < 21, this is always `false`.
  @SupportedPlatforms(
      platforms: [
        AndroidPlatform(
            available: "21",
            apiName: "WebResourceRequest.isRedirect",
            apiUrl: "https://developer.android.com/reference/android/webkit/WebResourceRequest#isRedirect()"
        )
      ]
  )
  bool? isRedirect;

  ///Use [navigationType] instead.
  @Deprecated("Use navigationType instead")
  TestClass3_? iosWKNavigationType;

  ///The type of action triggering the navigation.
  ///
  ///**NOTE**: available only on iOS.
  TestClass3_? navigationType;

  ///A value indicating whether the web content used a download attribute to indicate that this should be downloaded.
  ///
  ///**NOTE**: available only on iOS.
  bool? shouldPerformDownload;

  NavigationAction_(
      {required this.isForMainFrame,
        @Deprecated('Use hasGesture instead') this.androidHasGesture,
        this.hasGesture,
        @Deprecated('Use isRedirect instead') this.androidIsRedirect,
        this.isRedirect,
        @Deprecated("Use navigationType instead") this.iosWKNavigationType,
        this.navigationType,
        this.shouldPerformDownload});
}

class Util {
  static String serializeTest(int source) {
    return source.toString();
  }

  static int deserializeTest(String source) {
    return int.parse(source);
  }
}