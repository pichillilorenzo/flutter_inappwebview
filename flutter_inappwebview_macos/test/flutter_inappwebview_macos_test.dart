import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_macos/flutter_inappwebview_macos.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'WebAuthenticationSession.create sends additionalHeaderFields',
    () async {
      const channel = MethodChannel(
        'com.pichillilorenzo/flutter_webauthenticationsession',
      );
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

      final headerCases = <Map<String, String>?>[
        null,
        {},
        {'Authorization': 'Bearer token', 'X-Trace-Id': 'trace-123'},
      ];
      for (final headers in headerCases) {
        calls.clear();
        final session = await MacOSWebAuthenticationSession.static().create(
          url: WebUri('https://example.com/auth'),
          callbackURLScheme: 'example',
          additionalHeaderFields: headers,
        );

        final arguments = calls.single.arguments as Map<dynamic, dynamic>;
        expect(arguments['additionalHeaderFields'], headers);
        expect(session.additionalHeaderFields, headers);
      }
    },
  );
}
