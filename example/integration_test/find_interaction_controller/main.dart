import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'find_interactions.dart';

void main() {
  final shouldSkip = kIsWeb;

  group('FindInteractionController', () {
    findInteractions();
  }, skip: shouldSkip);
}
