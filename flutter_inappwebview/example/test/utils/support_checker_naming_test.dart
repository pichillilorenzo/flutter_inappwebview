import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/utils/controller_methods_registry.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';

void main() {
  group('SupportChecker naming helpers', () {
    test('classNameOf uses Type.toString()', () {
      expect(
        SupportChecker.classNameOf(InAppWebViewController),
        InAppWebViewController.toString(),
      );
      expect(
        SupportChecker.classNameOf(HeadlessInAppWebView),
        HeadlessInAppWebView.toString(),
      );
      expect(
        SupportChecker.classNameOf(InAppBrowser),
        InAppBrowser.toString(),
      );
    });

    test('eventClassNameOf uses Type.toString() with Events suffix', () {
      expect(
        SupportChecker.eventClassNameOf(InAppWebView),
        '${InAppWebView.toString()} Events',
      );
    });

    test('registered class names use Type.toString()', () {
      final classNames = SupportChecker.registeredClassNames;

      expect(
        classNames,
        contains(SupportChecker.classNameOf(InAppWebViewController)),
      );
      expect(
        classNames,
        contains(SupportChecker.classNameOf(HeadlessInAppWebView)),
      );
      expect(classNames, contains(SupportChecker.classNameOf(InAppBrowser)));
      expect(
        classNames,
        contains(SupportChecker.eventClassNameOf(InAppWebView)),
      );
    });

    test('API definitions use Type.toString() class names', () {
      final definitions = SupportChecker.getAllApiDefinitions();

      final controllerDefinition = definitions.firstWhere(
        (definition) =>
            definition.className ==
            SupportChecker.classNameOf(InAppWebViewController),
      );
      expect(
        controllerDefinition.className,
        InAppWebViewController.toString(),
      );
      expect(
        controllerDefinition.methods,
        isNotEmpty,
      );
      expect(
        controllerDefinition.methods.every(
          (method) => method.className == controllerDefinition.className,
        ),
        isTrue,
      );

      final eventsDefinition = definitions.firstWhere(
        (definition) =>
            definition.className ==
            SupportChecker.eventClassNameOf(InAppWebView),
      );
      expect(
        eventsDefinition.className,
        '${InAppWebView.toString()} Events',
      );
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
