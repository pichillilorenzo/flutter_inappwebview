import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';

int currentTest = 0;

void nextTest({@required BuildContext context, @required WidgetTestState state}) {
  if (currentTest + 1 < testRoutes.length) {
    currentTest++;
    String nextRoute = testRoutes[currentTest];
    Future.delayed(const Duration(milliseconds: 2000)).then((value) {
      Navigator.pushReplacementNamed(context, nextRoute);
    });
  }
}