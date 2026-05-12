import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
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

      final session = await IOSWebAuthenticationSession.static().create(
        url: WebUri('https://example.com/auth'),
        callbackURLScheme: 'example',
        additionalHeaderFields: {'Authorization': 'Bearer token'},
      );

      final arguments = calls.single.arguments as Map<dynamic, dynamic>;
      expect(arguments['additionalHeaderFields'], {
        'Authorization': 'Bearer token',
      });
      expect(session.additionalHeaderFields, {'Authorization': 'Bearer token'});
    },
  );
}
