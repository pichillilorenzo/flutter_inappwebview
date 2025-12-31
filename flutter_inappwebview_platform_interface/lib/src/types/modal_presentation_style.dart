import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'modal_presentation_style.g.dart';

///Class used to specify the modal presentation style when presenting a view controller.
@ExchangeableEnum()
class ModalPresentationStyle_ {
  // ignore: unused_field
  final int _value;
  const ModalPresentationStyle_._internal(this._value);

  ///A presentation style in which the presented view covers the screen.
  static const FULL_SCREEN = const ModalPresentationStyle_._internal(0);

  ///A presentation style that partially covers the underlying content.
  static const PAGE_SHEET = const ModalPresentationStyle_._internal(1);

  ///A presentation style that displays the content centered in the screen.
  static const FORM_SHEET = const ModalPresentationStyle_._internal(2);

  ///A presentation style where the content is displayed over another view controller’s content.
  static const CURRENT_CONTEXT = const ModalPresentationStyle_._internal(3);

  ///A custom view presentation style that is managed by a custom presentation controller and one or more custom animator objects.
  static const CUSTOM = const ModalPresentationStyle_._internal(4);

  ///A view presentation style in which the presented view covers the screen.
  static const OVER_FULL_SCREEN = const ModalPresentationStyle_._internal(5);

  ///A presentation style where the content is displayed over another view controller’s content.
  static const OVER_CURRENT_CONTEXT = const ModalPresentationStyle_._internal(
    6,
  );

  ///A presentation style where the content is displayed in a popover view.
  static const POPOVER = const ModalPresentationStyle_._internal(7);

  ///A presentation style that indicates no adaptations should be made.
  static const NONE = const ModalPresentationStyle_._internal(8);

  ///The default presentation style chosen by the system.
  ///
  ///**NOTE**: available on iOS 13.0+.
  static const AUTOMATIC = const ModalPresentationStyle_._internal(9);
}

///An iOS-specific class used to specify the modal presentation style when presenting a view controller.
///Use [ModalPresentationStyle] instead.
@Deprecated("Use ModalPresentationStyle instead")
@ExchangeableEnum()
class IOSUIModalPresentationStyle_ {
  // ignore: unused_field
  final int _value;
  const IOSUIModalPresentationStyle_._internal(this._value);

  ///A presentation style in which the presented view covers the screen.
  static const FULL_SCREEN = const IOSUIModalPresentationStyle_._internal(0);

  ///A presentation style that partially covers the underlying content.
  static const PAGE_SHEET = const IOSUIModalPresentationStyle_._internal(1);

  ///A presentation style that displays the content centered in the screen.
  static const FORM_SHEET = const IOSUIModalPresentationStyle_._internal(2);

  ///A presentation style where the content is displayed over another view controller’s content.
  static const CURRENT_CONTEXT = const IOSUIModalPresentationStyle_._internal(
    3,
  );

  ///A custom view presentation style that is managed by a custom presentation controller and one or more custom animator objects.
  static const CUSTOM = const IOSUIModalPresentationStyle_._internal(4);

  ///A view presentation style in which the presented view covers the screen.
  static const OVER_FULL_SCREEN = const IOSUIModalPresentationStyle_._internal(
    5,
  );

  ///A presentation style where the content is displayed over another view controller’s content.
  static const OVER_CURRENT_CONTEXT =
      const IOSUIModalPresentationStyle_._internal(6);

  ///A presentation style where the content is displayed in a popover view.
  static const POPOVER = const IOSUIModalPresentationStyle_._internal(7);

  ///A presentation style that indicates no adaptations should be made.
  static const NONE = const IOSUIModalPresentationStyle_._internal(8);

  ///The default presentation style chosen by the system.
  ///
  ///**NOTE**: available on iOS 13.0+.
  static const AUTOMATIC = const IOSUIModalPresentationStyle_._internal(9);
}
