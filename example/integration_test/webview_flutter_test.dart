import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import '.env.dart';

/// Returns a matcher that matches the isNullOrEmpty property.
const Matcher isNullOrEmpty = _NullOrEmpty();

class _NullOrEmpty extends Matcher {
  const _NullOrEmpty();

  @override
  bool matches(Object? item, Map matchState) =>
      item == null || (item as dynamic).isEmpty;

  @override
  Description describe(Description description) =>
      description.add('null or empty');
}

class Foo {
  String? bar;
  String? baz;

  Foo({this.bar, this.baz});

  Map<String, dynamic> toJson() {
    return {'bar': this.bar, 'baz': this.baz};
  }
}

class MyInAppBrowser extends InAppBrowser {
  final Completer<void> browserCreated = Completer<void>();
  final Completer<void> firstPageLoaded = Completer<void>();

  MyInAppBrowser(
      {int? windowId, UnmodifiableListView<UserScript>? initialUserScripts})
      : super(windowId: windowId, initialUserScripts: initialUserScripts);

  @override
  Future onBrowserCreated() async {
    browserCreated.complete();
  }

  @override
  void onLoadStop(Uri? url) {
    super.onLoadStop(url);

    if (!firstPageLoaded.isCompleted) {
      firstPageLoaded.complete();
    }
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  final Completer<void> browserCreated = Completer<void>();
  final Completer<void> firstPageLoaded = Completer<void>();
  final Completer<void> browserClosed = Completer<void>();

  @override
  void onOpened() {
    browserCreated.complete();
  }

  @override
  void onCompletedInitialLoad() {
    firstPageLoaded.complete();
  }

  @override
  void onClosed() {
    browserClosed.complete();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  group('InAppWebView', () {
    testWidgets('initialUrlRequest', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
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
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(currentUrl, 'https://github.com/flutter');
    });

    testWidgets('set/get options', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://github.com/flutter')),
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(javaScriptEnabled: false)),
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

    group('javascript code evaluation', () {
      testWidgets('evaluateJavascript', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
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

        var result = await controller.evaluateJavascript(source: """
        [1, true, ["bar", 5], {"foo": "baz"}];
      """);
        expect(result, isNotNull);
        expect(result[0], 1);
        expect(result[1], true);
        expect(listEquals(result[2] as List<dynamic>?, ["bar", 5]), true);
        expect(
            mapEquals(result[3]?.cast<String, String>(), {"foo": "baz"}), true);
      });

      testWidgets('evaluateJavascript with content world',
          (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
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

        await controller.evaluateJavascript(
            source: "var foo = 49;",
            contentWorld: ContentWorld.world(name: "custom-world"));
        var result = await controller.evaluateJavascript(source: "foo");
        expect(result, isNull);

        result = await controller.evaluateJavascript(
            source: "foo",
            contentWorld: ContentWorld.world(name: "custom-world"));
        expect(result, 49);
      });

      testWidgets('callAsyncJavaScript', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
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

        final String functionBody = """
        var p = new Promise(function (resolve, reject) {
           window.setTimeout(function() {
             if (x >= 0) {
               resolve(x);
             } else {
               reject(y);
             }
           }, 1000);
        });
        await p;
        return p;
      """;

        var result = await controller.callAsyncJavaScript(
            functionBody: functionBody,
            arguments: {'x': 49, 'y': 'error message'});
        expect(result, isNotNull);
        expect(result!.error, isNull);
        expect(result.value, 49);

        result = await controller.callAsyncJavaScript(
            functionBody: functionBody,
            arguments: {'x': -49, 'y': 'error message'});
        expect(result, isNotNull);
        expect(result!.value, isNull);
        expect(result.error, 'error message');
      });

      testWidgets('callAsyncJavaScript with content world',
          (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
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

        await controller.callAsyncJavaScript(
            functionBody: "window.foo = 49;",
            contentWorld: ContentWorld.world(name: "custom-world"));
        var result = await controller.callAsyncJavaScript(
            functionBody: "return window.foo;");
        expect(result, isNotNull);
        expect(result!.error, isNull);
        expect(result.value, isNull);

        result = await controller.callAsyncJavaScript(
            functionBody: "return window.foo;",
            contentWorld: ContentWorld.world(name: "custom-world"));
        expect(result, isNotNull);
        expect(result!.error, isNull);
        expect(result.value, 49);
      });
    });

    testWidgets('loadUrl', (WidgetTester tester) async {
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
      var url = await pageLoads.stream.first;
      expect(url, 'https://github.com/flutter');

      await controller.loadUrl(
          urlRequest: URLRequest(url: Uri.parse('https://www.google.com/')));
      url = await pageLoads.stream.first;
      expect(url, 'https://www.google.com/');

      pageLoads.close();
    });

    testWidgets('loadUrl with headers', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final StreamController<String> pageStarts =
          StreamController<String>.broadcast();
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
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(javaScriptEnabled: true)),
            onLoadStart: (controller, url) {
              pageStarts.add(url!.toString());
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      final Map<String, String> headers = <String, String>{
        'test_header': 'flutter_test_header'
      };
      await controller.loadUrl(
          urlRequest: URLRequest(
              url: Uri.parse('https://flutter-header-echo.herokuapp.com/'),
              headers: headers));
      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(currentUrl, 'https://flutter-header-echo.herokuapp.com/');

      await pageStarts.stream.firstWhere((String url) => url == currentUrl);
      await pageLoads.stream.firstWhere((String url) => url == currentUrl);

      final String? content = await controller.evaluateJavascript(
          source: 'document.documentElement.innerText');
      expect(content!.contains('flutter_test_header'), isTrue);

      pageStarts.close();
      pageLoads.close();
    });

