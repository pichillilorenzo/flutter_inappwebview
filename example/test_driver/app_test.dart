// Imports the Flutter Driver API.
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {

  group('Flutter InAppBrowser', () {
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    myTest({@required String name, @required Function callback, Timeout timeout}) {
      timeout = (timeout == null) ? new Timeout(new Duration(minutes: 5)) : timeout;
      test(name, () async {
        await Future.delayed(const Duration(milliseconds: 2000));
        callback();
      }, timeout: timeout);
    }

    //
    // IMPORTANT NOTE!!!
    // These tests need to follow the same order of "var routes" in "buildRoutes()" function
    // defined in main_test.dart
    //

    myTest(name: 'InAppWebViewInitialUrlTest', callback: () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewInitialUrlTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      String url = await driver.getText(appBarTitle);
      expect(url, "https://flutter.dev/");
    });

    myTest(name: 'InAppWebViewInitialFileTest', callback: () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewInitialFileTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "true");
    });

    myTest(name: 'InAppWebViewOnLoadResourceTest', callback: () async {
      List<String> resourceList = [
        "https://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css",
        "https://code.jquery.com/jquery-3.3.1.min.js",
        "https://via.placeholder.com/100x50"
      ];
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnLoadResourceTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      String title = await driver.getText(appBarTitle);
      print(title);
      for (String resource in resourceList) {
        expect(true, title.contains(resource));
      }
    });

    myTest(name: 'InAppWebViewJavaScriptHandlerTest', callback: () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewJavaScriptHandlerTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      String title = await driver.getText(appBarTitle);
      expect(true, !title.contains("false"));
    });

    myTest(name: 'InAppWebViewAjaxTest', callback: () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewAjaxTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "Lorenzo Pichilli Lorenzo Pichilli");
    });
  });
}