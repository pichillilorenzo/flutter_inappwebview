import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:source_gen/source_gen.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:analyzer/dart/constant/value.dart';

import 'model_visitor.dart';
import 'util.dart';

const _annotationsPackage = 'flutter_inappwebview_internal_annotations';

final _coreCheckerEnumSupportedPlatforms = TypeChecker.typeNamedLiterally(
  'EnumSupportedPlatforms',
  inPackage: _annotationsPackage,
);
final _coreCheckerDeprecated = TypeChecker.typeNamedLiterally(
  'Deprecated',
  inSdk: true,
);
final _coreCheckerEnumCustomValue = TypeChecker.typeNamedLiterally(
  'ExchangeableEnumCustomValue',
  inPackage: _annotationsPackage,
);

class ExchangeableEnumGenerator
    extends GeneratorForAnnotation<ExchangeableEnum> {
  /// Returns the type string with nullable suffix if not already nullable
  String _makeNullable(DartType type) {
    final typeStr = type.toString();
    if (Util.typeIsNullable(type)) {
      return typeStr;
    }
    return '$typeStr?';
  }

  /// Returns the base type string without nullable suffix
  String _getBaseType(DartType type) {
    final typeStr = type.toString();
    if (typeStr.endsWith('?')) {
      return typeStr.substring(0, typeStr.length - 1);
    }
    return typeStr;
  }

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final visitor = ModelVisitor();
    // Visits all the children of element in no particular order.
    element.visitChildren(visitor);

    final className = visitor.constructor.returnType.element.name ?? '';
    // remove "_" to generate the correct class name
    final extClassName = className.replaceFirst("_", "");

    final classBuffer = StringBuffer();
    final classDocs =
        visitor.constructor.returnType.element.documentationComment;
    if (classDocs != null) {
      classBuffer.writeln(classDocs);
    }
    final classSupportedDocs = Util.getSupportedDocs(
      _coreCheckerEnumSupportedPlatforms,
      visitor.constructor.returnType.element,
    );
    if (classSupportedDocs != null) {
      classBuffer.writeln(classSupportedDocs);
    }
    if (visitor.constructor.returnType.element.metadata.hasDeprecated) {
      classBuffer.writeln(
        "@Deprecated('${_coreCheckerDeprecated.firstAnnotationOfExact(visitor.constructor.returnType.element)?.getField("message")?.toStringValue()}')",
      );
    }
    classBuffer.writeln('class $extClassName {');

    final fieldEntriesSorted = visitor.fields.entries.toList();
    fieldEntriesSorted.sort((a, b) => a.key.compareTo(b.key));

    final methodEntriesSorted = visitor.methods.entries.toList();
    fieldEntriesSorted.sort((a, b) => a.key.compareTo(b.key));

    final FieldElement enumValue = fieldEntriesSorted
        .firstWhere((element) => element.key == "_value")
        .value;
    final FieldElement enumNativeValue = fieldEntriesSorted
        .firstWhere(
          (element) => element.key == "_nativeValue",
          orElse: () => MapEntry("_nativeValue", enumValue),
        )
        .value;

    final nativeValueNullableType = _makeNullable(enumNativeValue.type);

    classBuffer.writeln("final ${enumValue.type} _value;");
    classBuffer.writeln("final $nativeValueNullableType _nativeValue;");

    classBuffer.writeln(
      "const $extClassName._internal(this._value, this._nativeValue);",
    );
    classBuffer.writeln("// ignore: unused_element");
    classBuffer.writeln(
      "factory $extClassName._internalMultiPlatform(${enumValue.type} value, Function nativeValue) => $extClassName._internal(value, nativeValue());",
    );

    for (final entry in fieldEntriesSorted) {
      final fieldName = entry.key;
      final fieldElement = entry.value;
      if (fieldName == "_value" || fieldName == "_nativeValue") {
        continue;
      }
      final isEnumCustomValue =
          _coreCheckerEnumCustomValue.firstAnnotationOf(fieldElement) != null;
      if (isEnumCustomValue) {
        final fieldLibrary = fieldElement.library;
        if (fieldLibrary != null) {
          ParsedLibraryResult parsed =
              fieldLibrary.session.getParsedLibraryByElement(fieldLibrary)
                  as ParsedLibraryResult;
          final fieldBody = parsed
              .getFragmentDeclaration(fieldElement.firstFragment)
              ?.node
              .toString()
              .replaceAll(className, extClassName);
          if (fieldBody != null) {
            final docs = fieldElement.documentationComment;
            if (docs != null) {
              classBuffer.writeln(docs);
            }
            if (fieldElement.isStatic) {
              classBuffer.write("static ");
            }
            if (fieldElement.isLate) {
              classBuffer.write("late ");
            }
            if (fieldElement.isFinal) {
              classBuffer.write("final ");
            }
            if (fieldElement.isConst) {
              classBuffer.write("const ");
            }
            classBuffer.writeln("$fieldBody;");
          }
        }
        continue;
      }
      final docs = fieldElement.documentationComment;
      if (docs != null) {
        classBuffer.writeln(docs);
      }
      final fieldSupportedDocs = Util.getSupportedDocs(
        _coreCheckerEnumSupportedPlatforms,
        fieldElement,
      );
      if (fieldSupportedDocs != null) {
        classBuffer.writeln(fieldSupportedDocs);
      }
      if (fieldName == '_value' || fieldName == '_nativeValue') {
        classBuffer.writeln(
          "final ${fieldElement.type.toString().replaceFirst("_", "")} $fieldName;",
        );
      } else {
        final fieldValue = fieldElement.computeConstantValue()?.getField(
          "_value",
        );
        final constantValue = fieldValue != null && !fieldValue.isNull
            ? fieldValue.toIntValue() ?? "\'${fieldValue.toStringValue()}\'"
            : null;

        final fieldAnnotation = _coreCheckerEnumSupportedPlatforms
            .firstAnnotationOfExact(fieldElement);
        if (fieldAnnotation != null) {
          final defaultField = fieldAnnotation.getField('defaultValue')!;
          final defaultValue = !defaultField.isNull
              ? defaultField.toIntValue() ?? "'${defaultField.toStringValue()}'"
              : null;

          var nativeValueBody = "() {";
          nativeValueBody += "switch (defaultTargetPlatform) {";
          final platforms =
              fieldAnnotation.getField('platforms')?.toListValue() ??
              <DartObject>[];
          var hasWebSupport = false;
          var webSupportValue = null;
          if (platforms.isNotEmpty) {
            for (var platform in platforms) {
              final targetPlatformName = platform
                  .getField("targetPlatformName")!
                  .toStringValue();
              final platformValueField = platform.getField('value');
              final platformValue =
                  platformValueField != null && !platformValueField.isNull
                  ? platformValueField.toIntValue() ??
                        "'${platformValueField.toStringValue()}'"
                  : constantValue;
              if (targetPlatformName == "web") {
                hasWebSupport = true;
                webSupportValue = platformValue;
                continue;
              }
              nativeValueBody += "case TargetPlatform.$targetPlatformName:";
              nativeValueBody += "return $platformValue;";
            }
            nativeValueBody += "default:";
            nativeValueBody += "break;";
          }
          nativeValueBody += "}";
          if (hasWebSupport) {
            nativeValueBody += "if (kIsWeb) {";
            nativeValueBody += "return $webSupportValue;";
            nativeValueBody += "}";
          }
          nativeValueBody += "return $defaultValue;";
          nativeValueBody += "}";

          classBuffer.writeln(
            "static final $fieldName = $extClassName._internalMultiPlatform($constantValue, $nativeValueBody);",
          );
        } else {
          classBuffer.writeln(
            "static const $fieldName = $extClassName._internal($constantValue, $constantValue);",
          );
        }
      }
    }

    if (annotation.read("valuesProperty").boolValue) {
      classBuffer.writeln('///Set of all values of [$extClassName].');
      classBuffer.writeln('static final Set<$extClassName> values = [');
      for (final entry in fieldEntriesSorted) {
        final fieldName = entry.key;
        final fieldElement = entry.value;
        final isEnumCustomValue =
            _coreCheckerEnumCustomValue.firstAnnotationOf(fieldElement) != null;
        if (!fieldElement.isPrivate &&
            fieldElement.isStatic &&
            !isEnumCustomValue) {
          classBuffer.writeln('$extClassName.$fieldName,');
        }
      }
      classBuffer.writeln('].toSet();');
    }

    if (annotation.read("fromValueMethod").boolValue &&
        (!visitor.methods.containsKey("fromValue") ||
            Util.methodHasIgnore(visitor.methods['fromValue']!))) {
      final hasBitwiseOrOperator = annotation
          .read("bitwiseOrOperator")
          .boolValue;
      classBuffer.writeln("""
      ///Gets a possible [$extClassName] instance from [${enumValue.type}] value.
      static $extClassName? fromValue(${enumValue.type}${!Util.typeIsNullable(enumValue.type) ? '?' : ''} value) {
        if (value != null) {
          try {
            return $extClassName.values
                .firstWhere((element) => element.toValue() == value);
          } catch (e) {
            return ${!hasBitwiseOrOperator ? 'null' : "$extClassName._internal(value, value)"};
          }
        }
        return null;
      }
      """);
    }

    if (annotation.read("fromNativeValueMethod").boolValue &&
        (!visitor.methods.containsKey("fromNativeValue") ||
            Util.methodHasIgnore(visitor.methods['fromNativeValue']!))) {
      classBuffer.writeln("""
      ///Gets a possible [$extClassName] instance from a native value.
      static $extClassName? fromNativeValue($nativeValueNullableType value) {
        if (value != null) {
          try {
            return $extClassName.values
                .firstWhere((element) => element.toNativeValue() == value);
          } catch (e) {
            return null;
          }
        }
        return null;
      }
      """);
    }

    if (annotation.read("nameMethod").boolValue &&
        annotation.read("byNameMethod").boolValue &&
        (!visitor.methods.containsKey("byName") ||
            Util.methodHasIgnore(visitor.methods['byName']!))) {
      classBuffer.writeln("""
      /// Gets a possible [$extClassName] instance value with name [name].
      ///
      /// Goes through [$extClassName.values] looking for a value with
      /// name [name], as reported by [$extClassName.name].
      /// Returns the first value with the given name, otherwise `null`.
      static $extClassName? byName(String? name) {
        if (name != null) {
          try {
            return $extClassName.values
                .firstWhere((element) => element.name() == name);
          } catch (e) {
            return null;
          }
        }
        return null;
      }
      """);
    }

    if (annotation.read("nameMethod").boolValue &&
        annotation.read("asNameMapMethod").boolValue &&
        (!visitor.methods.containsKey("asNameMap") ||
            Util.methodHasIgnore(visitor.methods['asNameMap']!))) {
      classBuffer.writeln("""
      /// Creates a map from the names of [$extClassName] values to the values.
      ///
      /// The collection that this method is called on is expected to have
      /// values with distinct names, like the `values` list of an enum class.
      /// Only one value for each name can occur in the created map,
      /// so if two or more values have the same name (either being the
      /// same value, or being values of different enum type), at most one of
      /// them will be represented in the returned map.
      static Map<String, $extClassName> asNameMap() =>
          <String, $extClassName>{for (final value in $extClassName.values) value.name(): value};
      """);
    }

    for (final entry in methodEntriesSorted) {
      final methodElement = entry.value;
      if (Util.methodHasIgnore(methodElement)) {
        continue;
      }
      final methodLibrary = methodElement.library;
      if (methodLibrary == null) continue;
      ParsedLibraryResult parsed =
          methodLibrary.session.getParsedLibraryByElement(methodLibrary)
              as ParsedLibraryResult;
      final methodBodyRaw = parsed
          .getFragmentDeclaration(methodElement.firstFragment)
          ?.node
          .toString();
      if (methodBodyRaw != null) {
        // Replace type names: first className, then type references ending with _
        var methodBody = methodBodyRaw
            .replaceAll(className, extClassName)
            .replaceAll("_.", ".")
            .replaceAll("_?", "?")
            .replaceAll("_>", ">")
            .replaceAllMapped(
              RegExp(r'([A-Z][a-zA-Z0-9]*)_\b'),
              (match) => match.group(1)!,
            );

        final docs = methodElement.documentationComment;
        if (docs != null) {
          classBuffer.writeln(docs);
        }
        final fieldSupportedDocs = Util.getSupportedDocs(
          _coreCheckerEnumSupportedPlatforms,
          methodElement,
        );
        if (fieldSupportedDocs != null) {
          classBuffer.writeln(fieldSupportedDocs);
        }
        classBuffer.writeln(methodBody);
      }
    }

    if (annotation.read("toValueMethod").boolValue &&
        (!visitor.methods.containsKey("toValue") ||
            Util.methodHasIgnore(visitor.methods['toValue']!))) {
      classBuffer.writeln("""
      ///Gets [${enumValue.type}] value.
      ${enumValue.type} toValue() => _value;
      """);
    }

    if (annotation.read("toNativeValueMethod").boolValue &&
        (!visitor.methods.containsKey("toNativeValue") ||
            Util.methodHasIgnore(visitor.methods['toNativeValue']!))) {
      final nativeValueBaseType = _getBaseType(enumNativeValue.type);
      classBuffer.writeln("""
      ///Gets [$nativeValueBaseType] native value if supported by the current platform, otherwise `null`.
      $nativeValueNullableType toNativeValue() => _nativeValue;
      """);
    }

    if (annotation.read("nameMethod").boolValue &&
        (!visitor.methods.containsKey("name") ||
            Util.methodHasIgnore(visitor.methods['name']!))) {
      classBuffer.writeln('///Gets the name of the value.');
      classBuffer.writeln('String name() {');
      classBuffer.writeln('switch(_value) {');

      // Track unique case values to avoid duplicates
      final Set<String> addedCases = {};

      for (final entry in fieldEntriesSorted) {
        final fieldName = entry.key;
        final fieldElement = entry.value;

        // Skip custom values using ExchangeableEnumCustomValue
        final isEnumCustomValue =
            _coreCheckerEnumCustomValue.firstAnnotationOf(fieldElement) != null;
        if (isEnumCustomValue) {
          continue;
        }

        if (!fieldElement.isPrivate && fieldElement.isStatic) {
          final fieldValue = fieldElement.computeConstantValue()?.getField(
            "_value",
          );
          dynamic constantValue = fieldValue?.toIntValue();
          String caseValueStr;

          if (enumValue.type.isDartCoreString) {
            final stringValue = fieldValue?.toStringValue();
            if (stringValue == null) {
              // For nullable String types with null value
              constantValue = 'null';
              caseValueStr = 'null';
            } else {
              constantValue = "'$stringValue'";
              caseValueStr = stringValue;
            }
          } else {
            caseValueStr = constantValue.toString();
          }

          // Only add unique case values
          if (!addedCases.contains(caseValueStr)) {
            addedCases.add(caseValueStr);
            classBuffer.writeln("case $constantValue: return '$fieldName';");
          }
        }
      }
      classBuffer.writeln('}');
      classBuffer.writeln('return _value.toString();');
      classBuffer.writeln('}');
    }

    if (annotation.read("hashCodeMethod").boolValue &&
        (!visitor.fields.containsKey("hashCode") ||
            Util.methodHasIgnore(visitor.methods['hashCode']!))) {
      classBuffer.writeln("""
      @override
      int get hashCode => _value.hashCode;
      """);
    }

    if (annotation.read("equalsOperator").boolValue) {
      classBuffer.writeln("""
      @override
      bool operator ==(value) => value == _value;
      """);
    }

    if (annotation.read("bitwiseOrOperator").boolValue) {
      classBuffer.writeln(
        "$extClassName operator |($extClassName value) => $extClassName._internal(value.toValue() | _value, ",
      );
      classBuffer.write(
        "value.toNativeValue() != null && _nativeValue != null ? value.toNativeValue()! | _nativeValue! : null",
      );
      classBuffer.write(");");
    }

    classBuffer.writeln(
      '///Checks if the value is supported by the [defaultTargetPlatform].',
    );
    classBuffer.writeln('bool isSupported() {');
    classBuffer.writeln('return _nativeValue != null;');
    classBuffer.writeln('}');

    if (annotation.read("toStringMethod").boolValue &&
        (!visitor.methods.containsKey("toString") ||
            Util.methodHasIgnore(visitor.methods['toString']!))) {
      classBuffer.writeln('@override');
      classBuffer.writeln('String toString() {');
      if (enumValue.type.isDartCoreString) {
        classBuffer.writeln('return _value;');
      } else {
        if (annotation.read("nameMethod").boolValue) {
          classBuffer.writeln('return name();');
        } else {
          classBuffer.writeln('switch(_value) {');
          for (final entry in fieldEntriesSorted) {
            final fieldName = entry.key;
            final fieldElement = entry.value;
            if (!fieldElement.isPrivate && fieldElement.isStatic) {
              final fieldValue = fieldElement.computeConstantValue()?.getField(
                "_value",
              );
              final constantValue = fieldValue?.toIntValue();
              classBuffer.writeln("case $constantValue: return '$fieldName';");
            }
          }
          classBuffer.writeln('}');
          classBuffer.writeln('return _value.toString();');
        }
      }
      classBuffer.writeln('}');
    }

    classBuffer.writeln('}');
    return classBuffer.toString();
  }
}
