// End-to-end test of the Linux WebView backend inside a real Flutter Linux
// application: rendering into the Flutter texture, JavaScript evaluation,
// pointer input, keyboard input and scrolling.
//
// Run with:
//   flutter test integration_test/webview_rendering_input_test.dart -d linux
//
// The test works with both the WPE WebKit and the WebKitGTK backends.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_inappwebview_linux/flutter_inappwebview_linux.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

const String _kTestHtml = '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  html, body { margin: 0; padding: 0; background: #ffffff; font-family: sans-serif; }
  #box { position: absolute; left: 0; top: 0; width: 200px; height: 200px; background: #ff0000; }
  #btn { position: absolute; left: 250px; top: 20px; width: 200px; height: 60px; font-size: 20px; }
  #inp { position: absolute; left: 250px; top: 120px; width: 200px; height: 40px; font-size: 20px; }
  #tall { position: absolute; left: 0; top: 260px; width: 100px; height: 3000px; background: #0000ff; }
</style>
</head>
<body>
  <div id="box"></div>
  <button id="btn" onclick="window.clicks = (window.clicks || 0) + 1; document.getElementById('box').style.background = '#00ff00';">Click me</button>
  <input id="inp" type="text" value="">
  <div id="tall"></div>
  <script>
    window.clicks = 0;
    window.hovered = false;
    document.getElementById('btn').addEventListener('mouseover', function () { window.hovered = true; });
    window.keydowns = [];
    document.getElementById('inp').addEventListener('keydown', function (e) { window.keydowns.push(e.key); });
  </script>
