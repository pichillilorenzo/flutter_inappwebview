import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'model_visitor.dart';
import 'util.dart';

const _annotationsPackage = 'flutter_inappwebview_internal_annotations';

final _coreCheckerDeprecated = TypeChecker.typeNamedLiterally('Deprecated', inSdk: true);
final _coreCheckerSupportedPlatforms =
    TypeChecker.typeNamedLiterally('SupportedPlatforms', inPackage: _annotationsPackage);

class SupportedPlatformsGenerator
    extends GeneratorForAnnotation<SupportedPlatforms> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {

    final visitor = ModelVisitor();
    // Visits all the children of element in no particular order.
    element.visitChildren(visitor);

    final classAnnotation = _coreCheckerSupportedPlatforms.firstAnnotationOf(visitor.constructor.returnType.element)!;
    final ignoreClass = classAnnotation.getField('ignore')?.toBoolValue() ?? false;
    if (ignoreClass) {
      return '';
    }
    final ignorePropertyNames = (classAnnotation.getField('ignorePropertyNames')?.toListValue()?.map((e) => RegExp(e.toStringValue()!)) ?? []).toList();
    final ignoreMethodNames = (classAnnotation.getField('ignoreMethodNames')?.toListValue()?.map((e) => RegExp(e.toStringValue()!)) ?? []).toList();
    final ignoreParameterNames = (classAnnotation.getField('ignoreParameterNames')?.toListValue()?.map((e) => RegExp(e.toStringValue()!)) ?? []).toList();

    final fields = visitor.fields.entries.where((e) => !ignorePropertyNames.any((r) => r.hasMatch(e.key))).toList();
    final methods = visitor.methods.entries.where((e) => !ignoreMethodNames.any((r) => r.hasMatch(e.key))).toList();

    final isClassSupportedFunctionName = 'isClassSupported';
    final isPropertySupportedFunctionName = 'isPropertySupported';
    final isMethodSupportedFunctionName = 'isMethodSupported';

    final hasClassSupportedFunction = methods
            .firstWhereOrNull((m) => m.key == isClassSupportedFunctionName) !=
        null;
    final hasPropertySupportedFunction = methods.firstWhereOrNull(
            (m) => m.key == isPropertySupportedFunctionName) !=
        null;
    final hasMethodSupportedFunction = methods
            .firstWhereOrNull((m) => m.key == isMethodSupportedFunctionName) !=
        null;

    if (!hasClassSupportedFunction &&
        !hasPropertySupportedFunction &&
        !hasMethodSupportedFunction) {
      return '';
    }

    final fieldEntriesSorted = fields.where((e) {
      var hasAnnotation =
          _coreCheckerSupportedPlatforms.firstAnnotationOf(e.value) != null;
      if (!hasAnnotation && e.value.getter != null) {
        hasAnnotation = _coreCheckerSupportedPlatforms
                .firstAnnotationOf(e.value.getter!) != null;
      }
      return hasAnnotation;
    }).toList();
    fieldEntriesSorted.sort((a, b) => a.key.compareTo(b.key));

    final methodEntriesSorted = methods.where((e) {
      return _coreCheckerSupportedPlatforms.firstAnnotationOf(e.value) != null;
    }).toList();
    methodEntriesSorted.sort((a, b) => a.key.compareTo(b.key));

    if (!hasClassSupportedFunction && fieldEntriesSorted.isEmpty && methodEntriesSorted.isEmpty) {
      return '';
    }

    final classBuffer = StringBuffer();

    final packageName = element.library?.uri.pathSegments.first ?? 'unknown';
    var className = visitor.constructor.returnType.element.name ?? '';
    if (className.endsWith('_')) {
      className = className.substring(0, className.length - 1);
    }

    if (hasClassSupportedFunction) {
      classBuffer.writeln("""
      extension _${className}ClassSupported on $className {""");

      final classSupportedDocs =
      Util.getSupportedDocs(_coreCheckerSupportedPlatforms, visitor.constructor.returnType.element);
      if (classSupportedDocs != null) {
        classBuffer.writeln(
            '///{@template $packageName.$className.supported_platforms}');
        classBuffer.writeln(classSupportedDocs);
        classBuffer.writeln('///');
        classBuffer.writeln('///Use the [$className.$isClassSupportedFunctionName] method to check if this class is supported at runtime.');
        classBuffer.writeln('///{@endtemplate}');
      }
      if (visitor.constructor.returnType.element.metadata.hasDeprecated) {
        classBuffer.writeln(
            "@Deprecated('${_coreCheckerDeprecated.firstAnnotationOfExact(visitor.constructor.returnType.element)?.getField("message")?.toStringValue()}')");
      }

      classBuffer.writeln("""static bool $isClassSupportedFunctionName({TargetPlatform? platform}) {""");
      final classAnnotation = _coreCheckerSupportedPlatforms
          .firstAnnotationOfExact(visitor.constructor.returnType.element);

      final platforms =
          classAnnotation!.getField('platforms')?.toListValue() ?? [];
      if (platforms.isEmpty) {
        classBuffer.writeln("return false;");
      } else {
        final targetPlatforms = platforms
            .map((e) => e.getField("targetPlatformName")!.toStringValue())
            .toList();
        final hasWebSupport = targetPlatforms.contains("web");

        classBuffer.writeln("return ");
        if (hasWebSupport) {
          classBuffer.writeln("kIsWeb && platform == null ? true :");
        }
        classBuffer.writeln(
            "((kIsWeb && platform != null) || !kIsWeb) && [${targetPlatforms.where((e) => e != 'web').map((e) => "TargetPlatform.$e").join(', ')}].contains(platform ?? defaultTargetPlatform)");
        classBuffer.writeln(";");
      }
      classBuffer.writeln("""
        }
      }
      """);
    }

    if (hasPropertySupportedFunction && !fieldEntriesSorted.isEmpty) {
      final enumClassName = '${className}Property';

      classBuffer.writeln(
          "///List of [${className}]'s properties that can be used to check i they are supported or not by the current platform.");
      classBuffer.writeln("enum ${enumClassName} {");
      for (final entry in fieldEntriesSorted) {
        final fieldName = entry.key;
        final field = entry.value;

        classBuffer.writeln('///Can be used to check if the [$className.$fieldName] property is supported at runtime.');
        classBuffer.writeln('///');
        var fieldSupportedDocs =
            Util.getSupportedDocs(_coreCheckerSupportedPlatforms, field);
        String? parameterSupportedDocs = null;
        if (field.type is FunctionType) {
          final fieldFunction = field.type as FunctionType;
          final List<RegExp> customIgnoreParameterNames = _coreCheckerSupportedPlatforms
              .firstAnnotationOfExact(field)
              ?.getField('ignoreParameterNames')
              ?.toListValue()?.map((e) => RegExp(e.toStringValue()!)).toList() ?? [];
          final Map<String, List<DartObject>>? parameterPlatforms = _coreCheckerSupportedPlatforms
              .firstAnnotationOfExact(field)
              ?.getField('parameterPlatforms')
              ?.toMapValue()?.map((key, value) => MapEntry(key!.toStringValue()!, value!.toListValue()!));
          final parameters = fieldFunction.formalParameters.where((e) => ![...ignoreParameterNames, ...customIgnoreParameterNames].any((r) => r.hasMatch(e.name ?? ''))).toList();
          parameterSupportedDocs = Util.getParameterSupportedDocs(
              _coreCheckerSupportedPlatforms, parameters, parameterPlatforms);
        }
        if (fieldSupportedDocs == null && field.getter != null) {
          fieldSupportedDocs = Util.getSupportedDocs(
              _coreCheckerSupportedPlatforms, field.getter!);
        }
        if (fieldSupportedDocs != null || parameterSupportedDocs != null) {
          classBuffer.writeln(
              '///{@template $packageName.$className.$fieldName.supported_platforms}');
          if (fieldSupportedDocs != null) {
            classBuffer.writeln(fieldSupportedDocs);
          }
          if (parameterSupportedDocs != null) {
            if (fieldSupportedDocs != null) {
              classBuffer.writeln('///');
            }
            classBuffer.writeln(parameterSupportedDocs);
          }
          classBuffer.writeln('///');
          classBuffer.writeln('///Use the [$className.$isPropertySupportedFunctionName] method to check if this property is supported at runtime.');
          classBuffer.writeln('///{@endtemplate}');
        }
        if (field.metadata.hasDeprecated || field.getter?.metadata.hasDeprecated == true) {
          classBuffer.writeln(
              "@Deprecated('${_coreCheckerDeprecated.firstAnnotationOfExact(field.metadata.hasDeprecated ? field : field.getter!)?.getField("message")?.toStringValue()}')");
        }
        classBuffer.writeln("$fieldName,");
      }
      classBuffer.writeln("}");

      classBuffer.writeln("""
      extension _${className}PropertySupported on $className {
        static bool $isPropertySupportedFunctionName($enumClassName property, {TargetPlatform? platform}) {
          switch (property) {""");
      for (final entry in fieldEntriesSorted) {
        final fieldName = entry.key;
        final field = entry.value;
        var fieldAnnotation =
            _coreCheckerSupportedPlatforms.firstAnnotationOfExact(field);
        if (fieldAnnotation == null && field.getter != null) {
          fieldAnnotation = _coreCheckerSupportedPlatforms
              .firstAnnotationOfExact(field.getter!);
        }

        final platforms =
            fieldAnnotation!.getField('platforms')?.toListValue() ?? [];
        if (platforms.isEmpty) {
          continue;
        }

        final targetPlatforms = platforms
            .map((e) => e.getField("targetPlatformName")!.toStringValue())
            .toList();
        final hasWebSupport = targetPlatforms.contains("web");

        classBuffer.writeln("case $enumClassName.$fieldName:");
        classBuffer.writeln("return ");
        if (hasWebSupport) {
          classBuffer.writeln("kIsWeb && platform == null ? true :");
        }
        classBuffer.writeln(
            "((kIsWeb && platform != null) || !kIsWeb) && [${targetPlatforms.where((e) => e != 'web').map((e) => "TargetPlatform.$e").join(', ')}].contains(platform ?? defaultTargetPlatform)");
        classBuffer.writeln(";");
      }
      classBuffer.writeln("""
          }
        }
      }
      """);
    }

    if (hasMethodSupportedFunction && !methodEntriesSorted.isEmpty) {
      final enumClassName = '${className}Method';

      classBuffer.writeln(
          "///List of [${className}]'s methods that can be used to check if they are supported or not by the current platform.");
      classBuffer.writeln("enum ${enumClassName} {");
      for (final entry in methodEntriesSorted) {
        final methodName = entry.key;
        final method = entry.value;

        classBuffer.writeln('///Can be used to check if the [$className.$methodName] method is supported at runtime.');
        classBuffer.writeln('///');
        final methodSupportedDocs =
            Util.getSupportedDocs(_coreCheckerSupportedPlatforms, method);
        final List<RegExp> customIgnoreParameterNames = _coreCheckerSupportedPlatforms
            .firstAnnotationOfExact(method)
            ?.getField('ignoreParameterNames')
            ?.toListValue()?.map((e) => RegExp(e.toStringValue()!)).toList() ?? [];
        final parameters = method.formalParameters.where((e) => ![...ignoreParameterNames, ...customIgnoreParameterNames].any((r) => r.hasMatch(e.name ?? ''))).toList();
        final parameterSupportedDocs = Util.getParameterSupportedDocs(
            _coreCheckerSupportedPlatforms, parameters);
        if (methodSupportedDocs != null || parameterSupportedDocs != null) {
          classBuffer.writeln(
              '///{@template $packageName.$className.$methodName.supported_platforms}');
          if (methodSupportedDocs != null) {
            classBuffer.writeln(methodSupportedDocs);
          }
          if (parameterSupportedDocs != null) {
            if (methodSupportedDocs != null) {
              classBuffer.writeln('///');
            }
            classBuffer.writeln(parameterSupportedDocs);
          }
          classBuffer.writeln('///');
          classBuffer.writeln('///Use the [$className.$isMethodSupportedFunctionName] method to check if this method is supported at runtime.');
          classBuffer.writeln('///{@endtemplate}');
        }
        if (method.metadata.hasDeprecated) {
          classBuffer.writeln(
              "@Deprecated('${_coreCheckerDeprecated.firstAnnotationOfExact(method)?.getField("message")?.toStringValue()}')");
        }
        classBuffer.writeln("$methodName,");
      }
      classBuffer.writeln("}");

      classBuffer.writeln("""
      extension _${className}MethodSupported on $className {
        static bool $isMethodSupportedFunctionName($enumClassName method, {TargetPlatform? platform}) {
          switch (method) {""");
      for (final entry in methodEntriesSorted) {
        final methodName = entry.key;
        final method = entry.value;
        final methodAnnotation =
            _coreCheckerSupportedPlatforms.firstAnnotationOfExact(method);

        final platforms =
            methodAnnotation!.getField('platforms')?.toListValue() ?? [];
        if (platforms.isEmpty) {
          continue;
        }

        final targetPlatforms = platforms
            .map((e) => e.getField("targetPlatformName")!.toStringValue())
            .toList();
        final hasWebSupport = targetPlatforms.contains("web");

        classBuffer.writeln("case $enumClassName.$methodName:");
        classBuffer.writeln("return ");
        if (hasWebSupport) {
          classBuffer.writeln("kIsWeb && platform == null ? true :");
        }
        classBuffer.writeln(
            "((kIsWeb && platform != null) || !kIsWeb) && [${targetPlatforms.where((e) => e != 'web').map((e) => "TargetPlatform.$e").join(', ')}].contains(platform ?? defaultTargetPlatform)");
        classBuffer.writeln(";");
      }
      classBuffer.writeln("""
          }
        }
      }
      """);
    }

    return classBuffer.toString();
  }
}
