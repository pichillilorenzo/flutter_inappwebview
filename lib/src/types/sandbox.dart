///Class that describes what to allow in the iframe.
class Sandbox {
  final String? _value;

  const Sandbox._internal(this._value);

  ///Set of all values of [Sandbox].
  static final Set<Sandbox> values = [
    Sandbox.ALLOW_DOWNLOADS,
    Sandbox.ALLOW_FORMS,
    Sandbox.ALLOW_MODALS,
    Sandbox.ALLOW_ORIENTATION_LOCK,
    Sandbox.ALLOW_POINTER_LOCK,
    Sandbox.ALLOW_POPUPS,
    Sandbox.ALLOW_POPUPS_TO_ESCAPE_SANDBOX,
    Sandbox.ALLOW_PRESENTATION,
    Sandbox.ALLOW_SAME_ORIGIN,
    Sandbox.ALLOW_SCRIPTS,
    Sandbox.ALLOW_TOP_NAVIGATION,
    Sandbox.ALLOW_TOP_NAVIGATION_BY_USER_ACTIVATION,
  ].toSet();

  ///Gets a possible [Sandbox] instance from a [String] value.
  static Sandbox? fromValue(String? value) {
    if (value == null) {
      return _ALL;
    } else if (value == "") {
      return _NONE;
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
  String toString() =>
      _value == null ? "allow-all" : (_value == "" ? "allow-none" : "");

  static const _ALL = const Sandbox._internal(null);
  static const _NONE = const Sandbox._internal("");

  ///Allow all.
  static const ALLOW_ALL = const [_ALL];

  ///Allow none.
  static const ALLOW_NONE = const [_NONE];

  ///Allows for downloads to occur with a gesture from the user.
  static const ALLOW_DOWNLOADS = const Sandbox._internal("allow-downloads");

  ///Allows the resource to submit forms. If this keyword is not used, form submission is blocked.
  static const ALLOW_FORMS = const Sandbox._internal("allow-forms");

  ///Lets the resource open modal windows.
  static const ALLOW_MODALS = const Sandbox._internal("allow-modals");

  ///Lets the resource lock the screen orientation.
  static const ALLOW_ORIENTATION_LOCK =
  const Sandbox._internal("allow-orientation-lock");

  ///Lets the resource use the Pointer Lock API.
  static const ALLOW_POINTER_LOCK =
  const Sandbox._internal("allow-pointer-lock");

  ///Allows popups (such as `window.open()`, `target="_blank"`, or `showModalDialog()`).
  ///If this keyword is not used, the popup will silently fail to open.
  static const ALLOW_POPUPS = const Sandbox._internal("allow-popups");

  ///Lets the sandboxed document open new windows without those windows inheriting the sandboxing.
  ///For example, this can safely sandbox an advertisement without forcing the same restrictions upon the page the ad links to.
  static const ALLOW_POPUPS_TO_ESCAPE_SANDBOX =
  const Sandbox._internal("allow-popups-to-escape-sandbox");

  ///Lets the resource start a presentation session.
  static const ALLOW_PRESENTATION =
  const Sandbox._internal("allow-presentation");

  ///If this token is not used, the resource is treated as being from a special origin that always fails the
  ///same-origin policy (potentially preventing access to data storage/cookies and some JavaScript APIs).
  static const ALLOW_SAME_ORIGIN = const Sandbox._internal("allow-same-origin");

  ///Lets the resource run scripts (but not create popup windows).
  static const ALLOW_SCRIPTS = const Sandbox._internal("allow-scripts");

  ///Lets the resource navigate the top-level browsing context (the one named `_top`).
  static const ALLOW_TOP_NAVIGATION =
  const Sandbox._internal("allow-top-navigation");

  ///Lets the resource navigate the top-level browsing context, but only if initiated by a user gesture.
  static const ALLOW_TOP_NAVIGATION_BY_USER_ACTIVATION =
  const Sandbox._internal("allow-top-navigation-by-user-activation");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}