import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import '../constants.dart';
import '../util.dart';

part 'start_and_stop.dart';

void main() {
  final shouldSkip = !TracingController.isClassSupported();

  skippableGroup('Tracing Controller', () {
    startAndStop();
  }, skip: shouldSkip);
}
