import 'dart:async';
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

import '.env.dart';

class Foo {
  String? bar;
  String? baz;

  Foo({this.bar, this.baz});

  Map<String, dynamic> toJson() {
    return {
      'bar': this.bar,
      'baz': this.baz
    };
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    AndroidInAppWebViewController.setWebContentsDebuggingEnabled(false);
  }

  testWidgets('initialUrl', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrl: 'https://flutter.dev/',
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    final String? currentUrl = await controller.getUrl();
    expect(currentUrl, 'https://flutter.dev/');
  });

  testWidgets('loadUrl', (WidgetTester tester) async {
    final Completer controllerCompleter =
    Completer<InAppWebViewController>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrl: 'https://flutter.dev/',
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    await controller.loadUrl(url: 'https://www.google.com/');
    final String? currentUrl = await controller.getUrl();
    expect(currentUrl, 'https://www.google.com/');
  });

  testWidgets('loadUrl with headers', (WidgetTester tester) async {
    final Completer controllerCompleter =
    Completer<InAppWebViewController>();
    final StreamController<String> pageStarts = StreamController<String>();
    final StreamController<String> pageLoads = StreamController<String>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrl: 'https://flutter.dev/',
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true
            )
          ),
          onLoadStart: (controller, url) {
            pageStarts.add(url!);
          },
          onLoadStop: (controller, url) {
            pageLoads.add(url!);
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    final Map<String, String> headers = <String, String>{
      'test_header': 'flutter_test_header'
    };
    await controller.loadUrl(url: 'https://flutter-header-echo.herokuapp.com/',
        headers: headers);
    final String? currentUrl = await controller.getUrl();
    expect(currentUrl, 'https://flutter-header-echo.herokuapp.com/');

    await pageStarts.stream.firstWhere((String url) => url == currentUrl);
    await pageLoads.stream.firstWhere((String url) => url == currentUrl);

    final String content = await controller
        .evaluateJavascript(source: 'document.documentElement.innerText');
    expect(content.contains('flutter_test_header'), isTrue);
  });

  testWidgets('JavaScript Handler', (WidgetTester tester) async {

    final Completer controllerCompleter =
    Completer<InAppWebViewController>();
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
          initialFile: "test_assets/in_app_webview_javascript_handler_test.html",
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);

            controller.addJavaScriptHandler(handlerName:'handlerFoo', callback: (args) {
              handlerFoo.complete();
              return Foo(bar: 'bar_value', baz: 'baz_value');
            });

            controller.addJavaScriptHandler(handlerName: 'handlerFooWithArgs', callback: (args) {
              messagesReceived.add(args[0] as int);
              messagesReceived.add(args[1] as bool);
              messagesReceived.add(args[2] as List<dynamic>?);
              messagesReceived.add(args[3]?.cast<String, String>() as Map<String, String>?);
              messagesReceived.add(args[4]?.cast<String, String>() as Map<String, String>?);
              handlerFooWithArgs.complete();
            });
          },
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true
              )
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
    final InAppWebViewController controller = await controllerCompleter.future;
    await pageStarted.future;
    await pageLoaded.future;
    await handlerFoo.future;
    await handlerFooWithArgs.future;

    expect(messagesReceived[0], 1);
    expect(messagesReceived[1], true);
    expect(listEquals(messagesReceived[2] as List<dynamic>?, ["bar", 5]), true);
    expect(mapEquals(messagesReceived[3], {"foo": "baz"}), true);
    expect(mapEquals(messagesReceived[4], {"bar":"bar_value","baz":"baz_value"}), true);
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
    final Completer controllerCompleter =
    Completer<InAppWebViewController>();
    final GlobalKey key = GlobalKey();

    final InAppWebView webView = InAppWebView(
      key: key,
      initialUrl: 'data:text/html;charset=utf-8;base64,$resizeTestBase64',
      onWebViewCreated: (controller) {
        controllerCompleter.complete(controller);

        controller.addJavaScriptHandler(handlerName:'resize', callback: (args) {
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
          crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true
          )
      ),
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
          initialUrl: 'about:blank',
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  userAgent: 'Custom_User_Agent1',
              )
          ),
          onWebViewCreated: (controller) {
            controllerCompleter1.complete(controller);
          },
        ),
      ),
    );
    InAppWebViewController controller1 = await controllerCompleter1.future;
    final String customUserAgent1 = await controller1.evaluateJavascript(source: 'navigator.userAgent;');
    expect(customUserAgent1, 'Custom_User_Agent1');

    await controller1.setOptions(options: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          userAgent: 'Custom_User_Agent2',
        )
    ));

    final String customUserAgent2 = await controller1.evaluateJavascript(source: 'navigator.userAgent;');
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
            function isFullScreen() {
              var video = document.getElementById("video");
              return video.webkitDisplayingFullscreen;
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
            initialUrl: 'data:text/html;charset=utf-8;base64,$videoTestBase64',
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  mediaPlaybackRequiresUserGesture: false
                )
            ),
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );
      InAppWebViewController controller = await controllerCompleter.future;
      await pageLoaded.future;

      bool isPaused = await controller.evaluateJavascript(source: 'isPaused();');
      expect(isPaused, false);

      controllerCompleter = Completer<InAppWebViewController>();
      pageLoaded = Completer<void>();

      // We change the key to re-create a new webview as we change the mediaPlaybackRequiresUserGesture
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrl: 'data:text/html;charset=utf-8;base64,$videoTestBase64',
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    mediaPlaybackRequiresUserGesture: true
                )
            ),
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

          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: InAppWebView(
                key: GlobalKey(),
                initialUrl: 'data:text/html;charset=utf-8;base64,$videoTestBase64',
                onWebViewCreated: (controller) {
                  controllerCompleter.complete(controller);
                },
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        javaScriptEnabled: true,
                        mediaPlaybackRequiresUserGesture: false,
                    ),
                  ios: IOSInAppWebViewOptions(
                    allowsInlineMediaPlayback: true
                  )
                ),
                onLoadStop: (controller, url) {
                  pageLoaded.complete();
                },
              ),
            ),
          );
          InAppWebViewController controller = await controllerCompleter.future;
          await pageLoaded.future;

          bool isFullScreen =
          await controller.evaluateJavascript(source: 'isFullScreen();');
          expect(isFullScreen, false);
        });

    testWidgets('Video plays fullscreen when allowsInlineMediaPlayback is false',
            (WidgetTester tester) async {
          Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
          Completer<void> pageLoaded = Completer<void>();

          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: InAppWebView(
                key: GlobalKey(),
                initialUrl: 'data:text/html;charset=utf-8;base64,$videoTestBase64',
                onWebViewCreated: (controller) {
                  controllerCompleter.complete(controller);
                },
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      javaScriptEnabled: true,
                      mediaPlaybackRequiresUserGesture: false,
                    ),
                    ios: IOSInAppWebViewOptions(
                        allowsInlineMediaPlayback: false
                    )
                ),
                onLoadStop: (controller, url) {
                  pageLoaded.complete();
                },
              ),
            ),
          );

          InAppWebViewController controller = await controllerCompleter.future;
          await pageLoaded.future;

          bool isFullScreen = await controller.evaluateJavascript(source: 'isFullScreen();');
          expect(isFullScreen, true);
        }, skip: true /*https://github.com/flutter/flutter/issues/72572 */);
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
            initialUrl: 'data:text/html;charset=utf-8;base64,$audioTestBase64',
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    mediaPlaybackRequiresUserGesture: false
                )
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
      InAppWebViewController controller = await controllerCompleter.future;
      await pageStarted.future;
      await pageLoaded.future;

      bool isPaused = await controller.evaluateJavascript(source: 'isPaused();');
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
            initialUrl: 'data:text/html;charset=utf-8;base64,$audioTestBase64',
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    mediaPlaybackRequiresUserGesture: true
                ),
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
    final Completer controllerCompleter =
    Completer<InAppWebViewController>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          initialUrl: 'data:text/html;charset=utf-8;base64,$getTitleTestBase64',
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

    final InAppWebViewController controller = await controllerCompleter.future;
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
            initialUrl:
            'data:text/html;charset=utf-8;base64,$scrollTestPageBase64',
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller = await controllerCompleter.future;
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
            initialUrl:
            'data:text/html;charset=utf-8;base64,$scrollTestPageBase64',
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialOptions: InAppWebViewGroupOptions(
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true
              )
            ),
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller = await controllerCompleter.future;
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
    final String page = '''<!DOCTYPE html><head></head><body><a id="link" href="https://github.com/pichillilorenzo/flutter_inappwebview">flutter_inappwebview</a></body></html>''';
    final String pageEncoded = 'data:text/html;charset=utf-8;base64,' +
        base64Encode(const Utf8Encoder().convert(page));

    testWidgets('can allow requests', (WidgetTester tester) async {
      final Completer controllerCompleter =
      Completer<InAppWebViewController>();
      final StreamController<String> pageLoads = StreamController<String>.broadcast();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrl: pageEncoded,
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true
              ),
            ),
            shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
              return (shouldOverrideUrlLoadingRequest.url.contains('youtube.com'))
                  ? ShouldOverrideUrlLoadingAction.CANCEL
                  : ShouldOverrideUrlLoadingAction.ALLOW;
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!);
            },
          ),
        ),
      );

      await pageLoads.stream.first; // Wait for initial page load.
      final InAppWebViewController controller = await controllerCompleter.future;
      await controller
          .evaluateJavascript(source: 'location.href = "https://www.google.com/"');

      await pageLoads.stream.first; // Wait for the next page load.
      final String? currentUrl = await controller.getUrl();
      expect(currentUrl, 'https://www.google.com/');
    });

    testWidgets('allow requests on iOS only if iosWKNavigationType == IOSWKNavigationType.LINK_ACTIVATED', (WidgetTester tester) async {
      final Completer controllerCompleter =
      Completer<InAppWebViewController>();
      final StreamController<String> pageLoads = StreamController<String>.broadcast();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrl: pageEncoded,
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  useShouldOverrideUrlLoading: true
              ),
            ),
            shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
              return (shouldOverrideUrlLoadingRequest.iosWKNavigationType == IOSWKNavigationType.LINK_ACTIVATED)
                  ? ShouldOverrideUrlLoadingAction.ALLOW
                  : ShouldOverrideUrlLoadingAction.CANCEL;
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!);
            },
          ),
        ),
      );

      await pageLoads.stream.first; // Wait for initial page load.
      final InAppWebViewController controller = await controllerCompleter.future;
      await controller.evaluateJavascript(source: 'location.href = "https://www.google.com/"');

      // There should never be any second page load, since our new URL is
      // blocked. Still wait for a potential page change for some time in order
      // to give the test a chance to fail.
      await pageLoads.stream.map((event) => event as String?).first
          .timeout(const Duration(milliseconds: 500), onTimeout: () => null);
      String? currentUrl = await controller.getUrl();
      expect(currentUrl, isNot('https://www.google.com/'));

      await controller.evaluateJavascript(source: 'document.querySelector("#link").click();');
      await pageLoads.stream.first; // Wait for the next page load.
      currentUrl = await controller.getUrl();
      expect(currentUrl, 'https://github.com/pichillilorenzo/flutter_inappwebview');
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
            initialUrl: pageEncoded,
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  useShouldOverrideUrlLoading: true
              ),
            ),
            shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
              return (shouldOverrideUrlLoadingRequest.url.contains('youtube.com'))
                  ? ShouldOverrideUrlLoadingAction.CANCEL
                  : ShouldOverrideUrlLoadingAction.ALLOW;
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!);
            },
          ),
        ),
      );

      await pageLoads.stream.first; // Wait for initial page load.
      final InAppWebViewController controller = await controllerCompleter.future;
      await controller
          .evaluateJavascript(source: 'location.href = "https://www.youtube.com/"');

      // There should never be any second page load, since our new URL is
      // blocked. Still wait for a potential page change for some time in order
      // to give the test a chance to fail.
      await pageLoads.stream.map((event) => event as String?).first
          .timeout(const Duration(milliseconds: 500), onTimeout: () => null);
      final String? currentUrl = await controller.getUrl();
      expect(currentUrl, isNot(contains('youtube.com')));
    });

    testWidgets('supports asynchronous decisions', (WidgetTester tester) async {
      final Completer controllerCompleter =
      Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
      StreamController<String>.broadcast();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrl: pageEncoded,
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  useShouldOverrideUrlLoading: true
              ),
            ),
            shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
              var action = ShouldOverrideUrlLoadingAction.CANCEL;
              action = await Future<ShouldOverrideUrlLoadingAction>.delayed(
                  const Duration(milliseconds: 10),
                      () => ShouldOverrideUrlLoadingAction.ALLOW);
              return action;
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!);
            },
          ),
        ),
      );

      await pageLoads.stream.first; // Wait for initial page load.
      final InAppWebViewController controller = await controllerCompleter.future;
      await controller
          .evaluateJavascript(source: 'location.href = "https://www.google.com"');

      await pageLoads.stream.first; // Wait for second page to load.
      final String? currentUrl = await controller.getUrl();
      expect(currentUrl, 'https://www.google.com/');
    });
  });

  testWidgets('onLoadError', (WidgetTester tester) async {
    final Completer<String> errorUrlCompleter = Completer<String>();
    final Completer<int> errorCodeCompleter = Completer<int>();
    final Completer<String> errorMessageCompleter = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrl: 'https://www.notawebsite..com',
          onLoadError: (controller, url, code, message) {
            errorUrlCompleter.complete(url);
            errorCodeCompleter.complete(code);
            errorMessageCompleter.complete(message);
          },
        ),
      ),
    );

    final String url = await errorUrlCompleter.future;
    final int code = await errorCodeCompleter.future;
    final String message = await errorMessageCompleter.future;

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
              initialUrl:
              'data:text/html;charset=utf-8;base64,PCFET0NUWVBFIGh0bWw+',
              onLoadError: (controller, url, code, message) {
                errorUrlCompleter.complete(url);
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
        final Completer controllerCompleter =
        Completer<InAppWebViewController>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              height: 300,
              child: InAppWebView(
                key: GlobalKey(),
                initialUrl: 'https://flutter.dev/',
                initialOptions: InAppWebViewGroupOptions(
                  ios: IOSInAppWebViewOptions(
                    allowsBackForwardNavigationGestures: true
                  )
                ),
                onWebViewCreated: (controller) {
                  controllerCompleter.complete(controller);
                },
              ),
            ),
          ),
        );
        final InAppWebViewController controller = await controllerCompleter.future;
        final String? currentUrl = await controller.getUrl();
        expect(currentUrl, contains('flutter.dev'));
      });

  testWidgets('target _blank opens in same window',
          (WidgetTester tester) async {
        final Completer controllerCompleter =
        Completer<InAppWebViewController>();
        final StreamController<String> pageLoads = StreamController<String>.broadcast();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  javaScriptCanOpenWindowsAutomatically: true
                ),
              ),
              onLoadStop: (controller, url) {
                pageLoads.add(url!);
              },
            ),
          ),
        );
        await pageLoads.stream.first;
        final InAppWebViewController controller = await controllerCompleter.future;

        await controller.evaluateJavascript(source: 'window.open("about:blank", "_blank")');
        await pageLoads.stream.first;
        final String? currentUrl = await controller.getUrl();
        expect(currentUrl, 'about:blank');
      });

  testWidgets(
    'can open new window and go back',
        (WidgetTester tester) async {
      final Completer controllerCompleter =
      Completer<InAppWebViewController>();
      final StreamController<String> pageLoads = StreamController<String>.broadcast();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  javaScriptCanOpenWindowsAutomatically: true
              ),
            ),
            onLoadStop: (controller, url) {
              pageLoads.add(url!);
            },
            initialUrl: 'https://flutter.dev',
          ),
        ),
      );
      await pageLoads.stream.first;
      final InAppWebViewController controller = await controllerCompleter.future;

      await controller
          .evaluateJavascript(source: 'window.open("https://www.google.com")');
      await pageLoads.stream.first;
      expect(await controller.getUrl(), contains('google.com'));

      await controller.goBack();
      await pageLoads.stream.first;
      expect(await controller.getUrl(), contains('flutter.dev'));
    },
    skip: !Platform.isAndroid,
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
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  javaScriptCanOpenWindowsAutomatically: true
              ),
            ),
            initialUrl:
            'data:text/html;charset=utf-8;base64,$openWindowTestBase64',
            onLoadStop: (controller, url) {
              pageLoadCompleter.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller = await controllerCompleter.future;
      await pageLoadCompleter.future;

      await expectLater(controller.evaluateJavascript(source: 'iframeLoaded'), completion(true));
      await expectLater(
        controller.evaluateJavascript(
            source: 'document.querySelector("p") && document.querySelector("p").textContent'),
        completion(null),
      );
    },
    skip: !Platform.isAndroid,
  );

  testWidgets('intercept ajax request', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final Completer shouldInterceptAjaxPostRequestCompleter = Completer<void>();
    final Completer<Map<String, dynamic>> onAjaxReadyStateChangeCompleter = Completer<Map<String, dynamic>>();
    final Completer<Map<String, dynamic>> onAjaxProgressCompleter = Completer<Map<String, dynamic>>();
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

            var xhttp2 = new XMLHttpRequest();
            xhttp2.open("GET", "http://${environment["NODE_SERVER_IP"]}:8082/test-download-file");
            xhttp2.send();
          });
        </script>
    </body>
