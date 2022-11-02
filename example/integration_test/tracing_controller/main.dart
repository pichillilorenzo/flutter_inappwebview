import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'start_and_stop.dart';

void main() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
        ].contains(defaultTargetPlatform);

  group('Tracing Controller', () {
    startAndStop();
  }, skip: shouldSkip);
}