</body>
</html>
''';

Future<T> _waitFor<T>(
  Future<T?> Function() probe,
  bool Function(T?) accept, {
  Duration timeout = const Duration(seconds: 15),
  Duration interval = const Duration(milliseconds: 100),
}) async {
  final deadline = DateTime.now().add(timeout);
  T? last;
  while (DateTime.now().isBefore(deadline)) {
    last = await probe();
    if (accept(last)) return last as T;
    await Future<void>.delayed(interval);
  }
  throw TimeoutException('condition not met, last value: $last');
}

Future<ui.Image> _decodePng(Uint8List bytes) {
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(bytes, completer.complete);
  return completer.future;
}

Future<Color> _pixelAt(ui.Image image, int x, int y) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final offset = (y * image.width + x) * 4;
  final bytes = data!.buffer.asUint8List();
  return Color.fromARGB(bytes[offset + 3], bytes[offset], bytes[offset + 1], bytes[offset + 2]);
}

bool _isRoughly(Color c, int r, int g, int b, {int tolerance = 40}) {
  return (c.red - r).abs() <= tolerance &&
      (c.green - g).abs() <= tolerance &&
      (c.blue - b).abs() <= tolerance;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders, evaluates JS, and receives pointer/keyboard/scroll input',
      (WidgetTester tester) async {
    LinuxInAppWebViewPlatform.registerWith();

    final controllerCompleter = Completer<PlatformInAppWebViewController>();
    final loadStopCompleter = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 600,
              height: 400,
              child: Builder(
                builder: (context) => LinuxInAppWebViewWidget(
                  LinuxInAppWebViewWidgetCreationParams(
                    initialData: InAppWebViewInitialData(data: _kTestHtml),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      transparentBackground: false,
                    ),
                    onWebViewCreated: (controller) {
                      if (!controllerCompleter.isCompleted) {
                        controllerCompleter.complete(controller);
                      }
                    },
                    onLoadStop: (controller, url) {
                      if (!loadStopCompleter.isCompleted) {
                        loadStopCompleter.complete();
                      }
                    },
                  ),
                ).build(context),
              ),
            ),
          ),
        ),
      ),
    );

    // Let the platform view initialize and the page load.
    final controller = await controllerCompleter.future.timeout(const Duration(seconds: 20));
    for (int i = 0; i < 100 && !loadStopCompleter.isCompleted; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(loadStopCompleter.isCompleted, isTrue, reason: 'onLoadStop should fire');

    // --- JavaScript evaluation ---
    final title = await controller.evaluateJavascript(source: 'document.getElementById("btn").textContent');
    expect(title, 'Click me');

    // --- Rendering: the Flutter texture pipeline (pixel buffer) ---
    // Pump a few frames so WebKit has painted and frames were captured.
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    final Uint8List? png = await _waitFor<Uint8List>(
      () => controller.takeScreenshot(),
      (bytes) => bytes != null && bytes.length > 100,
    );
    final image = await _decodePng(png!);
    expect(image.width, greaterThan(100));
    expect(image.height, greaterThan(100));
    final scale = image.width / 600.0;
    final redPixel = await _pixelAt(image, (100 * scale).round(), (100 * scale).round());
    expect(_isRoughly(redPixel, 255, 0, 0), isTrue,
        reason: 'top-left box should be red, got $redPixel (image ${image.width}x${image.height})');
    final whitePixel = await _pixelAt(image, (550 * scale).round(), (230 * scale).round());
    expect(_isRoughly(whitePixel, 255, 255, 255), isTrue,
        reason: 'page background should be white, got $whitePixel');

    // --- Pointer input: hover + click the HTML button ---
    final webviewFinder = find.byType(Texture);
    expect(webviewFinder, findsOneWidget);
    final topLeft = tester.getTopLeft(webviewFinder);
    final buttonCenter = topLeft + const Offset(350, 50);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: topLeft + const Offset(10, 10));
    await tester.pump();
    await gesture.moveTo(buttonCenter);
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.down(buttonCenter);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));

    final clicks = await _waitFor<dynamic>(
      () => controller.evaluateJavascript(source: 'window.clicks'),
      (v) => v is num && v >= 1,
    );
    expect(clicks, 1);
    final hovered = await controller.evaluateJavascript(source: 'window.hovered');
    expect(hovered, isTrue);

    // The click handler turned the box green: verify through the texture pipeline.
    final Uint8List? png2 = await _waitFor<Uint8List>(
      () async {
        await tester.pump(const Duration(milliseconds: 50));
        final bytes = await controller.takeScreenshot();
        if (bytes == null) return null;
        final img = await _decodePng(bytes);
        final s = img.width / 600.0;
        final p = await _pixelAt(img, (100 * s).round(), (100 * s).round());
        return _isRoughly(p, 0, 255, 0) ? bytes : null;
      },
      (bytes) => bytes != null,
    );
    expect(png2, isNotNull, reason: 'box should turn green after the click');

    // --- Keyboard input: focus the <input> and type ---
    final inputCenter = topLeft + const Offset(350, 140);
    await gesture.moveTo(inputCenter);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.down(inputCenter);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));

    final focusedId = await _waitFor<dynamic>(
      () => controller.evaluateJavascript(source: 'document.activeElement && document.activeElement.id'),
      (v) => v == 'inp',
    );
    expect(focusedId, 'inp');

    for (final key in <LogicalKeyboardKey>[
      LogicalKeyboardKey.keyH,
      LogicalKeyboardKey.keyI,
    ]) {
      await tester.sendKeyDownEvent(key, platform: 'linux');
      await tester.pump(const Duration(milliseconds: 30));
      await tester.sendKeyUpEvent(key, platform: 'linux');
      await tester.pump(const Duration(milliseconds: 30));
    }
    // Shift+Exclamation to exercise modifiers/characters ("!").
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft, platform: 'linux');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.digit1, platform: 'linux', character: '!');
    await tester.pump(const Duration(milliseconds: 30));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.digit1, platform: 'linux');
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft, platform: 'linux');
    await tester.pump(const Duration(milliseconds: 100));

    final typed = await _waitFor<dynamic>(
      () => controller.evaluateJavascript(source: 'document.getElementById("inp").value'),
      (v) => v == 'hi!',
    );
    expect(typed, 'hi!');
    final keydowns = await controller.evaluateJavascript(source: 'JSON.stringify(window.keydowns)');
    expect(keydowns, contains('"h"'));

    // Backspace is a non-printable key: it must reach the page too.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.backspace, platform: 'linux');
    await tester.pump(const Duration(milliseconds: 30));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.backspace, platform: 'linux');
    final afterBackspace = await _waitFor<dynamic>(
      () => controller.evaluateJavascript(source: 'document.getElementById("inp").value'),
      (v) => v == 'hi',
    );
    expect(afterBackspace, 'hi');

    // --- Scrolling with the mouse wheel ---
    final testPointer = TestPointer(1, PointerDeviceKind.mouse);
    testPointer.hover(topLeft + const Offset(300, 300));
    await tester.sendEventToBinding(testPointer.scroll(const Offset(0, 300)));
    await tester.pump(const Duration(milliseconds: 100));
    final scrollY = await _waitFor<dynamic>(
      () => controller.evaluateJavascript(source: 'window.scrollY'),
      (v) => v is num && v > 0,
    );
    expect(scrollY, greaterThan(0));

    await gesture.removePointer();
    binding.reportData = <String, dynamic>{
      'imageSize': '${image.width}x${image.height}',
      'scrollY': scrollY,
    };
  });
}
