part of 'main.dart';

void videoPlaybackPolicy() {
  final shouldSkip = !InAppWebViewSettings.isPropertySupported(
    InAppWebViewSettingsProperty.mediaPlaybackRequiresUserGesture,
  );

  skippableGroup('Video playback policy', () {
    String videoTestBase64 = "";
    setUpAll(() async {
      final ByteData videoData = await rootBundle.load(
        'test_assets/sample_video.mp4',
      );
      final String base64VideoData = base64Encode(
        Uint8List.view(videoData.buffer),
      );
      final String videoTest =
          '''
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

    skippableTestWidgets('Auto media playback', (WidgetTester tester) async {
      Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
              url: WebUri(
                'data:text/html;charset=utf-8;base64,$videoTestBase64',
              ),
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
            ),
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );
      InAppWebViewController controller = await controllerCompleter.future;
      await pageLoaded.future;

      bool isPaused = await controller.evaluateJavascript(
        source: 'isPaused();',
      );
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
              url: WebUri(
                'data:text/html;charset=utf-8;base64,$videoTestBase64',
              ),
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: true,
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

    final shouldSkipTest2 = !InAppWebViewSettings.isPropertySupported(
      InAppWebViewSettingsProperty.allowsInlineMediaPlayback,
    );

    skippableTestWidgets(
      'Video plays inline when allowsInlineMediaPlayback is true',
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
                url: WebUri(
                  'data:text/html;charset=utf-8;base64,$videoTestBase64',
                ),
              ),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
              ),
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
      },
      skip: shouldSkipTest2,
    );

    final shouldSkipTest3 = !InAppWebViewSettings.isPropertySupported(
      InAppWebViewSettingsProperty.allowsInlineMediaPlayback,
    );

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
                url: WebUri(
                  'data:text/html;charset=utf-8;base64,$videoTestBase64',
                ),
              ),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: false,
              ),
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

        await tester.pump();

        await expectLater(onEnterFullscreenCompleter.future, completes);
      },
      skip: shouldSkipTest3,
    );

    final shouldSkipTest4 = !InAppWebViewSettings.isPropertySupported(
      InAppWebViewSettingsProperty.allowsInlineMediaPlayback,
    );
    // on Android, entering fullscreen requires user interaction
    skippableTestWidgets('exit fullscreen event', (WidgetTester tester) async {
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
              url: WebUri(
                'data:text/html;charset=utf-8;base64,$videoTestBase64',
              ),
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: false,
            ),
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
      await tester.pump();
      await controller.evaluateJavascript(source: "exitFullscreen();");

      await expectLater(onExitFullscreenCompleter.future, completes);
    }, skip: shouldSkipTest4);
  }, skip: shouldSkip);
}
