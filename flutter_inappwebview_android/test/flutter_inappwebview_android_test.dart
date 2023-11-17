import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android_platform_interface.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterInappwebviewAndroidPlatform
    with MockPlatformInterfaceMixin
    implements InAppWebViewFlutterAndroid {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final InAppWebViewFlutterAndroid initialPlatform = InAppWebViewFlutterAndroid.instance;

  test('$MethodChannelInAppWebViewFlutterAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelInAppWebViewFlutterAndroid>());
  });

  test('getPlatformVersion', () async {
    FlutterInappwebviewAndroid flutterInappwebviewAndroidPlugin = FlutterInappwebviewAndroid();
    MockFlutterInappwebviewAndroidPlatform fakePlatform = MockFlutterInappwebviewAndroidPlatform();
    InAppWebViewFlutterAndroid.instance = fakePlatform;

    expect(await flutterInappwebviewAndroidPlugin.getPlatformVersion(), '42');
  });
}
