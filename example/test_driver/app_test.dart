// Imports the Flutter Driver API.
import 'dart:async';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import '.env.dart';

void main() {

  group('Flutter InAppWebView', () {
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

    test('InAppWebViewInitialUrlTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');
      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewInitialFileTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewInitialUrlTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String url = await driver.getText(appBarTitle);
      expect(url, "https://flutter.dev/");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewInitialFileTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewInitialDataTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewInitialFileTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "true");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewInitialDataTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewOnProgressChangedTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewInitialDataTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "true");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnProgressChangedTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewOnScrollChangedTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnProgressChangedTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "true");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnScrollChangedTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewOnLoadResourceTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnScrollChangedTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "true");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnLoadResourceTest', () async {
      List<String> resourceList = [
        "https://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css",
        "https://code.jquery.com/jquery-3.3.1.min.js",
        "https://via.placeholder.com/100x50"
      ];
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewJavaScriptHandlerTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnLoadResourceTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      for (String resource in resourceList) {
        expect(true, title.contains(resource));
      }

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewJavaScriptHandlerTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewAjaxTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewJavaScriptHandlerTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(true, !title.contains("false"));

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewAjaxTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewFetchTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewAjaxTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "Lorenzo Pichilli Lorenzo Pichilli");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewFetchTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewOnLoadResourceCustomSchemeTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewFetchTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(true, title.contains("Lorenzo Pichilli") && title.contains("200"));

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnLoadResourceCustomSchemeTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewShouldOverrideUrlLoadingTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnLoadResourceCustomSchemeTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "true");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewShouldOverrideUrlLoadingTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewOnConsoleMessageTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewShouldOverrideUrlLoadingTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String url = await driver.getText(appBarTitle);
      expect(url, "https://flutter.dev/");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnConsoleMessageTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewOnDownloadStartTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnConsoleMessageTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "message LOG");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnDownloadStartTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewOnCreateWindowTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnDownloadStartTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String url = await driver.getText(appBarTitle);
      expect(url, "http://${environment["NODE_SERVER_IP"]}:8082/test-download-file");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnCreateWindowTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewOnJsDialogTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnCreateWindowTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String url = await driver.getText(appBarTitle);
      expect(url, "https://flutter.dev/");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnJsDialogTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');
      final alertButtonOk = find.byValueKey('AlertButtonOk');
      final confirmButtonCancel = find.byValueKey('ConfirmButtonCancel');
      final confirmButtonOk = find.byValueKey('ConfirmButtonOk');
      final promptTextField = find.byValueKey('PromptTextField');
      final promptButtonCancel = find.byValueKey('PromptButtonCancel');
      final promptButtonOk = find.byValueKey('PromptButtonOk');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewOnSafeBrowsingHitTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnJsDialogTest") {
        await Future.delayed(const Duration(milliseconds: 500));
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

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnSafeBrowsingHitTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewOnReceivedHttpAuthRequestTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnSafeBrowsingHitTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String url = await driver.getText(appBarTitle);
      if (Platform.isAndroid)
        expect(url, "chrome://safe-browsing/match?type=malware");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnReceivedHttpAuthRequestTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewSslRequestTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnReceivedHttpAuthRequestTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "Authorized");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewSslRequestTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewOnFindResultReceivedTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewSslRequestTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "Authorized");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnFindResultReceivedTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewOnNavigationStateChangeTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnFindResultReceivedTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "2");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnNavigationStateChangeTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewOnLoadErrorTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnNavigationStateChangeTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(true, title.contains("first-push") && title.contains("second-push"));

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnLoadErrorTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewOnLoadHttpErrorTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnLoadErrorTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      if (Platform.isAndroid) {
        expect(title, "-2");
      } else if (Platform.isIOS) {
        expect(title, "-1022");
      }

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewOnLoadHttpErrorTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewCookieManagerTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewOnLoadHttpErrorTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "404");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewCookieManagerTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewHttpAuthCredentialDatabaseTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewCookieManagerTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "myValue true true");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewHttpAuthCredentialDatabaseTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      final sideMenuButton = find.byValueKey('SideMenu');
      final listTiles = find.byValueKey('ListTiles');
      final nextTest = find.byValueKey('InAppWebViewContentBlockerTest');

      while((await driver.getText(appBarTitle)) == "InAppWebViewHttpAuthCredentialDatabaseTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "Authorized true true");

      await driver.tap(sideMenuButton);
      await driver.scrollUntilVisible(listTiles, nextTest, dyScroll: -300.0);
      await driver.tap(nextTest);
    }, timeout: new Timeout(new Duration(minutes: 5)));

    test('InAppWebViewContentBlockerTest', () async {
      final appBarTitle = find.byValueKey('AppBarTitle');

      while((await driver.getText(appBarTitle)) == "InAppWebViewContentBlockerTest") {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String title = await driver.getText(appBarTitle);
      expect(title, "true");
    }, timeout: new Timeout(new Duration(minutes: 5)));

  });
}