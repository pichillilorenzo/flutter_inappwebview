import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

part 'pull_to_refresh_size.g.dart';

///Class representing the size of the refresh indicator.
@ExchangeableEnum()
class PullToRefreshSize_ {
  // ignore: unused_field
  final int _value;
  const PullToRefreshSize_._internal(this._value);

  ///Default size.
  static const DEFAULT = PullToRefreshSize_._internal(1);

  ///Large size.
  static const LARGE = PullToRefreshSize_._internal(0);
}

///Android-specific class representing the size of the refresh indicator.
///Use [PullToRefreshSize] instead.
@Deprecated("Use PullToRefreshSize instead")
@ExchangeableEnum()
class AndroidPullToRefreshSize_ {
  // ignore: unused_field
  final int _value;
  const AndroidPullToRefreshSize_._internal(this._value);

  ///Default size.
  static const DEFAULT = AndroidPullToRefreshSize_._internal(1);

  ///Large size.
  static const LARGE = AndroidPullToRefreshSize_._internal(0);
}
