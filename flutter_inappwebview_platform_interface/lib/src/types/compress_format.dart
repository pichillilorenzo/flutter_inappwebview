import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'compress_format.g.dart';

///Class that represents the known formats a bitmap can be compressed into.
@ExchangeableEnum()
class CompressFormat_ {
  // ignore: unused_field
  final String _value;
  const CompressFormat_._internal(this._value);

  ///Compress to the `PNG` format.
  ///PNG is lossless, so `quality` is ignored.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(),
      EnumIOSPlatform(),
      EnumMacOSPlatform(),
      EnumWindowsPlatform(),
    ],
  )
  static const PNG = const CompressFormat_._internal("PNG");

  ///Compress to the `JPEG` format.
  ///Quality of `0` means compress for the smallest size.
  ///`100` means compress for max visual quality.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(),
      EnumIOSPlatform(),
      EnumMacOSPlatform(),
      EnumWindowsPlatform(),
    ],
  )
  static const JPEG = const CompressFormat_._internal("JPEG");

  ///Compress to the `WEBP` lossy format.
  ///Quality of `0` means compress for the smallest size.
  ///`100` means compress for max visual quality.
  @EnumSupportedPlatforms(
    platforms: [EnumAndroidPlatform(), EnumWindowsPlatform()],
  )
  static const WEBP = const CompressFormat_._internal("WEBP");

  ///Compress to the `WEBP` lossy format.
  ///Quality of `0` means compress for the smallest size.
  ///`100` means compress for max visual quality.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(available: '30')])
  static const WEBP_LOSSY = const CompressFormat_._internal("WEBP_LOSSY");

  ///Compress to the `WEBP` lossless format.
  ///Quality refers to how much effort to put into compression.
  ///A value of `0` means to compress quickly, resulting in a relatively large file size.
  ///`100` means to spend more time compressing, resulting in a smaller file.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(available: '30')])
  static const WEBP_LOSSLESS = const CompressFormat_._internal("WEBP_LOSSLESS");
}