    group("iOS loadFileURL", () {
      late Directory appSupportDir;
      late File fileHtml;
      late File fileJs;

      setUpAll(() async {
        appSupportDir = (await getApplicationSupportDirectory());

        final Directory htmlFolder = Directory('${appSupportDir.path}/html/');
        if (!await htmlFolder.exists()) {
          await htmlFolder.create(recursive: true);
        }

        final Directory jsFolder = Directory('${appSupportDir.path}/js/');
        if (!await jsFolder.exists()) {
          await jsFolder.create(recursive: true);
        }

        var html = """
      <!DOCTYPE html><html>
      <head>
        <title>file scheme</title>
      </head>
      <body>
        <script src="../js/main.js"></script>
      </body>
      </html>
    """;
        fileHtml = File(htmlFolder.path + "index.html");
        fileHtml.writeAsStringSync(html);

        var js = """
      console.log('message');
      """;
        fileJs = File(jsFolder.path + "main.js");
        fileJs.writeAsStringSync(js);
      });

      testWidgets('initialUrl with file:// scheme and allowingReadAccessTo',
          (WidgetTester tester) async {
        final Completer<ConsoleMessage?> consoleMessageShouldNotComplete =
            Completer<ConsoleMessage?>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest:
                  URLRequest(url: Uri.parse('file://${fileHtml.path}')),
              onConsoleMessage: (controller, consoleMessage) {
                consoleMessageShouldNotComplete.complete(consoleMessage);
              },
            ),
          ),
        );
        var result = await consoleMessageShouldNotComplete.future
            .timeout(const Duration(seconds: 2), onTimeout: () => null);
        expect(result, null);

        final Completer<ConsoleMessage> consoleMessageCompleter =
            Completer<ConsoleMessage>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest:
                  URLRequest(url: Uri.parse('file://${fileHtml.path}')),
              initialOptions: InAppWebViewGroupOptions(
                  ios: IOSInAppWebViewOptions(
                      allowingReadAccessTo:
                          Uri.parse('file://${appSupportDir.path}/'))),
              onConsoleMessage: (controller, consoleMessage) {
                consoleMessageCompleter.complete(consoleMessage);
              },
            ),
          ),
        );
        final ConsoleMessage consoleMessage =
            await consoleMessageCompleter.future;
        expect(consoleMessage.messageLevel, ConsoleMessageLevel.LOG);
        expect(consoleMessage.message, 'message');
      }, skip: !Platform.isIOS);

      testWidgets(
          'loadUrl with file:// scheme and allowingReadAccessTo argument',
          (WidgetTester tester) async {
        final Completer<ConsoleMessage?> consoleMessageShouldNotComplete =
            Completer<ConsoleMessage?>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              onWebViewCreated: (controller) {
                controller.loadUrl(
                    urlRequest:
                        URLRequest(url: Uri.parse('file://${fileHtml.path}')));
              },
              onConsoleMessage: (controller, consoleMessage) {
                consoleMessageShouldNotComplete.complete(consoleMessage);
              },
            ),
          ),
        );
        var result = await consoleMessageShouldNotComplete.future
            .timeout(const Duration(seconds: 2), onTimeout: () => null);
        expect(result, null);

        final Completer<ConsoleMessage> consoleMessageCompleter =
            Completer<ConsoleMessage>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              onWebViewCreated: (controller) {
                controller.loadUrl(
                    urlRequest:
                        URLRequest(url: Uri.parse('file://${fileHtml.path}')),
                    allowingReadAccessTo:
                        Uri.parse('file://${appSupportDir.path}/'));
              },
              onConsoleMessage: (controller, consoleMessage) {
                consoleMessageCompleter.complete(consoleMessage);
              },
            ),
          ),
        );
        final ConsoleMessage consoleMessage =
            await consoleMessageCompleter.future;
        expect(consoleMessage.messageLevel, ConsoleMessageLevel.LOG);
        expect(consoleMessage.message, 'message');
      }, skip: !Platform.isIOS);
    }, skip: !Platform.isIOS);

    testWidgets('JavaScript Handler', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageStarted = Completer<void>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<void> handlerFoo = Completer<void>();
      final Completer<void> handlerFooWithArgs = Completer<void>();
      final List<dynamic> messagesReceived = <dynamic>[];
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialFile:
                "test_assets/in_app_webview_javascript_handler_test.html",
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);

              controller.addJavaScriptHandler(
                  handlerName: 'handlerFoo',
                  callback: (args) {
                    handlerFoo.complete();
                    return Foo(bar: 'bar_value', baz: 'baz_value');
                  });

              controller.addJavaScriptHandler(
                  handlerName: 'handlerFooWithArgs',
                  callback: (args) {
                    messagesReceived.add(args[0] as int);
                    messagesReceived.add(args[1] as bool);
                    messagesReceived.add(args[2] as List<dynamic>?);
                    messagesReceived.add(args[3]?.cast<String, String>()
                        as Map<String, String>?);
                    messagesReceived.add(args[4]?.cast<String, String>()
                        as Map<String, String>?);
                    handlerFooWithArgs.complete();
                  });
            },
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(javaScriptEnabled: true)),
            onLoadStart: (controller, url) {
              pageStarted.complete();
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      await pageStarted.future;
      await pageLoaded.future;
      await handlerFoo.future;
      await handlerFooWithArgs.future;

      expect(messagesReceived[0], 1);
      expect(messagesReceived[1], true);
      expect(
          listEquals(messagesReceived[2] as List<dynamic>?, ["bar", 5]), true);
      expect(mapEquals(messagesReceived[3], {"foo": "baz"}), true);
      expect(
          mapEquals(
              messagesReceived[4], {"bar": "bar_value", "baz": "baz_value"}),
          true);
    });

    testWidgets('resize webview', (WidgetTester tester) async {
      final String resizeTest = '''
        <!DOCTYPE html><html>
        <head><title>Resize test</title>
          <script type="text/javascript">
            function onResize() {
              window.flutter_inappwebview.callHandler('resize')
            }
            function onLoad() {
              window.onresize = onResize;
            }
          </script>
        </head>
        <body onload="onLoad();" bgColor="blue">
        </body>
        </html>
      ''';
      final String resizeTestBase64 =
          base64Encode(const Utf8Encoder().convert(resizeTest));
      final Completer<void> resizeCompleter = Completer<void>();
      final Completer<void> pageStarted = Completer<void>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final GlobalKey key = GlobalKey();

      final InAppWebView webView = InAppWebView(
        key: key,
        initialUrlRequest: URLRequest(
            url: Uri.parse(
                'data:text/html;charset=utf-8;base64,$resizeTestBase64')),
        onWebViewCreated: (controller) {
          controllerCompleter.complete(controller);

          controller.addJavaScriptHandler(
              handlerName: 'resize',
              callback: (args) {
                resizeCompleter.complete(true);
              });
        },
        onLoadStart: (controller, url) {
          pageStarted.complete();
        },
        onLoadStop: (controller, url) {
          pageLoaded.complete();
        },
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(javaScriptEnabled: true)),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: <Widget>[
              SizedBox(
                width: 200,
                height: 200,
                child: webView,
              ),
            ],
          ),
        ),
      );

      await controllerCompleter.future;
      await pageStarted.future;
      await pageLoaded.future;

      expect(resizeCompleter.isCompleted, false);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: <Widget>[
              SizedBox(
                width: 400,
                height: 400,
                child: webView,
              ),
            ],
          ),
        ),
      );

      await resizeCompleter.future;
    });

    testWidgets('set custom userAgent', (WidgetTester tester) async {
      final Completer controllerCompleter1 =
          Completer<InAppWebViewController>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
              userAgent: 'Custom_User_Agent1',
            )),
            onWebViewCreated: (controller) {
              controllerCompleter1.complete(controller);
            },
          ),
        ),
      );
      InAppWebViewController controller1 = await controllerCompleter1.future;
      final String customUserAgent1 =
          await controller1.evaluateJavascript(source: 'navigator.userAgent;');
      expect(customUserAgent1, 'Custom_User_Agent1');

      await controller1.setOptions(
          options: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
        userAgent: 'Custom_User_Agent2',
      )));

      final String customUserAgent2 =
          await controller1.evaluateJavascript(source: 'navigator.userAgent;');
      expect(customUserAgent2, 'Custom_User_Agent2');
    });

    group('Video playback policy', () {
      String videoTestBase64 = "";
      setUpAll(() async {
        final ByteData videoData =
            await rootBundle.load('test_assets/sample_video.mp4');
        final String base64VideoData =
            base64Encode(Uint8List.view(videoData.buffer));
        final String videoTest = '''
        <!DOCTYPE html><html>
        <head><title>Video auto play</title>
          <script type="text/javascript">
            function play() {
              var video = document.getElementById("video");
              video.play();
            }
            function isPaused() {
              var video = document.getElementById("video");
              return video.paused;
            }
            function exitFullscreen() {
              if (document.exitFullscreen) {
                document.exitFullscreen();
              } else if (document.webkitExitFullscreen) {
                document.webkitExitFullscreen();
              } else if (document.msExitFullscreen) {
                document.msExitFullscreen();
              }
            }
          </script>
        </head>
        <body onload="play();">
        <video controls playsinline autoplay id="video">
          <source src="data:video/mp4;charset=utf-8;base64,$base64VideoData">
        </video>
        </body>
        </html>
      ''';
        videoTestBase64 = base64Encode(const Utf8Encoder().convert(videoTest));
      });

      testWidgets('Auto media playback', (WidgetTester tester) async {
        Completer<InAppWebViewController> controllerCompleter =
            Completer<InAppWebViewController>();
        Completer<void> pageLoaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      'data:text/html;charset=utf-8;base64,$videoTestBase64')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                      javaScriptEnabled: true,
                      mediaPlaybackRequiresUserGesture: false)),
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        );
        InAppWebViewController controller = await controllerCompleter.future;
        await pageLoaded.future;

        bool isPaused =
            await controller.evaluateJavascript(source: 'isPaused();');
        expect(isPaused, false);

        controllerCompleter = Completer<InAppWebViewController>();
        pageLoaded = Completer<void>();

        // We change the key to re-create a new webview as we change the mediaPlaybackRequiresUserGesture
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      'data:text/html;charset=utf-8;base64,$videoTestBase64')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                      javaScriptEnabled: true,
                      mediaPlaybackRequiresUserGesture: true)),
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        );

        controller = await controllerCompleter.future;
        await pageLoaded.future;

        isPaused = await controller.evaluateJavascript(source: 'isPaused();');
        expect(isPaused, true);
      });

      testWidgets('Video plays inline when allowsInlineMediaPlayback is true',
          (WidgetTester tester) async {
        Completer<InAppWebViewController> controllerCompleter =
            Completer<InAppWebViewController>();
        Completer<void> pageLoaded = Completer<void>();
        Completer<void> onEnterFullscreenCompleter = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      'data:text/html;charset=utf-8;base64,$videoTestBase64')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                  ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true)),
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
              onEnterFullscreen: (controller) {
                onEnterFullscreenCompleter.complete();
              },
            ),
          ),
        );

        await pageLoaded.future;
        expect(onEnterFullscreenCompleter.future, doesNotComplete);
      });

      testWidgets(
          'Video plays fullscreen when allowsInlineMediaPlayback is false',
          (WidgetTester tester) async {
        Completer<InAppWebViewController> controllerCompleter =
            Completer<InAppWebViewController>();
        Completer<void> pageLoaded = Completer<void>();
        Completer<void> onEnterFullscreenCompleter = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      'data:text/html;charset=utf-8;base64,$videoTestBase64')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                  ios:
                      IOSInAppWebViewOptions(allowsInlineMediaPlayback: false)),
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
              onEnterFullscreen: (controller) {
                onEnterFullscreenCompleter.complete();
              },
            ),
          ),
        );

        await pageLoaded.future;
        await expectLater(onEnterFullscreenCompleter.future, completes);
      }, skip: true);

      testWidgets('exit fullscreen event', (WidgetTester tester) async {
        Completer<InAppWebViewController> controllerCompleter =
            Completer<InAppWebViewController>();
        Completer<void> pageLoaded = Completer<void>();
        Completer<void> onExitFullscreenCompleter = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      'data:text/html;charset=utf-8;base64,$videoTestBase64')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                  ios:
                      IOSInAppWebViewOptions(allowsInlineMediaPlayback: false)),
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
              onExitFullscreen: (controller) {
                onExitFullscreenCompleter.complete();
              },
            ),
          ),
        );

        InAppWebViewController controller = await controllerCompleter.future;
        await pageLoaded.future;

        await Future.delayed(Duration(seconds: 2));
        await controller.evaluateJavascript(source: "exitFullscreen();");

        await expectLater(onExitFullscreenCompleter.future, completes);
      }, skip: true /*!Platform.isAndroid*/);
    });

    group('Audio playback policy', () {
      String audioTestBase64 = "";
      setUpAll(() async {
        final ByteData audioData =
            await rootBundle.load('test_assets/sample_audio.ogg');
        final String base64AudioData =
            base64Encode(Uint8List.view(audioData.buffer));
        final String audioTest = '''
        <!DOCTYPE html><html>
        <head><title>Audio auto play</title>
          <script type="text/javascript">
            function play() {
              var audio = document.getElementById("audio");
              audio.play();
            }
            function isPaused() {
              var audio = document.getElementById("audio");
              return audio.paused;
            }
          </script>
        </head>
        <body onload="play();">
        <audio controls id="audio">
          <source src="data:audio/ogg;charset=utf-8;base64,$base64AudioData">
        </audio>
        </body>
        </html>
      ''';
        audioTestBase64 = base64Encode(const Utf8Encoder().convert(audioTest));
      });

      testWidgets('Auto media playback', (WidgetTester tester) async {
        Completer<InAppWebViewController> controllerCompleter =
            Completer<InAppWebViewController>();
        Completer<void> pageStarted = Completer<void>();
        Completer<void> pageLoaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      'data:text/html;charset=utf-8;base64,$audioTestBase64')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                      javaScriptEnabled: true,
                      mediaPlaybackRequiresUserGesture: false)),
              onLoadStart: (controller, url) {
                pageStarted.complete();
              },
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        );
        InAppWebViewController controller = await controllerCompleter.future;
        await pageStarted.future;
        await pageLoaded.future;

        bool isPaused =
            await controller.evaluateJavascript(source: 'isPaused();');
        expect(isPaused, false);

        controllerCompleter = Completer<InAppWebViewController>();
        pageStarted = Completer<void>();
        pageLoaded = Completer<void>();

        // We change the key to re-create a new webview as we change the mediaPlaybackRequiresUserGesture
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      'data:text/html;charset=utf-8;base64,$audioTestBase64')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    mediaPlaybackRequiresUserGesture: true),
              ),
              onLoadStart: (controller, url) {
                pageStarted.complete();
              },
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        );

        controller = await controllerCompleter.future;
        await pageStarted.future;
        await pageLoaded.future;

        isPaused = await controller.evaluateJavascript(source: 'isPaused();');
        expect(isPaused, true);
      });
    });

    testWidgets('getTitle', (WidgetTester tester) async {
      final String getTitleTest = '''
        <!DOCTYPE html><html>
        <head><title>Some title</title>
        </head>
        <body>
        </body>
        </html>
      ''';
      final String getTitleTestBase64 =
          base64Encode(const Utf8Encoder().convert(getTitleTest));
      final Completer<void> pageStarted = Completer<void>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer controllerCompleter = Completer<InAppWebViewController>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            initialUrlRequest: URLRequest(
                url: Uri.parse(
                    'data:text/html;charset=utf-8;base64,$getTitleTestBase64')),
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
      await pageLoaded.future;

      final String? title = await controller.getTitle();
      expect(title, 'Some title');
    });

    group('Programmatic Scroll', () {
      testWidgets('setAndGetScrollPosition', (WidgetTester tester) async {
        final String scrollTestPage = '''
        <!DOCTYPE html>
        <html>
          <head>
            <style>
              body {
                height: 100%;
                width: 100%;
              }
              #container{
                width:5000px;
                height:5000px;
            }
            </style>
          </head>
          <body>
            <div id="container"/>
          </body>
        </html>
      ''';

        final String scrollTestPageBase64 =
            base64Encode(const Utf8Encoder().convert(scrollTestPage));

        final Completer<void> pageLoaded = Completer<void>();
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      'data:text/html;charset=utf-8;base64,$scrollTestPageBase64')),
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
        await controller.scrollTo(x: 0, y: 0);

        await tester.pumpAndSettle(Duration(seconds: 3));

        // Check scrollTo()
        const int X_SCROLL = 123;
        const int Y_SCROLL = 321;

        await controller.scrollTo(x: X_SCROLL, y: Y_SCROLL);
        await tester.pumpAndSettle(Duration(seconds: 2));
        int? scrollPosX = await controller.getScrollX();
        int? scrollPosY = await controller.getScrollY();
        expect(scrollPosX, X_SCROLL);
        expect(scrollPosY, Y_SCROLL);

        // Check scrollBy() (on top of scrollTo())
        await controller.scrollBy(x: X_SCROLL, y: Y_SCROLL);
        await tester.pumpAndSettle(Duration(seconds: 2));
        scrollPosX = await controller.getScrollX();
        scrollPosY = await controller.getScrollY();
        expect(scrollPosX, X_SCROLL * 2);
        expect(scrollPosY, Y_SCROLL * 2);
      });
    });

    group('Android Hybrid Composition', () {
      testWidgets('setAndGetScrollPosition', (WidgetTester tester) async {
        final String scrollTestPage = '''
        <!DOCTYPE html>
        <html>
          <head>
            <style>
              body {
                height: 100%;
                width: 100%;
              }
              #container{
                width:5000px;
                height:5000px;
            }
            </style>
          </head>
          <body>
            <div id="container"/>
          </body>
        </html>
      ''';

        final String scrollTestPageBase64 =
            base64Encode(const Utf8Encoder().convert(scrollTestPage));

        final Completer<void> pageLoaded = Completer<void>();
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      'data:text/html;charset=utf-8;base64,$scrollTestPageBase64')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialOptions: InAppWebViewGroupOptions(
                  android:
                      AndroidInAppWebViewOptions(useHybridComposition: true)),
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        );

        final InAppWebViewController controller =
            await controllerCompleter.future;
        await pageLoaded.future;
        await controller.scrollTo(x: 0, y: 0);

        await tester.pumpAndSettle(Duration(seconds: 3));

        // Check scrollTo()
        const int X_SCROLL = 123;
        const int Y_SCROLL = 321;

        await controller.scrollTo(x: X_SCROLL, y: Y_SCROLL);
        await tester.pumpAndSettle(Duration(seconds: 2));
        int? scrollPosX = await controller.getScrollX();
        int? scrollPosY = await controller.getScrollY();
        expect(scrollPosX, X_SCROLL);
        expect(scrollPosY, Y_SCROLL);

        // Check scrollBy() (on top of scrollTo())
        await controller.scrollBy(x: X_SCROLL, y: Y_SCROLL);
        await tester.pumpAndSettle(Duration(seconds: 2));
        scrollPosX = await controller.getScrollX();
        scrollPosY = await controller.getScrollY();
        expect(scrollPosX, X_SCROLL * 2);
        expect(scrollPosY, Y_SCROLL * 2);
      }, skip: !Platform.isAndroid);
    }, skip: !Platform.isAndroid);

    group('shouldOverrideUrlLoading', () {
      final String page =
          '''<!DOCTYPE html><head></head><body><a id="link" href="https://github.com/pichillilorenzo/flutter_inappwebview">flutter_inappwebview</a></body></html>''';
      final String pageEncoded = 'data:text/html;charset=utf-8;base64,' +
          base64Encode(const Utf8Encoder().convert(page));

      testWidgets('can allow requests', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final StreamController<String> pageLoads =
            StreamController<String>.broadcast();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: Uri.parse(pageEncoded)),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true, useShouldOverrideUrlLoading: true),
              ),
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                return (navigationAction.request.url!.host
                        .contains('youtube.com'))
                    ? NavigationActionPolicy.CANCEL
                    : NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, url) {
                pageLoads.add(url!.toString());
              },
            ),
          ),
        );

        await pageLoads.stream.first; // Wait for initial page load.
        final InAppWebViewController controller =
            await controllerCompleter.future;
        await controller.evaluateJavascript(
            source: 'location.href = "https://www.google.com/"');

        await pageLoads.stream.first; // Wait for the next page load.
        final String? currentUrl = (await controller.getUrl())?.toString();
        expect(currentUrl, 'https://www.google.com/');

        pageLoads.close();
      });

      testWidgets(
          'allow requests on iOS only if iosWKNavigationType == IOSWKNavigationType.LINK_ACTIVATED',
          (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final StreamController<String> pageLoads =
            StreamController<String>.broadcast();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: Uri.parse(pageEncoded)),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true, useShouldOverrideUrlLoading: true),
              ),
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var isFirstLoad =
                    navigationAction.request.url!.scheme == "data";
                return (isFirstLoad ||
                        navigationAction.iosWKNavigationType ==
                            IOSWKNavigationType.LINK_ACTIVATED)
                    ? NavigationActionPolicy.ALLOW
                    : NavigationActionPolicy.CANCEL;
              },
              onLoadStop: (controller, url) {
                pageLoads.add(url!.toString());
              },
            ),
          ),
        );

        await pageLoads.stream.first; // Wait for initial page load.
        final InAppWebViewController controller =
            await controllerCompleter.future;
        await controller.evaluateJavascript(
            source: 'location.href = "https://www.google.com/"');

        // There should never be any second page load, since our new URL is
        // blocked. Still wait for a potential page change for some time in order
        // to give the test a chance to fail.
        await pageLoads.stream
            .map((event) => event as String?)
            .first
            .timeout(const Duration(milliseconds: 500), onTimeout: () => null);
        String? currentUrl = (await controller.getUrl())?.toString();
        expect(currentUrl, isNot('https://www.google.com/'));

        await controller.evaluateJavascript(
            source: 'document.querySelector("#link").click();');
        await pageLoads.stream.first; // Wait for the next page load.
        currentUrl = (await controller.getUrl())?.toString();
        expect(currentUrl,
            'https://github.com/pichillilorenzo/flutter_inappwebview');

        pageLoads.close();
      }, skip: !Platform.isIOS);

      testWidgets('can block requests', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final StreamController<String> pageLoads =
            StreamController<String>.broadcast();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: Uri.parse(pageEncoded)),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true, useShouldOverrideUrlLoading: true),
              ),
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                return (navigationAction.request.url!.host
                        .contains('youtube.com'))
                    ? NavigationActionPolicy.CANCEL
                    : NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, url) {
                pageLoads.add(url!.toString());
              },
            ),
          ),
        );

        await pageLoads.stream.first; // Wait for initial page load.
        final InAppWebViewController controller =
            await controllerCompleter.future;
        await controller.evaluateJavascript(
            source: 'location.href = "https://www.youtube.com/"');

        // There should never be any second page load, since our new URL is
        // blocked. Still wait for a potential page change for some time in order
        // to give the test a chance to fail.
        await pageLoads.stream
            .map((event) => event as String?)
            .first
            .timeout(const Duration(milliseconds: 500), onTimeout: () => null);
        final String? currentUrl = (await controller.getUrl())?.toString();
        expect(currentUrl, isNot(contains('youtube.com')));

        pageLoads.close();
      });

      testWidgets('supports asynchronous decisions',
          (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final StreamController<String> pageLoads =
            StreamController<String>.broadcast();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: Uri.parse(pageEncoded)),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true, useShouldOverrideUrlLoading: true),
              ),
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var action = NavigationActionPolicy.CANCEL;
                action = await Future<NavigationActionPolicy>.delayed(
                    const Duration(milliseconds: 10),
                    () => NavigationActionPolicy.ALLOW);
                return action;
              },
              onLoadStop: (controller, url) {
                pageLoads.add(url!.toString());
              },
            ),
          ),
        );

        await pageLoads.stream.first; // Wait for initial page load.
        final InAppWebViewController controller =
            await controllerCompleter.future;
        await controller.evaluateJavascript(
            source: 'location.href = "https://www.google.com"');

        await pageLoads.stream.first; // Wait for second page to load.
        final String? currentUrl = (await controller.getUrl())?.toString();
        expect(currentUrl, 'https://www.google.com/');

        pageLoads.close();
      });
    });

    testWidgets('onLoadError', (WidgetTester tester) async {
      final Completer<String> errorUrlCompleter = Completer<String>();
      final Completer<int> errorCodeCompleter = Completer<int>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://www.notawebsite..com')),
            onLoadError: (controller, url, code, message) {
              errorUrlCompleter.complete(url.toString());
              errorCodeCompleter.complete(code);
            },
          ),
        ),
      );

      final String url = await errorUrlCompleter.future;
      final int code = await errorCodeCompleter.future;

      if (Platform.isAndroid) {
        expect(code, -2);
      } else if (Platform.isIOS) {
        expect(code, -1003);
      }
      expect(url, 'https://www.notawebsite..com/');
    });

    testWidgets('onLoadError is not called with valid url',
        (WidgetTester tester) async {
      final Completer<String> errorUrlCompleter = Completer<String>();
      final Completer<int> errorCodeCompleter = Completer<int>();
      final Completer<String> errorMessageCompleter = Completer<String>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
                url: Uri.parse(
                    'data:text/html;charset=utf-8;base64,PCFET0NUWVBFIGh0bWw+')),
            onLoadError: (controller, url, code, message) {
              errorUrlCompleter.complete(url.toString());
              errorCodeCompleter.complete(code);
              errorMessageCompleter.complete(message);
            },
          ),
        ),
      );

      expect(errorUrlCompleter.future, doesNotComplete);
      expect(errorCodeCompleter.future, doesNotComplete);
      expect(errorMessageCompleter.future, doesNotComplete);
    });

    testWidgets('launches with allowsBackForwardNavigationGestures true on iOS',
        (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 400,
            height: 300,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest:
                  URLRequest(url: Uri.parse('https://github.com/flutter')),
              initialOptions: InAppWebViewGroupOptions(
                  ios: IOSInAppWebViewOptions(
                      allowsBackForwardNavigationGestures: true)),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
            ),
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(currentUrl, 'https://github.com/flutter');
    }, skip: !Platform.isIOS);

    testWidgets('target _blank opens in same window',
        (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialUrlRequest: URLRequest(url: Uri.parse("about:blank")),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  javaScriptCanOpenWindowsAutomatically: true),
            ),
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );
      await pageLoads.stream.first;
      final InAppWebViewController controller =
          await controllerCompleter.future;

      await controller.evaluateJavascript(
          source: 'window.open("about:blank", "_blank");');
      await pageLoads.stream.first;
      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(currentUrl, 'about:blank');

      pageLoads.close();
    });

    testWidgets(
      'can open new window and go back',
      (WidgetTester tester) async {
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
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    javaScriptCanOpenWindowsAutomatically: true),
              ),
              onLoadStop: (controller, url) {
                pageLoads.add(url!.toString());
              },
            ),
          ),
        );
        await pageLoads.stream.first;
        final InAppWebViewController controller =
            await controllerCompleter.future;

        await controller.evaluateJavascript(
            source: 'window.open("https://github.com/flutter");');
        await pageLoads.stream.first;
        expect((await controller.getUrl())?.toString(),
            contains('github.com/flutter'));

        await controller.goBack();
        await pageLoads.stream.first;
        expect(
            (await controller.getUrl())?.toString(), contains('flutter.dev'));

        pageLoads.close();
      },
      skip: true /* !Platform.isAndroid */,
    );

    testWidgets(
      'javascript does not run in parent window',
      (WidgetTester tester) async {
        final String iframe = '''
        <!DOCTYPE html>
        <script>
          window.onload = () => {
            window.open(`javascript:
              var elem = document.createElement("p");
              elem.innerHTML = "<b>Executed JS in parent origin: " + window.location.origin + "</b>";
              document.body.append(elem);
            `);
          };
        </script>
      ''';
        final String iframeTestBase64 =
            base64Encode(const Utf8Encoder().convert(iframe));

        final String openWindowTest = '''
        <!DOCTYPE html>
        <html>
        <head>
          <title>XSS test</title>
        </head>
        <body>
          <iframe
            onload="window.iframeLoaded = true;"
            src="data:text/html;charset=utf-8;base64,$iframeTestBase64"></iframe>
        </body>
        </html>
      ''';
        final String openWindowTestBase64 =
            base64Encode(const Utf8Encoder().convert(openWindowTest));
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> pageLoadCompleter = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      'data:text/html;charset=utf-8;base64,$openWindowTestBase64')),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    javaScriptCanOpenWindowsAutomatically: true),
              ),
              onLoadStop: (controller, url) {
                pageLoadCompleter.complete();
              },
            ),
          ),
        );

        final InAppWebViewController controller =
            await controllerCompleter.future;
        await pageLoadCompleter.future;

        expect(controller.evaluateJavascript(source: 'iframeLoaded'),
            completion(true));
        expect(
          controller.evaluateJavascript(
              source:
                  'document.querySelector("p") && document.querySelector("p").textContent'),
          completion(null),
        );
      },
      skip: !Platform.isAndroid,
    );

    group('intercept ajax request', () {
      testWidgets('send string data', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer shouldInterceptAjaxPostRequestCompleter =
            Completer<void>();
        final Completer<Map<String, dynamic>> onAjaxReadyStateChangeCompleter =
            Completer<Map<String, dynamic>>();
        final Completer<Map<String, dynamic>> onAjaxProgressCompleter =
            Completer<Map<String, dynamic>>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>InAppWebViewAjaxTest</title>
    </head>
    <body>
        <h1>InAppWebViewAjaxTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            var xhttp = new XMLHttpRequest();
            xhttp.open("POST", "http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post");
            xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            xhttp.send("firstname=Foo&lastname=Bar");
          });
        </script>
    </body>
</html>
                    """),
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                clearCache: true,
                useShouldInterceptAjaxRequest: true,
              )),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
                assert(ajaxRequest.data == "firstname=Foo&lastname=Bar");

                ajaxRequest.responseType = 'json';
                ajaxRequest.data = "firstname=Foo2&lastname=Bar2";
                shouldInterceptAjaxPostRequestCompleter.complete(controller);
                return ajaxRequest;
              },
              onAjaxReadyStateChange: (controller, ajaxRequest) async {
                if (ajaxRequest.readyState == AjaxRequestReadyState.DONE &&
                    ajaxRequest.status == 200) {
                  Map<String, dynamic> res = ajaxRequest.response;
                  onAjaxReadyStateChangeCompleter.complete(res);
                }
                return AjaxRequestAction.PROCEED;
              },
              onAjaxProgress: (controller, ajaxRequest) async {
                if (ajaxRequest.event!.type == AjaxRequestEventType.LOAD) {
                  Map<String, dynamic> res = ajaxRequest.response;
                  onAjaxProgressCompleter.complete(res);
                }
                return AjaxRequestAction.PROCEED;
              },
            ),
          ),
        );

        await shouldInterceptAjaxPostRequestCompleter.future;
        final Map<String, dynamic> onAjaxReadyStateChangeValue =
            await onAjaxReadyStateChangeCompleter.future;
        final Map<String, dynamic> onAjaxProgressValue =
            await onAjaxProgressCompleter.future;

        expect(
            mapEquals(onAjaxReadyStateChangeValue,
                {'firstname': 'Foo2', 'lastname': 'Bar2'}),
            true);
        expect(
            mapEquals(
                onAjaxProgressValue, {'firstname': 'Foo2', 'lastname': 'Bar2'}),
            true);
      });

      testWidgets('send json data', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer shouldInterceptAjaxPostRequestCompleter =
            Completer<void>();
        final Completer<Map<String, dynamic>> onAjaxReadyStateChangeCompleter =
            Completer<Map<String, dynamic>>();
        final Completer<Map<String, dynamic>> onAjaxProgressCompleter =
            Completer<Map<String, dynamic>>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>InAppWebViewAjaxTest</title>
    </head>
    <body>
        <h1>InAppWebViewAjaxTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            var jsonData = {
              firstname: 'Foo',
              lastname: 'Bar'
            };
            var xhttp = new XMLHttpRequest();
            xhttp.open("POST", "http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post");
            xhttp.setRequestHeader("Content-type", "application/json");
            xhttp.send(JSON.stringify(jsonData));
          });
        </script>
    </body>
</html>
                    """),
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                clearCache: true,
                useShouldInterceptAjaxRequest: true,
              )),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
                String data = ajaxRequest.data;
                assert(data.contains('"firstname":"Foo"') &&
                    data.contains('"lastname":"Bar"'));

                ajaxRequest.responseType = 'json';
                ajaxRequest.data = '{"firstname": "Foo2", "lastname": "Bar2"}';
                shouldInterceptAjaxPostRequestCompleter.complete(controller);
                return ajaxRequest;
              },
              onAjaxReadyStateChange: (controller, ajaxRequest) async {
                if (ajaxRequest.readyState == AjaxRequestReadyState.DONE &&
                    ajaxRequest.status == 200) {
                  Map<String, dynamic> res = ajaxRequest.response;
                  onAjaxReadyStateChangeCompleter.complete(res);
                }
                return AjaxRequestAction.PROCEED;
              },
              onAjaxProgress: (controller, ajaxRequest) async {
                if (ajaxRequest.event!.type == AjaxRequestEventType.LOAD) {
                  Map<String, dynamic> res = ajaxRequest.response;
                  onAjaxProgressCompleter.complete(res);
                }
                return AjaxRequestAction.PROCEED;
              },
            ),
          ),
        );

        await shouldInterceptAjaxPostRequestCompleter.future;
        final Map<String, dynamic> onAjaxReadyStateChangeValue =
            await onAjaxReadyStateChangeCompleter.future;
        final Map<String, dynamic> onAjaxProgressValue =
            await onAjaxProgressCompleter.future;

        expect(
            mapEquals(onAjaxReadyStateChangeValue,
                {'firstname': 'Foo2', 'lastname': 'Bar2'}),
            true);
        expect(
            mapEquals(
                onAjaxProgressValue, {'firstname': 'Foo2', 'lastname': 'Bar2'}),
            true);
      });

      testWidgets('send URLSearchParams data', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer shouldInterceptAjaxPostRequestCompleter =
            Completer<void>();
        final Completer<Map<String, dynamic>> onAjaxReadyStateChangeCompleter =
            Completer<Map<String, dynamic>>();
        final Completer<Map<String, dynamic>> onAjaxProgressCompleter =
            Completer<Map<String, dynamic>>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>InAppWebViewAjaxTest</title>
    </head>
    <body>
        <h1>InAppWebViewAjaxTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            var paramsString = "firstname=Foo&lastname=Bar";
            var searchParams = new URLSearchParams(paramsString);
            var xhttp = new XMLHttpRequest();
            xhttp.open("POST", "http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post");
            xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            xhttp.send(searchParams);
          });
        </script>
    </body>
