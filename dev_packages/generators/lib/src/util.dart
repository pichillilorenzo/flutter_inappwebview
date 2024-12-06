import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:source_gen/source_gen.dart';

final _coreCheckerObjectMethod =
    const TypeChecker.fromRuntime(ExchangeableObjectMethod);

abstract class Util {
  static bool typeIsNullable(DartType type) {
    return type.nullabilitySuffix != NullabilitySuffix.none ||
        type.toString() == 'dynamic';
  }

  static bool methodHasIgnore(MethodElement method) {
    return _coreCheckerObjectMethod
            .firstAnnotationOf(method)
            ?.getField("ignore")
            ?.toBoolValue() ==
        true;
  }

  static ClassElement? getClassElement(Element element) {
    if (element is ClassElement) {
      return element;
    }
    if (element.enclosingElement != null) {
      return getClassElement(element.enclosingElement!);
    }
    return null;
  }

  static String? getSupportedDocs(TypeChecker checker, Element element) {
    final platformSupportedList = <String>[];
    final platforms = checker
            .firstAnnotationOfExact(element)
            ?.getField('platforms')
            ?.toListValue() ??
        <DartObject>[];

    final classElement = getClassElement(element);
    List<DartObject> classElementPlatforms = [];
    if (classElement != null) {
      classElementPlatforms = checker
              .firstAnnotationOfExact(classElement)
              ?.getField('platforms')
              ?.toListValue() ??
          <DartObject>[];
    }
    for (var platform in platforms) {
      final classElementPlatform = classElementPlatforms
          .firstWhereOrNull((p) => p.type == platform.type);
      final classElementPlatformName =
          classElementPlatform?.getField("name")!.toStringValue()!;
      var platformName = platform.getField("name")!.toStringValue()!;
      if (classElementPlatformName != null &&
          kPlatformNameValues.contains(platformName) &&
          !kPlatformNameValues.contains(classElementPlatformName)) {
        platformName = classElementPlatformName;
      }
      final apiName = platform.getField("apiName")?.toStringValue();
      final apiUrl = platform.getField("apiUrl")?.toStringValue();
      final available = platform.getField("available")?.toStringValue();
      final requiresSameOrigin =
          platform.getField("requiresSameOrigin")?.toBoolValue() ?? false;
      var api = available != null ? "$available+ " : "";
      if (requiresSameOrigin) {
        api += "but requires same origin";
        if (apiName != null || apiUrl != null) {
          api += " ";
        }
      }
      if (apiName != null && apiUrl != null) {
        api += "([Official API - $apiName]($apiUrl))";
      } else if (apiName != null) {
        api += "(Official API - $apiName)";
      } else if (apiUrl != null) {
        api += "([Official API]($apiUrl))";
      }

      var platformNote = "";
      final note = platform.getField("note")?.toStringValue();
      if (note != null) {
        final noteLines = note.split("\n");
        platformNote += noteLines[0].trim();
        for (int i = 1; i < noteLines.length; i++) {
          platformNote += " ${noteLines[i].trim()}";
        }
      }

      platformSupportedList.add(
          "///- ${(platformName + ' ' + api).trim()}${platformNote.isNotEmpty ? ":\n///    - " + platformNote : ""}");
    }
    if (platformSupportedList.isNotEmpty) {
      return """///
        ///**Officially Supported Platforms/Implementations**:
        ${platformSupportedList.join("\n")}""";
    }
    return null;
  }

  static String? getParameterSupportedDocs(
      TypeChecker checker, List<ParameterElement> parameters,
      [Map<String, List<DartObject>>? workaroundPlatforms]) {
    final nonDeprecatedParameters =
        parameters.where((p) => !p.hasDeprecated).toList();
    if (nonDeprecatedParameters.isEmpty) {
      return null;
    }

    final classElement = getClassElement(nonDeprecatedParameters.first);
    List<DartObject> classElementPlatforms = [];
    if (classElement != null) {
      classElementPlatforms = checker
              .firstAnnotationOfExact(classElement)
              ?.getField('platforms')
              ?.toListValue() ??
          <DartObject>[];
    }

    var docs =
        "///**Parameters - Officially Supported Platforms/Implementations**:";
    for (final parameter in nonDeprecatedParameters) {
      var platforms = checker
              .firstAnnotationOfExact(parameter)
              ?.getField('platforms')
              ?.toListValue() ??
          (workaroundPlatforms?[parameter.name] != null
              ? workaroundPlatforms![parameter.name]!
              : <DartObject>[]);
      if (platforms.isEmpty) {
        docs += "\n///- [${parameter.name}]: all platforms";
      } else {
        docs += "\n///- [${parameter.name}]: ";

        for (var platform in platforms) {
          final classElementPlatform = classElementPlatforms
              .firstWhereOrNull((p) => p.type == platform.type);
          final classElementPlatformName =
              classElementPlatform?.getField("name")!.toStringValue()!;
          var platformName = platform.getField("name")!.toStringValue();
          if (classElementPlatformName != null &&
              kPlatformNameValues.contains(platformName) &&
              !kPlatformNameValues.contains(classElementPlatformName)) {
            platformName = classElementPlatformName;
          }
          final apiName = platform.getField("apiName")?.toStringValue();
          final apiUrl = platform.getField("apiUrl")?.toStringValue();
          final available = platform.getField("available")?.toStringValue();
          final requiresSameOrigin =
              platform.getField("requiresSameOrigin")?.toBoolValue() ?? false;
          var api = available != null ? "$available+ " : "";
          if (requiresSameOrigin) {
            api += "but requires same origin";
            if (apiName != null || apiUrl != null) {
              api += " ";
            }
          }
          if (apiName != null && apiUrl != null) {
            api += "([Official API - $apiName]($apiUrl))";
          } else if (apiName != null) {
            api += "(Official API - $apiName)";
          } else if (apiUrl != null) {
            api += "([Official API]($apiUrl))";
          }
          docs += "\n///    - $platformName $api";

          final note = platform.getField("note")?.toStringValue();
          if (note != null) {
            docs += ": ";
            final noteLines = note.split("\n");
            docs += noteLines[0].trim();
            for (int i = 1; i < noteLines.length; i++) {
              docs += " ${noteLines[i].trim()}";
            }
          }
        }
      }
    }
    return docs;
  }

  static Iterable<DartType> getGenericTypes(DartType type) {
    return type is ParameterizedType ? type.typeArguments : const [];
  }

  static bool canHaveGenerics(DartType type) {
    final element = type.element;
    if (element is ClassElement) {
      return element.typeParameters.isNotEmpty;
    }
    return false;
  }

  static bool isDartCoreType(DartType type) {
    return type.isDartCoreBool ||
        type.isDartCoreDouble ||
        type.isDartCoreEnum ||
        type.isDartCoreFunction ||
        type.isDartCoreInt ||
        type.isDartCoreIterable ||
        type.isDartCoreList ||
        type.isDartCoreMap ||
        type.isDartCoreNull ||
        type.isDartCoreNum ||
        type.isDartCoreObject ||
        type.isDartCoreSet ||
        type.isDartCoreString ||
        type.isDartCoreSymbol ||
        type is DynamicType;
  }
}
