import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'custom_widget_test.dart';

int countTestPassed = 0;
int countTestFailed = 0;
int currentTest = 0;
List<String> testRoutes = [
  '/',
  '/InAppWebViewInitialFileTest',
  '/InAppWebViewOnLoadResourceTest'
];

void nextTest({@required BuildContext context}) {
  if (currentTest + 1 < testRoutes.length) {
    currentTest++;
    String nextRoute = testRoutes[currentTest];
    Navigator.pushReplacementNamed(context, nextRoute);
  } else {
    AnsiPen penError = new AnsiPen()..white()..rgb(r: 1.0, g: 0.0, b: 0.0);
    AnsiPen penSuccess = new AnsiPen()..white()..rgb(r: 0.0, g: 1.0, b: 0.0);

    if (countTestFailed > 0)
      print("\n" + penError("Total tests failed $countTestFailed.") + "\n");
    if (countTestPassed > 0)
      print("\n" + penSuccess("Total tests passed $countTestPassed.") + "\n");
  }
}

bool customAssert({WidgetTest widget, String name, @required bool value}) {
  try {
    assert(value);
  } catch (e, stackTrace) {
    String message = "${widget != null ? "'" + widget.name + "' - " : ""} ERROR - Failed assertion: ";
    List<String> stakTraceSplitted = stackTrace.toString().split("\n");
    String lineCallingAssert = stakTraceSplitted[3].trim().substring(2).trim();

    AnsiPen penError = new AnsiPen()..white()..rgb(r: 1.0, g: 0.0, b: 0.0);
    print("\n" + penError(message + lineCallingAssert) + "\n");
    countTestFailed++;
    return false;
  }
  countTestPassed++;
  try {
    throw Exception();
  } on Exception catch(e, stackTrace) {
    String message = "${widget != null ? "'" + widget.name + "' - " : ""} Test ";
    message += (name != null) ? "'$name' " : "";
    message += "passed!";
    List<String> stakTraceSplitted = stackTrace.toString().split("\n");
    String lineCallingAssert = stakTraceSplitted[1].trim().substring(2).trim();
    message += " $lineCallingAssert";

    AnsiPen pen = new AnsiPen()..white()..rgb(r: 1.0, g: 0.8, b: 0.2);
    print("\n" + pen(message) + "\n");
  }
  return true;
}