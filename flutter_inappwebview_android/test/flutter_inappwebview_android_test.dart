import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('nullable native context-menu titles do not crash', () async {
    ContextMenuItem? clickedItem;
    var configuredActionCalled = false;
    final contextMenu = ContextMenu(
      menuItems: [
        ContextMenuItem(
          id: 7,
          title: 'Configured item',
          action: () {
            configuredActionCalled = true;
          },
        ),
      ],
      onContextMenuActionItemClicked: (item) {
        clickedItem = item;
      },
    );
    final controller = AndroidInAppWebViewController(
      AndroidInAppWebViewControllerCreationParams(
        id: 1,
        webviewParams: PlatformInAppWebViewWidgetCreationParams(
          contextMenu: contextMenu,
        ),
      ),
    );
    addTearDown(controller.dispose);

    await controller.handler!(
      const MethodCall('onContextMenuActionItemClicked', {
        'id': 99,
        'androidId': 99,
        'iosId': null,
        'title': null,
      }),
    );

    expect(clickedItem, isNotNull);
    expect(clickedItem!.title, isEmpty);
    expect(configuredActionCalled, isFalse);

    await controller.handler!(
      const MethodCall('onContextMenuActionItemClicked', {
        'id': 7,
        'androidId': 7,
        'iosId': null,
        'title': null,
      }),
    );

    expect(clickedItem!.title, 'Configured item');
    expect(configuredActionCalled, isTrue);
  });

  test('setBackgroundColor sends lossless ARGB hex values', () async {
    const channel = MethodChannel('com.pichillilorenzo/flutter_inappwebview_2');
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return true;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final controller = AndroidInAppWebViewController(
      const AndroidInAppWebViewControllerCreationParams(id: 2),
    );
    addTearDown(controller.dispose);

    await controller.setBackgroundColor(const Color(0xffffffff));
    await controller.setBackgroundColor(const Color(0x00112233));

    expect(
      calls.map((call) => call.method),
      everyElement('setBackgroundColor'),
    );
    expect(calls[0].arguments, {'color': '#ffffffff'});
    expect(calls[1].arguments, {'color': '#00112233'});
  });
}
