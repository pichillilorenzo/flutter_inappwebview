import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/webview_creation_failure.dart';

void main() {
  test('reported failures reach listeners', () async {
    final received = <WindowsWebViewCreationFailure>[];
    final sub = WindowsWebViewCreationFailures.stream.listen(received.add);
    addTearDown(sub.cancel);

    final error = Exception('HRESULT 0x80070005');
    WindowsWebViewCreationFailures.report(error, StackTrace.current);
    await Future<void>.delayed(Duration.zero);

    expect(received, hasLength(1));
    expect(received.single.error, same(error));
  });

  test('the requested URL is carried so hosts can tell whose creation failed',
      () async {
    final received = <WindowsWebViewCreationFailure>[];
    final sub = WindowsWebViewCreationFailures.stream.listen(received.add);
    addTearDown(sub.cancel);

    WindowsWebViewCreationFailures.report(
      Exception('boom'),
      StackTrace.current,
      requestedUrl: 'file:///plugins/a/index.html',
    );
    await Future<void>.delayed(Duration.zero);

    expect(received.single.requestedUrl, 'file:///plugins/a/index.html');
  });

  test('reporting without listeners does not throw', () {
    expect(
      () => WindowsWebViewCreationFailures.report(
        Exception('no listener'),
        StackTrace.current,
      ),
      returnsNormally,
    );
  });
}
