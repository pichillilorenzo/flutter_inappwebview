class ExchangeableObject {
  final bool toMapMethod;
  final bool toJsonMethod;
  final bool fromMapFactory;
  final bool fromMapForceAllInline;
  final bool nullableFromMapFactory;
  final bool toStringMethod;
  final bool copyMethod;

  const ExchangeableObject({
    this.toMapMethod = true,
    this.toJsonMethod = true,
    this.fromMapFactory = true,
    this.fromMapForceAllInline = false,
    this.nullableFromMapFactory = true,
    this.toStringMethod = true,
    this.copyMethod = false
  });
}
