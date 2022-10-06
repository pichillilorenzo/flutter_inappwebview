class ExchangeableObjectProperty {
  final Function? serializer;
  final Function? deserializer;

  const ExchangeableObjectProperty({
    this.serializer,
    this.deserializer
  });
}
