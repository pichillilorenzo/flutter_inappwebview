import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('exit reasons of newer WebView2 runtimes map to values', () {
    expect(
      ProcessFailedReason.fromNativeValue(7),
      same(ProcessFailedReason.NORMAL_EXIT),
    );
    expect(
      ProcessFailedReason.fromNativeValue(8),
      same(ProcessFailedReason.ABNORMAL_EXIT),
    );
    expect(
      ProcessFailedReason.fromNativeValue(9),
      same(ProcessFailedReason.INTEGRITY_FAILURE),
    );
  });

  test('a process failed detail keeps the new reason', () {
    final detail = ProcessFailedDetail.fromMap({'kind': 1, 'reason': 8})!;

    expect(detail.reason, same(ProcessFailedReason.ABNORMAL_EXIT));
    expect(detail.toMap()['reason'], 8);
  });
}
