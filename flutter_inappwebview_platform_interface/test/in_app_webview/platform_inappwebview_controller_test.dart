import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestInAppWebViewController extends PlatformInAppWebViewController {
  _TestInAppWebViewController()
    : super.implementation(
        const PlatformInAppWebViewControllerCreationParams(id: null),
      );
}

void main() {
  test('createPdf is advertised for the Linux implementation', () {
    final controller = _TestInAppWebViewController();

    expect(
      controller.isMethodSupported(
        PlatformInAppWebViewControllerMethod.createPdf,
        platform: TargetPlatform.linux,
      ),
      isTrue,
    );
  });
}