</html>
                    """),
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                clearCache: true,
                useShouldInterceptAjaxRequest: true,
              )),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
                assert(ajaxRequest.data == "firstname=Foo&lastname=Bar");

                ajaxRequest.responseType = 'json';
                ajaxRequest.data = "firstname=Foo2&lastname=Bar2";
                shouldInterceptAjaxPostRequestCompleter.complete(controller);
                return ajaxRequest;
              },
              onAjaxReadyStateChange: (controller, ajaxRequest) async {
                if (ajaxRequest.readyState == AjaxRequestReadyState.DONE &&
                    ajaxRequest.status == 200) {
                  Map<String, dynamic> res = ajaxRequest.response;
                  onAjaxReadyStateChangeCompleter.complete(res);
                }
                return AjaxRequestAction.PROCEED;
              },
              onAjaxProgress: (controller, ajaxRequest) async {
                if (ajaxRequest.event!.type == AjaxRequestEventType.LOAD) {
                  Map<String, dynamic> res = ajaxRequest.response;
                  onAjaxProgressCompleter.complete(res);
                }
                return AjaxRequestAction.PROCEED;
              },
            ),
          ),
        );

        await shouldInterceptAjaxPostRequestCompleter.future;
        final Map<String, dynamic> onAjaxReadyStateChangeValue =
            await onAjaxReadyStateChangeCompleter.future;
        final Map<String, dynamic> onAjaxProgressValue =
            await onAjaxProgressCompleter.future;

        expect(
            mapEquals(onAjaxReadyStateChangeValue,
                {'firstname': 'Foo2', 'lastname': 'Bar2'}),
            true);
        expect(
            mapEquals(
                onAjaxProgressValue, {'firstname': 'Foo2', 'lastname': 'Bar2'}),
            true);
      });

      testWidgets('send FormData', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer shouldInterceptAjaxPostRequestCompleter =
            Completer<void>();
        final Completer<Map<String, dynamic>> onAjaxReadyStateChangeCompleter =
            Completer<Map<String, dynamic>>();
        final Completer<Map<String, dynamic>> onAjaxProgressCompleter =
            Completer<Map<String, dynamic>>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>InAppWebViewAjaxTest</title>
    </head>
    <body>
        <h1>InAppWebViewAjaxTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            var formData = new FormData();
            formData.append('firstname', 'Foo');
            formData.append('lastname', 'Bar');
            var xhttp = new XMLHttpRequest();
            xhttp.open("POST", "http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post");
            xhttp.send(formData);
          });
        </script>
    </body>
</html>
                    """),
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                clearCache: true,
                useShouldInterceptAjaxRequest: true,
              )),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
                assert(ajaxRequest.data != null);

                var body = ajaxRequest.data.cast<int>();
                var bodyString = String.fromCharCodes(body);
                assert(bodyString.indexOf("WebKitFormBoundary") >= 0);

                ajaxRequest.data = utf8.encode(bodyString
                    .replaceFirst("Foo", "Foo2")
                    .replaceFirst("Bar", "Bar2"));
                ajaxRequest.responseType = 'json';
                shouldInterceptAjaxPostRequestCompleter.complete(controller);
                return ajaxRequest;
              },
              onAjaxReadyStateChange: (controller, ajaxRequest) async {
                if (ajaxRequest.readyState == AjaxRequestReadyState.DONE &&
                    ajaxRequest.status == 200) {
                  Map<String, dynamic> res = ajaxRequest.response;
                  onAjaxReadyStateChangeCompleter.complete(res);
                }
                return AjaxRequestAction.PROCEED;
              },
              onAjaxProgress: (controller, ajaxRequest) async {
                if (ajaxRequest.event!.type == AjaxRequestEventType.LOAD) {
                  Map<String, dynamic> res = ajaxRequest.response;
                  onAjaxProgressCompleter.complete(res);
                }
                return AjaxRequestAction.PROCEED;
              },
            ),
          ),
        );

        await shouldInterceptAjaxPostRequestCompleter.future;
        final Map<String, dynamic> onAjaxReadyStateChangeValue =
            await onAjaxReadyStateChangeCompleter.future;
        final Map<String, dynamic> onAjaxProgressValue =
            await onAjaxProgressCompleter.future;

        expect(
            mapEquals(onAjaxReadyStateChangeValue,
                {'firstname': 'Foo2', 'lastname': 'Bar2'}),
            true);
        expect(
            mapEquals(
                onAjaxProgressValue, {'firstname': 'Foo2', 'lastname': 'Bar2'}),
            true);
      });
    });

    group('intercept fetch request', () {
      testWidgets('send string data', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<Map<String, dynamic>> fetchPostCompleter =
            Completer<Map<String, dynamic>>();
        final Completer<void> shouldInterceptFetchPostRequestCompleter =
            Completer<void>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>InAppWebViewFetchTest</title>
    </head>
    <body>
        <h1>InAppWebViewFetchTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            fetch("http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post", {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: "firstname=Foo&lastname=Bar"
            }).then(function(response) {
                response.json().then(function(value) {
                  window.flutter_inappwebview.callHandler('fetchPost', value);
                }).catch(function(error) {
                  window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
                });
            }).catch(function(error) {
              window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
            });
          });
        </script>
    </body>
</html>
                    """),
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                clearCache: true,
                useShouldInterceptFetchRequest: true,
              )),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);

                controller.addJavaScriptHandler(
                    handlerName: "fetchPost",
                    callback: (args) {
                      fetchPostCompleter
                          .complete(args[0] as Map<String, dynamic>);
                    });
              },
              shouldInterceptFetchRequest: (controller, fetchRequest) async {
                assert(fetchRequest.body == "firstname=Foo&lastname=Bar");

                fetchRequest.body = "firstname=Foo2&lastname=Bar2";
                shouldInterceptFetchPostRequestCompleter.complete();
                return fetchRequest;
              },
            ),
          ),
        );

        await shouldInterceptFetchPostRequestCompleter.future;
        var fetchPostCompleterValue = await fetchPostCompleter.future;

        expect(
            mapEquals(fetchPostCompleterValue,
                {'firstname': 'Foo2', 'lastname': 'Bar2'}),
            true);
      });

      testWidgets('send json data', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<Map<String, dynamic>> fetchPostCompleter =
            Completer<Map<String, dynamic>>();
        final Completer<void> shouldInterceptFetchPostRequestCompleter =
            Completer<void>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>InAppWebViewFetchTest</title>
    </head>
    <body>
        <h1>InAppWebViewFetchTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            var jsonData = {
              firstname: 'Foo',
              lastname: 'Bar'
            };
            fetch("http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post", {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json'
                },
                body: JSON.stringify(jsonData)
            }).then(function(response) {
                response.json().then(function(value) {
                  window.flutter_inappwebview.callHandler('fetchPost', value);
                }).catch(function(error) {
                    window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
                });
            }).catch(function(error) {
                window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
            });
          });
        </script>
    </body>
</html>
                    """),
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                clearCache: true,
                useShouldInterceptFetchRequest: true,
              )),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);

                controller.addJavaScriptHandler(
                    handlerName: "fetchPost",
                    callback: (args) {
                      fetchPostCompleter
                          .complete(args[0] as Map<String, dynamic>);
                    });
              },
              shouldInterceptFetchRequest: (controller, fetchRequest) async {
                String body = fetchRequest.body;
                assert(body.contains('"firstname":"Foo"') &&
                    body.contains('"lastname":"Bar"'));

                fetchRequest.body = '{"firstname": "Foo2", "lastname": "Bar2"}';
                shouldInterceptFetchPostRequestCompleter.complete();
                return fetchRequest;
              },
            ),
          ),
        );

        await shouldInterceptFetchPostRequestCompleter.future;
        var fetchPostCompleterValue = await fetchPostCompleter.future;

        expect(
            mapEquals(fetchPostCompleterValue,
                {'firstname': 'Foo2', 'lastname': 'Bar2'}),
            true);
      });

      testWidgets('send URLSearchParams data', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<Map<String, dynamic>> fetchPostCompleter =
            Completer<Map<String, dynamic>>();
        final Completer<void> shouldInterceptFetchPostRequestCompleter =
            Completer<void>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>InAppWebViewFetchTest</title>
    </head>
    <body>
        <h1>InAppWebViewFetchTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            var paramsString = "firstname=Foo&lastname=Bar";
            var searchParams = new URLSearchParams(paramsString);
            fetch("http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post", {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: searchParams
            }).then(function(response) {
                response.json().then(function(value) {
                  window.flutter_inappwebview.callHandler('fetchPost', value);
                }).catch(function(error) {
                    window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
                });
            }).catch(function(error) {
                window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
            });
          });
        </script>
    </body>
