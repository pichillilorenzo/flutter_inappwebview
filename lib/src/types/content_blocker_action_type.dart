import '../content_blocker.dart';

///Class that represents the kind of action that can be used with a [ContentBlockerTrigger].
class ContentBlockerActionType {
  final String _value;

  const ContentBlockerActionType._internal(this._value);

  ///Set of all values of [ContentBlockerActionType].
  static final Set<ContentBlockerActionType> values = [
    ContentBlockerActionType.BLOCK,
    ContentBlockerActionType.CSS_DISPLAY_NONE,
    ContentBlockerActionType.MAKE_HTTPS,
  ].toSet();

  ///Gets a possible [ContentBlockerActionType] instance from a [String] value.
  static ContentBlockerActionType? fromValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerActionType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  @override
  String toString() => _value;

  ///Stops loading of the resource. If the resource was cached, the cache is ignored.
  static const BLOCK = const ContentBlockerActionType._internal('block');

  ///Hides elements of the page based on a CSS selector. A selector field contains the selector list. Any matching element has its display property set to none, which hides it.
  ///
  ///**NOTE**: on Android, JavaScript must be enabled.
  static const CSS_DISPLAY_NONE =
  const ContentBlockerActionType._internal('css-display-none');

  ///Changes a URL from http to https. URLs with a specified (nondefault) port and links using other protocols are unaffected.
  static const MAKE_HTTPS =
  const ContentBlockerActionType._internal('make-https');

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}