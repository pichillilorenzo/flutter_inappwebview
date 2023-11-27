import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

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

  static String? getSupportedDocs(TypeChecker checker, Element element) {
    final platformNoteList = <String>[];
    final platformSupportedList = <String>[];
    final platforms = checker
            .firstAnnotationOfExact(element)
            ?.getField('platforms')
            ?.toListValue() ??
        <DartObject>[];
    for (var platform in platforms) {
      final platformName = platform.getField("name")!.toStringValue();
      final note = platform.getField("note")?.toStringValue();
      if (note != null) {
        final noteLines = note.split("\n");
        var platformNote =
            "///**NOTE for $platformName**: ${noteLines[0].trim()}";
        for (int i = 1; i < noteLines.length; i++) {
          platformNote += "\n///${noteLines[i].trim()}";
        }
        platformNoteList.add(platformNote);
      }

      final apiName = platform.getField("apiName")?.toStringValue();
      final apiUrl = platform.getField("apiUrl")?.toStringValue();
      final available = platform.getField("available")?.toStringValue();
      final requiresSameOrigin =
          platform.getField("requiresSameOrigin")?.toBoolValue() ?? false;
      var api = available != null ? "$available+ " : "";
      if (requiresSameOrigin) {
        api += "but iframe requires same origin ";
      }
      if (apiName != null && apiUrl != null) {
        api += "([Official API - $apiName]($apiUrl))";
      } else if (apiName != null) {
        api += "(Official API - $apiName)";
      } else if (apiUrl != null) {
        api += "([Official API]($apiUrl))";
      }
      platformSupportedList.add("///- $platformName $api");
    }
    if (platformSupportedList.isNotEmpty) {
      if (platformNoteList.isNotEmpty) {
        return """///
        ${platformNoteList.join("\n///\n")}
        ///
        ///**Officially Supported Platforms/Implementations**:
        ${platformSupportedList.join("\n")}""";
      } else {
        return """///
        ///**Officially Supported Platforms/Implementations**:
        ${platformSupportedList.join("\n")}""";
      }
    }
    return null;
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
