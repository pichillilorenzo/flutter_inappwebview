import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../env.dart';

void sslRequest() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  testWidgets('SSL request', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(
              url: WebUri("https://${environment["NODE_SERVER_IP"]}:4433/")),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onReceivedServerTrustAuthRequest: (controller, challenge) async {
            return new ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED);
          },
          onReceivedClientCertRequest: (controller, challenge) async {
            return new ClientCertResponse(
                certificatePath: "test_assets/certificate.pfx",
                certificatePassword: "",
                keyStoreType: "PKCS12",
                action: ClientCertResponseAction.PROCEED);
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    final String h1Content = await controller.evaluateJavascript(
        source: "document.body.querySelector('h1').textContent");
    expect(h1Content, "Authorized");
  }, skip: shouldSkip);
}
