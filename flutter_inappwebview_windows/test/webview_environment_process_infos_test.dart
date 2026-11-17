import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late WindowsWebViewEnvironment environment;
  late MethodChannel channel;
  const managerChannel = MethodChannel(
    'com.pichillilorenzo/flutter_webview_environment',
  );

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    messenger.setMockMethodCallHandler(managerChannel, (call) async {
      expect(call.method, 'create');
      return true;
    });
    environment = await WindowsWebViewEnvironment.static().create();
    channel = MethodChannel(
      'com.pichillilorenzo/flutter_webview_environment_${environment.id}',
    );
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockMethodCallHandler(managerChannel, null);
    environment.disposeChannel();
    debugDefaultTargetPlatformOverride = null;
  });

  TypeMatcher<PlatformException> hasCode(String code) =>
      isA<PlatformException>().having((e) => e.code, 'code', code);

  test(
    'only a successful empty native snapshot becomes an empty list',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'getProcessInfos');
        expect(call.arguments, isEmpty);
        return <Object?>[];
      });
      expect(await environment.getProcessInfos(), isEmpty);
    },
  );

  test('a null native snapshot is unavailable, not zero processes', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    await expectLater(
      environment.getProcessInfos(),
      throwsA(hasCode('process_info_collection_failed')),
    );
  });

  test('a non-list native snapshot is a collection error', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => {'invalid': true});
    await expectLater(
      environment.getProcessInfos(),
      throwsA(hasCode('process_info_collection_failed')),
    );
  });

  for (final invalid in <Object?>[
    null,
    'not a process map',
    <String, Object?>{},
    {'kind': 999, 'processId': 22},
    {'kind': 1, 'processId': 'invalid'},
    {'kind': 1, 'frameInfos': 'invalid'},
  ]) {
    test(
      'invalid native item $invalid cannot return a partial snapshot',
      () async {
        messenger.setMockMethodCallHandler(
          channel,
          (_) async => [
            {'kind': 1, 'processId': 321, 'frameInfos': null},
            invalid,
          ],
        );
        await expectLater(
          environment.getProcessInfos(),
          throwsA(
            hasCode('process_info_collection_failed').having(
              (e) => e.details,
              'decode stage',
              {'stage': 'methodChannel.decode'},
            ),
          ),
        );
      },
    );
  }

  test(
    'an environment without a channel cannot report an empty snapshot',
    () async {
      final uncreated = WindowsWebViewEnvironment(
        const WindowsWebViewEnvironmentCreationParams(),
      );
      await expectLater(
        uncreated.getProcessInfos(),
        throwsA(hasCode('webview_environment_unavailable')),
      );
    },
  );

  test('a disposed environment cannot report an empty snapshot', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'dispose');
      return null;
    });
    await environment.dispose();
    await expectLater(
      environment.getProcessInfos(),
      throwsA(hasCode('webview_environment_unavailable')),
    );
  });

  for (final code in [
    'process_info_unsupported',
    'webview_environment_unavailable',
    'process_info_collection_failed',
  ]) {
    test('$code preserves native stage and signed HRESULT', () async {
      const details = {
        'stage': 'GetProcessExtendedInfos.callback',
        'hresult': -2147467259,
      };
      messenger.setMockMethodCallHandler(channel, (_) async {
        throw PlatformException(
          code: code,
          message: 'native error',
          details: details,
        );
      });
      await expectLater(
        environment.getProcessInfos(),
        throwsA(hasCode(code).having((e) => e.details, 'details', details)),
      );
    });
  }

  test('a missing native implementation remains an error', () async {
    await expectLater(
      environment.getProcessInfos(),
      throwsA(isA<MissingPluginException>()),
    );
  });

  test('successful process snapshots preserve optional fields', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => [
        {'kind': 1, 'processId': 321, 'frameInfos': null},
        {'kind': 2, 'processId': null, 'frameInfos': <Object?>[]},
      ],
    );
    final result = await environment.getProcessInfos();
    expect(result, hasLength(2));
    expect(result[0].processId, 321);
    expect(result[0].frameInfos, isNull);
    expect(result[1].processId, isNull);
    expect(result[1].frameInfos, isEmpty);
  });
}
