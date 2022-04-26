import '../in_app_webview/webview.dart';

///Class used to configure the [WebView]'s over-scroll mode.
///Setting the over-scroll mode of a WebView will have an effect only if the [WebView] is capable of scrolling.
class OverScrollMode {
  final int _value;

  const OverScrollMode._internal(this._value);

  ///Set of all values of [OverScrollMode].
  static final Set<OverScrollMode> values = [
    OverScrollMode.OVER_SCROLL_ALWAYS,
    OverScrollMode.OVER_SCROLL_IF_CONTENT_SCROLLS,
    OverScrollMode.OVER_SCROLL_NEVER,
  ].toSet();

  ///Gets a possible [OverScrollMode] instance from an [int] value.
  static OverScrollMode? fromValue(int? value) {
    if (value != null) {
      try {
        return OverScrollMode.values
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
        return "OVER_SCROLL_IF_CONTENT_SCROLLS";
      case 2:
        return "OVER_SCROLL_NEVER";
      case 0:
      default:
        return "OVER_SCROLL_ALWAYS";
    }
  }

  ///Always allow a user to over-scroll this view, provided it is a view that can scroll.
  static const OVER_SCROLL_ALWAYS = const OverScrollMode._internal(0);

  ///Allow a user to over-scroll this view only if the content is large enough to meaningfully scroll, provided it is a view that can scroll.
  static const OVER_SCROLL_IF_CONTENT_SCROLLS =
  const OverScrollMode._internal(1);

  ///Never allow a user to over-scroll this view.
  static const OVER_SCROLL_NEVER = const OverScrollMode._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An Android-specific class used to configure the [WebView]'s over-scroll mode.
///Setting the over-scroll mode of a WebView will have an effect only if the [WebView] is capable of scrolling.
///Use [OverScrollMode] instead.
@Deprecated("Use OverScrollMode instead")
class AndroidOverScrollMode {
  final int _value;

  const AndroidOverScrollMode._internal(this._value);

  ///Set of all values of [AndroidOverScrollMode].
  static final Set<AndroidOverScrollMode> values = [
    AndroidOverScrollMode.OVER_SCROLL_ALWAYS,
    AndroidOverScrollMode.OVER_SCROLL_IF_CONTENT_SCROLLS,
    AndroidOverScrollMode.OVER_SCROLL_NEVER,
  ].toSet();

  ///Gets a possible [AndroidOverScrollMode] instance from an [int] value.
  static AndroidOverScrollMode? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidOverScrollMode.values
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
        return "OVER_SCROLL_IF_CONTENT_SCROLLS";
      case 2:
        return "OVER_SCROLL_NEVER";
      case 0:
      default:
        return "OVER_SCROLL_ALWAYS";
    }
  }

  ///Always allow a user to over-scroll this view, provided it is a view that can scroll.
  static const OVER_SCROLL_ALWAYS = const AndroidOverScrollMode._internal(0);

  ///Allow a user to over-scroll this view only if the content is large enough to meaningfully scroll, provided it is a view that can scroll.
  static const OVER_SCROLL_IF_CONTENT_SCROLLS =
  const AndroidOverScrollMode._internal(1);

  ///Never allow a user to over-scroll this view.
  static const OVER_SCROLL_NEVER = const AndroidOverScrollMode._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}