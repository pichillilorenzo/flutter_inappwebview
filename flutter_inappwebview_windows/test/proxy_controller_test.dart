import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_windows/src/proxy_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WindowsProxyController controller;
  late List<MethodCall> log;

  setUp(() {
    log = [];
    controller = WindowsProxyController.static();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(
          'com.pichillilorenzo/flutter_inappwebview_proxycontroller'),
      (call) async {
        log.add(call);
        return true;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(
          'com.pichillilorenzo/flutter_inappwebview_proxycontroller'),
      null,
    );
  });

  group('WindowsProxyController', () {
    test('setProxyOverride sends correct method call', () async {
      await controller.setProxyOverride(
        settings: ProxySettings(
          proxyRules: [ProxyRule(url: 'http://proxy.example.com:8080')],
        ),
      );

      expect(log, hasLength(1));
      expect(log.first.method, 'setProxyOverride');

      final args = log.first.arguments as Map<dynamic, dynamic>;
      expect(args.containsKey('settings'), isTrue);

      final settings = args['settings'] as Map<dynamic, dynamic>;
      final rules = settings['proxyRules'] as List;
      expect(rules, hasLength(1));
      expect((rules.first as Map)['url'], 'http://proxy.example.com:8080');
    });

    test('setProxyOverride with bypass rules', () async {
      await controller.setProxyOverride(
        settings: ProxySettings(
          proxyRules: [ProxyRule(url: 'http://proxy:8080')],
          bypassRules: ['localhost', '*.example.com'],
        ),
      );

      expect(log, hasLength(1));
      final args = log.first.arguments as Map<dynamic, dynamic>;
      final settings = args['settings'] as Map<dynamic, dynamic>;
      expect(settings['bypassRules'], ['localhost', '*.example.com']);
    });

    test('clearProxyOverride sends correct method call', () async {
      await controller.clearProxyOverride();

      expect(log, hasLength(1));
      expect(log.first.method, 'clearProxyOverride');
    });

    test('setProxyOverride with multiple proxy rules', () async {
      await controller.setProxyOverride(
        settings: ProxySettings(
          proxyRules: [
            ProxyRule(
              url: 'http://http-proxy:80',
              schemeFilter: ProxySchemeFilter.MATCH_HTTP,
            ),
            ProxyRule(
              url: 'https://https-proxy:443',
              schemeFilter: ProxySchemeFilter.MATCH_HTTPS,
            ),
          ],
        ),
      );

      expect(log, hasLength(1));
      final args = log.first.arguments as Map<dynamic, dynamic>;
      final settings = args['settings'] as Map<dynamic, dynamic>;
      final rules = settings['proxyRules'] as List;
      expect(rules, hasLength(2));
    });
  });

  group('ProxySettings toMap/fromMap', () {
    test('roundtrip with proxy rules', () {
      final settings = ProxySettings(
        proxyRules: [
          ProxyRule(url: 'http://proxy:8080'),
          ProxyRule(
              url: 'socks5://socks:1080',
              schemeFilter: ProxySchemeFilter.MATCH_ALL_SCHEMES),
        ],
        bypassRules: ['localhost', '10.0.0.0/8'],
      );

      final map = settings.toMap();
      final restored = ProxySettings.fromMap(map);

      expect(restored, isNotNull);
      expect(restored!.proxyRules, hasLength(2));
      expect(restored.proxyRules[0].url, 'http://proxy:8080');
      expect(restored.proxyRules[1].url, 'socks5://socks:1080');
      expect(restored.bypassRules, ['localhost', '10.0.0.0/8']);
    });

    test('fromMap with null returns null', () {
      expect(ProxySettings.fromMap(null), isNull);
    });

    test('empty settings roundtrip', () {
      final settings = ProxySettings();
      final map = settings.toMap();
      final restored = ProxySettings.fromMap(map);

      expect(restored, isNotNull);
      expect(restored!.proxyRules, isEmpty);
      expect(restored.bypassRules, isEmpty);
    });
  });

  group('isClassSupported', () {
    test('Windows is supported', () {
      expect(
        ProxySettings.isClassSupported(platform: TargetPlatform.windows),
        isTrue,
      );
    });

    test('all platforms are supported', () {
      for (final platform in [
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
        TargetPlatform.linux,
        TargetPlatform.windows,
      ]) {
        expect(
          ProxySettings.isClassSupported(platform: platform),
          isTrue,
          reason: '$platform should be supported',
        );
      }
    });
  });
}
