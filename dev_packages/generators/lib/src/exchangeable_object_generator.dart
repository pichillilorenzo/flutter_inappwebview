import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:collection/collection.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:source_gen/source_gen.dart';

import 'model_visitor.dart';
import 'util.dart';

final _coreChecker = const TypeChecker.fromRuntime(ExchangeableObject);
final _coreCheckerObjectConstructor =
    const TypeChecker.fromRuntime(ExchangeableObjectConstructor);
final _coreCheckerObjectProperty =
    const TypeChecker.fromRuntime(ExchangeableObjectProperty);
final _coreCheckerObjectMethod =
    const TypeChecker.fromRuntime(ExchangeableObjectMethod);
final _coreCheckerEnum = const TypeChecker.fromRuntime(ExchangeableEnum);
final _coreCheckerDeprecated = const TypeChecker.fromRuntime(Deprecated);
final _coreCheckerSupportedPlatforms =
    const TypeChecker.fromRuntime(SupportedPlatforms);

class ExchangeableObjectGenerator
    extends GeneratorForAnnotation<ExchangeableObject> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final visitor = ModelVisitor();
    // Visits all the children of element in no particular order.
    element.visitChildren(visitor);

    final className = visitor.constructor.returnType.element.name;
    final superClass =
        visitor.constructor.returnType.superclass?.element.name != 'Object'
            ? visitor.constructor.returnType.superclass
            : null;
    final interfaces = visitor.constructor.returnType.interfaces;
    final superClassName = superClass?.element.name.replaceFirst("_", "");
    // remove "_" to generate the correct class name
    final extClassName = className.replaceFirst("_", "");

    final classBuffer = StringBuffer();
    final classDocs =
        visitor.constructor.returnType.element.documentationComment;
    if (classDocs != null) {
      classBuffer.writeln(classDocs);
    }
    final classSupportedDocs = Util.getSupportedDocs(
        _coreCheckerSupportedPlatforms, visitor.constructor.returnType.element);
    if (classSupportedDocs != null) {
      classBuffer.writeln(classSupportedDocs);
    }
    if (visitor.constructor.returnType.element.hasDeprecated) {
      classBuffer.writeln(
          "@Deprecated('${_coreCheckerDeprecated.firstAnnotationOfExact(visitor.constructor.returnType.element)?.getField("message")?.toStringValue()}')");
    }

    classBuffer.write(
        '${(visitor.constructor.enclosingElement as ClassElement).isAbstract ? 'abstract ' : ''}class $extClassName');
    if (interfaces.isNotEmpty) {
      classBuffer.writeln(
          ' implements ${interfaces.map((i) => i.element.name.replaceFirst("_", "")).join(', ')}');
    }
    if (superClass != null) {
      classBuffer.writeln(' extends ${superClassName}');
    }
    classBuffer.writeln(' {');

    final deprecatedFields = <VariableElement>[];
    final constructorFields = <String>[];
    final superConstructorFields = <String>[];

    final fieldEntriesSorted = visitor.fields.entries.toList();
    fieldEntriesSorted.sort((a, b) => a.key.compareTo(b.key));

    final fieldValuesSorted = visitor.fields.values.toList();
    fieldValuesSorted.sort((a, b) => a.name.compareTo(b.name));

    final methodEntriesSorted = visitor.methods.entries.toList();
    fieldEntriesSorted.sort((a, b) => a.key.compareTo(b.key));

    for (final entry in fieldEntriesSorted) {
      final fieldName = entry.key;
      final fieldElement = entry.value;
      if (!fieldElement.isPrivate) {
        final isNullable = Util.typeIsNullable(fieldElement.type);
        final constructorParameter = visitor.constructorParameters[fieldName];
        if (constructorParameter != null) {
          // remove class reference terminating with "_"
          var defaultValueCode =
              constructorParameter.defaultValueCode?.replaceFirst("_.", ".");
          var constructorField =
              '${!isNullable && defaultValueCode == null ? 'required ' : ''}this.$fieldName${defaultValueCode != null ? ' = $defaultValueCode' : ''}';
          if (fieldElement.hasDeprecated) {
            deprecatedFields.add(fieldElement);
            constructorField =
                "@Deprecated('${_coreCheckerDeprecated.firstAnnotationOfExact(fieldElement)?.getField("message")?.toStringValue()}') " +
                    constructorField;
          }
          constructorFields.add(constructorField);
        }
      }
      final docs = fieldElement.documentationComment;
      if (docs != null) {
        classBuffer.writeln(docs);
      }
      final fieldSupportedDocs =
          Util.getSupportedDocs(_coreCheckerSupportedPlatforms, fieldElement);
      if (fieldSupportedDocs != null) {
        classBuffer.writeln(fieldSupportedDocs);
      }
      if (fieldElement.hasDeprecated) {
        classBuffer.writeln(
            "@Deprecated('${_coreCheckerDeprecated.firstAnnotationOfExact(fieldElement)?.getField("message")?.toStringValue()}')");
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
      // remove class reference terminating with "_"
      classBuffer
          .write("${fieldElement.type.toString().replaceFirst("_", "")} ");
      if (!fieldElement.hasInitializer) {
        classBuffer.writeln("$fieldName;");
      } else {
        ParsedLibraryResult parsed = fieldElement.session
                ?.getParsedLibraryByElement(fieldElement.library)
            as ParsedLibraryResult;
        final fieldBody = parsed
            .getElementDeclaration(fieldElement)
            ?.node
            .toString()
            .replaceAll(className, extClassName);
        classBuffer.writeln("$fieldBody;");
      }
    }

    if (superClass != null) {
      ConstructorElement superConstructor = superClass.constructors.first;
      for (final parameter in superConstructor.parameters) {
        final parameterName = parameter.name;
        final parameterType = parameter.type;
        final isNullable = Util.typeIsNullable(parameter.type);
        // remove class reference terminating with "_"
        var defaultValueCode =
            parameter.defaultValueCode?.replaceFirst("_.", ".");
        var constructorField =
            '${!isNullable && defaultValueCode == null ? 'required ' : ''}${parameterType.toString().replaceFirst("_", "")} $parameterName${defaultValueCode != null ? ' = $defaultValueCode' : ''}';
        if (parameter.hasDeprecated) {
          deprecatedFields.add(parameter);
          constructorField =
              "@Deprecated('${_coreCheckerDeprecated.firstAnnotationOfExact(parameter)?.getField("message")?.toStringValue()}') " +
                  constructorField;
        }
        constructorFields.add(constructorField);
        superConstructorFields.add("$parameterName: $parameterName");
      }
    }

    final hasCustomConstructor =
        _coreCheckerObjectConstructor.hasAnnotationOf(visitor.constructor);
    final constructorDocs = visitor.constructor.documentationComment;
    if (constructorDocs != null) {
      classBuffer.writeln(constructorDocs);
    }
    var constructorSupportedDocs = Util.getSupportedDocs(
        _coreCheckerSupportedPlatforms, visitor.constructor);
    if (constructorSupportedDocs == null) {
      constructorSupportedDocs = Util.getSupportedDocs(
          _coreCheckerSupportedPlatforms,
          visitor.constructor.returnType.element);
    }
    if (constructorSupportedDocs != null) {
      classBuffer.writeln(constructorSupportedDocs);
    }
    if (hasCustomConstructor) {
      ParsedLibraryResult parsed = visitor.constructor.session
              ?.getParsedLibraryByElement(visitor.constructor.library)
          as ParsedLibraryResult;
      final constructorBody =
          parsed.getElementDeclaration(visitor.constructor)?.node;
      if (constructorBody != null) {
        classBuffer.writeln(constructorBody
            .toString()
            .replaceAll(className, extClassName)
            .replaceAll("_.", ".")
            .replaceAll("@ExchangeableObjectConstructor()", ""));
      }
    } else if (constructorFields.length > 0) {
      if (visitor.constructor.isConst) {
        classBuffer.write('const ');
      }
      classBuffer.writeln('$extClassName({');
      classBuffer.writeln(constructorFields.join(', '));
    } else {
      if (visitor.constructor.isConst) {
        classBuffer.write('const ');
      }
      classBuffer.writeln('$extClassName(');
    }

    if (!hasCustomConstructor && constructorFields.length > 0) {
      classBuffer.write('})');
    } else if (!hasCustomConstructor) {
      classBuffer.write(')');
    }

    if (superClass != null) {
      classBuffer.write(': super(');
      if (superConstructorFields.isNotEmpty) {
        classBuffer.write('${superConstructorFields.join(", ")}');
      }
      classBuffer.write(')');
    }

    if (!hasCustomConstructor && deprecatedFields.length > 0) {
      classBuffer.writeln(' {');
      for (final deprecatedField in deprecatedFields) {
        final deprecatedUseNewFieldNameInConstructor =
            _coreCheckerObjectProperty
                    .firstAnnotationOf(deprecatedField)
                    ?.getField("deprecatedUseNewFieldNameInConstructor")
                    ?.toBoolValue() ??
                true;
        if (!deprecatedUseNewFieldNameInConstructor) {
          continue;
        }

        final message = _coreCheckerDeprecated
            .firstAnnotationOfExact(deprecatedField)!
            .getField("message")!
            .toStringValue()!
            .trim();
        if (!message.startsWith("Use ") && !message.endsWith(" instead")) {
          continue;
        }

        final newFieldName = message
            .replaceFirst("Use ", "")
            .replaceFirst(" instead", "")
            .trim();

        final newFieldElement = visitor.fields[newFieldName];
        final shouldUseNewFieldName = newFieldElement != null;
        if (shouldUseNewFieldName) {
          final deprecatedFieldName = deprecatedField.name;
          final fieldTypeElement = newFieldElement.type.element;
          final deprecatedFieldTypeElement = deprecatedField.type.element;

          final isNullable = Util.typeIsNullable(newFieldElement.type);
          var hasDefaultValue = (newFieldElement is ParameterElement)
              ? (newFieldElement as ParameterElement).hasDefaultValue
              : false;
          if (!isNullable && hasDefaultValue) {
            continue;
          }

          classBuffer.write('$newFieldName = $newFieldName ?? ');
          if (fieldTypeElement != null && deprecatedFieldTypeElement != null) {
            final deprecatedIsNullable =
                Util.typeIsNullable(deprecatedField.type);
            final hasFromMap = hasFromMapMethod(fieldTypeElement);
            final hasFromNativeValue =
                hasFromNativeValueMethod(fieldTypeElement);
            final hasFromValue = hasFromValueMethod(fieldTypeElement);
            final deprecatedHasToMap =
                hasFromMapMethod(deprecatedFieldTypeElement);
            final deprecatedHasToNativeValue =
                hasToNativeValueMethod(deprecatedFieldTypeElement);
            final deprecatedHasToValue =
                hasToValueMethod(deprecatedFieldTypeElement);
            if (hasFromMap && deprecatedHasToMap) {
              final hasNullableFromMap =
                  hasNullableFromMapFactory(fieldTypeElement);
              classBuffer.write(fieldTypeElement.name!.replaceFirst("_", "") +
                  ".fromMap($deprecatedFieldName${deprecatedIsNullable ? '?' : ''}.toMap())${!isNullable && hasNullableFromMap ? '!' : ''}");
            } else if (hasFromNativeValue && deprecatedHasToNativeValue) {
              classBuffer.write(fieldTypeElement.name!.replaceFirst("_", "") +
                  '.fromNativeValue($deprecatedFieldName${deprecatedIsNullable ? '?' : ''}.toNativeValue())${!isNullable ? '!' : ''}');
            } else if (hasFromValue && deprecatedHasToValue) {
              classBuffer.write(fieldTypeElement.name!.replaceFirst("_", "") +
                  '.fromValue($deprecatedFieldName${deprecatedIsNullable ? '?' : ''}.toValue())${!isNullable ? '!' : ''}');
            } else if (deprecatedField.type
                        .getDisplayString(withNullability: false) ==
                    "Uri" &&
                newFieldElement.type.getDisplayString(withNullability: false) ==
                    "WebUri") {
              if (deprecatedIsNullable) {
                classBuffer.write(
                    "($deprecatedFieldName != null ? WebUri.uri($deprecatedFieldName!) : ${isNullable ? "null" : "WebUri('')"})");
              } else {
                classBuffer.write("WebUri.uri($deprecatedFieldName)");
              }
            } else {
              classBuffer.write(deprecatedFieldName);
            }
          } else {
            classBuffer.write(deprecatedFieldName);
          }
          classBuffer.writeln(';');
        }
      }
      classBuffer.writeln('}');
    } else if (!hasCustomConstructor) {
      classBuffer.writeln(';');
    }

    if (annotation.read("fromMapFactory").boolValue &&
        (!visitor.methods.containsKey("fromMap") ||
            Util.methodHasIgnore(visitor.methods['fromMap']!))) {
      classBuffer.writeln(
          '///Gets a possible [$extClassName] instance from a [Map] value.');
      final nullable = annotation.read("nullableFromMapFactory").boolValue;
      classBuffer
          .writeln('static $extClassName${nullable ? '?' : ''} fromMap(');
      classBuffer.writeln(
          'Map<String, dynamic>${nullable ? '?' : ''} map, {EnumMethod? enumMethod}');
      classBuffer.writeln(') {');
      if (nullable) {
        classBuffer.writeln('if (map == null) { return null; }');
      }
      classBuffer.writeln('final instance = $extClassName(');
      final fieldElements = <FieldElement>[];
      if (superClass != null) {
        fieldElements.addAll(superClass.element.fields);
      }
      fieldElements.addAll(fieldValuesSorted);
      final nonRequiredFields = <String>[];
      final requiredFields = <String>[];
      for (final fieldElement in fieldElements) {
        final fieldName = fieldElement.name;
        if (!fieldElement.isPrivate &&
            !fieldElement.isStatic &&
            !(fieldElement.type.isDartCoreFunction ||
                fieldElement.type is FunctionType)) {
          var value = "map['$fieldName']";

          if (fieldElement.hasDeprecated) {
            final deprecatedUseNewFieldNameInFromMapMethod =
                _coreCheckerObjectProperty
                        .firstAnnotationOf(fieldElement)
                        ?.getField("deprecatedUseNewFieldNameInFromMapMethod")
                        ?.toBoolValue() ??
                    true;

            final deprecationMessage = _coreCheckerDeprecated
                .firstAnnotationOfExact(fieldElement)
                ?.getField("message")
                ?.toStringValue()
                ?.trim();
            if (deprecationMessage != null &&
                deprecationMessage.startsWith("Use ") &&
                deprecationMessage.endsWith(" instead") &&
                deprecatedUseNewFieldNameInFromMapMethod) {
              final newFieldName = deprecationMessage
                  .replaceFirst("Use ", "")
                  .replaceFirst(" instead", "")
                  .trim();
              final newFieldElement = fieldElements
                  .firstWhereOrNull((element) => element.name == newFieldName);
              final shouldUseNewFieldName = newFieldElement != null &&
                  (newFieldElement.type == fieldElement.type ||
                      (fieldElement.name.startsWith(RegExp(r'android|ios')) &&
                          fieldElement.name.toLowerCase().replaceFirst(
                                  RegExp(r'android|ioswk|ios'), "") ==
                              newFieldName.toLowerCase()) ||
                      (newFieldElement.type.element != null &&
                          fieldElement.type.element != null &&
                          ((hasFromNativeValueMethod(
                                      newFieldElement.type.element!) &&
                                  hasFromNativeValueMethod(
                                      fieldElement.type.element!) ||
                              (hasFromMapMethod(
                                      newFieldElement.type.element!) &&
                                  hasFromMapMethod(
                                      fieldElement.type.element!))))));
              if (shouldUseNewFieldName) {
                value = "map['$newFieldName']";
              }
            } else {
              final leaveDeprecatedInFromMapMethod = _coreCheckerObjectProperty
                      .firstAnnotationOf(fieldElement)
                      ?.getField("leaveDeprecatedInFromMapMethod")
                      ?.toBoolValue() ??
                  false;
              if (!leaveDeprecatedInFromMapMethod) {
                continue;
              }
            }
          }

          final mapValue = value;

          final customDeserializer = _coreCheckerObjectProperty
              .firstAnnotationOf(fieldElement)
              ?.getField("deserializer")
              ?.toFunctionValue();
          if (customDeserializer != null) {
            final deserializerClassName =
                customDeserializer.enclosingElement.name;
            if (deserializerClassName != null) {
              value =
                  "$deserializerClassName.${customDeserializer.name}($value, enumMethod: enumMethod)";
            } else {
              value =
                  "${customDeserializer.name}($value, enumMethod: enumMethod)";
            }
          } else {
            value = getFromMapValue(value, fieldElement.type);
          }
          final constructorParameter = visitor.constructorParameters[fieldName];
          final isRequiredParameter = constructorParameter != null &&
              (constructorParameter.isRequiredNamed ||
                  constructorParameter.isFinal ||
                  fieldElement.isFinal ||
                  !Util.typeIsNullable(constructorParameter.type)) &&
              !constructorParameter.hasDefaultValue;
          if (isRequiredParameter ||
              fieldElement.isFinal ||
              annotation.read("fromMapForceAllInline").boolValue) {
            requiredFields.add('$fieldName: $value,');
          } else {
            final isFieldNullable = Util.typeIsNullable(fieldElement.type);
            if (!isFieldNullable) {
              nonRequiredFields.add("if ($mapValue != null) {");
            }
            nonRequiredFields.add("instance.$fieldName = $value;");
            if (!isFieldNullable) {
              nonRequiredFields.add("}");
            }
          }
        }
      }
      classBuffer.writeln(requiredFields.join("\n") + ');');
      if (nonRequiredFields.isNotEmpty) {
        classBuffer.writeln(nonRequiredFields.join("\n"));
      }
      classBuffer.writeln('return instance;');
      classBuffer.writeln('}');
    }

    for (final entry in methodEntriesSorted) {
      final methodElement = entry.value;
      if (Util.methodHasIgnore(methodElement)) {
        continue;
      }
      ParsedLibraryResult parsed = methodElement.session
              ?.getParsedLibraryByElement(methodElement.library)
          as ParsedLibraryResult;
      final methodBody = parsed.getElementDeclaration(methodElement)?.node;
      if (methodBody != null) {
        final docs = methodElement.documentationComment;
        if (docs != null) {
          classBuffer.writeln(docs);
        }
        final fieldSupportedDocs = Util.getSupportedDocs(
            _coreCheckerSupportedPlatforms, methodElement);
        if (fieldSupportedDocs != null) {
          classBuffer.writeln(fieldSupportedDocs);
        }
        classBuffer
            .writeln(methodBody.toString().replaceAll(className, extClassName));
      }
    }

    if (annotation.read("toMapMethod").boolValue &&
        (!visitor.methods.containsKey("toMap") ||
            Util.methodHasIgnore(visitor.methods['toMap']!))) {
      classBuffer.writeln('///Converts instance to a map.');
      classBuffer
          .writeln('Map<String, dynamic> toMap({EnumMethod? enumMethod}) {');
      classBuffer.writeln('return {');
      final fieldElements = <FieldElement>[];
      if (superClass != null) {
        for (final fieldElement in superClass.element.fields) {
          if (!fieldElement.isPrivate &&
              !fieldElement.isStatic &&
              !(fieldElement.type.isDartCoreFunction ||
                  fieldElement.type is FunctionType)) {
            fieldElements.add(fieldElement);
          }
        }
      }
      for (final entry in fieldEntriesSorted) {
        final fieldElement = entry.value;
        if (!fieldElement.isPrivate &&
            !fieldElement.isStatic &&
            !(fieldElement.type.isDartCoreFunction ||
                fieldElement.type is FunctionType)) {
          fieldElements.add(fieldElement);
        }
      }
      for (final fieldElement in fieldElements) {
        if (!fieldElement.isPrivate &&
            !fieldElement.isStatic &&
            !(fieldElement.type.isDartCoreFunction ||
                fieldElement.type is FunctionType)) {
          if (fieldElement.hasDeprecated) {
            final leaveDeprecatedInToMapMethod = _coreCheckerObjectProperty
                    .firstAnnotationOf(fieldElement)
                    ?.getField("leaveDeprecatedInToMapMethod")
                    ?.toBoolValue() ??
                false;
            if (!leaveDeprecatedInToMapMethod) {
              continue;
            }
          }

          final fieldName = fieldElement.name;
          var mapValue = fieldName;
          final customSerializer = _coreCheckerObjectProperty
              .firstAnnotationOf(fieldElement)
              ?.getField("serializer")
              ?.toFunctionValue();
          if (customSerializer != null) {
            final serializerClassName = customSerializer.enclosingElement.name;
            if (serializerClassName != null) {
              mapValue =
                  "$serializerClassName.${customSerializer.name}($mapValue, enumMethod: enumMethod)";
            } else {
              mapValue =
                  "${customSerializer.name}($mapValue, enumMethod: enumMethod)";
            }
          } else {
            mapValue = getToMapValue(fieldName, fieldElement.type);
          }

          classBuffer.writeln('"$fieldName": $mapValue,');
        }
      }
      for (final entry in methodEntriesSorted) {
        final methodElement = entry.value;
        final toMapMergeWith = _coreCheckerObjectMethod
            .firstAnnotationOf(methodElement)
            ?.getField("toMapMergeWith")
            ?.toBoolValue();
        if (toMapMergeWith == true) {
          classBuffer
              .writeln('...${methodElement.name}(enumMethod: enumMethod),');
        }
      }
      classBuffer.writeln('};');
      classBuffer.writeln('}');
    }

    if (annotation.read("toJsonMethod").boolValue &&
        (!visitor.methods.containsKey("toJson") ||
            Util.methodHasIgnore(visitor.methods['toJson']!))) {
      classBuffer.writeln('///Converts instance to a map.');
      classBuffer.writeln('Map<String, dynamic> toJson() {');
      classBuffer.writeln('return toMap();');
      classBuffer.writeln('}');
    }

    if (annotation.read("copyMethod").boolValue &&
        (!visitor.methods.containsKey("copy") ||
            Util.methodHasIgnore(visitor.methods['copy']!))) {
      classBuffer.writeln('///Returns a copy of $extClassName.');
      classBuffer.writeln('$extClassName copy() {');
      classBuffer
          .writeln('return $extClassName.fromMap(toMap()) ?? $extClassName();');
      classBuffer.writeln('}');
    }

    if (annotation.read("toStringMethod").boolValue &&
        (!visitor.methods.containsKey("toString") ||
            Util.methodHasIgnore(visitor.methods['toString']!))) {
      classBuffer.writeln('@override');
      classBuffer.writeln('String toString() {');
      classBuffer.write('return \'$extClassName{');
      final fieldNames = <String>[];
      if (superClass != null) {
        for (final fieldElement in superClass.element.fields) {
          final fieldName = fieldElement.name;
          if (!fieldElement.isPrivate &&
              !fieldElement.hasDeprecated &&
              !fieldElement.isStatic &&
              !(fieldElement.type.isDartCoreFunction ||
                  fieldElement.type is FunctionType)) {
            fieldNames.add('$fieldName: \$$fieldName');
          }
        }
      }
      for (final entry in fieldEntriesSorted) {
        final fieldName = entry.key;
        final fieldElement = entry.value;
        if (!fieldElement.isPrivate &&
            !fieldElement.hasDeprecated &&
            !fieldElement.isStatic &&
            !(fieldElement.type.isDartCoreFunction ||
                fieldElement.type is FunctionType)) {
          fieldNames.add('$fieldName: \$$fieldName');
        }
      }
      classBuffer.write(fieldNames.join(', '));
      classBuffer.writeln('}\';');
      classBuffer.writeln('}');
    }

    classBuffer.writeln('}');
    return classBuffer.toString();
  }

  String getFromMapValue(String value, DartType elementType) {
    final fieldTypeElement = elementType.element;
    // remove class reference terminating with "_"
    final classNameReference = fieldTypeElement?.name?.replaceFirst("_", "");
    final isNullable = Util.typeIsNullable(elementType);
    final displayString = elementType.getDisplayString(withNullability: false);
    if (displayString == "Uri") {
      if (!isNullable) {
        return "(Uri.tryParse($value) ?? Uri())";
      } else {
        return "$value != null ? Uri.tryParse($value) : null";
      }
    } else if (displayString == "WebUri") {
      if (!isNullable) {
        return "WebUri($value)";
      } else {
        return "$value != null ? WebUri($value) : null";
      }
    } else if (displayString == "Color" || displayString == "Color_") {
      if (!isNullable) {
        return "UtilColor.fromStringRepresentation($value)!";
      } else {
        return "$value != null ? UtilColor.fromStringRepresentation($value) : null";
      }
    } else if (displayString == "EdgeInsets") {
      return "MapEdgeInsets.fromMap($value?.cast<String, dynamic>())${!isNullable ? '!' : ''}";
    } else if (displayString == "Size") {
      return "MapSize.fromMap($value?.cast<String, dynamic>())${!isNullable ? '!' : ''}";
    } else if (displayString == "DateTime") {
      if (!isNullable) {
        return "DateTime.fromMillisecondsSinceEpoch($value)!";
      } else {
        return "$value != null ? DateTime.fromMillisecondsSinceEpoch($value) : null";
      }
    } else if (displayString == "Uint8List") {
      if (!isNullable) {
        return "Uint8List.fromList($value.cast<int>())";
      } else {
        return "$value != null ? Uint8List.fromList($value.cast<int>()) : null";
      }
    } else if (elementType.isDartCoreList || elementType.isDartCoreSet) {
      final genericTypes = Util.getGenericTypes(elementType);
      final genericType = genericTypes.isNotEmpty ? genericTypes.first : null;
      final genericTypeReplaced = genericType != null
          ? genericType.toString().replaceAll("_", "")
          : null;
      if (genericType != null && !Util.isDartCoreType(genericType)) {
        final genericTypeFieldName = 'e';
        return (isNullable ? '$value != null ? ' : '') +
            "${elementType.isDartCoreSet ? 'Set' : 'List'}<$genericTypeReplaced>.from(" +
            value +
            '.map(($genericTypeFieldName) => ' +
            getFromMapValue('$genericTypeFieldName', genericType) +
            '))' +
            (isNullable ? ' : null' : '');
      } else {
        if (genericType != null) {
          return (isNullable ? '$value != null ? ' : '') +
              "${elementType.isDartCoreSet ? 'Set' : 'List'}<$genericTypeReplaced>.from(" +
              "$value!.cast<${genericTypeReplaced}>())" +
              (isNullable ? ' : null' : '');
        } else {
          return value;
        }
      }
    } else if (elementType.isDartCoreMap) {
      final genericTypes = Util.getGenericTypes(elementType);
      return "$value${isNullable ? '?' : ''}.cast<${genericTypes.elementAt(0)}, ${genericTypes.elementAt(1)}>()";
    } else if (fieldTypeElement != null && hasFromMapMethod(fieldTypeElement)) {
      final hasNullableFromMap = hasNullableFromMapFactory(fieldTypeElement);
      return classNameReference! +
          ".fromMap($value?.cast<String, dynamic>(), enumMethod: enumMethod)${!isNullable && hasNullableFromMap ? '!' : ''}";
    } else {
      final hasFromValue =
          fieldTypeElement != null && hasFromValueMethod(fieldTypeElement);
      final hasFromNativeValue = fieldTypeElement != null &&
          hasFromNativeValueMethod(fieldTypeElement);
      final hasByName =
          fieldTypeElement != null && hasByNameMethod(fieldTypeElement);
      if (fieldTypeElement != null &&
          (hasFromValue || hasFromNativeValue || hasByName)) {
        if ([hasFromValue, hasFromNativeValue, hasByName]
                .where((e) => e)
                .length >
            1) {
          String? defaultEnumMethodValue = null;
          if (hasFromNativeValue) {
            defaultEnumMethodValue = "EnumMethod.nativeValue";
          } else if (hasFromValue) {
            defaultEnumMethodValue = "EnumMethod.value";
          } else {
            defaultEnumMethodValue = "EnumMethod.name";
          }
          var wrapper = "switch (enumMethod ?? $defaultEnumMethodValue) {";
          wrapper += "EnumMethod.nativeValue => " +
              (hasFromNativeValue
                  ? classNameReference! + '.fromNativeValue($value)'
                  : "null") +
              ", ";
          wrapper += "EnumMethod.value => " +
              (hasFromValue
                  ? classNameReference! + '.fromValue($value)'
                  : "null") +
              ", ";
          wrapper += "EnumMethod.name => " +
              (hasByName ? classNameReference! + '.byName($value)' : "null");
          wrapper += "}";
          value = wrapper;
        } else {
          if (hasFromNativeValue) {
            value = classNameReference! + '.fromNativeValue($value)';
          } else if (hasFromValue) {
            value = classNameReference! + '.fromValue($value)';
          } else {
            value = classNameReference! + '.byName($value)';
          }
        }
        if (!isNullable) {
          value += '!';
        }
        return value;
      }
    }

    return value;
  }

  String getToMapValue(String fieldName, DartType elementType) {
    final fieldTypeElement = elementType.element;
    final isNullable = Util.typeIsNullable(elementType);
    final displayString = elementType.getDisplayString(withNullability: false);
    if (displayString == "Uri") {
      return fieldName + (isNullable ? '?' : '') + '.toString()';
    } else if (displayString == "WebUri") {
      return fieldName + (isNullable ? '?' : '') + '.toString()';
    } else if (displayString == "Color" || displayString == "Color_") {
      return fieldName + (isNullable ? '?' : '') + '.toHex()';
    } else if (displayString == "EdgeInsets") {
      return fieldName + (isNullable ? '?' : '') + '.toMap()';
    } else if (displayString == "Size") {
      return fieldName + (isNullable ? '?' : '') + '.toMap()';
    } else if (displayString == "DateTime") {
      return fieldName + (isNullable ? '?' : '') + '.millisecondsSinceEpoch';
    } else if (elementType.isDartCoreList || elementType.isDartCoreSet) {
      final genericType = Util.getGenericTypes(elementType).first;
      if (!Util.isDartCoreType(genericType)) {
        final genericTypeFieldName = 'e';
        return fieldName +
            (isNullable ? '?' : '') +
            '.map(($genericTypeFieldName) => ' +
            getToMapValue('$genericTypeFieldName', genericType) +
            ').toList()';
      } else {
        return elementType.isDartCoreSet
            ? "$fieldName${(isNullable ? '?' : '')}.toList()"
            : fieldName;
      }
    } else if (fieldTypeElement != null && hasToMapMethod(fieldTypeElement)) {
      return fieldName +
          (Util.typeIsNullable(elementType) ? '?' : '') +
          '.toMap(enumMethod: enumMethod)';
    } else {
      final hasToValue =
          fieldTypeElement != null && hasToValueMethod(fieldTypeElement);
      final hasToNativeValue =
          fieldTypeElement != null && hasToNativeValueMethod(fieldTypeElement);
      final hasName =
          fieldTypeElement != null && hasNameMethod(fieldTypeElement);
      if (fieldTypeElement != null &&
          (hasToValue || hasToNativeValue || hasName)) {
        if ([hasToValue, hasToNativeValue, hasName].where((e) => e).length >
            1) {
          String? defaultEnumMethodValue = null;
          if (hasToNativeValue) {
            defaultEnumMethodValue = "EnumMethod.nativeValue";
          } else if (hasToValue) {
            defaultEnumMethodValue = "EnumMethod.value";
          } else {
            defaultEnumMethodValue = "EnumMethod.name";
          }
          var wrapper = "switch (enumMethod ?? $defaultEnumMethodValue) {";
          wrapper += "EnumMethod.nativeValue => " +
              (hasToNativeValue
                  ? (fieldName + (isNullable ? '?' : '') + '.toNativeValue()')
                  : "null") +
              ", ";
          wrapper += "EnumMethod.value => " +
              (hasToValue
                  ? (fieldName + (isNullable ? '?' : '') + '.toValue()')
                  : "null") +
              ", ";
          wrapper += "EnumMethod.name => " +
              (hasName
                  ? (fieldName + (isNullable ? '?' : '') + '.name()')
                  : "null");
          wrapper += "}";
          return wrapper;
        } else {
          if (hasToNativeValue) {
            return fieldName + (isNullable ? '?' : '') + '.toNativeValue()';
          } else if (hasToValue) {
            return fieldName + (isNullable ? '?' : '') + '.toValue()';
          } else {
            return fieldName + (isNullable ? '?' : '') + '.name()';
          }
        }
      }
    }

    return fieldName;
  }

  bool hasToMapMethod(Element element) {
    final hasAnnotation = _coreChecker.hasAnnotationOf(element);
    final toMapMethod = _coreChecker
            .firstAnnotationOfExact(element)
            ?.getField('toMapMethod')
            ?.toBoolValue() ??
        false;
    if (hasAnnotation && toMapMethod) {
      return true;
    }

    final fieldVisitor = ModelVisitor();
    element.visitChildren(fieldVisitor);
    for (var entry in fieldVisitor.methods.entries) {
      if (entry.key == "toMap") {
        return true;
      }
    }

    return false;
  }

  bool hasFromMapMethod(Element element) {
    final hasAnnotation = _coreChecker.hasAnnotationOf(element);
    final fromMapFactory = _coreChecker
            .firstAnnotationOfExact(element)
            ?.getField('fromMapFactory')
            ?.toBoolValue() ??
        false;
    if (hasAnnotation && fromMapFactory) {
      return true;
    }

    final fieldVisitor = ModelVisitor();
    element.visitChildren(fieldVisitor);
    for (var entry in fieldVisitor.methods.entries) {
      if (entry.key == "fromMap") {
        return true;
      }
    }

    return false;
  }

  bool hasNullableFromMapFactory(Element element) {
    final hasAnnotation = _coreChecker.hasAnnotationOf(element);
    final fromMapFactory = _coreChecker
            .firstAnnotationOfExact(element)
            ?.getField('fromMapFactory')
            ?.toBoolValue() ??
        false;
    final nullableFromMapFactory = _coreChecker
            .firstAnnotationOfExact(element)
            ?.getField('nullableFromMapFactory')
            ?.toBoolValue() ??
        false;
    if (hasAnnotation && fromMapFactory && nullableFromMapFactory) {
      return true;
    }

    final fieldVisitor = ModelVisitor();
    element.visitChildren(fieldVisitor);
    for (var entry in fieldVisitor.methods.entries) {
      if (entry.key == "fromMap" &&
          Util.typeIsNullable(entry.value.returnType)) {
        return true;
      }
    }

    return false;
  }

  bool hasFromValueMethod(Element element) {
    final hasAnnotation = _coreCheckerEnum.hasAnnotationOf(element);
    final fromValueMethod = _coreCheckerEnum
            .firstAnnotationOfExact(element)
            ?.getField('fromValueMethod')
            ?.toBoolValue() ??
        false;
    if (hasAnnotation && fromValueMethod) {
      return true;
    }

    final fieldVisitor = ModelVisitor();
    element.visitChildren(fieldVisitor);
    for (var entry in fieldVisitor.methods.entries) {
      if (entry.key == "fromValue") {
        return true;
      }
    }

    return false;
  }

  bool hasFromNativeValueMethod(Element element) {
    final hasAnnotation = _coreCheckerEnum.hasAnnotationOf(element);
    final fromNativeValueMethod = _coreCheckerEnum
            .firstAnnotationOfExact(element)
            ?.getField('fromNativeValueMethod')
            ?.toBoolValue() ??
        false;
    if (hasAnnotation && fromNativeValueMethod) {
      return true;
    }

    final fieldVisitor = ModelVisitor();
    element.visitChildren(fieldVisitor);
    for (var entry in fieldVisitor.methods.entries) {
      if (entry.key == "fromNativeValue") {
        return true;
      }
    }

    return false;
  }

  bool hasByNameMethod(Element element) {
    final hasAnnotation = _coreCheckerEnum.hasAnnotationOf(element);
    final byNameMethod = _coreCheckerEnum
            .firstAnnotationOfExact(element)
            ?.getField('byNameMethod')
            ?.toBoolValue() ??
        false;
    if (hasAnnotation && byNameMethod) {
      return true;
    }

    final fieldVisitor = ModelVisitor();
    element.visitChildren(fieldVisitor);
    for (var entry in fieldVisitor.methods.entries) {
      if (entry.key == "byName") {
        return true;
      }
    }

    return false;
  }

  bool hasToValueMethod(Element element) {
    final hasAnnotation = _coreCheckerEnum.hasAnnotationOf(element);
    final hasToValueMethod = _coreCheckerEnum
            .firstAnnotationOfExact(element)
            ?.getField('toValueMethod')
            ?.toBoolValue() ??
        false;
    if (hasAnnotation && hasToValueMethod) {
      return true;
    }

    final fieldVisitor = ModelVisitor();
    element.visitChildren(fieldVisitor);
    for (var entry in fieldVisitor.methods.entries) {
      if (entry.key == "toValue") {
        return true;
      }
    }

    return false;
  }

  bool hasToNativeValueMethod(Element element) {
    final hasAnnotation = _coreCheckerEnum.hasAnnotationOf(element);
    final hasToNativeValueMethod = _coreCheckerEnum
            .firstAnnotationOfExact(element)
            ?.getField('toNativeValueMethod')
            ?.toBoolValue() ??
        false;
    if (hasAnnotation && hasToNativeValueMethod) {
      return true;
    }

    final fieldVisitor = ModelVisitor();
    element.visitChildren(fieldVisitor);
    for (var entry in fieldVisitor.methods.entries) {
      if (entry.key == "toNativeValue") {
        return true;
      }
    }

    return false;
  }

  bool hasNameMethod(Element element) {
    final hasAnnotation = _coreCheckerEnum.hasAnnotationOf(element);
    final hasNameMethod = _coreCheckerEnum
            .firstAnnotationOfExact(element)
            ?.getField('nameMethod')
            ?.toBoolValue() ??
        false;
    if (hasAnnotation && hasNameMethod) {
      return true;
    }

    final fieldVisitor = ModelVisitor();
    element.visitChildren(fieldVisitor);
    for (var entry in fieldVisitor.methods.entries) {
      if (entry.key == "name") {
        return true;
      }
    }

    return false;
  }
}
