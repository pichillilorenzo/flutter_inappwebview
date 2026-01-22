import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_windows/src/find_interaction/find_interaction_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName =
      'com.pichillilorenzo/flutter_inappwebview_find_interaction_1';
  const testQuery = 'Flutter';

  late WindowsFindInteractionController controller;
  late MethodChannel channel;
  MethodCall? lastMethodCall;

  setUp(() {
    channel = const MethodChannel(channelName);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          lastMethodCall = call;
          return null;
        });

    controller = WindowsFindInteractionController(
      const WindowsFindInteractionControllerCreationParams(),
    );
    controller.init(1);
  });

  tearDown(() {
    controller.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    lastMethodCall = null;
  });

  test('test_native_find_all', () async {
    await controller.findAll(find: testQuery);

    expect(lastMethodCall?.method, 'findAll');
    expect((lastMethodCall?.arguments as Map)['find'], testQuery);
  });

  test('test_native_find_next', () async {
    await controller.findNext(forward: true);

    expect(lastMethodCall?.method, 'findNext');
    expect((lastMethodCall?.arguments as Map)['forward'], true);
  });

  test('test_native_find_previous', () async {
    await controller.findNext(forward: false);

    expect(lastMethodCall?.method, 'findNext');
    expect((lastMethodCall?.arguments as Map)['forward'], false);
  });

  test('test_native_find_clear', () async {
    await controller.clearMatches();

    expect(lastMethodCall?.method, 'clearMatches');
  });

  test('test_set_search_text', () async {
    const searchText = 'inappwebview';

    await controller.setSearchText(searchText);

    expect(lastMethodCall?.method, 'setSearchText');
    expect((lastMethodCall?.arguments as Map)['searchText'], searchText);
  });

  test('test_get_search_text', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          lastMethodCall = call;
          if (call.method == 'getSearchText') {
            return testQuery;
          }
          return null;
        });

    final result = await controller.getSearchText();

    expect(lastMethodCall?.method, 'getSearchText');
    expect(result, testQuery);
  });

  test('test_get_active_find_session', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          lastMethodCall = call;
          if (call.method == 'getActiveFindSession') {
            return {
              'highlightedResultIndex': 1,
              'resultCount': 3,
              'searchResultDisplayStyle': 0,
            };
          }
          return null;
        });

    final result = await controller.getActiveFindSession();

    expect(lastMethodCall?.method, 'getActiveFindSession');
    expect(result?.highlightedResultIndex, 1);
    expect(result?.resultCount, 3);
    expect(result?.searchResultDisplayStyle.name(), 'CURRENT_AND_TOTAL');
  });

  test('test_set_find_options', () async {
    final options = FindOptions(
      findTerm: 'example',
      shouldMatchCase: true,
      shouldHighlightAllMatches: true,
    );

    await controller.setFindOptions(options: options);

    expect(lastMethodCall?.method, 'setFindOptions');
    final args = (lastMethodCall?.arguments as Map?)?.cast<String, dynamic>();
    expect(args?['options']['findTerm'], 'example');
    expect(args?['options']['shouldMatchCase'], true);
    expect(args?['options']['shouldHighlightAllMatches'], true);
  });

  test('test_static_factory', () {
    final instanceA = WindowsFindInteractionController.static();
    final instanceB = WindowsFindInteractionController.static();

    expect(identical(instanceA, instanceB), true);
  });
}
