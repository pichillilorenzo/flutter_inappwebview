import '../android/proxy_controller.dart';

///Class that represent scheme filters used by [ProxyController].
class ProxySchemeFilter {
  final String _value;

  const ProxySchemeFilter._internal(this._value);

  ///Set of all values of [ProxySchemeFilter].
  static final Set<ProxySchemeFilter> values = [
    ProxySchemeFilter.MATCH_ALL_SCHEMES,
    ProxySchemeFilter.MATCH_HTTP,
    ProxySchemeFilter.MATCH_HTTPS,
  ].toSet();

  ///Gets a possible [ProxySchemeFilter] instance from a [String] value.
  static ProxySchemeFilter? fromValue(String? value) {
    if (value != null) {
      try {
        return ProxySchemeFilter.values
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

  ///Matches all schemes.
  static const MATCH_ALL_SCHEMES = const ProxySchemeFilter._internal("*");

  ///HTTP scheme.
  static const MATCH_HTTP = const ProxySchemeFilter._internal("http");

  ///HTTPS scheme.
  static const MATCH_HTTPS =
  const ProxySchemeFilter._internal("https");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}