</html>
                    """),
          initialHeaders: {},
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                clearCache: true,
                useShouldInterceptAjaxRequest: true,
              )
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
            if (ajaxRequest.url!.endsWith("/test-ajax-post")) {
              ajaxRequest.responseType = 'json';
              ajaxRequest.data = "firstname=Foo2&lastname=Bar2";
              shouldInterceptAjaxPostRequestCompleter.complete(controller);
            }
            return ajaxRequest;
          },
          onAjaxReadyStateChange: (controller, ajaxRequest) async {
            if (ajaxRequest.readyState == AjaxRequestReadyState.DONE && ajaxRequest.status == 200 && ajaxRequest.url!.endsWith("/test-ajax-post")) {
              Map<String, dynamic> res = ajaxRequest.response;
              onAjaxReadyStateChangeCompleter.complete(res);
            }
            return AjaxRequestAction.PROCEED;
          },
          onAjaxProgress: (controller, ajaxRequest) async {
            if (ajaxRequest.event!.type == AjaxRequestEventType.LOAD && ajaxRequest.url!.endsWith("/test-ajax-post")) {
              Map<String, dynamic> res = ajaxRequest.response;
              onAjaxProgressCompleter.complete(res);
            }
            return AjaxRequestAction.PROCEED;
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await shouldInterceptAjaxPostRequestCompleter.future;
    final Map<String, dynamic> onAjaxReadyStateChangeValue = await onAjaxReadyStateChangeCompleter.future;
    final Map<String, dynamic> onAjaxProgressValue = await onAjaxProgressCompleter.future;

    expect(mapEquals(onAjaxReadyStateChangeValue, {'firstname': 'Foo2', 'lastname': 'Bar2'}), true);
    expect(mapEquals(onAjaxProgressValue, {'firstname': 'Foo2', 'lastname': 'Bar2'}), true);
  });

  testWidgets('Content Blocker', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrl: 'https://flutter.dev/',
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  clearCache: true,
                  contentBlockers: [
                    ContentBlocker(
                        trigger: ContentBlockerTrigger(
                            urlFilter: ".*",
                            resourceType: [
                              ContentBlockerTriggerResourceType.IMAGE,
                              ContentBlockerTriggerResourceType.STYLE_SHEET
                            ],
                            ifTopUrl: [
                              "https://flutter.dev/"
                            ]),
                        action: ContentBlockerAction(
                            type: ContentBlockerActionType.BLOCK))
                  ]
              )
          ),
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    await expectLater(pageLoaded.future, completes);
  });

  testWidgets('Cookie Manager', (WidgetTester tester) async {
    CookieManager cookieManager = CookieManager.instance();
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final Completer<String> pageLoaded = Completer<String>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrl: 'https://flutter.dev/',
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  clearCache: true,
              )
          ),
          onLoadStop: (controller, url) {
            pageLoaded.complete(url);
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    final String url = await pageLoaded.future;

    await cookieManager.setCookie(url: url, name: "myCookie", value: "myValue");
    List<Cookie> cookies = await cookieManager.getCookies(url: url);
    expect(cookies, isNotEmpty);

    Cookie? cookie = await cookieManager.getCookie(url: url, name: "myCookie");
    expect(cookie?.value.toString(), "myValue");

    await cookieManager.deleteCookie(url: url, name: "myCookie");
    cookie = await cookieManager.getCookie(url: url, name: "myCookie");
    expect(cookie, isNull);

    await cookieManager.deleteCookies(url: url);
    cookies = await cookieManager.getCookies(url: url);
    expect(cookies, isEmpty);
  });

  testWidgets('intercept fetch request', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final Completer<String> fetchGetCompleter = Completer<String>();
    final Completer<Map<String, dynamic>> fetchPostCompleter = Completer<Map<String, dynamic>>();
    final Completer<void> shouldInterceptFetchPostRequestCompleter = Completer<void>();
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
            fetch(new Request("http://${environment["NODE_SERVER_IP"]}:8082/test-download-file")).then(function(response) {
                window.flutter_inappwebview.callHandler('fetchGet', response.status);
            }).catch(function(error) {
                window.flutter_inappwebview.callHandler('fetchGet', "ERROR: " + error);
            });

            fetch("http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post", {
                method: 'POST',
                body: JSON.stringify({
                    firstname: 'Foo',
                    lastname: 'Bar'
                }),
                headers: {
                  'Content-Type': 'application/json'
                }
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
          initialHeaders: {},
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                clearCache: true,
                useShouldInterceptFetchRequest: true,
              )
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);

            controller.addJavaScriptHandler(handlerName: "fetchGet", callback: (args) {
              fetchGetCompleter.complete(args[0].toString());
            });

            controller.addJavaScriptHandler(handlerName: "fetchPost", callback: (args) {
              fetchPostCompleter.complete(args[0] as Map<String, dynamic>);
            });
          },
          shouldInterceptFetchRequest: (controller, fetchRequest) async {
            if (fetchRequest.url!.endsWith("/test-ajax-post")) {
              fetchRequest.body = utf8.encode("""{
                "firstname": "Foo2",
                "lastname": "Bar2"
              }
              """) as Uint8List;
              shouldInterceptFetchPostRequestCompleter.complete();
            }
            return fetchRequest;
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;

    var fetchGetCompleterValue = await fetchGetCompleter.future;
    expect(fetchGetCompleterValue, '200');

    await shouldInterceptFetchPostRequestCompleter.future;
    var fetchPostCompleterValue = await fetchPostCompleter.future;

    expect(mapEquals(fetchPostCompleterValue, {'firstname': 'Foo2', 'lastname': 'Bar2'}), true);
  });

  testWidgets('Http Auth Credential Database', (WidgetTester tester) async {
    HttpAuthCredentialDatabase httpAuthCredentialDatabase = HttpAuthCredentialDatabase.instance();
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    httpAuthCredentialDatabase.setHttpAuthCredential(
        protectionSpace: ProtectionSpace(host: environment["NODE_SERVER_IP"]!, protocol: "http", realm: "Node", port: 8081),
        credential: HttpAuthCredential(username: "USERNAME", password: "PASSWORD")
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrl: "http://${environment["NODE_SERVER_IP"]}:8081/",
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                clearCache: true,
              )
          ),
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onReceivedHttpAuthRequest: (controller, challenge) async {
            return new HttpAuthResponse(action: HttpAuthResponseAction.USE_SAVED_HTTP_AUTH_CREDENTIALS);
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    final String h1Content = await controller.evaluateJavascript(source: "document.body.querySelector('h1').textContent");
    expect(h1Content, "Authorized");

    var credentials = await httpAuthCredentialDatabase.getHttpAuthCredentials(protectionSpace:
      ProtectionSpace(host: environment["NODE_SERVER_IP"]!, protocol: "http", realm: "Node", port: 8081)
    );
    expect(credentials.length, 1);

    await httpAuthCredentialDatabase.clearAllAuthCredentials();
    credentials = await httpAuthCredentialDatabase.getHttpAuthCredentials(protectionSpace:
      ProtectionSpace(host: environment["NODE_SERVER_IP"]!, protocol: "http", realm: "Node", port: 8081)
    );
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
          initialUrl: "http://${environment["NODE_SERVER_IP"]}:8081/",
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                clearCache: true,
              )
          ),
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
    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    final String h1Content = await controller.evaluateJavascript(source: "document.body.querySelector('h1').textContent");
    expect(h1Content, "Authorized");
  });

  testWidgets('onConsoleMessage', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final Completer<ConsoleMessage> onConsoleMessageCompleter = Completer<ConsoleMessage>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialFile: "test_assets/in_app_webview_on_console_message_test.html",
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onConsoleMessage: (controller, consoleMessage) {
            onConsoleMessageCompleter.complete(consoleMessage);
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    final ConsoleMessage consoleMessage = await onConsoleMessageCompleter.future;
    expect(consoleMessage.message, 'message');
    expect(consoleMessage.messageLevel, ConsoleMessageLevel.LOG);
  });

  group("WebView Windows", () {
    testWidgets('onCreateWindow return false', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialFile: "test_assets/in_app_webview_on_create_window_test.html",
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  clearCache: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                )
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              if (url == "https://flutter.dev/") {
                pageLoaded.complete();
              }
            },
            onCreateWindow: (controller, createWindowRequest) async {
              controller.loadUrl(url: createWindowRequest.url!);
              return false;
            },
          ),
        ),
      );
      final InAppWebViewController controller = await controllerCompleter.future;
      await expectLater(pageLoaded.future, completes);
    });

    testWidgets('onCreateWindow return true', (WidgetTester tester) async {
      int? windowId;
      String? windowUrl;

      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final Completer<void> onCreateWindowCompleter = Completer<void>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialFile: "test_assets/in_app_webview_on_create_window_test.html",
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  clearCache: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                )
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onCreateWindow: (controller, createWindowRequest) async {
              windowId = createWindowRequest.windowId;
              windowUrl = createWindowRequest.url;
              onCreateWindowCompleter.complete();
              return true;
            },
          ),
        ),
      );

      final InAppWebViewController controller = await controllerCompleter.future;
      await expectLater(onCreateWindowCompleter.future, completes);

      final Completer windowControllerCompleter = Completer<InAppWebViewController>();
      final Completer<String> windowPageLoaded = Completer<String>();
      final Completer<void> onCloseWindowCompleter = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialFile: windowUrl!,
            windowId: windowId!,
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  clearCache: true,
                )
            ),
            onWebViewCreated: (controller) {
              windowControllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) async {
              windowPageLoaded.complete(url!);
              await controller.evaluateJavascript(source: "window.close();");
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

  testWidgets('onDownloadStart', (WidgetTester tester) async {
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
                clearCache: true,
                useOnDownloadStart: true
              )
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onDownloadStart: (controller, url) {
            onDownloadStartCompleter.complete(url);
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    final String url = await onDownloadStartCompleter.future;
    expect(url, "http://${environment["NODE_SERVER_IP"]}:8082/test-download-file");
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
              )
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            controller.findAllAsync(find: "InAppWebViewInitialFileTest");
          },
          onFindResultReceived: (controller, int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting) async {
            if (isDoneCounting && !numberOfMatchesCompleter.isCompleted) {
              numberOfMatchesCompleter.complete(numberOfMatches);
            }
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    final int numberOfMatches = await numberOfMatchesCompleter.future;
    expect(numberOfMatches, 2);
  });

  testWidgets('javascript dialogs', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<JsAlertRequest> alertCompleter = Completer<JsAlertRequest>();
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
              )
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);

            controller.addJavaScriptHandler(handlerName: 'confirm', callback: (args) {
              confirmCompleter.complete(args[0] as bool);
            });

            controller.addJavaScriptHandler(handlerName: 'prompt', callback: (args) {
              promptCompleter.complete(args[0] as String);
            });
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onJsAlert:
              (controller, jsAlertRequest) async {
            JsAlertResponseAction action = JsAlertResponseAction.CONFIRM;
            alertCompleter.complete(jsAlertRequest);
            return JsAlertResponse(
                handledByClient: true, action: action);
          },
          onJsConfirm:
              (controller, jsConfirmRequest) async {
            JsConfirmResponseAction action = JsConfirmResponseAction.CONFIRM;
            return JsConfirmResponse(
                handledByClient: true, action: action);
          },
          onJsPrompt: (controller, jsPromptRequest) async {
            JsPromptResponseAction action = JsPromptResponseAction.CONFIRM;
            return JsPromptResponse(
                handledByClient: true,
                action: action,
                value: 'new value');
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
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
          initialUrl: 'https://google.com/404',
          onLoadHttpError: (controller, url, statusCode, description) async {
            errorUrlCompleter.complete(url);
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
          initialFile: "test_assets/in_app_webview_on_load_resource_custom_scheme_test.html",
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  clearCache: true,
                  resourceCustomSchemes: ["my-special-custom-scheme"]
              )
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);

            controller.addJavaScriptHandler(handlerName: "imageLoaded", callback: (args) {
              imageLoaded.complete();
            });
          },
          onLoadResourceCustomScheme: (controller, scheme, url) async {
            if (scheme == "my-special-custom-scheme") {
              var bytes = await rootBundle.load("test_assets/" + url.replaceFirst("my-special-custom-scheme://", "", 0));
              var response = CustomSchemeResponse(data: bytes.buffer.asUint8List(), contentType: "image/svg+xml", contentEnconding: "utf-8");
              return response;
            }
            return null;
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
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
          initialFile: "test_assets/in_app_webview_on_load_resource_test.html",
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  clearCache: true,
                  useOnLoadResource: true
              )
          ),
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onLoadResource: (controller, response) async {
            resourceLoaded.add(response.url!);
            if (resourceLoaded.length == resourceList.length) {
              loadedResourceCompleter.complete();
            }
          }
        ),
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
          initialUrl: "https://flutter.dev/",
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    clearCache: true
                )
            ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onUpdateVisitedHistory: (controller, url, androidIsReload) async {
              if (url!.endsWith("second-push")) {
                secondPushCompleter.complete();
              } else if (url.endsWith("first-push")) {
                firstPushCompleter.complete();
              }
            },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
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
    expect(await controller.getUrl(), 'https://flutter.dev/first-push');

    await secondPushCompleter.future;
    expect(await controller.getUrl(), 'https://flutter.dev/second-push');
  });

  testWidgets('onProgressChanged', (WidgetTester tester) async {
    final Completer<void> onProgressChangedCompleter = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrl: 'https://flutter.dev/',
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  clearCache: true,
              )
          ),
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
          initialUrl: 'chrome://safe-browsing/match?type=malware',
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
            pageLoaded.complete(url);
          },
          androidOnSafeBrowsingHit: (controller, url, threatType) async {
            return SafeBrowsingResponse(report: true, action: SafeBrowsingResponseAction.PROCEED);
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
          initialUrl: 'https://flutter.dev/',
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

    final InAppWebViewController controller = await controllerCompleter.future;
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
          initialUrl: "https://${environment["NODE_SERVER_IP"]}:4433/",
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onReceivedServerTrustAuthRequest: (controller, challenge) async {
            return new ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
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
    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    final String h1Content = await controller.evaluateJavascript(source: "document.body.querySelector('h1').textContent");
    expect(h1Content, "Authorized");
  });

  testWidgets('onPrint', (WidgetTester tester) async {
    final Completer<String> onPrintCompleter = Completer<String>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrl: 'https://flutter.dev/',
          onLoadStop: (controller, url) async {
            await controller.evaluateJavascript(source: "window.print();");
          },
          onPrint: (controller, url) {
            onPrintCompleter.complete(url);
          },
        ),
      ),
    );
    final String url = await onPrintCompleter.future;
    expect(url, 'https://flutter.dev/');
  });

  testWidgets('onWindowFocus', (WidgetTester tester) async {
    final Completer<void> onWindowFocusCompleter = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrl: 'https://flutter.dev/',
          onLoadStop: (controller, url) async {
            await controller.evaluateJavascript(source: 'window.dispatchEvent(new Event("focus"));');
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
          initialUrl: 'https://flutter.dev/',
          onLoadStop: (controller, url) async {
            await controller.evaluateJavascript(source: 'window.dispatchEvent(new Event("blur"));');
          },
          onWindowBlur: (controller) {
            onWindowBlurCompleter.complete();
          },
        ),
      ),
    );
    await expectLater(onWindowBlurCompleter.future, completes);
  });
}
