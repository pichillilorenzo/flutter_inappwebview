///Class that represents the known formats a bitmap can be compressed into.
class CompressFormat {
  final String _value;

  const CompressFormat._internal(this._value);

  ///Set of all values of [CompressFormat].
  static final Set<CompressFormat> values = [
    CompressFormat.JPEG,
    CompressFormat.PNG,
    CompressFormat.WEBP,
    CompressFormat.WEBP_LOSSY,
    CompressFormat.WEBP_LOSSLESS,
  ].toSet();

  ///Gets a possible [CompressFormat] instance from a [String] value.
  static CompressFormat? fromValue(String? value) {
    if (value != null) {
      try {
        return CompressFormat.values
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

  ///Compress to the `PNG` format.
  ///PNG is lossless, so `quality` is ignored.
  static const PNG = const CompressFormat._internal("PNG");

  ///Compress to the `JPEG` format.
  ///Quality of `0` means compress for the smallest size.
  ///`100` means compress for max visual quality.
  static const JPEG = const CompressFormat._internal("JPEG");

  ///Compress to the `WEBP` lossy format.
  ///Quality of `0` means compress for the smallest size.
  ///`100` means compress for max visual quality.
  ///
  ///**NOTE**: available only on Android.
  static const WEBP = const CompressFormat._internal("WEBP");

  ///Compress to the `WEBP` lossy format.
  ///Quality of `0` means compress for the smallest size.
  ///`100` means compress for max visual quality.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**NOTE for Android**: available on Android 30+.
  static const WEBP_LOSSY = const CompressFormat._internal("WEBP_LOSSY");

  ///Compress to the `WEBP` lossless format.
  ///Quality refers to how much effort to put into compression.
  ///A value of `0` means to compress quickly, resulting in a relatively large file size.
  ///`100` means to spend more time compressing, resulting in a smaller file.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**NOTE for Android**: available on Android 30+.
  static const WEBP_LOSSLESS = const CompressFormat._internal("WEBP_LOSSLESS");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}