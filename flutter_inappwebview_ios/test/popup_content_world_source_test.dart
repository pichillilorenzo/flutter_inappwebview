import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readNativeSource(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

String _section(String source, String start, String end) {
  final startIndex = source.indexOf(start);
  final endIndex = source.indexOf(end, startIndex + start.length);
  expect(startIndex, isNonNegative, reason: 'Missing section start: $start');
  expect(
    endIndex,
    greaterThan(startIndex),
    reason: 'Missing section end: $end',
  );
  return source.substring(startIndex, endIndex);
}

void main() {
  final source = _readNativeSource(
    'ios/flutter_inappwebview_ios/Sources/flutter_inappwebview_ios/'
    'InAppWebView/InAppWebView.swift',
  );

  test('direct named-world injection fails before bootstrap', () {
    final section = _section(
      source,
      'public func injectDeferredObject(source: String, contentWorld:',
      '#if compiler(>=6.0)',
    );

    expect(section, contains('contentWorld != WKContentWorld.page'));
    expect(
      section.indexOf('completionHandler?(nil)'),
      lessThan(
        section.indexOf(
          'generateCodeForScriptEvaluation(scriptMessageHandler: self',
        ),
      ),
    );
  });

  test('old popup named-world evaluation fails closed', () {
    final section = _section(
      source,
      'public func evaluateJavascript(source: String, contentWorld:',
      'public func callAsyncJavaScript(_ functionBody:',
    );

    expect(section, contains('guard contentWorld == WKContentWorld.page else'));
    expect(section, contains('completionHandler?(nil)'));
    expect(
      section.indexOf('completionHandler?(nil)'),
      lessThan(
        section.indexOf(
          'injectDeferredObject(source: source, withWrapper: nil',
        ),
      ),
    );
  });

  test('low-level old popup evaluation only falls back for top-level page', () {
    final section = _section(
      source,
      'public func evaluateJavaScript(_ javaScript: String, frame:',
      'public func evaluateJavascript(source: String, completionHandler:',
    );

    expect(
      section,
      contains('contentWorld == WKContentWorld.page, frame == nil'),
    );
    expect(
      section,
      contains(
        'completionHandler?(.failure(popupContentWorldUnavailableError()))',
      ),
    );
  });

  test('old popup async evaluation fails before content-world bootstrap', () {
    final section = _section(
      source,
      'public func callAsyncJavaScript(functionBody: String, arguments:',
      'private func popupContentWorldUnavailableError()',
    );

    expect(section, contains('if #unavailable(iOS 18.0), windowId != nil'));
    expect(
      section.indexOf('completionHandler?(['),
      lessThan(
        section.indexOf(
          'generateCodeForScriptEvaluation(scriptMessageHandler: self',
        ),
      ),
    );
  });
}
