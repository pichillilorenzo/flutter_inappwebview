import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class _Controller with ChannelController {
  @override
  void dispose() => disposeChannel();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('disposeChannel is idempotent and handles an absent channel', () {
    final empty = _Controller();
    expect(empty.disposeChannel, returnsNormally);

    final controller = _Controller();
    controller.channel = const MethodChannel('test/channel-controller');
    controller.disposeChannel();

    expect(controller.disposed, isTrue);
    expect(controller.disposeChannel, returnsNormally);
  });
}
