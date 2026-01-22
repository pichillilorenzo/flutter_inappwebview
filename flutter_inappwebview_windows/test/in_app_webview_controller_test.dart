import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/in_app_webview.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/in_app_webview_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName = 'com.pichillilorenzo/flutter_inappwebview_1';
  late WindowsInAppWebViewController controller;
  late MethodChannel channel;
  MethodCall? lastMethodCall;

  setUp(() {
    channel = const MethodChannel(channelName);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      lastMethodCall = call;
      switch (call.method) {
        case 'getFrameId':
          return 42;
        case 'getMemoryUsageTargetLevel':
          return MemoryUsageTargetLevel.LOW.toNativeValue();
        case 'getFavicon':
          return [1, 2, 3];
        case 'showSaveAsUI':
          return SaveAsUIResult.CANCELLED.toNativeValue();
      }
      return null;
    });

    controller = WindowsInAppWebViewController(
      WindowsInAppWebViewControllerCreationParams(
        id: 1,
        webviewParams: WindowsInAppWebViewWidgetCreationParams(),
      ),
    );
  });

  tearDown(() {
    controller.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    lastMethodCall = null;
  });

  test('getFrameId uses method channel', () async {
    final result = await controller.getFrameId();

    expect(lastMethodCall?.method, 'getFrameId');
    expect(result, 42);
  });

  test('getMemoryUsageTargetLevel uses method channel', () async {
    final result = await controller.getMemoryUsageTargetLevel();

    expect(lastMethodCall?.method, 'getMemoryUsageTargetLevel');
    expect(result, MemoryUsageTargetLevel.LOW);
  });

  test('setMemoryUsageTargetLevel uses method channel', () async {
    await controller.setMemoryUsageTargetLevel(MemoryUsageTargetLevel.NORMAL);

    expect(lastMethodCall?.method, 'setMemoryUsageTargetLevel');
    final args = (lastMethodCall?.arguments as Map?)?.cast<String, dynamic>();
    expect(args?['level'], MemoryUsageTargetLevel.NORMAL.toNativeValue());
  });

  test('getFavicon uses method channel', () async {
    final result = await controller.getFavicon(
      url: WebUri('https://example.com/favicon.ico'),
    );

    expect(lastMethodCall?.method, 'getFavicon');
    final args = (lastMethodCall?.arguments as Map?)?.cast<String, dynamic>();
    expect(args?['url'], 'https://example.com/favicon.ico');
    expect(args?['faviconImageFormat'], FaviconImageFormat.PNG.toNativeValue());
    expect(result, isNotNull);
    expect(result?.toList(), [1, 2, 3]);
  });

  test('showSaveAsUI uses method channel', () async {
    final result = await controller.showSaveAsUI();

    expect(lastMethodCall?.method, 'showSaveAsUI');
    expect(result, SaveAsUIResult.CANCELLED);
  });

  test('handles new WebView2 events', () async {
    FaviconChangedRequest? faviconRequest;
    LaunchingExternalUriSchemeRequest? launchingRequest;
    NotificationReceivedRequest? notificationRequest;
    SaveAsUIShowingRequest? saveAsRequest;
    SaveFileSecurityCheckStartingRequest? saveFileRequest;
    ScreenCaptureStartingRequest? screenCaptureRequest;

    final eventController = WindowsInAppWebViewController(
      WindowsInAppWebViewControllerCreationParams(
        id: 2,
        webviewParams: WindowsInAppWebViewWidgetCreationParams(
          onFaviconChanged: (controller, request) {
            faviconRequest = request;
          },
          onLaunchingExternalUriScheme: (controller, request) async {
            launchingRequest = request;
            return LaunchingExternalUriSchemeResponse(cancel: true);
          },
          onNotificationReceived: (controller, request) async {
            notificationRequest = request;
            return NotificationReceivedResponse(handled: true);
          },
          onSaveAsUIShowing: (controller, request) async {
            saveAsRequest = request;
            return SaveAsUIShowingResponse(cancel: true);
          },
          onSaveFileSecurityCheckStarting: (controller, request) async {
            saveFileRequest = request;
            return SaveFileSecurityCheckStartingResponse(cancelSave: true);
          },
          onScreenCaptureStarting: (controller, request) async {
            screenCaptureRequest = request;
            return ScreenCaptureStartingResponse(cancel: true, handled: true);
          },
        ),
      ),
    );

    await eventController.handleMethod(
      const MethodCall('onFaviconChanged', {
        'url': 'https://example.com',
        'icon': [1, 2, 3],
      }),
    );

    final launchingResult = await eventController.handleMethod(
      const MethodCall('onLaunchingExternalUriScheme', {
        'uri': 'app://example',
        'initiatingOrigin': 'https://example.com',
        'isUserInitiated': true,
      }),
    );

    final notificationResult = await eventController.handleMethod(
      const MethodCall('onNotificationReceived', {
        'senderOrigin': 'https://example.com',
        'notification': {'title': 'Hello'},
      }),
    );

    final saveAsResult = await eventController.handleMethod(
      const MethodCall('onSaveAsUIShowing', {
        'contentMimeType': 'text/plain',
        'cancel': false,
        'suppressDefaultDialog': false,
      }),
    );

    final saveFileResult = await eventController.handleMethod(
      const MethodCall('onSaveFileSecurityCheckStarting', {
        'documentOriginUri': 'https://example.com',
        'fileExtension': '.txt',
        'filePath': 'C:/tmp/test.txt',
        'cancelSave': false,
        'suppressDefaultPolicy': false,
      }),
    );

    final screenCaptureResult = await eventController.handleMethod(
      const MethodCall('onScreenCaptureStarting', {
        'cancel': false,
        'handled': false,
      }),
    );

    expect(faviconRequest?.url?.toString(), 'https://example.com');
    expect(faviconRequest?.icon, isNotNull);

    expect(launchingRequest?.uri.toString(), 'app://example');
    expect((launchingResult as Map)['cancel'], true);

    expect(notificationRequest?.notification.title, 'Hello');
    expect((notificationResult as Map)['handled'], true);

    expect(saveAsRequest?.contentMimeType, 'text/plain');
    expect((saveAsResult as Map)['cancel'], true);

    expect(saveFileRequest?.fileExtension, '.txt');
    expect((saveFileResult as Map)['cancelSave'], true);

    expect(screenCaptureRequest?.handled, false);
    expect((screenCaptureResult as Map)['cancel'], true);
    expect((screenCaptureResult as Map)['handled'], true);

    eventController.dispose();
  });
}
