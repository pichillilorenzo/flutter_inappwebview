///Class that represents the error code for a web authentication session error.
class WebAuthenticationSessionError {
  final int _value;

  const WebAuthenticationSessionError._internal(this._value);

  ///Set of all values of [WebAuthenticationSessionError].
  static final Set<WebAuthenticationSessionError> values = [
    WebAuthenticationSessionError.CANCELED_LOGIN,
    WebAuthenticationSessionError.PRESENTATION_CONTEXT_NOT_PROVIDED,
    WebAuthenticationSessionError.PRESENTATION_CONTEXT_INVALID
  ].toSet();

  ///Gets a possible [WebAuthenticationSessionError] instance from an [int] value.
  static WebAuthenticationSessionError? fromValue(int? value) {
    if (value != null) {
      try {
        return WebAuthenticationSessionError.values
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
      case 1:
        return "CANCELED_LOGIN";
      case 2:
        return "PRESENTATION_CONTEXT_NOT_PROVIDED";
      case 3:
        return "PRESENTATION_CONTEXT_INVALID";
      default:
        return "UNKNOWN";
    }
  }

  ///The login has been canceled.
  static final CANCELED_LOGIN = WebAuthenticationSessionError._internal(1);

  ///A context wasn’t provided.
  static final PRESENTATION_CONTEXT_NOT_PROVIDED = WebAuthenticationSessionError._internal(2);

  ///The context was invalid.
  static final PRESENTATION_CONTEXT_INVALID = WebAuthenticationSessionError._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}
