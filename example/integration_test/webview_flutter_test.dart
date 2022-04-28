import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'in_app_webview/main.dart' as in_app_webview_tests;

import '.env.dart';

import 'util.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  in_app_webview_tests.main();

  group('InAppWebView', () {


    group("iosOnNavigationResponse", () {
      testWidgets('allow navigation', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> pageLoaded = Completer<void>();
        final Completer<String> onNavigationResponseCompleter =
            Completer<String>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest:
                  URLRequest(url: Uri.parse('https://github.com/flutter')),
              initialOptions: InAppWebViewGroupOptions(
                  ios: IOSInAppWebViewOptions(useOnNavigationResponse: true)),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
              iosOnNavigationResponse: (controller, navigationResponse) async {
                onNavigationResponseCompleter
                    .complete(navigationResponse.response!.url.toString());
                return IOSNavigationResponseAction.ALLOW;
              },
            ),
          ),
        );

        await pageLoaded.future;
        final String url = await onNavigationResponseCompleter.future;
        expect(url, 'https://github.com/flutter');
      }, skip: defaultTargetPlatform != TargetPlatform.iOS);

      testWidgets('cancel navigation', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> pageLoaded = Completer<void>();
        final Completer<String> onNavigationResponseCompleter =
            Completer<String>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest:
                  URLRequest(url: Uri.parse('https://github.com/flutter')),
              initialOptions: InAppWebViewGroupOptions(
                  ios: IOSInAppWebViewOptions(useOnNavigationResponse: true)),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
              iosOnNavigationResponse: (controller, navigationResponse) async {
                onNavigationResponseCompleter
                    .complete(navigationResponse.response!.url.toString());
                return IOSNavigationResponseAction.CANCEL;
              },
            ),
          ),
        );

        final String url = await onNavigationResponseCompleter.future;
        expect(url, 'https://github.com/flutter');
        expect(pageLoaded.future, doesNotComplete);
      }, skip: defaultTargetPlatform != TargetPlatform.iOS);
    }, skip: defaultTargetPlatform != TargetPlatform.iOS);

    testWidgets('initialUserScripts', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            initialUserScripts: UnmodifiableListView<UserScript>([
              UserScript(
                  source: "var foo = 49;",
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START),
              UserScript(
                  source: "var foo2 = 19;",
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                  contentWorld: ContentWorld.PAGE),
              UserScript(
                  source: "var bar = 2;",
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                  contentWorld: ContentWorld.DEFAULT_CLIENT),
              UserScript(
                  source: "var bar2 = 12;",
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                  contentWorld: ContentWorld.world(name: "test")),
            ]),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) async {
              pageLoaded.complete();
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      expect(await controller.evaluateJavascript(source: "foo;"), 49);
      expect(await controller.evaluateJavascript(source: "foo2;"), 19);
      expect(
          await controller.evaluateJavascript(
              source: "foo2;", contentWorld: ContentWorld.PAGE),
          19);
      expect(await controller.evaluateJavascript(source: "bar;"), isNull);
      expect(await controller.evaluateJavascript(source: "bar2;"), isNull);
      expect(
          await controller.evaluateJavascript(
              source: "bar;", contentWorld: ContentWorld.DEFAULT_CLIENT),
          2);
      expect(
          await controller.evaluateJavascript(
              source: "bar2;", contentWorld: ContentWorld.world(name: "test")),
          12);
    });

    group('POST requests', () {
      testWidgets('initialUrlRequest', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> postPageLoaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      "http://${environment["NODE_SERVER_IP"]}:8082/test-post"),
                  method: 'POST',
                  body: Uint8List.fromList(utf8.encode("name=FooBar")),
                  headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                  }),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                postPageLoaded.complete();
              },
            ),
          ),
        );

        final InAppWebViewController controller =
            await controllerCompleter.future;
        await postPageLoaded.future;

        final String? currentUrl = (await controller.getUrl())?.toString();
        expect(currentUrl,
            'http://${environment["NODE_SERVER_IP"]}:8082/test-post');

        final String? pContent = await controller.evaluateJavascript(
            source: "document.querySelector('p').innerHTML;");
        expect(pContent, "HELLO FooBar!");
      });

      testWidgets('loadUrl', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> postPageLoaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                if (url?.scheme != "about") {
                  postPageLoaded.complete();
                }
              },
            ),
          ),
        );

        final InAppWebViewController controller =
            await controllerCompleter.future;

        var postData = Uint8List.fromList(utf8.encode("name=FooBar"));
        await controller.loadUrl(
            urlRequest: URLRequest(
                url: Uri.parse(
                    "http://${environment["NODE_SERVER_IP"]}:8082/test-post"),
                method: 'POST',
                body: postData,
                headers: {
              'Content-Type': 'application/x-www-form-urlencoded'
            }));

        await postPageLoaded.future;

        final String? currentUrl = (await controller.getUrl())?.toString();
        expect(currentUrl,
            'http://${environment["NODE_SERVER_IP"]}:8082/test-post');

        final String? pContent = await controller.evaluateJavascript(
            source: "document.querySelector('p').innerHTML;");
        expect(pContent, "HELLO FooBar!");
      });

      testWidgets('postUrl', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> postPageLoaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                if (url?.scheme != "about") {
                  postPageLoaded.complete();
                }
              },
            ),
          ),
        );

        final InAppWebViewController controller =
            await controllerCompleter.future;

        var postData = Uint8List.fromList(utf8.encode("name=FooBar"));
        await controller.postUrl(
            url: Uri.parse(
                "http://${environment["NODE_SERVER_IP"]}:8082/test-post"),
            postData: postData);

        await postPageLoaded.future;

        final String? currentUrl = (await controller.getUrl())?.toString();
        expect(currentUrl,
            'http://${environment["NODE_SERVER_IP"]}:8082/test-post');

        final String? pContent = await controller.evaluateJavascript(
            source: "document.querySelector('p').innerHTML;");
        expect(pContent, "HELLO FooBar!");
      });
    });

    testWidgets('loadData', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoads.stream.first;

      await controller.loadData(
          data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <link rel="stylesheet" href="https://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css">
        <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
    </head>
    <body>
      <img src="https://via.placeholder.com/100x50" alt="placeholder 100x50">
    </body>
</html>
""",
          encoding: 'utf-8',
          mimeType: 'text/html',
          historyUrl: Uri.parse("https://flutter.dev"),
          baseUrl: Uri.parse("https://flutter.dev"));
      await pageLoads.stream.first;

      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(currentUrl, 'https://flutter.dev/');

      pageLoads.close();
    });

    testWidgets('loadFile', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoads.stream.first;

      await controller.loadFile(
          assetFilePath: "test_assets/in_app_webview_initial_file_test.html");
      await pageLoads.stream.first;

      final Uri? url = await controller.getUrl();
      expect(url, isNotNull);
      expect(url!.scheme, 'file');
      expect(url.path,
          endsWith("test_assets/in_app_webview_initial_file_test.html"));

      pageLoads.close();
    });

    testWidgets('reload', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://github.com/flutter')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      String? url = await pageLoads.stream.first;
      expect(url, 'https://github.com/flutter');

      await controller.reload();
      url = await pageLoads.stream.first;
      expect(url, 'https://github.com/flutter');

      pageLoads.close();
    });

    testWidgets('web history - go back and forward',
        (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev/')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;

      var url = await pageLoads.stream.first;
      var webHistory = await controller.getCopyBackForwardList();
      expect(url, 'https://flutter.dev/');
      expect(webHistory!.currentIndex, 0);
      expect(webHistory.list!.length, 1);
      expect(webHistory.list![0].url.toString(), 'https://flutter.dev/');

      await controller.loadUrl(
          urlRequest: URLRequest(url: Uri.parse('https://github.com/flutter')));
      url = await pageLoads.stream.first;
      webHistory = await controller.getCopyBackForwardList();
      expect(url, 'https://github.com/flutter');
      expect(await controller.canGoBack(), true);
      expect(await controller.canGoForward(), false);
      expect(await controller.canGoBackOrForward(steps: -1), true);
      expect(await controller.canGoBackOrForward(steps: 1), false);
      expect(webHistory!.currentIndex, 1);
      expect(webHistory.list!.length, 2);
      expect(webHistory.list![0].url.toString(), 'https://flutter.dev/');
      expect(webHistory.list![1].url.toString(), 'https://github.com/flutter');

      await Future.delayed(Duration(seconds: 1));
      await controller.goBack();
      url = await pageLoads.stream.first;
      webHistory = await controller.getCopyBackForwardList();
      expect(url, 'https://flutter.dev/');
      expect(await controller.canGoBack(), false);
      expect(await controller.canGoForward(), true);
      expect(await controller.canGoBackOrForward(steps: -1), false);
      expect(await controller.canGoBackOrForward(steps: 1), true);
      expect(webHistory!.currentIndex, 0);
      expect(webHistory.list!.length, 2);
      expect(webHistory.list![0].url.toString(), 'https://flutter.dev/');
      expect(webHistory.list![1].url.toString(), 'https://github.com/flutter');

      await Future.delayed(Duration(seconds: 1));
      await controller.goForward();
      url = await pageLoads.stream.first;
      webHistory = await controller.getCopyBackForwardList();
      expect(url, 'https://github.com/flutter');
      expect(await controller.canGoBack(), true);
      expect(await controller.canGoForward(), false);
      expect(await controller.canGoBackOrForward(steps: -1), true);
      expect(await controller.canGoBackOrForward(steps: 1), false);
      expect(webHistory!.currentIndex, 1);
      expect(webHistory.list!.length, 2);
      expect(webHistory.list![0].url.toString(), 'https://flutter.dev/');
      expect(webHistory.list![1].url.toString(), 'https://github.com/flutter');

      await Future.delayed(Duration(seconds: 1));
      await controller.goTo(historyItem: webHistory.list![0]);
      url = await pageLoads.stream.first;
      webHistory = await controller.getCopyBackForwardList();
      expect(url, 'https://flutter.dev/');
      expect(await controller.canGoBack(), false);
      expect(await controller.canGoForward(), true);
      expect(await controller.canGoBackOrForward(steps: -1), false);
      expect(await controller.canGoBackOrForward(steps: 1), true);
      expect(webHistory!.currentIndex, 0);
      expect(webHistory.list!.length, 2);
      expect(webHistory.list![0].url.toString(), 'https://flutter.dev/');
      expect(webHistory.list![1].url.toString(), 'https://github.com/flutter');

      pageLoads.close();
    });

    testWidgets('getProgress', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final int? progress = await controller.getProgress();
      expect(progress, 100);
    });

    testWidgets('getHtml', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final String? html = await controller.getHtml();
      expect(html, isNotNull);
    });

    testWidgets('getFavicons', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final List<Favicon>? favicons = await controller.getFavicons();
      expect(favicons, isNotNull);
      expect(favicons, isNotEmpty);
    });

    testWidgets('isLoading', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageStarted = Completer<void>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(clearCache: true)),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStart: (controller, url) {
              pageStarted.complete();
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageStarted.future;
      expect(await controller.isLoading(), true);

      await pageLoaded.future;
      expect(await controller.isLoading(), false);
    });

    testWidgets('stopLoading', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(clearCache: true)),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStart: (controller, url) {
              controller.stopLoading();
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;

      if (defaultTargetPlatform == TargetPlatform.android) {
        await pageLoaded.future;
        expect(await controller.evaluateJavascript(source: "document.body"),
            isNullOrEmpty);
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        expect(pageLoaded.future, doesNotComplete);
      }
    });

    testWidgets('injectJavascriptFileFromUrl', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<void> jQueryLoaded = Completer<void>();
      final Completer<void> jQueryLoadError = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await controller.injectJavascriptFileFromUrl(
          urlFile:
              Uri.parse('https://www.notawebsite..com/jquery-3.3.1.min.js'),
          scriptHtmlTagAttributes: ScriptHtmlTagAttributes(
            id: 'jquery-error',
            onError: () {
              jQueryLoadError.complete();
            },
          ));
      await jQueryLoadError.future;
      expect(
          await controller.evaluateJavascript(
              source: "document.body.querySelector('#jquery-error') == null;"),
          false);
      expect(
          await controller.evaluateJavascript(source: "window.jQuery == null;"),
          true);

      await controller.injectJavascriptFileFromUrl(
          urlFile: Uri.parse('https://code.jquery.com/jquery-3.3.1.min.js'),
          scriptHtmlTagAttributes: ScriptHtmlTagAttributes(
            id: 'jquery',
            onLoad: () {
              jQueryLoaded.complete();
            },
          ));
      await jQueryLoaded.future;
      expect(
          await controller.evaluateJavascript(
              source: "document.body.querySelector('#jquery') == null;"),
          false);
      expect(
          await controller.evaluateJavascript(source: "window.jQuery == null;"),
          false);
    });

    testWidgets('injectJavascriptFileFromAsset', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await controller.injectJavascriptFileFromAsset(
          assetFilePath: 'test_assets/js/jquery-3.3.1.min.js');
      expect(
          await controller.evaluateJavascript(source: "window.jQuery == null;"),
          false);
    });

    testWidgets('injectCSSCode', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await controller.injectCSSCode(source: """
      body {
        background-color: rgb(0, 0, 255);
      }
      """);

      String? backgroundColor = await controller.evaluateJavascript(source: """
      var element = document.body;
      var style = getComputedStyle(element);
      style.backgroundColor;
      """);
      expect(backgroundColor, 'rgb(0, 0, 255)');
    });

    testWidgets('injectCSSFileFromUrl', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await controller.injectCSSFileFromUrl(
          urlFile: Uri.parse(
              'https://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css'),
          cssLinkHtmlTagAttributes: CSSLinkHtmlTagAttributes(id: 'bootstrap'));
      await Future.delayed(Duration(seconds: 2));
      expect(
          await controller.evaluateJavascript(
              source: "document.head.querySelector('#bootstrap') == null;"),
          false);
    });

    testWidgets('injectCSSFileFromAsset', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await controller.injectCSSFileFromAsset(
          assetFilePath: 'test_assets/css/blue-body.css');

      String? backgroundColor = await controller.evaluateJavascript(source: """
      var element = document.body;
      var style = getComputedStyle(element);
      style.backgroundColor;
      """);
      expect(backgroundColor, 'rgb(0, 0, 255)');
    });

    testWidgets('takeScreenshot', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      var screenshotConfiguration = ScreenshotConfiguration(
          compressFormat: CompressFormat.JPEG,
          quality: 20,
          rect: InAppWebViewRect(width: 100, height: 100, x: 50, y: 50));
      var screenshot = await controller.takeScreenshot(
          screenshotConfiguration: screenshotConfiguration);
      expect(screenshot, isNotNull);
    });

    testWidgets('clearCache', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;
      await expectLater(controller.clearCache(), completes);
    });

    testWidgets('T-Rex Runner game', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      var html = await controller.getTRexRunnerHtml();
      var css = await controller.getTRexRunnerCss();

      expect(html, isNotNull);
      expect(css, isNotNull);
    });

    testWidgets('pause/resume timers', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await controller.evaluateJavascript(source: """
      var count = 0;
      setInterval(function() {
        count = count + 10;
      }, 20);
      """);

      await controller.pauseTimers();
      await Future.delayed(Duration(seconds: 2));
      await controller.resumeTimers();
      expect(
          await controller.evaluateJavascript(source: "count;"), lessThan(50));
      await Future.delayed(Duration(seconds: 4));
      expect(await controller.evaluateJavascript(source: "count;"),
          greaterThan(50));
    });

    testWidgets('printCurrentPage', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await expectLater(controller.printCurrentPage(), completes);
    }, skip: true);

    testWidgets('getContentHeight', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final contentHeight = await controller.getContentHeight();
      expect(contentHeight, isNonZero);
      expect(contentHeight, isPositive);
    });

    testWidgets('zoomBy', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await expectLater(
          controller.zoomBy(zoomFactor: 3.0, animated: true), completes);
    });

    testWidgets('getZoomScale', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final scale = await controller.getZoomScale();
      expect(scale, isNonZero);
      expect(scale, isPositive);
    });

    testWidgets('clearFocus', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await expectLater(controller.clearFocus(), completes);
    });

    testWidgets('requestFocusNodeHref', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await expectLater(controller.requestFocusNodeHref(), completes);
    });

    testWidgets('requestImageRef', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await expectLater(controller.requestImageRef(), completes);
    });

    testWidgets('getMetaTags', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      List<MetaTag> metaTags = await controller.getMetaTags();
      expect(metaTags, isNotEmpty);
    });

    testWidgets('getMetaThemeColor', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: Uri.parse('https://github.com')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      expect(await controller.getMetaThemeColor(), isNotNull);
    });

    testWidgets('getCertificate', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      var sslCertificate = await controller.getCertificate();
      expect(sslCertificate, isNotNull);
      expect(sslCertificate!.x509Certificate, isNotNull);
      expect(sslCertificate.issuedBy, isNotNull);
      expect(sslCertificate.issuedTo, isNotNull);
      expect(sslCertificate.validNotAfterDate, isNotNull);
      expect(sslCertificate.validNotBeforeDate, isNotNull);
    });

    testWidgets('add/remove user scripts', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoads.stream.first;

      var userScript1 = UserScript(
          source: "window.foo = 49;",
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START);
      var userScript2 = UserScript(
          source: "window.bar = 19;",
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END);
      await controller.addUserScripts(userScripts: [userScript1, userScript2]);
      await controller.reload();
      await pageLoads.stream.first;
      var value = await controller.evaluateJavascript(source: "window.foo;");
      expect(value, 49);
      value = await controller.evaluateJavascript(source: "window.bar;");
      expect(value, 19);

      await controller.removeUserScript(userScript: userScript1);
      await controller.reload();
      await pageLoads.stream.first;
      value = await controller.evaluateJavascript(source: "window.foo;");
      expect(value, isNull);
      value = await controller.evaluateJavascript(source: "window.bar;");
      expect(value, 19);

      await controller.removeAllUserScripts();
      await controller.reload();
      await pageLoads.stream.first;
      value = await controller.evaluateJavascript(source: "window.foo;");
      expect(value, isNull);
      value = await controller.evaluateJavascript(source: "window.bar;");
      expect(value, isNull);

      pageLoads.close();
    });

    // testWidgets('saveWebArchive', (WidgetTester tester) async {
    //   final Completer controllerCompleter = Completer<InAppWebViewController>();
    //   final Completer<void> pageLoaded = Completer<void>();
    //
    //   await tester.pumpWidget(
    //     Directionality(
    //       textDirection: TextDirection.ltr,
    //       child: InAppWebView(
    //         key: GlobalKey(),
    //         initialUrlRequest:
    //             URLRequest(url: Uri.parse('https://github.com/flutter')),
    //         onWebViewCreated: (controller) {
    //           controllerCompleter.complete(controller);
    //         },
    //         onLoadStop: (controller, url) {
    //           pageLoaded.complete();
    //         },
    //       ),
    //     ),
    //   );
    //
    //   final InAppWebViewController controller =
    //       await controllerCompleter.future;
    //   await pageLoaded.future;
    //
    //   // wait a little bit after page load otherwise Android will not save the web archive
    //   await Future.delayed(Duration(seconds: 1));
    //
    //   var supportDir = await getApplicationSupportDirectory();
    //
    //   var fileName = "flutter-website.";
    //   if (defaultTargetPlatform == TargetPlatform.android) {
    //     fileName = fileName + WebArchiveFormat.MHT.toValue();
    //   } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    //     fileName = fileName + WebArchiveFormat.WEBARCHIVE.toValue();
    //   }
    //
    //   var fullPath = supportDir.path + Platform.pathSeparator + fileName;
    //   var path = await controller.saveWebArchive(filePath: fullPath);
    //   expect(path, isNotNull);
    //   expect(path, endsWith(fileName));
    //
    //   path = await controller.saveWebArchive(
    //       filePath: supportDir.path, autoname: true);
    //   expect(path, isNotNull);
    // });

    testWidgets('isSecureContext', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoads.stream.first;
      expect(await controller.isSecureContext(), true);

      await controller.loadUrl(
          urlRequest: URLRequest(url: Uri.parse('http://example.com/')));
      await pageLoads.stream.first;
      expect(await controller.isSecureContext(), false);

      pageLoads.close();
    });

    test('getDefaultUserAgent', () async {
      expect(await InAppWebViewController.getDefaultUserAgent(), isNotNull);
    });

    testWidgets('launches with pull-to-refresh feature',
        (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final pullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(
            color: Colors.blue,
            size: AndroidPullToRefreshSize.DEFAULT,
            backgroundColor: Colors.grey,
            enabled: true,
            slingshotDistance: 150,
            distanceToTriggerSync: 150,
            attributedTitle: IOSNSAttributedString(string: "test")),
        onRefresh: () {},
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://github.com/flutter')),
            initialOptions: InAppWebViewGroupOptions(
                android:
                    AndroidInAppWebViewOptions(useHybridComposition: true)),
            pullToRefreshController: pullToRefreshController,
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(currentUrl, 'https://github.com/flutter');
    });

    group('WebMessage', () {
      testWidgets('WebMessageChannel', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer webMessageCompleter = Completer<String>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(data: """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebMessageChannel Test</title>
</head>
<body>
    <button id="button" onclick="port.postMessage(input.value);" />Send</button>
    <br />
    <input id="input" type="text" value="JavaScript To Native" />

    <script>
      var port;
      window.addEventListener('message', function(event) {
          if (event.data == 'capturePort') {
              if (event.ports[0] != null) {
                  port = event.ports[0];
                  port.onmessage = function (event) {
                      console.log(event.data);
                  };
              }
          }
      }, false);
    </script>
</body>
</html>
                      """),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onConsoleMessage: (controller, consoleMessage) {
                webMessageCompleter.complete(consoleMessage.message);
              },
              onLoadStop: (controller, url) async {
                var webMessageChannel =
                    await controller.createWebMessageChannel();
                var port1 = webMessageChannel!.port1;
                var port2 = webMessageChannel.port2;

                await port1.setWebMessageCallback((message) async {
                  await port1
                      .postMessage(WebMessage(data: message! + " and back"));
                });
                await controller.postWebMessage(
                    message: WebMessage(data: "capturePort", ports: [port2]),
                    targetOrigin: Uri.parse("*"));
                await controller.evaluateJavascript(
                    source: "document.getElementById('button').click();");
              },
            ),
          ),
        );
        await controllerCompleter.future;

        final String message = await webMessageCompleter.future;
        expect(message, 'JavaScript To Native and back');
      });

      testWidgets('WebMessageListener', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> pageLoaded = Completer<void>();
        final Completer webMessageCompleter = Completer<String>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              onWebViewCreated: (controller) async {
                await controller.addWebMessageListener(WebMessageListener(
                  jsObjectName: "myTestObj",
                  allowedOriginRules: Set.from(["https://*.example.com"]),
                  onPostMessage:
                      (message, sourceOrigin, isMainFrame, replyProxy) {
                    assert(
                        sourceOrigin.toString() == "https://www.example.com");
                    assert(isMainFrame);

                    replyProxy.postMessage(message! + " and back");
                  },
                ));
                controllerCompleter.complete(controller);
              },
              onConsoleMessage: (controller, consoleMessage) {
                webMessageCompleter.complete(consoleMessage.message);
              },
              onLoadStop: (controller, url) async {
                if (url.toString() == "https://www.example.com/") {
                  pageLoaded.complete();
                }
              },
            ),
          ),
        );
        final controller = await controllerCompleter.future;
        await controller.loadUrl(
            urlRequest: URLRequest(url: Uri.parse("https://www.example.com/")));
        await pageLoaded.future;

        await controller.evaluateJavascript(source: """
          myTestObj.addEventListener('message', function(event) {
            console.log(event.data);
          });
          myTestObj.postMessage('JavaScript To Native');
        """);

        final String message = await webMessageCompleter.future;
        expect(message, 'JavaScript To Native and back');
      });
    });

    group('android methods', () {
      testWidgets('clearSslPreferences', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> pageLoaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest:
                  URLRequest(url: Uri.parse('https://flutter.dev')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        );

        final InAppWebViewController controller =
            await controllerCompleter.future;
        await pageLoaded.future;
        await expectLater(controller.android.clearSslPreferences(), completes);
      }, skip: defaultTargetPlatform != TargetPlatform.android);

      testWidgets('pause/resume', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> pageLoaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest:
                  URLRequest(url: Uri.parse('https://flutter.dev')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        );

        final InAppWebViewController controller =
            await controllerCompleter.future;
        await pageLoaded.future;
        await expectLater(controller.android.pause(), completes);
        await Future.delayed(Duration(seconds: 1));
        await expectLater(controller.android.resume(), completes);
      }, skip: defaultTargetPlatform != TargetPlatform.android);

      testWidgets('getOriginalUrl', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> pageLoaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest:
                  URLRequest(url: Uri.parse('https://github.com/flutter')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        );

        final InAppWebViewController controller =
            await controllerCompleter.future;
        await pageLoaded.future;
        var originUrl = (await controller.getOriginalUrl())?.toString();
        expect(originUrl, 'https://github.com/flutter');
      });

      testWidgets('pageDown/pageUp', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> pageLoaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest:
                  URLRequest(url: Uri.parse('https://flutter.dev')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        );

        final InAppWebViewController controller =
            await controllerCompleter.future;
        await pageLoaded.future;
        expect(await controller.android.pageDown(bottom: false), true);
        await Future.delayed(Duration(seconds: 1));
        expect(await controller.android.pageUp(top: false), true);
      }, skip: defaultTargetPlatform != TargetPlatform.android);

      testWidgets('zoomIn/zoomOut', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> pageLoaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest:
                  URLRequest(url: Uri.parse('https://flutter.dev')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        );

        final InAppWebViewController controller =
            await controllerCompleter.future;
        await pageLoaded.future;
        expect(await controller.android.zoomIn(), true);
        await Future.delayed(Duration(seconds: 1));
        expect(await controller.android.zoomOut(), true);
      }, skip: defaultTargetPlatform != TargetPlatform.android);

      testWidgets('clearHistory', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final StreamController<String> pageLoads =
            StreamController<String>.broadcast();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest:
                  URLRequest(url: Uri.parse('https://flutter.dev')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                pageLoads.add(url!.toString());
              },
            ),
          ),
        );

        final InAppWebViewController controller =
            await controllerCompleter.future;
        await pageLoads.stream.first;
        await controller.loadUrl(
            urlRequest:
                URLRequest(url: Uri.parse('https://github.com/flutter')));
        await pageLoads.stream.first;

        var webHistory = await controller.getCopyBackForwardList();
        expect(webHistory!.list!.length, 2);

        await controller.android.clearHistory();

        webHistory = await controller.getCopyBackForwardList();
        expect(webHistory!.list!.length, 1);

        pageLoads.close();
      }, skip: defaultTargetPlatform != TargetPlatform.android);

      test('clearClientCertPreferences', () async {
        await expectLater(
            AndroidInAppWebViewController.clearClientCertPreferences(),
            completes);
      }, skip: defaultTargetPlatform != TargetPlatform.android);

      test('getSafeBrowsingPrivacyPolicyUrl', () async {
        expect(
            await AndroidInAppWebViewController
                .getSafeBrowsingPrivacyPolicyUrl(),
            isNotNull);
      }, skip: defaultTargetPlatform != TargetPlatform.android);

      test('setSafeBrowsingWhitelist', () async {
        expect(
            await AndroidInAppWebViewController.setSafeBrowsingWhitelist(
                hosts: ["flutter.dev", "github.com"]),
            true);
      }, skip: defaultTargetPlatform != TargetPlatform.android);

      test('getCurrentWebViewPackage', () async {
        expect(await AndroidInAppWebViewController.getCurrentWebViewPackage(),
            isNotNull);
      }, skip: defaultTargetPlatform != TargetPlatform.android);

      test('setWebContentsDebuggingEnabled', () async {
        expect(
            AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true),
            completes);
      }, skip: defaultTargetPlatform != TargetPlatform.android);
    }, skip: defaultTargetPlatform != TargetPlatform.android);

    group('ios methods', () {
      testWidgets('reloadFromOrigin', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> pageLoaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest:
                  URLRequest(url: Uri.parse('https://flutter.dev')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        );

        final InAppWebViewController controller =
            await controllerCompleter.future;
        await pageLoaded.future;
        await expectLater(controller.ios.reloadFromOrigin(), completes);
      }, skip: defaultTargetPlatform != TargetPlatform.iOS);

      testWidgets('createPdf', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> pageLoaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest:
                  URLRequest(url: Uri.parse('https://flutter.dev')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        );

        final InAppWebViewController controller =
            await controllerCompleter.future;
        await pageLoaded.future;

        var iosWKPdfConfiguration = IOSWKPDFConfiguration(
            rect: InAppWebViewRect(width: 100, height: 100, x: 50, y: 50));
        var pdf = await controller.ios
            .createPdf(iosWKPdfConfiguration: iosWKPdfConfiguration);
        expect(pdf, isNotNull);
      }, skip: defaultTargetPlatform != TargetPlatform.iOS);

      testWidgets('createWebArchiveData', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> pageLoaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest:
                  URLRequest(url: Uri.parse('https://flutter.dev')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        );

        final InAppWebViewController controller =
            await controllerCompleter.future;
        await pageLoaded.future;

        expect(await controller.ios.createWebArchiveData(), isNotNull);
      }, skip: defaultTargetPlatform != TargetPlatform.iOS);

      testWidgets('Apple Pay API enabled', (WidgetTester tester) async {
        final Completer<void> pageLoaded = Completer<void>();
        final Completer<String> alertMessageCompleter = Completer<String>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(data: """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Pay API</title>
</head>
<body>
    <script>
      window.alert(window.ApplePaySession != null);
    </script>
</body>
</html>
                  """),
              initialOptions: InAppWebViewGroupOptions(
                ios: IOSInAppWebViewOptions(
                  applePayAPIEnabled: true,
                ),
              ),
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
              onJsAlert: (controller, jsAlertRequest) async {
                alertMessageCompleter.complete(jsAlertRequest.message);
              },
            ),
          ),
        );
        await pageLoaded.future;
        final message = await alertMessageCompleter.future;
        expect(message, 'true');
      }, skip: defaultTargetPlatform != TargetPlatform.iOS);

      test('handlesURLScheme', () async {
        expect(await IOSInAppWebViewController.handlesURLScheme("http"), true);
        expect(await IOSInAppWebViewController.handlesURLScheme("https"), true);
      }, skip: defaultTargetPlatform != TargetPlatform.iOS);
    }, skip: defaultTargetPlatform != TargetPlatform.iOS);
  });

  group('Service Worker', () {
    testWidgets('shouldInterceptRequest', (WidgetTester tester) async {
      final Completer completer = Completer();

      var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        AndroidServiceWorkerController serviceWorkerController =
            AndroidServiceWorkerController.instance();

        await serviceWorkerController
            .setServiceWorkerClient(AndroidServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            if (!completer.isCompleted) {
              completer.complete();
            }
            return null;
          },
        ));
      } else {
        completer.complete();
      }

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://mdn.github.io/sw-test/')),
          ),
        ),
      );

      expect(completer.future, completes);
    }, skip: defaultTargetPlatform != TargetPlatform.android);

    testWidgets('setServiceWorkerClient to null', (WidgetTester tester) async {
      final Completer<String> pageLoaded = Completer<String>();

      var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        AndroidServiceWorkerController serviceWorkerController =
            AndroidServiceWorkerController.instance();

        await serviceWorkerController.setServiceWorkerClient(null);
      }

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://mdn.github.io/sw-test/')),
            onLoadStop: (controller, url) {
              pageLoaded.complete(url!.toString());
            },
          ),
        ),
      );

      final String url = await pageLoaded.future;
      expect(url, "https://mdn.github.io/sw-test/");
    }, skip: defaultTargetPlatform != TargetPlatform.android);
  });

  group('Cookie Manager', () {
    testWidgets('set, get, delete', (WidgetTester tester) async {
      CookieManager cookieManager = CookieManager.instance();
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<String> pageLoaded = Completer<String>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://flutter.dev/')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
              clearCache: true,
            )),
            onLoadStop: (controller, url) {
              pageLoaded.complete(url!.toString());
            },
          ),
        ),
      );

      final url = Uri.parse(await pageLoaded.future);

      await cookieManager.setCookie(
          url: url, name: "myCookie", value: "myValue");
      List<Cookie> cookies = await cookieManager.getCookies(url: url);
      expect(cookies, isNotEmpty);

      Cookie? cookie =
          await cookieManager.getCookie(url: url, name: "myCookie");
      expect(cookie?.value.toString(), "myValue");

      await cookieManager.deleteCookie(url: url, name: "myCookie");
      cookie = await cookieManager.getCookie(url: url, name: "myCookie");
      expect(cookie, isNull);

      await cookieManager.deleteCookies(url: url);
      cookies = await cookieManager.getCookies(url: url);
      expect(cookies, isEmpty);
    });
  });

  group('HeadlessInAppWebView', () {
    test('run and dispose', () async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      var headlessWebView = new HeadlessInAppWebView(
        initialUrlRequest:
            URLRequest(url: Uri.parse("https://github.com/flutter")),
        onWebViewCreated: (controller) {
          controllerCompleter.complete(controller);
        },
      );
      headlessWebView.onLoadStop = (controller, url) async {
        pageLoaded.complete();
      };

      await headlessWebView.run();
      expect(headlessWebView.isRunning(), true);

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final String? url = (await controller.getUrl())?.toString();
      expect(url, 'https://github.com/flutter');

      await headlessWebView.dispose();

      expect(headlessWebView.isRunning(), false);
    });

    test('take screenshot', () async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      var headlessWebView = new HeadlessInAppWebView(
          initialUrlRequest:
              URLRequest(url: Uri.parse("https://github.com/flutter")),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) async {
            pageLoaded.complete();
          });

      await headlessWebView.run();
      expect(headlessWebView.isRunning(), true);

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final String? url = (await controller.getUrl())?.toString();
      expect(url, 'https://github.com/flutter');

      final Size? size = await headlessWebView.getSize();
      expect(size, isNotNull);

      final Uint8List? screenshot = await controller.takeScreenshot();
      expect(screenshot, isNotNull);

      await headlessWebView.dispose();

      expect(headlessWebView.isRunning(), false);
    });

    test('set and get custom size', () async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();

      var headlessWebView = new HeadlessInAppWebView(
        initialUrlRequest:
            URLRequest(url: Uri.parse("https://github.com/flutter")),
        initialSize: Size(600, 800),
        onWebViewCreated: (controller) {
          controllerCompleter.complete(controller);
        },
      );

      await headlessWebView.run();
      expect(headlessWebView.isRunning(), true);

      final Size? size = await headlessWebView.getSize();
      expect(size, isNotNull);
      expect(size, Size(600, 800));

      await headlessWebView.setSize(Size(1080, 1920));
      final Size? newSize = await headlessWebView.getSize();
      expect(newSize, isNotNull);
      expect(newSize, Size(1080, 1920));

      await headlessWebView.dispose();

      expect(headlessWebView.isRunning(), false);
    });

    test('set/get options', () async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      var headlessWebView = new HeadlessInAppWebView(
        initialUrlRequest:
            URLRequest(url: Uri.parse("https://github.com/flutter")),
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(javaScriptEnabled: false)),
        onWebViewCreated: (controller) {
          controllerCompleter.complete(controller);
        },
        onLoadStop: (controller, url) async {
          pageLoaded.complete();
        },
      );

      await headlessWebView.run();
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      InAppWebViewGroupOptions? options = await controller.getOptions();
      expect(options, isNotNull);
      expect(options!.crossPlatform.javaScriptEnabled, false);

      await controller.setOptions(
          options: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(javaScriptEnabled: true)));

      options = await controller.getOptions();
      expect(options, isNotNull);
      expect(options!.crossPlatform.javaScriptEnabled, true);
    });
  });

  group('InAppBrowser', () {
    test('openUrlRequest and close', () async {
      var inAppBrowser = new MyInAppBrowser();
      expect(inAppBrowser.isOpened(), false);
      expect(() async {
        await inAppBrowser.show();
      }, throwsA(isInstanceOf<InAppBrowserNotOpenedException>()));

      await inAppBrowser.openUrlRequest(
          urlRequest: URLRequest(url: Uri.parse("https://github.com/flutter")));
      await inAppBrowser.browserCreated.future;
      expect(inAppBrowser.isOpened(), true);
      expect(() async {
        await inAppBrowser.openUrlRequest(
            urlRequest: URLRequest(url: Uri.parse("https://flutter.dev")));
      }, throwsA(isInstanceOf<InAppBrowserAlreadyOpenedException>()));

      await inAppBrowser.firstPageLoaded.future;
      var controller = inAppBrowser.webViewController;

      final String? url = (await controller.getUrl())?.toString();
      expect(url, 'https://github.com/flutter');

      await inAppBrowser.close();
      expect(inAppBrowser.isOpened(), false);
      expect(() async => await inAppBrowser.webViewController.getUrl(),
          throwsA(isInstanceOf<MissingPluginException>()));
    });

    test('openFile and close', () async {
      var inAppBrowser = new MyInAppBrowser();
      expect(inAppBrowser.isOpened(), false);
      expect(() async {
        await inAppBrowser.show();
      }, throwsA(isInstanceOf<InAppBrowserNotOpenedException>()));

      await inAppBrowser.openFile(
          assetFilePath: "test_assets/in_app_webview_initial_file_test.html");
      await inAppBrowser.browserCreated.future;
      expect(inAppBrowser.isOpened(), true);
      expect(() async {
        await inAppBrowser.openUrlRequest(
            urlRequest:
                URLRequest(url: Uri.parse("https://github.com/flutter")));
      }, throwsA(isInstanceOf<InAppBrowserAlreadyOpenedException>()));

      await inAppBrowser.firstPageLoaded.future;
      var controller = inAppBrowser.webViewController;

      final String? url = (await controller.getUrl())?.toString();
      expect(url, endsWith("in_app_webview_initial_file_test.html"));

      await inAppBrowser.close();
      expect(inAppBrowser.isOpened(), false);
      expect(() async => await inAppBrowser.webViewController.getUrl(),
          throwsA(isInstanceOf<MissingPluginException>()));
    });

    test('openData and close', () async {
      var inAppBrowser = new MyInAppBrowser();
      expect(inAppBrowser.isOpened(), false);
      expect(() async {
        await inAppBrowser.show();
      }, throwsA(isInstanceOf<InAppBrowserNotOpenedException>()));

      await inAppBrowser.openData(
          data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <link rel="stylesheet" href="https://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css">
        <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
    </head>
    <body>
      <img src="https://via.placeholder.com/100x50" alt="placeholder 100x50">
    </body>
</html>
""",
          encoding: 'utf-8',
          mimeType: 'text/html',
          androidHistoryUrl: Uri.parse("https://flutter.dev"),
          baseUrl: Uri.parse("https://flutter.dev"));
      await inAppBrowser.browserCreated.future;
      expect(inAppBrowser.isOpened(), true);
      expect(() async {
        await inAppBrowser.openUrlRequest(
            urlRequest:
                URLRequest(url: Uri.parse("https://github.com/flutter")));
      }, throwsA(isInstanceOf<InAppBrowserAlreadyOpenedException>()));

      await inAppBrowser.firstPageLoaded.future;
      var controller = inAppBrowser.webViewController;

      final String? url = (await controller.getUrl())?.toString();
      expect(url, 'https://flutter.dev/');

      await inAppBrowser.close();
      expect(inAppBrowser.isOpened(), false);
      expect(() async => await inAppBrowser.webViewController.getUrl(),
          throwsA(isInstanceOf<MissingPluginException>()));
    });

    test('set/get options', () async {
      var inAppBrowser = new MyInAppBrowser();
      await inAppBrowser.openUrlRequest(
          urlRequest: URLRequest(url: Uri.parse("https://github.com/flutter")),
          options: InAppBrowserClassOptions(
              crossPlatform: InAppBrowserOptions(hideToolbarTop: true)));
      await inAppBrowser.browserCreated.future;
      await inAppBrowser.firstPageLoaded.future;

      InAppBrowserClassOptions? options = await inAppBrowser.getOptions();
      expect(options, isNotNull);
      expect(options!.crossPlatform.hideToolbarTop, true);

      await inAppBrowser.setOptions(
          options: InAppBrowserClassOptions(
              crossPlatform: InAppBrowserOptions(hideToolbarTop: false)));

      options = await inAppBrowser.getOptions();
      expect(options, isNotNull);
      expect(options!.crossPlatform.hideToolbarTop, false);
    });
  });

  group('ChromeSafariBrowser', () {
    test('open and close', () async {
      var chromeSafariBrowser = new MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
          url: Uri.parse("https://github.com/flutter"));
      await chromeSafariBrowser.browserCreated.future;
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: Uri.parse("https://flutter.dev"));
      }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await chromeSafariBrowser.browserClosed.future;
      expect(chromeSafariBrowser.isOpened(), false);
    });

    test('add custom menu item', () async {
      var chromeSafariBrowser = new MyChromeSafariBrowser();
      chromeSafariBrowser.addMenuItem(ChromeSafariBrowserMenuItem(
          id: 2,
          label: 'Custom item menu 1',
          action: (url, title) {
            print('Custom item menu 1 clicked!');
          }));
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
          url: Uri.parse("https://github.com/flutter"));
      await chromeSafariBrowser.browserCreated.future;
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: Uri.parse("https://flutter.dev"));
      }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await chromeSafariBrowser.browserClosed.future;
      expect(chromeSafariBrowser.isOpened(), false);
    });

    group('Android Custom Tabs', () {
      test('add custom action button', () async {
        var chromeSafariBrowser = new MyChromeSafariBrowser();
        var actionButtonIcon =
            await rootBundle.load('test_assets/images/flutter-logo.png');
        chromeSafariBrowser.setActionButton(ChromeSafariBrowserActionButton(
            id: 1,
            description: 'Action Button description',
            icon: actionButtonIcon.buffer.asUint8List(),
            action: (url, title) {
              print('Action Button 1 clicked!');
            }));
        expect(chromeSafariBrowser.isOpened(), false);

        await chromeSafariBrowser.open(
            url: Uri.parse("https://github.com/flutter"));
        await chromeSafariBrowser.browserCreated.future;
        expect(chromeSafariBrowser.isOpened(), true);
        expect(() async {
          await chromeSafariBrowser.open(url: Uri.parse("https://flutter.dev"));
        }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

        await expectLater(
            chromeSafariBrowser.firstPageLoaded.future, completes);
        await chromeSafariBrowser.close();
        await chromeSafariBrowser.browserClosed.future;
        expect(chromeSafariBrowser.isOpened(), false);
      });

      test('Custom Tabs single instance', () async {
        var chromeSafariBrowser = new MyChromeSafariBrowser();
        expect(chromeSafariBrowser.isOpened(), false);

        await chromeSafariBrowser.open(
            url: Uri.parse("https://github.com/flutter"),
            options: ChromeSafariBrowserClassOptions(
                android:
                    AndroidChromeCustomTabsOptions(isSingleInstance: true)));
        await chromeSafariBrowser.browserCreated.future;
        expect(chromeSafariBrowser.isOpened(), true);
        expect(() async {
          await chromeSafariBrowser.open(url: Uri.parse("https://flutter.dev"));
        }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

        await expectLater(
            chromeSafariBrowser.firstPageLoaded.future, completes);
        await chromeSafariBrowser.close();
        await chromeSafariBrowser.browserClosed.future;
        expect(chromeSafariBrowser.isOpened(), false);
      });

      test('Trusted Web Activity', () async {
        var chromeSafariBrowser = new MyChromeSafariBrowser();
        expect(chromeSafariBrowser.isOpened(), false);

        await chromeSafariBrowser.open(
            url: Uri.parse("https://github.com/flutter"),
            options: ChromeSafariBrowserClassOptions(
                android: AndroidChromeCustomTabsOptions(
                    isTrustedWebActivity: true)));
        await chromeSafariBrowser.browserCreated.future;
        expect(chromeSafariBrowser.isOpened(), true);
        expect(() async {
          await chromeSafariBrowser.open(url: Uri.parse("https://flutter.dev"));
        }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

        await expectLater(
            chromeSafariBrowser.firstPageLoaded.future, completes);
        await chromeSafariBrowser.close();
        await chromeSafariBrowser.browserClosed.future;
        expect(chromeSafariBrowser.isOpened(), false);
      });

      test('Trusted Web Activity single instance', () async {
        var chromeSafariBrowser = new MyChromeSafariBrowser();
        expect(chromeSafariBrowser.isOpened(), false);

        await chromeSafariBrowser.open(
            url: Uri.parse("https://github.com/flutter"),
            options: ChromeSafariBrowserClassOptions(
                android: AndroidChromeCustomTabsOptions(
                    isTrustedWebActivity: true, isSingleInstance: true)));
        await chromeSafariBrowser.browserCreated.future;
        expect(chromeSafariBrowser.isOpened(), true);
        expect(() async {
          await chromeSafariBrowser.open(url: Uri.parse("https://flutter.dev"));
        }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

        await expectLater(
            chromeSafariBrowser.firstPageLoaded.future, completes);
        await chromeSafariBrowser.close();
        await chromeSafariBrowser.browserClosed.future;
        expect(chromeSafariBrowser.isOpened(), false);
      });
    }, skip: defaultTargetPlatform != TargetPlatform.android);
  });

  group('InAppLocalhostServer', () {
    final InAppLocalhostServer localhostServer = InAppLocalhostServer();

    setUpAll(() async {
      await localhostServer.start();
    });

    testWidgets('load asset file', (WidgetTester tester) async {
      expect(localhostServer.isRunning(), true);

      final Completer controllerCompleter = Completer<InAppWebViewController>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
                url: Uri.parse('http://localhost:8080/test_assets/index.html')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(currentUrl, 'http://localhost:8080/test_assets/index.html');
    });

    tearDownAll(() async {
      await localhostServer.close();
    });
  });
}
