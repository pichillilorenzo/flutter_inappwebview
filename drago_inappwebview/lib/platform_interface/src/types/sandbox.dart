import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

part 'sandbox.g.dart';

///Class that describes what to allow in the iframe.
@ExchangeableEnum()
class Sandbox_ {
  final String? _value;
  const Sandbox_._internal(this._value);

  ///Gets a possible [Sandbox] instance from a native value.
  static Sandbox? fromNativeValue(String? value) {
    if (value == null) {
      return Sandbox._ALL;
    } else if (value == "") {
      return Sandbox._NONE;
    }
    try {
      return Sandbox.values.firstWhere(
        (element) => element.toNativeValue() == value,
      );
    } catch (e) {
      return null;
    }
  }

  ///Gets a possible [Sandbox] instance from a [String] value.
  static Sandbox? fromValue(String? value) {
    if (value == null) {
      return Sandbox._ALL;
    } else if (value == "") {
      return Sandbox._NONE;
    }
    try {
      return Sandbox.values.firstWhere((element) => element.toValue() == value);
    } catch (e) {
      return null;
    }
  }

  ///Gets [String] value.
  String? toValue() => _value;

  @override
  String toString() {
    if (_value == null) return 'allow-all';
    if (_value == '') return 'allow-none';
    return _value ?? '';
  }

  static const _ALL = Sandbox_._internal(null);
  static const _NONE = Sandbox_._internal("");

  ///Allow all.
  @ExchangeableEnumCustomValue()
  static const ALLOW_ALL = [_ALL];

  ///Allow none.
  @ExchangeableEnumCustomValue()
  static const ALLOW_NONE = [_NONE];

  ///Allows for downloads to occur with a gesture from the user.
  static const ALLOW_DOWNLOADS = Sandbox_._internal("allow-downloads");

  ///Allows the resource to submit forms. If this keyword is not used, form submission is blocked.
  static const ALLOW_FORMS = Sandbox_._internal("allow-forms");

  ///Lets the resource open modal windows.
  static const ALLOW_MODALS = Sandbox_._internal("allow-modals");

  ///Lets the resource lock the screen orientation.
  static const ALLOW_ORIENTATION_LOCK = Sandbox_._internal(
    "allow-orientation-lock",
  );

  ///Lets the resource use the Pointer Lock API.
  static const ALLOW_POINTER_LOCK = Sandbox_._internal(
    "allow-pointer-lock",
  );

  ///Allows popups (such as `window.open()`, `target="_blank"`, or `showModalDialog()`).
  ///If this keyword is not used, the popup will silently fail to open.
  static const ALLOW_POPUPS = Sandbox_._internal("allow-popups");

  ///Lets the sandboxed document open new windows without those windows inheriting the sandboxing.
  ///For example, this can safely sandbox an advertisement without forcing the same restrictions upon the page the ad links to.
  static const ALLOW_POPUPS_TO_ESCAPE_SANDBOX = Sandbox_._internal(
    "allow-popups-to-escape-sandbox",
  );

  ///Lets the resource start a presentation session.
  static const ALLOW_PRESENTATION = Sandbox_._internal(
    "allow-presentation",
  );

  ///If this token is not used, the resource is treated as being from a special origin that always fails the
  ///same-origin policy (potentially preventing access to data storage/cookies and some JavaScript APIs).
  static const ALLOW_SAME_ORIGIN = Sandbox_._internal(
    "allow-same-origin",
  );

  ///Lets the resource run scripts (but not create popup windows).
  static const ALLOW_SCRIPTS = Sandbox_._internal("allow-scripts");

  ///Lets the resource navigate the top-level browsing context (the one named `_top`).
  static const ALLOW_TOP_NAVIGATION = Sandbox_._internal(
    "allow-top-navigation",
  );

  ///Lets the resource navigate the top-level browsing context, but only if initiated by a user gesture.
  static const ALLOW_TOP_NAVIGATION_BY_USER_ACTIVATION =
      Sandbox_._internal("allow-top-navigation-by-user-activation");
}
