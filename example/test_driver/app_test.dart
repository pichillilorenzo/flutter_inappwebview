// Imports the Flutter Driver API.
import 'dart:async';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {

  group('Flutter InAppBrowser', () {
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      await driver.setTextEntryEmulation(enabled: true);
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    //
    // IMPORTANT NOTE!!!
    // These tests need to follow the same order of "var routes" in "buildRoutes()" function
    // defined in main_test.dart
    //

    test('InAppWebViewInitialUrlTest', () async {
      await Future.delayed(const Duration(milliseconds: 2000));
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewInitialUrlTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      String url = await driver.getText(appBarTitle);
      expect(url, "https://flutter.dev/");
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewInitialFileTest', () async {
      await Future.delayed(const Duration(milliseconds: 2000));
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewInitialFileTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "true");
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnLoadResourceTest', () async {
      await Future.delayed(const Duration(milliseconds: 2000));
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
      for (String resource in resourceList) {
        expect(true, title.contains(resource));
      }
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewJavaScriptHandlerTest', () async {
      await Future.delayed(const Duration(milliseconds: 2000));
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewJavaScriptHandlerTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      String title = await driver.getText(appBarTitle);
      expect(true, !title.contains("false"));
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewAjaxTest', () async {
      await Future.delayed(const Duration(milliseconds: 2000));
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewAjaxTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "Lorenzo Pichilli Lorenzo Pichilli");
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnLoadResourceCustomSchemeTest', () async {
      await Future.delayed(const Duration(milliseconds: 2000));
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnLoadResourceCustomSchemeTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "true");
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewFetchTest', () async {
      await Future.delayed(const Duration(milliseconds: 2000));
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewFetchTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      String title = await driver.getText(appBarTitle);
      expect(true, title.contains("Lorenzo Pichilli") && title.contains("200"));
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewShouldOverrideUrlLoadingTest', () async {
      await Future.delayed(const Duration(milliseconds: 2000));
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewShouldOverrideUrlLoadingTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      String url = await driver.getText(appBarTitle);
      expect(url, "https://flutter.dev/");
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnConsoleMessageTest', () async {
      await Future.delayed(const Duration(milliseconds: 2000));
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnConsoleMessageTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "message LOG");
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnDownloadStartTest', () async {
      await Future.delayed(const Duration(milliseconds: 2000));
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnDownloadStartTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      String url = await driver.getText(appBarTitle);
      expect(url, "http://192.168.1.20:8082/test-download-file");
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnTargetBlankTest', () async {
      await Future.delayed(const Duration(milliseconds: 2000));
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnTargetBlankTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      String url = await driver.getText(appBarTitle);
      expect(url, "https://flutter.dev/");
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnJsDialogTest', () async {
      await Future.delayed(const Duration(milliseconds: 2000));
      final appBarTitle = find.byValueKey('AppBarTitle');
      final alertButtonOk = find.byValueKey('AlertButtonOk');
      final confirmButtonCancel = find.byValueKey('ConfirmButtonCancel');
      final confirmButtonOk = find.byValueKey('ConfirmButtonOk');
      final promptTextField = find.byValueKey('PromptTextField');
      final promptButtonCancel = find.byValueKey('PromptButtonCancel');
      final promptButtonOk = find.byValueKey('PromptButtonOk');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnJsDialogTest") {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      await driver.tap(alertButtonOk);

      String title = await driver.getText(appBarTitle);
      expect(title, "alert");

      await Future.delayed(const Duration(milliseconds: 500));

      await driver.tap(confirmButtonOk);

      title = await driver.getText(appBarTitle);
      expect(title, "confirm true");

      await Future.delayed(const Duration(milliseconds: 500));

      await driver.tap(promptTextField);
      await driver.enterText("new value");
      await driver.waitFor(find.text("new value"));

      await driver.tap(promptButtonOk);

      title = await driver.getText(appBarTitle);
      expect(title, "prompt new value");

    }, timeout: new Timeout(new Duration(minutes: 5)));

  });
}