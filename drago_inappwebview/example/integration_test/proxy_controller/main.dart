import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drago_inappwebview/drago_inappwebview.dart';
import '../constants.dart';
import '../env.dart';
import '../util.dart';

part 'clear_and_set_proxy_override.dart';

void main() {
  final shouldSkip = !ProxyController.isClassSupported();

  skippableGroup('Proxy Controller', () {
    clearAndSetProxyOverride();
  }, skip: shouldSkip);
}
