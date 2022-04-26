///Class representing the [InAppWebViewHitTestResult] type.
class InAppWebViewHitTestResultType {
  final int _value;

  const InAppWebViewHitTestResultType._internal(this._value);

  ///Set of all values of [InAppWebViewHitTestResultType].
  static final Set<InAppWebViewHitTestResultType> values = [
    InAppWebViewHitTestResultType.UNKNOWN_TYPE,
    InAppWebViewHitTestResultType.PHONE_TYPE,
    InAppWebViewHitTestResultType.GEO_TYPE,
    InAppWebViewHitTestResultType.EMAIL_TYPE,
    InAppWebViewHitTestResultType.IMAGE_TYPE,
    InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.EDIT_TEXT_TYPE,
  ].toSet();

  ///Gets a possible [InAppWebViewHitTestResultType] instance from an [int] value.
  static InAppWebViewHitTestResultType? fromValue(int? value) {
    if (value != null) {
      try {
        return InAppWebViewHitTestResultType.values
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
      case 2:
        return "PHONE_TYPE";
      case 3:
        return "GEO_TYPE";
      case 4:
        return "EMAIL_TYPE";
      case 5:
        return "IMAGE_TYPE";
      case 7:
        return "SRC_ANCHOR_TYPE";
      case 8:
        return "SRC_IMAGE_ANCHOR_TYPE";
      case 9:
        return "EDIT_TEXT_TYPE";
      case 0:
      default:
        return "UNKNOWN_TYPE";
    }
  }

  ///Default [InAppWebViewHitTestResult], where the target is unknown.
  static const UNKNOWN_TYPE = const InAppWebViewHitTestResultType._internal(0);

  ///[InAppWebViewHitTestResult] for hitting a phone number.
  static const PHONE_TYPE = const InAppWebViewHitTestResultType._internal(2);

  ///[InAppWebViewHitTestResult] for hitting a map address.
  static const GEO_TYPE = const InAppWebViewHitTestResultType._internal(3);

  ///[InAppWebViewHitTestResult] for hitting an email address.
  static const EMAIL_TYPE = const InAppWebViewHitTestResultType._internal(4);

  ///[InAppWebViewHitTestResult] for hitting an HTML::img tag.
  static const IMAGE_TYPE = const InAppWebViewHitTestResultType._internal(5);

  ///[InAppWebViewHitTestResult] for hitting a HTML::a tag with src=http.
  static const SRC_ANCHOR_TYPE =
  const InAppWebViewHitTestResultType._internal(7);

  ///[InAppWebViewHitTestResult] for hitting a HTML::a tag with src=http + HTML::img.
  static const SRC_IMAGE_ANCHOR_TYPE =
  const InAppWebViewHitTestResultType._internal(8);

  ///[InAppWebViewHitTestResult] for hitting an edit text area.
  static const EDIT_TEXT_TYPE =
  const InAppWebViewHitTestResultType._internal(9);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}