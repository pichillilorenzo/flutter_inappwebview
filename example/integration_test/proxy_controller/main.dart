import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'clear_and_set_proxy_override.dart';

void main() {
  final shouldSkip = kIsWeb;

  group('Proxy Controller', () {
    clearAndSetProxyOverride();
  }, skip: shouldSkip);
}
