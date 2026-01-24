import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/utils/controller_methods_registry.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';

void main() {
  group('SupportChecker naming', () {
    test('helper class names use Type.toString()', () {
      expect(
        SupportChecker.classNameOf(InAppWebViewController),
        (InAppWebViewController).toString(),
      );
      expect(
        SupportChecker.classNameOf(HeadlessInAppWebView),
        (HeadlessInAppWebView).toString(),
      );
      expect(
        SupportChecker.classNameOf(InAppBrowser),
        (InAppBrowser).toString(),
      );
      expect(
        SupportChecker.eventClassNameOf(InAppWebView),
        '${(InAppWebView).toString()} Events',
      );
    });

    test('API definitions use (Type).toString() class names', () {
      final definitions = SupportChecker.getAllApiDefinitions();

      final controllerDefinition = definitions.firstWhere(
        (definition) =>
            definition.className == (InAppWebViewController).toString(),
      );
      expect(
        controllerDefinition.className,
        (InAppWebViewController).toString(),
      );
      expect(controllerDefinition.methods, isNotEmpty);
      expect(
        controllerDefinition.methods.every(
          (method) => method.className == controllerDefinition.className,
        ),
        isTrue,
      );

      final eventsDefinition = definitions.firstWhere(
        (definition) =>
            definition.className == '${(InAppWebView).toString()} Events',
      );
      expect(eventsDefinition.className, '${(InAppWebView).toString()} Events');
      expect(
        eventsDefinition.events.every(
          (event) => event.className == eventsDefinition.className,
        ),
        isTrue,
      );
    });
  });

  group('ControllerMethodsRegistry naming', () {
    test('method entries use enum .name for id and name', () {
      final registry = ControllerMethodsRegistry.instance;
      final methods = registry.allMethods;

      expect(methods, isNotEmpty);

      for (final entry in methods) {
        expect(entry.id, entry.methodEnum.name);
        expect(entry.name, entry.methodEnum.name);
        expect(entry.id.contains('.'), isFalse);
        expect(entry.name.contains('.'), isFalse);
      }
    });

    test('category ids use enum .name', () {
      final registry = ControllerMethodsRegistry.instance;
      for (final category in registry.categories) {
        expect(category.id, category.categoryType.name);
        expect(category.id.contains('.'), isFalse);
      }
    });
  });
}
