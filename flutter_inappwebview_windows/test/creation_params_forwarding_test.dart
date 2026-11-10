import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/headless_in_app_webview.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/in_app_webview.dart';
import 'package:flutter_test/flutter_test.dart';

void _onProcessFailed(dynamic controller, ProcessFailedDetail detail) {}

void _onAcceleratorKeyPressed(
  dynamic controller,
  AcceleratorKeyPressedDetail detail,
) {}

Future<ShowFileChooserResponse?> _onShowFileChooser(
  dynamic controller,
  ShowFileChooserRequest request,
) async => null;

void main() {
  test('the widget keeps Windows process and key callbacks', () {
    final params =
        WindowsInAppWebViewWidgetCreationParams.fromPlatformInAppWebViewWidgetCreationParams(
          PlatformInAppWebViewWidgetCreationParams(
            onProcessFailed: _onProcessFailed,
            onAcceleratorKeyPressed: _onAcceleratorKeyPressed,
            onShowFileChooser: _onShowFileChooser,
          ),
        );

    expect(params.onProcessFailed, same(_onProcessFailed));
    expect(params.onAcceleratorKeyPressed, same(_onAcceleratorKeyPressed));
    expect(params.onShowFileChooser, same(_onShowFileChooser));
  });

  test('the headless WebView keeps Windows process and key callbacks', () {
    final params =
        WindowsHeadlessInAppWebViewCreationParams.fromPlatformHeadlessInAppWebViewCreationParams(
          PlatformHeadlessInAppWebViewCreationParams(
            onProcessFailed: _onProcessFailed,
            onAcceleratorKeyPressed: _onAcceleratorKeyPressed,
            onShowFileChooser: _onShowFileChooser,
          ),
        );

    expect(params.onProcessFailed, same(_onProcessFailed));
    expect(params.onAcceleratorKeyPressed, same(_onAcceleratorKeyPressed));
    expect(params.onShowFileChooser, same(_onShowFileChooser));
  });
}
