import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'console allowlist preserves null, empty, and explicit enum identities',
    () {
      expect(InAppWebViewSettings().toMap()['consoleMessageLevels'], isNull);
      expect(
        InAppWebViewSettings.fromMap({
          'consoleMessageLevels': null,
        })!.consoleMessageLevels,
        isNull,
      );
      expect(
        InAppWebViewSettings(
          consoleMessageLevels: [],
        ).toMap()['consoleMessageLevels'],
        isEmpty,
      );
      final settings = InAppWebViewSettings(
        consoleMessageLevels: [
          ConsoleMessageLevel.WARNING,
          ConsoleMessageLevel.ERROR,
        ],
      );
      expect(settings.toMap()['consoleMessageLevels'], [2, 3]);
      expect(
        InAppWebViewSettings.fromMap(settings.toMap())!.consoleMessageLevels,
        [ConsoleMessageLevel.WARNING, ConsoleMessageLevel.ERROR],
      );
      // DEBUG is numerically greater than ERROR, but an allowlist is not a threshold.
      expect(ConsoleMessageLevel.DEBUG.toNativeValue(), 4);
      expect(
        settings.consoleMessageLevels,
        isNot(contains(ConsoleMessageLevel.DEBUG)),
      );
      final diagnostic = InAppWebViewSettings.fromMap({
        'consoleMessageLevels': [0, 1, 2, 3, 4],
      })!;
      expect(
        diagnostic.consoleMessageLevels,
        containsAll(ConsoleMessageLevel.values),
      );
    },
  );
}
