import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'set_get_delete.dart';

void main() {
  final shouldSkip = kIsWeb;

  group('Cookie Manager', () {
    setGetDelete();
  }, skip: shouldSkip);
}
