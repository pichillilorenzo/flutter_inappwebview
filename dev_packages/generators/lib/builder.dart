import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'src/exchangeable_object_generator.dart';
import 'src/exchangeable_enum_generator.dart';

Builder generateExchangeableObject(BuilderOptions options) =>
    SharedPartBuilder([ExchangeableObjectGenerator()], 'exchangeable_object');

Builder generateExchangeableEnum(BuilderOptions options) =>
    SharedPartBuilder([ExchangeableEnumGenerator()], 'exchangeable_enum');
