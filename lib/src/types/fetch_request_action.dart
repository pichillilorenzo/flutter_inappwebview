import 'fetch_request.dart';

///Class used by [FetchRequest] class.
class FetchRequestAction {
  final int _value;

  const FetchRequestAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Aborts the fetch request.
  static const ABORT = const FetchRequestAction._internal(0);

  ///Proceeds with the fetch request.
  static const PROCEED = const FetchRequestAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}