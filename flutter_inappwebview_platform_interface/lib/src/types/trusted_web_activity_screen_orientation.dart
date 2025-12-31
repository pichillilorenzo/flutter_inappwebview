import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'trusted_web_activity_screen_orientation.g.dart';

///Class representing Screen Orientation Lock type value of a Trusted Web Activity:
///https://www.w3.org/TR/screen-orientation/#screenorientation-interface
@ExchangeableEnum()
class TrustedWebActivityScreenOrientation_ {
  // ignore: unused_field
  final int _value;
  const TrustedWebActivityScreenOrientation_._internal(this._value);

  /// The default screen orientation is the set of orientations to which the screen is locked when
  /// there is no current orientation lock.
  static const DEFAULT = const TrustedWebActivityScreenOrientation_._internal(
    0,
  );

  ///  Portrait-primary is an orientation where the screen width is less than or equal to the
  ///  screen height. If the device's natural orientation is portrait, then it is in
  ///  portrait-primary when held in that position.
  static const PORTRAIT_PRIMARY =
      const TrustedWebActivityScreenOrientation_._internal(1);

  /// Portrait-secondary is an orientation where the screen width is less than or equal to the
  /// screen height. If the device's natural orientation is portrait, then it is in
  /// portrait-secondary when rotated 180° from its natural position.
  static const PORTRAIT_SECONDARY =
      const TrustedWebActivityScreenOrientation_._internal(2);

  /// Landscape-primary is an orientation where the screen width is greater than the screen height.
  /// If the device's natural orientation is landscape, then it is in landscape-primary when held
  /// in that position.
  static const LANDSCAPE_PRIMARY =
      const TrustedWebActivityScreenOrientation_._internal(3);

  /// Landscape-secondary is an orientation where the screen width is greater than the
  /// screen height. If the device's natural orientation is landscape, it is in
  /// landscape-secondary when rotated 180° from its natural orientation.
  static const LANDSCAPE_SECONDARY =
      const TrustedWebActivityScreenOrientation_._internal(4);

  /// Any is an orientation that means the screen can be locked to any one of portrait-primary,
  /// portrait-secondary, landscape-primary and landscape-secondary.
  static const ANY = const TrustedWebActivityScreenOrientation_._internal(5);

  /// Landscape is an orientation where the screen width is greater than the screen height and
  /// depending on platform convention locking the screen to landscape can represent
  /// landscape-primary, landscape-secondary or both.
  static const LANDSCAPE = const TrustedWebActivityScreenOrientation_._internal(
    6,
  );

  /// Portrait is an orientation where the screen width is less than or equal to the screen height
  /// and depending on platform convention locking the screen to portrait can represent
  /// portrait-primary, portrait-secondary or both.
  static const PORTRAIT = const TrustedWebActivityScreenOrientation_._internal(
    7,
  );

  /// Natural is an orientation that refers to either portrait-primary or landscape-primary
  /// depending on the device's usual orientation. This orientation is usually provided by
  /// the underlying operating system.
  static const NATURAL = const TrustedWebActivityScreenOrientation_._internal(
    8,
  );
}
