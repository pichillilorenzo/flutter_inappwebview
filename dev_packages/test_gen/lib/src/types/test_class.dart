import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import '../test/test_class_2.dart';
import 'test_enum.dart';

part 'test_class.g.dart';

///Custom docs
@ExchangeableObject()
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
class TestClass_ extends TestClass3 {
  ///Docs 1
  String test1;
  ///Docs 2
  List<TestClass2_> test2;

  List<Color?>? colors;

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

class TestClass3 {
  String asd;

  TestClass3({required this.asd});
}

class Util {
  static String serializeTest(int source) {
    return source.toString();
  }

  static int deserializeTest(String source) {
    return int.parse(source);
  }
}