</html>
                    """),
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                clearCache: true,
                useShouldInterceptFetchRequest: true,
              )),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);

                controller.addJavaScriptHandler(
                    handlerName: "fetchPost",
                    callback: (args) {
                      fetchPostCompleter
                          .complete(args[0] as Map<String, dynamic>);
                    });
              },
              shouldInterceptFetchRequest: (controller, fetchRequest) async {
                assert(fetchRequest.body == "firstname=Foo&lastname=Bar");

                fetchRequest.body = "firstname=Foo2&lastname=Bar2";
                shouldInterceptFetchPostRequestCompleter.complete();
                return fetchRequest;
              },
            ),
          ),
        );

        await shouldInterceptFetchPostRequestCompleter.future;
        var fetchPostCompleterValue = await fetchPostCompleter.future;

        expect(
            mapEquals(fetchPostCompleterValue,
                {'firstname': 'Foo2', 'lastname': 'Bar2'}),
            true);
      });

      testWidgets('send FormData', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<Map<String, dynamic>> fetchPostCompleter =
            Completer<Map<String, dynamic>>();
        final Completer<void> shouldInterceptFetchPostRequestCompleter =
            Completer<void>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>InAppWebViewFetchTest</title>
    </head>
    <body>
        <h1>InAppWebViewFetchTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            var formData = new FormData();
            formData.append('firstname', 'Foo');
            formData.append('lastname', 'Bar');
            fetch("http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post", {
                method: 'POST',
                body: formData
            }).then(function(response) {
                response.json().then(function(value) {
                  window.flutter_inappwebview.callHandler('fetchPost', value);
                }).catch(function(error) {
                    window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
                });
            }).catch(function(error) {
                window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
            });
          });
        </script>
    </body>
</html>
                    """),
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                clearCache: true,
                useShouldInterceptFetchRequest: true,
              )),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);

                controller.addJavaScriptHandler(
                    handlerName: "fetchPost",
                    callback: (args) {
                      fetchPostCompleter
                          .complete(args[0] as Map<String, dynamic>);
                    });
              },
              shouldInterceptFetchRequest: (controller, fetchRequest) async {
                assert(fetchRequest.body != null);

                var body = fetchRequest.body.cast<int>();
                var bodyString = String.fromCharCodes(body);
                assert(bodyString.indexOf("WebKitFormBoundary") >= 0);

                fetchRequest.body = utf8.encode(bodyString
                    .replaceFirst("Foo", "Foo2")
                    .replaceFirst("Bar", "Bar2"));
                shouldInterceptFetchPostRequestCompleter.complete();
                return fetchRequest;
              },
            ),
          ),
        );

        await shouldInterceptFetchPostRequestCompleter.future;
        var fetchPostCompleterValue = await fetchPostCompleter.future;

        expect(
            mapEquals(fetchPostCompleterValue,
                {'firstname': 'Foo2', 'lastname': 'Bar2'}),
            true);
      });
    });

    testWidgets('Content Blocker', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
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
                crossPlatform:
                    InAppWebViewOptions(clearCache: true, contentBlockers: [
              ContentBlocker(
                  trigger:
                      ContentBlockerTrigger(urlFilter: ".*", resourceType: [
                    ContentBlockerTriggerResourceType.IMAGE,
                    ContentBlockerTriggerResourceType.STYLE_SHEET
                  ], ifTopUrl: [
                    "https://flutter.dev/"
                  ]),
                  action: ContentBlockerAction(
                      type: ContentBlockerActionType.BLOCK))
            ])),
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );
      await expectLater(pageLoaded.future, completes);
    });

    testWidgets('Http Auth Credential Database', (WidgetTester tester) async {
      HttpAuthCredentialDatabase httpAuthCredentialDatabase =
          HttpAuthCredentialDatabase.instance();
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      httpAuthCredentialDatabase.setHttpAuthCredential(
          protectionSpace: URLProtectionSpace(
              host: environment["NODE_SERVER_IP"]!,
              protocol: "http",
              realm: "Node",
              port: 8081),
          credential:
              URLCredential(username: "USERNAME", password: "PASSWORD"));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
                url:
                    Uri.parse("http://${environment["NODE_SERVER_IP"]}:8081/")),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
              clearCache: true,
            )),
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onReceivedHttpAuthRequest: (controller, challenge) async {
              return new HttpAuthResponse(
                  action:
                      HttpAuthResponseAction.USE_SAVED_HTTP_AUTH_CREDENTIALS);
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final String h1Content = await controller.evaluateJavascript(
          source: "document.body.querySelector('h1').textContent");
      expect(h1Content, "Authorized");

      var credentials = await httpAuthCredentialDatabase.getHttpAuthCredentials(
          protectionSpace: URLProtectionSpace(
              host: environment["NODE_SERVER_IP"]!,
              protocol: "http",
              realm: "Node",
              port: 8081));
      expect(credentials.length, 1);

      await httpAuthCredentialDatabase.clearAllAuthCredentials();
      credentials = await httpAuthCredentialDatabase.getHttpAuthCredentials(
          protectionSpace: URLProtectionSpace(
              host: environment["NODE_SERVER_IP"]!,
              protocol: "http",
              realm: "Node",
              port: 8081));
      expect(credentials, isEmpty);
    });

    testWidgets('onReceivedHttpAuthRequest', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
                url:
                    Uri.parse("http://${environment["NODE_SERVER_IP"]}:8081/")),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
              clearCache: true,
            )),
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onReceivedHttpAuthRequest: (controller, challenge) async {
              return new HttpAuthResponse(
                  username: "USERNAME",
                  password: "PASSWORD",
                  action: HttpAuthResponseAction.PROCEED,
                  permanentPersistence: true);
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final String h1Content = await controller.evaluateJavascript(
          source: "document.body.querySelector('h1').textContent");
      expect(h1Content, "Authorized");
    });

    testWidgets('onConsoleMessage', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<ConsoleMessage> onConsoleMessageCompleter =
          Completer<ConsoleMessage>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialFile:
                "test_assets/in_app_webview_on_console_message_test.html",
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onConsoleMessage: (controller, consoleMessage) {
              onConsoleMessageCompleter.complete(consoleMessage);
            },
          ),
        ),
      );

      final ConsoleMessage consoleMessage =
          await onConsoleMessageCompleter.future;
      expect(consoleMessage.message, 'message');
      expect(consoleMessage.messageLevel, ConsoleMessageLevel.LOG);
    });

    group("WebView Windows", () {
      testWidgets('onCreateWindow return false', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> pageLoaded = Completer<void>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialFile:
                  "test_assets/in_app_webview_on_create_window_test.html",
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                clearCache: true,
                javaScriptCanOpenWindowsAutomatically: true,
              )),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                if (url!.toString() == "https://flutter.dev/") {
                  pageLoaded.complete();
                }
              },
              onCreateWindow: (controller, createNavigationAction) async {
                controller.loadUrl(urlRequest: createNavigationAction.request);
                return false;
              },
            ),
          ),
        );

        await expectLater(pageLoaded.future, completes);
      });

      testWidgets('onCreateWindow return true', (WidgetTester tester) async {
        final Completer controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<int> onCreateWindowCompleter = Completer<int>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialFile:
                  "test_assets/in_app_webview_on_create_window_test.html",
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    clearCache: true,
                    javaScriptCanOpenWindowsAutomatically: true,
                  ),
                  android:
                      AndroidInAppWebViewOptions(supportMultipleWindows: true)),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onCreateWindow: (controller, createNavigationAction) async {
                onCreateWindowCompleter
                    .complete(createNavigationAction.windowId);
                return true;
              },
            ),
          ),
        );

        var windowId = await onCreateWindowCompleter.future;

        final Completer windowControllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<String> windowPageLoaded = Completer<String>();
        final Completer<void> onCloseWindowCompleter = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              windowId: windowId,
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                clearCache: true,
              )),
              onWebViewCreated: (controller) {
                windowControllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) async {
                if (url!.scheme != "about" && !windowPageLoaded.isCompleted) {
                  windowPageLoaded.complete(url.toString());
                  await controller.evaluateJavascript(
                      source: "window.close();");
                }
              },
              onCloseWindow: (controller) {
                onCloseWindowCompleter.complete();
              },
            ),
          ),
        );

        final String windowUrlLoaded = await windowPageLoaded.future;

        expect(windowUrlLoaded, "https://flutter.dev/");
        await expectLater(onCloseWindowCompleter.future, completes);
      });
    });

    testWidgets('onFindResultReceived', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<int> numberOfMatchesCompleter = Completer<int>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialFile: "test_assets/in_app_webview_initial_file_test.html",
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
              clearCache: true,
            )),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              controller.findAllAsync(find: "InAppWebViewInitialFileTest");
            },
            onFindResultReceived: (controller, int activeMatchOrdinal,
                int numberOfMatches, bool isDoneCounting) async {
              if (isDoneCounting && !numberOfMatchesCompleter.isCompleted) {
                numberOfMatchesCompleter.complete(numberOfMatches);
              }
            },
          ),
        ),
      );

      final int numberOfMatches = await numberOfMatchesCompleter.future;
      expect(numberOfMatches, 2);
    });

    testWidgets('onDownloadStartRequest', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<String> onDownloadStartCompleter = Completer<String>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>InAppWebViewOnDownloadStartTest</title>
    </head>
    <body>
        <h1>InAppWebViewOnDownloadStartTest</h1>
        <a id="download-file" href="http://${environment["NODE_SERVER_IP"]}:8082/test-download-file">download file</a>
        <script>
            window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
                document.querySelector("#download-file").click();
            });
        </script>
    </body>
