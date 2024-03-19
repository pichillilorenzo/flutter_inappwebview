// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modal_transition_style.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to specify the transition style when presenting a view controller.
class ModalTransitionStyle {
  final int _value;
  final int _nativeValue;
  const ModalTransitionStyle._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ModalTransitionStyle._internalMultiPlatform(
          int value, Function nativeValue) =>
      ModalTransitionStyle._internal(value, nativeValue());

  ///When the view controller is presented, its view slides up from the bottom of the screen.
  ///On dismissal, the view slides back down. This is the default transition style.
  static const COVER_VERTICAL = ModalTransitionStyle._internal(0, 0);

  ///When the view controller is presented, the current view fades out while the new view fades in at the same time.
  ///On dismissal, a similar type of cross-fade is used to return to the original view.
  static const CROSS_DISSOLVE = ModalTransitionStyle._internal(2, 2);

  ///When the view controller is presented, the current view initiates a horizontal 3D flip from right-to-left,
  ///resulting in the revealing of the new view as if it were on the back of the previous view.
  ///On dismissal, the flip occurs from left-to-right, returning to the original view.
  static const FLIP_HORIZONTAL = ModalTransitionStyle._internal(1, 1);

  ///When the view controller is presented, one corner of the current view curls up to reveal the presented view underneath.
  ///On dismissal, the curled up page unfurls itself back on top of the presented view.
  ///A view controller presented using this transition is itself prevented from presenting any additional view controllers.
  static const PARTIAL_CURL = ModalTransitionStyle._internal(3, 3);

  ///Set of all values of [ModalTransitionStyle].
  static final Set<ModalTransitionStyle> values = [
    ModalTransitionStyle.COVER_VERTICAL,
    ModalTransitionStyle.CROSS_DISSOLVE,
    ModalTransitionStyle.FLIP_HORIZONTAL,
    ModalTransitionStyle.PARTIAL_CURL,
  ].toSet();

  ///Gets a possible [ModalTransitionStyle] instance from [int] value.
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

  ///Gets a possible [ModalTransitionStyle] instance from a native value.
  static ModalTransitionStyle? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ModalTransitionStyle.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 0:
        return 'COVER_VERTICAL';
      case 2:
        return 'CROSS_DISSOLVE';
      case 1:
        return 'FLIP_HORIZONTAL';
      case 3:
        return 'PARTIAL_CURL';
    }
    return _value.toString();
  }
}

///An iOS-specific class used to specify the transition style when presenting a view controller.
///Use [ModalTransitionStyle] instead.
@Deprecated('Use ModalTransitionStyle instead')
class IOSUIModalTransitionStyle {
  final int _value;
  final int _nativeValue;
  const IOSUIModalTransitionStyle._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory IOSUIModalTransitionStyle._internalMultiPlatform(
          int value, Function nativeValue) =>
      IOSUIModalTransitionStyle._internal(value, nativeValue());

  ///When the view controller is presented, its view slides up from the bottom of the screen.
  ///On dismissal, the view slides back down. This is the default transition style.
  static const COVER_VERTICAL = IOSUIModalTransitionStyle._internal(0, 0);

  ///When the view controller is presented, the current view fades out while the new view fades in at the same time.
  ///On dismissal, a similar type of cross-fade is used to return to the original view.
  static const CROSS_DISSOLVE = IOSUIModalTransitionStyle._internal(2, 2);

  ///When the view controller is presented, the current view initiates a horizontal 3D flip from right-to-left,
  ///resulting in the revealing of the new view as if it were on the back of the previous view.
  ///On dismissal, the flip occurs from left-to-right, returning to the original view.
  static const FLIP_HORIZONTAL = IOSUIModalTransitionStyle._internal(1, 1);

  ///When the view controller is presented, one corner of the current view curls up to reveal the presented view underneath.
  ///On dismissal, the curled up page unfurls itself back on top of the presented view.
  ///A view controller presented using this transition is itself prevented from presenting any additional view controllers.
  static const PARTIAL_CURL = IOSUIModalTransitionStyle._internal(3, 3);

  ///Set of all values of [IOSUIModalTransitionStyle].
  static final Set<IOSUIModalTransitionStyle> values = [
    IOSUIModalTransitionStyle.COVER_VERTICAL,
    IOSUIModalTransitionStyle.CROSS_DISSOLVE,
    IOSUIModalTransitionStyle.FLIP_HORIZONTAL,
    IOSUIModalTransitionStyle.PARTIAL_CURL,
  ].toSet();

  ///Gets a possible [IOSUIModalTransitionStyle] instance from [int] value.
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

  ///Gets a possible [IOSUIModalTransitionStyle] instance from a native value.
  static IOSUIModalTransitionStyle? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return IOSUIModalTransitionStyle.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 0:
        return 'COVER_VERTICAL';
      case 2:
        return 'CROSS_DISSOLVE';
      case 1:
        return 'FLIP_HORIZONTAL';
      case 3:
        return 'PARTIAL_CURL';
    }
    return _value.toString();
  }
}
