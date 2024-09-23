class ExchangeableEnum {
  final bool valuesProperty;
  final bool toValueMethod;
  final bool fromValueMethod;
  final bool toNativeValueMethod;
  final bool fromNativeValueMethod;
  final bool toStringMethod;
  final bool hashCodeMethod;
  final bool equalsOperator;
  final bool bitwiseOrOperator;

  const ExchangeableEnum({
    this.valuesProperty = true,
    this.toValueMethod = true,
    this.fromValueMethod = true,
    this.toNativeValueMethod = true,
    this.fromNativeValueMethod = true,
    this.toStringMethod = true,
    this.hashCodeMethod = true,
    this.equalsOperator = true,
    this.bitwiseOrOperator = false
  });
}