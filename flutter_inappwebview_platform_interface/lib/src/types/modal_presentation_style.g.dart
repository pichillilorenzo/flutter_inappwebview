// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modal_presentation_style.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to specify the modal presentation style when presenting a view controller.
class ModalPresentationStyle {
  final int _value;
  final int _nativeValue;
  const ModalPresentationStyle._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ModalPresentationStyle._internalMultiPlatform(
          int value, Function nativeValue) =>
      ModalPresentationStyle._internal(value, nativeValue());

  ///The default presentation style chosen by the system.
  ///
  ///**NOTE**: available on iOS 13.0+.
  static const AUTOMATIC = ModalPresentationStyle._internal(9, 9);

  ///A presentation style where the content is displayed over another view controller’s content.
  static const CURRENT_CONTEXT = ModalPresentationStyle._internal(3, 3);

  ///A custom view presentation style that is managed by a custom presentation controller and one or more custom animator objects.
  static const CUSTOM = ModalPresentationStyle._internal(4, 4);

  ///A presentation style that displays the content centered in the screen.
  static const FORM_SHEET = ModalPresentationStyle._internal(2, 2);

  ///A presentation style in which the presented view covers the screen.
  static const FULL_SCREEN = ModalPresentationStyle._internal(0, 0);

  ///A presentation style that indicates no adaptations should be made.
  static const NONE = ModalPresentationStyle._internal(8, 8);

  ///A presentation style where the content is displayed over another view controller’s content.
  static const OVER_CURRENT_CONTEXT = ModalPresentationStyle._internal(6, 6);

  ///A view presentation style in which the presented view covers the screen.
  static const OVER_FULL_SCREEN = ModalPresentationStyle._internal(5, 5);

  ///A presentation style that partially covers the underlying content.
  static const PAGE_SHEET = ModalPresentationStyle._internal(1, 1);

  ///A presentation style where the content is displayed in a popover view.
  static const POPOVER = ModalPresentationStyle._internal(7, 7);

  ///Set of all values of [ModalPresentationStyle].
  static final Set<ModalPresentationStyle> values = [
    ModalPresentationStyle.AUTOMATIC,
    ModalPresentationStyle.CURRENT_CONTEXT,
    ModalPresentationStyle.CUSTOM,
    ModalPresentationStyle.FORM_SHEET,
    ModalPresentationStyle.FULL_SCREEN,
    ModalPresentationStyle.NONE,
    ModalPresentationStyle.OVER_CURRENT_CONTEXT,
    ModalPresentationStyle.OVER_FULL_SCREEN,
    ModalPresentationStyle.PAGE_SHEET,
    ModalPresentationStyle.POPOVER,
  ].toSet();

  ///Gets a possible [ModalPresentationStyle] instance from [int] value.
  static ModalPresentationStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return ModalPresentationStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ModalPresentationStyle] instance from a native value.
  static ModalPresentationStyle? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ModalPresentationStyle.values
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
      case 9:
        return 'AUTOMATIC';
      case 3:
        return 'CURRENT_CONTEXT';
      case 4:
        return 'CUSTOM';
      case 2:
        return 'FORM_SHEET';
      case 0:
        return 'FULL_SCREEN';
      case 8:
        return 'NONE';
      case 6:
        return 'OVER_CURRENT_CONTEXT';
      case 5:
        return 'OVER_FULL_SCREEN';
      case 1:
        return 'PAGE_SHEET';
      case 7:
        return 'POPOVER';
    }
    return _value.toString();
  }
}

///An iOS-specific class used to specify the modal presentation style when presenting a view controller.
///Use [ModalPresentationStyle] instead.
@Deprecated('Use ModalPresentationStyle instead')
class IOSUIModalPresentationStyle {
  final int _value;
  final int _nativeValue;
  const IOSUIModalPresentationStyle._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory IOSUIModalPresentationStyle._internalMultiPlatform(
          int value, Function nativeValue) =>
      IOSUIModalPresentationStyle._internal(value, nativeValue());

  ///The default presentation style chosen by the system.
  ///
  ///**NOTE**: available on iOS 13.0+.
  static const AUTOMATIC = IOSUIModalPresentationStyle._internal(9, 9);

  ///A presentation style where the content is displayed over another view controller’s content.
  static const CURRENT_CONTEXT = IOSUIModalPresentationStyle._internal(3, 3);

  ///A custom view presentation style that is managed by a custom presentation controller and one or more custom animator objects.
  static const CUSTOM = IOSUIModalPresentationStyle._internal(4, 4);

  ///A presentation style that displays the content centered in the screen.
  static const FORM_SHEET = IOSUIModalPresentationStyle._internal(2, 2);

  ///A presentation style in which the presented view covers the screen.
  static const FULL_SCREEN = IOSUIModalPresentationStyle._internal(0, 0);

  ///A presentation style that indicates no adaptations should be made.
  static const NONE = IOSUIModalPresentationStyle._internal(8, 8);

  ///A presentation style where the content is displayed over another view controller’s content.
  static const OVER_CURRENT_CONTEXT =
      IOSUIModalPresentationStyle._internal(6, 6);

  ///A view presentation style in which the presented view covers the screen.
  static const OVER_FULL_SCREEN = IOSUIModalPresentationStyle._internal(5, 5);

  ///A presentation style that partially covers the underlying content.
  static const PAGE_SHEET = IOSUIModalPresentationStyle._internal(1, 1);

  ///A presentation style where the content is displayed in a popover view.
  static const POPOVER = IOSUIModalPresentationStyle._internal(7, 7);

  ///Set of all values of [IOSUIModalPresentationStyle].
  static final Set<IOSUIModalPresentationStyle> values = [
    IOSUIModalPresentationStyle.AUTOMATIC,
    IOSUIModalPresentationStyle.CURRENT_CONTEXT,
    IOSUIModalPresentationStyle.CUSTOM,
    IOSUIModalPresentationStyle.FORM_SHEET,
    IOSUIModalPresentationStyle.FULL_SCREEN,
    IOSUIModalPresentationStyle.NONE,
    IOSUIModalPresentationStyle.OVER_CURRENT_CONTEXT,
    IOSUIModalPresentationStyle.OVER_FULL_SCREEN,
    IOSUIModalPresentationStyle.PAGE_SHEET,
    IOSUIModalPresentationStyle.POPOVER,
  ].toSet();

  ///Gets a possible [IOSUIModalPresentationStyle] instance from [int] value.
  static IOSUIModalPresentationStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSUIModalPresentationStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [IOSUIModalPresentationStyle] instance from a native value.
  static IOSUIModalPresentationStyle? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return IOSUIModalPresentationStyle.values
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
      case 9:
        return 'AUTOMATIC';
      case 3:
        return 'CURRENT_CONTEXT';
      case 4:
        return 'CUSTOM';
      case 2:
        return 'FORM_SHEET';
      case 0:
        return 'FULL_SCREEN';
      case 8:
        return 'NONE';
      case 6:
        return 'OVER_CURRENT_CONTEXT';
      case 5:
        return 'OVER_FULL_SCREEN';
      case 1:
        return 'PAGE_SHEET';
      case 7:
        return 'POPOVER';
    }
    return _value.toString();
  }
}