</html>
          """),
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    clearCache: true, useOnDownloadStart: true)),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onDownloadStartRequest: (controller, request) {
              onDownloadStartCompleter.complete(request.url.toString());
            },
          ),
        ),
      );

      final String url = await onDownloadStartCompleter.future;
      expect(url,
          "http://${environment["NODE_SERVER_IP"]}:8082/test-download-file");
    });

    testWidgets('javascript dialogs', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<JsAlertRequest> alertCompleter =
          Completer<JsAlertRequest>();
      final Completer<bool> confirmCompleter = Completer<bool>();
      final Completer<String> promptCompleter = Completer<String>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialFile: "test_assets/in_app_webview_on_js_dialog_test.html",
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
              clearCache: true,
            )),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);

              controller.addJavaScriptHandler(
                  handlerName: 'confirm',
                  callback: (args) {
                    confirmCompleter.complete(args[0] as bool);
                  });

              controller.addJavaScriptHandler(
                  handlerName: 'prompt',
                  callback: (args) {
                    promptCompleter.complete(args[0] as String);
                  });
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onJsAlert: (controller, jsAlertRequest) async {
              JsAlertResponseAction action = JsAlertResponseAction.CONFIRM;
              alertCompleter.complete(jsAlertRequest);
              return JsAlertResponse(handledByClient: true, action: action);
            },
            onJsConfirm: (controller, jsConfirmRequest) async {
              JsConfirmResponseAction action = JsConfirmResponseAction.CONFIRM;
              return JsConfirmResponse(handledByClient: true, action: action);
            },
            onJsPrompt: (controller, jsPromptRequest) async {
              JsPromptResponseAction action = JsPromptResponseAction.CONFIRM;
              return JsPromptResponse(
                  handledByClient: true, action: action, value: 'new value');
            },
          ),
        ),
      );

      await pageLoaded.future;

      final JsAlertRequest jsAlertRequest = await alertCompleter.future;
      expect(jsAlertRequest.message, 'alert message');

      final bool onJsConfirmValue = await confirmCompleter.future;
      expect(onJsConfirmValue, true);

      final String onJsPromptValue = await promptCompleter.future;
      expect(onJsPromptValue, 'new value');
    });

    testWidgets('onLoadHttpError', (WidgetTester tester) async {
      final Completer<String> errorUrlCompleter = Completer<String>();
      final Completer<int> statusCodeCompleter = Completer<int>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://google.com/404')),
            onLoadHttpError: (controller, url, statusCode, description) async {
              errorUrlCompleter.complete(url.toString());
              statusCodeCompleter.complete(statusCode);
            },
          ),
        ),
      );

      final String url = await errorUrlCompleter.future;
      final int code = await statusCodeCompleter.future;

      expect(url, 'https://google.com/404');
      expect(code, 404);
    });

    testWidgets('onLoadResourceCustomScheme', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> imageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialFile:
                "test_assets/in_app_webview_on_load_resource_custom_scheme_test.html",
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    clearCache: true,
                    resourceCustomSchemes: ["my-special-custom-scheme"])),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);

              controller.addJavaScriptHandler(
                  handlerName: "imageLoaded",
                  callback: (args) {
                    imageLoaded.complete();
                  });
            },
            onLoadResourceCustomScheme: (controller, url) async {
              if (url.scheme == "my-special-custom-scheme") {
                var bytes = await rootBundle.load("test_assets/" +
                    url
                        .toString()
                        .replaceFirst("my-special-custom-scheme://", "", 0));
                var response = CustomSchemeResponse(
                    data: bytes.buffer.asUint8List(),
                    contentType: "image/svg+xml",
                    contentEncoding: "utf-8");
                return response;
              }
              return null;
            },
          ),
        ),
      );

      await expectLater(imageLoaded.future, completes);
    });

    testWidgets('onLoadResource', (WidgetTester tester) async {
      List<String> resourceList = [
        "https://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css",
        "https://code.jquery.com/jquery-3.3.1.min.js",
        "https://via.placeholder.com/100x50"
      ];
      List<String> resourceLoaded = [];

      final Completer<void> loadedResourceCompleter = Completer<void>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
              key: GlobalKey(),
              initialFile:
                  "test_assets/in_app_webview_on_load_resource_test.html",
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                      clearCache: true, useOnLoadResource: true)),
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
              onLoadResource: (controller, response) async {
                resourceLoaded.add(response.url!.toString());
                if (resourceLoaded.length == resourceList.length) {
                  loadedResourceCompleter.complete();
                }
              }),
        ),
      );

      await pageLoaded.future;
      await loadedResourceCompleter.future;

      expect(resourceLoaded, unorderedEquals(resourceList));
    });

    testWidgets('onUpdateVisitedHistory', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> firstPushCompleter = Completer<void>();
      final Completer<void> secondPushCompleter = Completer<void>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse("https://flutter.dev/")),
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(clearCache: true)),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onUpdateVisitedHistory: (controller, url, androidIsReload) async {
              if (url!.toString().endsWith("second-push")) {
                secondPushCompleter.complete();
              } else if (url.toString().endsWith("first-push")) {
                firstPushCompleter.complete();
              }
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await controller.evaluateJavascript(source: """
var state = {}
var title = ''
var url = 'first-push';
history.pushState(state, title, url);

