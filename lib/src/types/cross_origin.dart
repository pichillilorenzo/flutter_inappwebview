import 'script_html_tag_attributes.dart';
import 'css_link_html_tag_attributes.dart';

///Class that represents the `crossorigin` content attribute on media elements, which is a CORS settings attribute.
///It could be used with [ScriptHtmlTagAttributes] and [CSSLinkHtmlTagAttributes]
///when fetching a resource `<link>` or a `<script>` (or resources fetched by the `<script>`).
class CrossOrigin {
  final String _value;

  const CrossOrigin._internal(this._value);

  ///Set of all values of [CrossOrigin].
  static final Set<CrossOrigin> values = [
    CrossOrigin.ANONYMOUS,
    CrossOrigin.USE_CREDENTIALS,
  ].toSet();

  ///Gets a possible [CrossOrigin] instance from a [String] value.
  static CrossOrigin? fromValue(String? value) {
    if (value != null) {
      try {
        return CrossOrigin.values
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

  ///CORS requests for this element will have the credentials flag set to 'same-origin'.
  static const ANONYMOUS = const CrossOrigin._internal("anonymous");

  ///CORS requests for this element will have the credentials flag set to 'include'.
  static const USE_CREDENTIALS = const CrossOrigin._internal("use-credentials");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}