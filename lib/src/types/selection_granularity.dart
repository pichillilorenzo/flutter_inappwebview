///Class used to set the level of granularity with which the user can interactively select content in the web view.
class SelectionGranularity {
  final int _value;

  const SelectionGranularity._internal(this._value);

  ///Set of all values of [SelectionGranularity].
  static final Set<SelectionGranularity> values = [
    SelectionGranularity.DYNAMIC,
    SelectionGranularity.CHARACTER,
  ].toSet();

  ///Gets a possible [SelectionGranularity] instance from an [int] value.
  static SelectionGranularity? fromValue(int? value) {
    if (value != null) {
      try {
        return SelectionGranularity.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "CHARACTER";
      case 0:
      default:
        return "DYNAMIC";
    }
  }

  ///Selection granularity varies automatically based on the selection.
  static const DYNAMIC = const SelectionGranularity._internal(0);

  ///Selection endpoints can be placed at any character boundary.
  static const CHARACTER = const SelectionGranularity._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An iOS-specific class used to set the level of granularity with which the user can interactively select content in the web view.
///Use [SelectionGranularity] instead.
@Deprecated("Use SelectionGranularity instead")
class IOSWKSelectionGranularity {
  final int _value;

  const IOSWKSelectionGranularity._internal(this._value);

  ///Set of all values of [IOSWKSelectionGranularity].
  static final Set<IOSWKSelectionGranularity> values = [
    IOSWKSelectionGranularity.DYNAMIC,
    IOSWKSelectionGranularity.CHARACTER,
  ].toSet();

  ///Gets a possible [IOSWKSelectionGranularity] instance from an [int] value.
  static IOSWKSelectionGranularity? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSWKSelectionGranularity.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "CHARACTER";
      case 0:
      default:
        return "DYNAMIC";
    }
  }

  ///Selection granularity varies automatically based on the selection.
  static const DYNAMIC = const IOSWKSelectionGranularity._internal(0);

  ///Selection endpoints can be placed at any character boundary.
  static const CHARACTER = const IOSWKSelectionGranularity._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}