setTimeout(function() {
    var url = 'second-push';
    history.pushState(state, title, url);
}, 500);
""");

      await firstPushCompleter.future;
      expect((await controller.getUrl())?.toString(),
          'https://flutter.dev/first-push');

      await secondPushCompleter.future;
      expect((await controller.getUrl())?.toString(),
          'https://flutter.dev/second-push');
    });

    testWidgets('onProgressChanged', (WidgetTester tester) async {
      final Completer<void> onProgressChangedCompleter = Completer<void>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://github.com/flutter')),
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
              clearCache: true,
            )),
            onProgressChanged: (controller, progress) {
              if (progress == 100) {
                onProgressChangedCompleter.complete();
              }
            },
          ),
        ),
      );
      await expectLater(onProgressChangedCompleter.future, completes);
    });

    testWidgets('androidOnSafeBrowsingHit', (WidgetTester tester) async {
      final Completer<String> pageLoaded = Completer<String>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
                url: Uri.parse('chrome://safe-browsing/match?type=malware')),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                // if I set javaScriptEnabled to true, it will crash!
                javaScriptEnabled: false,
                clearCache: true,
              ),
              android: AndroidInAppWebViewOptions(
                safeBrowsingEnabled: true,
              ),
            ),
            onWebViewCreated: (controller) {
              controller.android.startSafeBrowsing();
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete(url!.toString());
            },
            androidOnSafeBrowsingHit: (controller, url, threatType) async {
              return SafeBrowsingResponse(
                  report: true, action: SafeBrowsingResponseAction.PROCEED);
            },
          ),
        ),
      );

      final String url = await pageLoaded.future;
      expect(url, "chrome://safe-browsing/match?type=malware");
    }, skip: !Platform.isAndroid);

    testWidgets('onScrollChanged', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<void> onScrollChangedCompleter = Completer<void>();
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
            onScrollChanged: (controller, x, y) {
              if (x == 0 && y == 500) {
                onScrollChangedCompleter.complete();
              }
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      controller.scrollTo(x: 0, y: 500);
      await tester.pumpAndSettle(Duration(seconds: 1));

      await expectLater(onScrollChangedCompleter.future, completes);
    });

    testWidgets('SSL request', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
                url: Uri.parse(
                    "https://${environment["NODE_SERVER_IP"]}:4433/")),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return new ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED);
            },
            onReceivedClientCertRequest: (controller, challenge) async {
              return new ClientCertResponse(
                  certificatePath: "test_assets/certificate.pfx",
                  certificatePassword: "",
                  androidKeyStoreType: "PKCS12",
                  action: ClientCertResponseAction.PROCEED);
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final String h1Content = await controller.evaluateJavascript(
          source: "document.body.querySelector('h1').textContent");
      expect(h1Content, "Authorized");
    });

    testWidgets('onPrint', (WidgetTester tester) async {
      final Completer<String> onPrintCompleter = Completer<String>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://github.com/flutter')),
            onLoadStop: (controller, url) async {
              await controller.evaluateJavascript(source: "window.print();");
            },
            onPrint: (controller, url) {
              onPrintCompleter.complete(url?.toString());
            },
          ),
        ),
      );
      final String url = await onPrintCompleter.future;
      expect(url, 'https://github.com/flutter');
    }, skip: true);

    testWidgets('onWindowFocus', (WidgetTester tester) async {
      final Completer<void> onWindowFocusCompleter = Completer<void>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://github.com/flutter')),
            onLoadStop: (controller, url) async {
              await controller.evaluateJavascript(
                  source: 'window.dispatchEvent(new Event("focus"));');
            },
            onWindowFocus: (controller) {
              onWindowFocusCompleter.complete();
            },
          ),
        ),
      );
      await expectLater(onWindowFocusCompleter.future, completes);
    });

    testWidgets('onWindowBlur', (WidgetTester tester) async {
      final Completer<void> onWindowBlurCompleter = Completer<void>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://github.com/flutter')),
            onLoadStop: (controller, url) async {
              await controller.evaluateJavascript(
                  source: 'window.dispatchEvent(new Event("blur"));');
            },
            onWindowBlur: (controller) {
              onWindowBlurCompleter.complete();
            },
          ),
        ),
      );
      await expectLater(onWindowBlurCompleter.future, completes);
    });

    testWidgets('onPageCommitVisible', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<String> onPageCommitVisibleCompleter =
          Completer<String>();

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
            onPageCommitVisible: (controller, url) {
              onPageCommitVisibleCompleter.complete(url?.toString());
            },
          ),
        ),
      );

      final String? url = await onPageCommitVisibleCompleter.future;
      expect(url, 'https://github.com/flutter');
    });

    testWidgets('onTitleChanged', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<void> onTitleChangedCompleter = Completer<void>();

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
            onTitleChanged: (controller, title) {
              if (title == "title test") {
                onTitleChangedCompleter.complete();
              }
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;
      await controller.evaluateJavascript(
          source: "document.title = 'title test';");
      await expectLater(onTitleChangedCompleter.future, completes);
    });

    testWidgets('onZoomScaleChanged', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<void> onZoomScaleChangedCompleter = Completer<void>();

      var listenForScaleChange = false;

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
            onZoomScaleChanged: (controller, oldScale, newScale) {
              if (listenForScaleChange) {
                onZoomScaleChangedCompleter.complete();
              }
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;
      listenForScaleChange = true;

      await controller.zoomBy(zoomFactor: 2);

      await expectLater(onZoomScaleChangedCompleter.future, completes);
    });

    testWidgets('androidOnPermissionRequest', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<List<String>> onPermissionRequestCompleter =
          Completer<List<String>>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://permission.site/')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            androidOnPermissionRequest: (controller, origin, resources) async {
              onPermissionRequestCompleter.complete(resources);
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;
      await controller.evaluateJavascript(
          source: "document.querySelector('#camera').click();");
      final List<String> resources = await onPermissionRequestCompleter.future;

      expect(listEquals(resources, ['android.webkit.resource.VIDEO_CAPTURE']),
          true);
    }, skip: !Platform.isAndroid);

    testWidgets('androidShouldInterceptRequest', (WidgetTester tester) async {
      List<String> resourceList = [
        "https://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css",
        "https://code.jquery.com/jquery-3.3.1.min.js",
        "https://via.placeholder.com/100x50"
      ];
      List<String> resourceLoaded = [];

      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<void> loadedResourceCompleter = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(data: """
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
                    """),
            initialOptions: InAppWebViewGroupOptions(
                android: AndroidInAppWebViewOptions(
                    useShouldInterceptRequest: true)),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            androidShouldInterceptRequest: (controller, request) async {
              resourceLoaded.add(request.url.toString());
              if (resourceLoaded.length == resourceList.length) {
                loadedResourceCompleter.complete();
              }
              return null;
            },
          ),
        ),
      );

      await pageLoaded.future;
      await loadedResourceCompleter.future;
      expect(resourceLoaded, containsAll(resourceList));
    }, skip: !Platform.isAndroid);

    testWidgets('androidOnReceivedIcon', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<Uint8List> onReceivedIconCompleter =
          Completer<Uint8List>();

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
            androidOnReceivedIcon: (controller, icon) {
              onReceivedIconCompleter.complete(icon);
            },
          ),
        ),
      );

      await pageLoaded.future;
      final Uint8List icon = await onReceivedIconCompleter.future;
      expect(icon, isNotNull);
    }, skip: !Platform.isAndroid);

    testWidgets('androidOnReceivedTouchIconUrl', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<String> onReceivedTouchIconUrlCompleter =
          Completer<String>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <link rel="apple-touch-icon" sizes="72x72" href="https://placehold.it/72x72">
    </head>
    <body></body>
</html>
                    """),
            initialOptions: InAppWebViewGroupOptions(
                android: AndroidInAppWebViewOptions(
                    useShouldInterceptRequest: true)),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            androidOnReceivedTouchIconUrl: (controller, url, precomposed) {
              onReceivedTouchIconUrlCompleter.complete(url.toString());
            },
          ),
        ),
      );

      final String url = await onReceivedTouchIconUrlCompleter.future;

      expect(url, "https://placehold.it/72x72");
    }, skip: !Platform.isAndroid);

    testWidgets('androidOnJsBeforeUnload', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<String> onJsBeforeUnloadCompleter = Completer<String>();

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
            onLoadStop: (controller, url) async {
              await controller.evaluateJavascript(source: """
            window.addEventListener('beforeunload', function (e) {
              e.preventDefault();
              e.returnValue = '';
            });
            """);
              if (!pageLoaded.isCompleted) {
                pageLoaded.complete();
              }
            },
            androidOnJsBeforeUnload: (controller, jsBeforeUnloadRequest) async {
              onJsBeforeUnloadCompleter
                  .complete(jsBeforeUnloadRequest.url.toString());
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;
      await controller.evaluateJavascript(
          source: "window.location.href = 'https://github.com/flutter';");
      final String url = await onJsBeforeUnloadCompleter.future;
      expect(url, 'https://github.com/flutter');
    }, skip: true /*!Platform.isAndroid*/);

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
      }, skip: !Platform.isIOS);

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
      }, skip: !Platform.isIOS);
    }, skip: !Platform.isIOS);

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

      if (Platform.isAndroid) {
        await pageLoaded.future;
        expect(await controller.evaluateJavascript(source: "document.body"),
            isNullOrEmpty);
      } else if (Platform.isIOS) {
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

    testWidgets('saveWebArchive', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
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

      // wait a little bit after page load otherwise Android will not save the web archive
      await Future.delayed(Duration(seconds: 1));

      var supportDir = await getApplicationSupportDirectory();

      var fileName = "flutter-website.";
      if (Platform.isAndroid) {
        fileName = fileName + WebArchiveFormat.MHT.toValue();
      } else if (Platform.isIOS) {
        fileName = fileName + WebArchiveFormat.WEBARCHIVE.toValue();
      }

      var fullPath = supportDir.path + Platform.pathSeparator + fileName;
      var path = await controller.saveWebArchive(filePath: fullPath);
      expect(path, isNotNull);
      expect(path, endsWith(fileName));

      path = await controller.saveWebArchive(
          filePath: supportDir.path, autoname: true);
      expect(path, isNotNull);
    });

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
      }, skip: !Platform.isAndroid);

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
      }, skip: !Platform.isAndroid);

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
      }, skip: !Platform.isAndroid);

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
      }, skip: !Platform.isAndroid);

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
      }, skip: !Platform.isAndroid);

      test('clearClientCertPreferences', () async {
        await expectLater(
            AndroidInAppWebViewController.clearClientCertPreferences(),
            completes);
      }, skip: !Platform.isAndroid);

      test('getSafeBrowsingPrivacyPolicyUrl', () async {
        expect(
            await AndroidInAppWebViewController
                .getSafeBrowsingPrivacyPolicyUrl(),
            isNotNull);
      }, skip: !Platform.isAndroid);

      test('setSafeBrowsingWhitelist', () async {
        expect(
            await AndroidInAppWebViewController.setSafeBrowsingWhitelist(
                hosts: ["flutter.dev", "github.com"]),
            true);
      }, skip: !Platform.isAndroid);

      test('getCurrentWebViewPackage', () async {
        expect(await AndroidInAppWebViewController.getCurrentWebViewPackage(),
            isNotNull);
      }, skip: !Platform.isAndroid);

      test('setWebContentsDebuggingEnabled', () async {
        expect(
            AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true),
            completes);
      }, skip: !Platform.isAndroid);
    }, skip: !Platform.isAndroid);

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
      }, skip: !Platform.isIOS);

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
      }, skip: !Platform.isIOS);

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
      }, skip: !Platform.isIOS);

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
      }, skip: !Platform.isIOS);

      test('handlesURLScheme', () async {
        expect(await IOSInAppWebViewController.handlesURLScheme("http"), true);
        expect(await IOSInAppWebViewController.handlesURLScheme("https"), true);
      }, skip: !Platform.isIOS);
    }, skip: !Platform.isIOS);
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
    }, skip: !Platform.isAndroid);

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
    }, skip: !Platform.isAndroid);
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
    }, skip: !Platform.isAndroid);
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
