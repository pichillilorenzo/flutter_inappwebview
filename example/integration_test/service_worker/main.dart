import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'set_service_worker_client.dart';
import 'should_intercept_request.dart';

void main() {
  final shouldSkip = kIsWeb;

  group('Service Worker', () {
    shouldInterceptRequest();
    setServiceWorkerClient();
  }, skip: shouldSkip);
}