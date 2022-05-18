///Class used to specify the transition style when presenting a view controller.
class ModalTransitionStyle {
  final int _value;

  const ModalTransitionStyle._internal(this._value);

  ///Set of all values of [ModalTransitionStyle].
  static final Set<ModalTransitionStyle> values = [
    ModalTransitionStyle.COVER_VERTICAL,
    ModalTransitionStyle.FLIP_HORIZONTAL,
    ModalTransitionStyle.CROSS_DISSOLVE,
    ModalTransitionStyle.PARTIAL_CURL,
  ].toSet();

  ///Gets a possible [ModalTransitionStyle] instance from an [int] value.
  static ModalTransitionStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return ModalTransitionStyle.values
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
        return "FLIP_HORIZONTAL";
      case 2:
        return "CROSS_DISSOLVE";
      case 3:
        return "PARTIAL_CURL";
      case 0:
      default:
        return "COVER_VERTICAL";
    }
  }

  ///When the view controller is presented, its view slides up from the bottom of the screen.
  ///On dismissal, the view slides back down. This is the default transition style.
  static const COVER_VERTICAL = const ModalTransitionStyle._internal(0);

  ///When the view controller is presented, the current view initiates a horizontal 3D flip from right-to-left,
  ///resulting in the revealing of the new view as if it were on the back of the previous view.
  ///On dismissal, the flip occurs from left-to-right, returning to the original view.
  static const FLIP_HORIZONTAL = const ModalTransitionStyle._internal(1);

  ///When the view controller is presented, the current view fades out while the new view fades in at the same time.
  ///On dismissal, a similar type of cross-fade is used to return to the original view.
  static const CROSS_DISSOLVE = const ModalTransitionStyle._internal(2);

  ///When the view controller is presented, one corner of the current view curls up to reveal the presented view underneath.
  ///On dismissal, the curled up page unfurls itself back on top of the presented view.
  ///A view controller presented using this transition is itself prevented from presenting any additional view controllers.
  static const PARTIAL_CURL = const ModalTransitionStyle._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An iOS-specific class used to specify the transition style when presenting a view controller.
///Use [ModalTransitionStyle] instead.
@Deprecated("Use ModalTransitionStyle instead")
class IOSUIModalTransitionStyle {
  final int _value;

  const IOSUIModalTransitionStyle._internal(this._value);

  ///Set of all values of [IOSUIModalTransitionStyle].
  static final Set<IOSUIModalTransitionStyle> values = [
    IOSUIModalTransitionStyle.COVER_VERTICAL,
    IOSUIModalTransitionStyle.FLIP_HORIZONTAL,
    IOSUIModalTransitionStyle.CROSS_DISSOLVE,
    IOSUIModalTransitionStyle.PARTIAL_CURL,
  ].toSet();

  ///Gets a possible [IOSUIModalTransitionStyle] instance from an [int] value.
  static IOSUIModalTransitionStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSUIModalTransitionStyle.values
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
        return "FLIP_HORIZONTAL";
      case 2:
        return "CROSS_DISSOLVE";
      case 3:
        return "PARTIAL_CURL";
      case 0:
      default:
        return "COVER_VERTICAL";
    }
  }

  ///When the view controller is presented, its view slides up from the bottom of the screen.
  ///On dismissal, the view slides back down. This is the default transition style.
  static const COVER_VERTICAL = const IOSUIModalTransitionStyle._internal(0);

  ///When the view controller is presented, the current view initiates a horizontal 3D flip from right-to-left,
  ///resulting in the revealing of the new view as if it were on the back of the previous view.
  ///On dismissal, the flip occurs from left-to-right, returning to the original view.
  static const FLIP_HORIZONTAL = const IOSUIModalTransitionStyle._internal(1);

  ///When the view controller is presented, the current view fades out while the new view fades in at the same time.
  ///On dismissal, a similar type of cross-fade is used to return to the original view.
  static const CROSS_DISSOLVE = const IOSUIModalTransitionStyle._internal(2);

  ///When the view controller is presented, one corner of the current view curls up to reveal the presented view underneath.
  ///On dismissal, the curled up page unfurls itself back on top of the presented view.
  ///A view controller presented using this transition is itself prevented from presenting any additional view controllers.
  static const PARTIAL_CURL = const IOSUIModalTransitionStyle._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}