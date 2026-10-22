class ExchangeableObjectProperty {
  final Function? serializer;
  final Function? deserializer;
  final bool deprecatedUseNewFieldNameInConstructor;
  final bool deprecatedUseNewFieldNameInFromMapMethod;
  final bool leaveDeprecatedInFromMapMethod;
  final bool leaveDeprecatedInToMapMethod;

  const ExchangeableObjectProperty({
    this.serializer,
    this.deserializer,
    this.deprecatedUseNewFieldNameInConstructor = true,
    this.deprecatedUseNewFieldNameInFromMapMethod = true,
    this.leaveDeprecatedInFromMapMethod = false,
    this.leaveDeprecatedInToMapMethod = false,
  });
}
