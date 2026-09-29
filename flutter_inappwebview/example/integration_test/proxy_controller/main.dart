import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../constants.dart';
import '../env.dart';
import '../util.dart';

part 'clear_and_set_proxy_override.dart';
part 'proxy_override_applies_to_containers.dart';
part 'empty_proxy_override_is_refused.dart';
part 'proxy_override_for_container.dart';

void main() {
  final shouldSkip = !ProxyController.isClassSupported();

  skippableGroup('Proxy Controller', () {
    clearAndSetProxyOverride();
    proxyOverrideAppliesToContainers();
    emptyProxyOverrideIsRefused();
    proxyOverrideForContainer();
  }, skip: shouldSkip);
}
