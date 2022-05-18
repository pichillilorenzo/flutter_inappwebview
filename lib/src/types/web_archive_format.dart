///Class that represents the known Web Archive formats used when saving a web page.
class WebArchiveFormat {
  final String _value;

  const WebArchiveFormat._internal(this._value);

  ///Set of all values of [WebArchiveFormat].
  static final Set<WebArchiveFormat> values =
  [WebArchiveFormat.MHT, WebArchiveFormat.WEBARCHIVE].toSet();

  ///Gets a possible [WebArchiveFormat] instance from a [String] value.
  static WebArchiveFormat? fromValue(String? value) {
    if (value != null) {
      try {
        return WebArchiveFormat.values
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

  ///Web Archive format used only by Android.
  static const MHT = const WebArchiveFormat._internal("mht");

  ///Web Archive format used only by iOS.
  static const WEBARCHIVE = const WebArchiveFormat._internal("webarchive");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}