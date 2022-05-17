import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

class ModelVisitor extends SimpleElementVisitor<void> {
  late ConstructorElement constructor;
  final constructorParameters = <String, ParameterElement>{};
  final fields = <String, FieldElement>{};
  final methods = <String, MethodElement>{};

  @override
  void visitConstructorElement(ConstructorElement element) {
    constructor = element;
    for (final param in element.parameters) {
      constructorParameters.putIfAbsent(param.name, () => param);
    }
  }

  @override
  void visitFieldElement(FieldElement element) {
    fields[element.name] = element;
  }

  @override
  void visitMethodElement(MethodElement element) {
    methods[element.name] = element;
  }
}
