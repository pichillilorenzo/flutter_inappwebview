import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_linux/flutter_inappwebview_linux.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

// The maps below have the shape the native side sends
// (linux/types/http_authentication_challenge.cc and
// linux/types/server_trust_challenge.cc). linux/test/authentication_challenge_test.cc
// checks the native half of the same contract.

Map<String, dynamic> _httpAuthChallenge({required int previousFailureCount}) =>
    {
      'protectionSpace': {
        'host': '127.0.0.1',
        'port': 8081,
        'protocol': null,
        'realm': 'Node',
        'authenticationMethod': 'NSURLAuthenticationMethodHTTPBasic',
        'isProxy': false,
        'sslCertificate': null,
        'sslError': null,
      },
      'previousFailureCount': previousFailureCount,
      'proposedCredential': null,
      'failureResponse': null,
      'error': null,
    };

Map<String, dynamic> _serverTrustChallenge({required int sslErrorCode}) => {
  'protectionSpace': {
    'host': '127.0.0.1',
    'port': 4433,
    'protocol': 'https',
    'sslCertificate': null,
    'sslError': {
      'code': sslErrorCode,
      'message': 'The signing certificate authority is not known.',
    },
    'authenticationMethod': 'NSURLAuthenticationMethodServerTrust',
  },
};

// GTlsCertificateFlags values.
const _unknownCa = 1;
const _badIdentity = 2;
const _notActivated = 4;
const _expired = 8;
const _revoked = 16;
const _genericError = 64;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = StandardMethodCodec();
  var nextId = 0;

  // Native values of multi-platform enums are resolved from
  // defaultTargetPlatform, so pin it to Linux for the whole file.
  setUpAll(() => debugDefaultTargetPlatformOverride = TargetPlatform.linux);
  tearDownAll(() => debugDefaultTargetPlatformOverride = null);

  /// Creates a controller and returns a function that invokes [method] on its
  /// channel the way the native side does, returning the decoded reply.
  Future<dynamic> Function(String method, Map<String, dynamic> arguments)
  createController(LinuxInAppWebViewWidgetCreationParams webviewParams) {
    final id = 'authentication_challenge_test_${nextId++}';
    LinuxInAppWebViewController(
      LinuxInAppWebViewControllerCreationParams(
        id: id,
        webviewParams: webviewParams,
      ),
    );
    return (method, arguments) async {
      ByteData? reply;
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'com.pichillilorenzo/flutter_inappwebview_$id',
            codec.encodeMethodCall(MethodCall(method, arguments)),
            (data) => reply = data,
          );
      return codec.decodeEnvelope(reply!);
    };
  }

  group('onReceivedHttpAuthRequest', () {
    test('delivers a first challenge with previousFailureCount 0', () async {
      HttpAuthenticationChallenge? received;
      final invoke = createController(
        LinuxInAppWebViewWidgetCreationParams(
          onReceivedHttpAuthRequest: (controller, challenge) async {
            received = challenge;
            return HttpAuthResponse(
              username: 'USERNAME',
              password: 'PASSWORD',
              action: HttpAuthResponseAction.PROCEED,
            );
          },
        ),
      );

      final reply = await invoke(
        'onReceivedHttpAuthRequest',
        _httpAuthChallenge(previousFailureCount: 0),
      );

      expect(received, isNotNull);
      expect(received!.previousFailureCount, 0);
      expect(received!.protectionSpace.host, '127.0.0.1');
      expect(received!.protectionSpace.port, 8081);
      expect(received!.protectionSpace.realm, 'Node');
      expect(
        received!.protectionSpace.authenticationMethod,
        URLProtectionSpaceAuthenticationMethod
            .NSURL_AUTHENTICATION_METHOD_HTTP_BASIC,
      );
      expect(reply, {
        'action': 1,
        'username': 'USERNAME',
        'password': 'PASSWORD',
        'permanentPersistence': false,
      });
    });

    test('delivers a retry with previousFailureCount 1', () async {
      HttpAuthenticationChallenge? received;
      final invoke = createController(
        LinuxInAppWebViewWidgetCreationParams(
          onReceivedHttpAuthRequest: (controller, challenge) async {
            received = challenge;
            return HttpAuthResponse(action: HttpAuthResponseAction.CANCEL);
          },
        ),
      );

      final reply = await invoke(
        'onReceivedHttpAuthRequest',
        _httpAuthChallenge(previousFailureCount: 1),
      );

      expect(received, isNotNull);
      expect(received!.previousFailureCount, 1);
      expect((reply as Map)['action'], 0);
    });

    test('sends every action as the value the native side expects', () {
      // linux/types/http_auth_response.h: CANCEL = 0, PROCEED = 1,
      // USE_SAVED_CREDENTIAL = 2.
      expect(HttpAuthResponseAction.CANCEL.toNativeValue(), 0);
      expect(HttpAuthResponseAction.PROCEED.toNativeValue(), 1);
      expect(
        HttpAuthResponseAction.USE_SAVED_HTTP_AUTH_CREDENTIALS.toNativeValue(),
        2,
      );
    });
  });

  group('onReceivedServerTrustAuthRequest', () {
    test('delivers the challenge with its SslError', () async {
      ServerTrustChallenge? received;
      final invoke = createController(
        LinuxInAppWebViewWidgetCreationParams(
          onReceivedServerTrustAuthRequest: (controller, challenge) async {
            received = challenge;
            return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.PROCEED,
            );
          },
        ),
      );

      final reply = await invoke(
        'onReceivedServerTrustAuthRequest',
        _serverTrustChallenge(sslErrorCode: _unknownCa),
      );

      expect(received, isNotNull);
      expect(received!.protectionSpace.host, '127.0.0.1');
      expect(received!.protectionSpace.port, 4433);
      expect(received!.protectionSpace.sslError?.code, SslErrorType.UNTRUSTED);
      expect(reply, {'action': 1});
    });

    test('decodes every SslError code the native side sends', () {
      final expected = {
        _unknownCa: SslErrorType.UNTRUSTED,
        _badIdentity: SslErrorType.IDMISMATCH,
        _notActivated: SslErrorType.NOT_YET_VALID,
        _expired: SslErrorType.EXPIRED,
        _revoked: SslErrorType.REVOKED,
        _genericError: SslErrorType.INVALID,
      };
      expected.forEach((code, type) {
        expect(SslError.fromMap({'code': code})?.code, type, reason: '$code');
      });
    });
  });
}
