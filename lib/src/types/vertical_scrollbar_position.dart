///Class used to configure the position of the vertical scroll bar.
class VerticalScrollbarPosition {
  final int _value;

  const VerticalScrollbarPosition._internal(this._value);

  ///Set of all values of [VerticalScrollbarPosition].
  static final Set<VerticalScrollbarPosition> values = [
    VerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT,
    VerticalScrollbarPosition.SCROLLBAR_POSITION_LEFT,
    VerticalScrollbarPosition.SCROLLBAR_POSITION_RIGHT,
  ].toSet();

  ///Gets a possible [VerticalScrollbarPosition] instance from an [int] value.
  static VerticalScrollbarPosition? fromValue(int? value) {
    if (value != null) {
      try {
        return VerticalScrollbarPosition.values
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
        return "SCROLLBAR_POSITION_LEFT";
      case 2:
        return "SCROLLBAR_POSITION_RIGHT";
      case 0:
      default:
        return "SCROLLBAR_POSITION_DEFAULT";
    }
  }

  ///Position the scroll bar at the default position as determined by the system.
  static const SCROLLBAR_POSITION_DEFAULT =
  const VerticalScrollbarPosition._internal(0);

  ///Position the scroll bar along the left edge.
  static const SCROLLBAR_POSITION_LEFT =
  const VerticalScrollbarPosition._internal(1);

  ///Position the scroll bar along the right edge.
  static const SCROLLBAR_POSITION_RIGHT =
  const VerticalScrollbarPosition._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An Android-specific class used to configure the position of the vertical scroll bar.
///Use [VerticalScrollbarPosition] instead.
@Deprecated("Use VerticalScrollbarPosition instead")
class AndroidVerticalScrollbarPosition {
  final int _value;

  const AndroidVerticalScrollbarPosition._internal(this._value);

  ///Set of all values of [AndroidVerticalScrollbarPosition].
  static final Set<AndroidVerticalScrollbarPosition> values = [
    AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT,
    AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_LEFT,
    AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_RIGHT,
  ].toSet();

  ///Gets a possible [AndroidVerticalScrollbarPosition] instance from an [int] value.
  static AndroidVerticalScrollbarPosition? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidVerticalScrollbarPosition.values
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
        return "SCROLLBAR_POSITION_LEFT";
      case 2:
        return "SCROLLBAR_POSITION_RIGHT";
      case 0:
      default:
        return "SCROLLBAR_POSITION_DEFAULT";
    }
  }

  ///Position the scroll bar at the default position as determined by the system.
  static const SCROLLBAR_POSITION_DEFAULT =
  const AndroidVerticalScrollbarPosition._internal(0);

  ///Position the scroll bar along the left edge.
  static const SCROLLBAR_POSITION_LEFT =
  const AndroidVerticalScrollbarPosition._internal(1);

  ///Position the scroll bar along the right edge.
  static const SCROLLBAR_POSITION_RIGHT =
  const AndroidVerticalScrollbarPosition._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}