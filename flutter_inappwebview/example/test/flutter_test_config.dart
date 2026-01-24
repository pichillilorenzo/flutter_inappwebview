import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'test_helpers/mock_inappwebview_platform.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockInAppWebViewPlatform.initialize();
  await testMain();
}
