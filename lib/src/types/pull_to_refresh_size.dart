///Class representing the size of the refresh indicator.
class PullToRefreshSize {
  final int _value;

  const PullToRefreshSize._internal(this._value);

  ///Set of all values of [PullToRefreshSize].
  static final Set<PullToRefreshSize> values = [
    PullToRefreshSize.DEFAULT,
    PullToRefreshSize.LARGE,
  ].toSet();

  ///Gets a possible [PullToRefreshSize] instance from an [int] value.
  static PullToRefreshSize? fromValue(int? value) {
    if (value != null) {
      try {
        return PullToRefreshSize.values
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
      case 0:
        return "LARGE";
      case 1:
      default:
        return "DEFAULT";
    }
  }

  ///Default size.
  static const DEFAULT = const PullToRefreshSize._internal(1);

  ///Large size.
  static const LARGE = const PullToRefreshSize._internal(0);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Android-specific class representing the size of the refresh indicator.
///Use [PullToRefreshSize] instead.
@Deprecated("Use PullToRefreshSize instead")
class AndroidPullToRefreshSize {
  final int _value;

  const AndroidPullToRefreshSize._internal(this._value);

  ///Set of all values of [AndroidPullToRefreshSize].
  static final Set<AndroidPullToRefreshSize> values = [
    AndroidPullToRefreshSize.DEFAULT,
    AndroidPullToRefreshSize.LARGE,
  ].toSet();

  ///Gets a possible [AndroidPullToRefreshSize] instance from an [int] value.
  static AndroidPullToRefreshSize? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidPullToRefreshSize.values
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
      case 0:
        return "LARGE";
      case 1:
      default:
        return "DEFAULT";
    }
  }

  ///Default size.
  static const DEFAULT = const AndroidPullToRefreshSize._internal(1);

  ///Large size.
  static const LARGE = const AndroidPullToRefreshSize._internal(0);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}