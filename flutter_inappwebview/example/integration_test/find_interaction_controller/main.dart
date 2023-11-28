import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import '../util.dart';

part 'find_interactions.dart';

void main() {
  final shouldSkip =
      kIsWeb || [TargetPlatform.macOS].contains(defaultTargetPlatform);

  skippableGroup('FindInteractionController', () {
    findInteractions();
  }, skip: shouldSkip);
}
