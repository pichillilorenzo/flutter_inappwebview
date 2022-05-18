import '../web_storage/web_storage.dart';

///Class that represents the type of Web Storage: `localStorage` or `sessionStorage`.
///Used by the [Storage] class.
class WebStorageType {
  final String _value;

  const WebStorageType._internal(this._value);

  ///Set of all values of [WebStorageType].
  static final Set<WebStorageType> values = [
    WebStorageType.LOCAL_STORAGE,
    WebStorageType.SESSION_STORAGE,
  ].toSet();

  ///Gets a possible [WebStorageType] instance from a [String] value.
  static WebStorageType? fromValue(String? value) {
    if (value != null) {
      try {
        return WebStorageType.values
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

  ///`window.localStorage`: same as [SESSION_STORAGE], but persists even when the browser is closed and reopened.
  static const LOCAL_STORAGE = const WebStorageType._internal("localStorage");

  ///`window.sessionStorage`: maintains a separate storage area for each given origin that's available for the duration
  ///of the page session (as long as the browser is open, including page reloads and restores).
  static const SESSION_STORAGE =
  const WebStorageType._internal("sessionStorage");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}