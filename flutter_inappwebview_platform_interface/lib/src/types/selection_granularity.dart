import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'selection_granularity.g.dart';

///Class used to set the level of granularity with which the user can interactively select content in the web view.
@ExchangeableEnum()
class SelectionGranularity_ {
  // ignore: unused_field
  final int _value;
  const SelectionGranularity_._internal(this._value);

  ///Selection granularity varies automatically based on the selection.
  static const DYNAMIC = const SelectionGranularity_._internal(0);

  ///Selection endpoints can be placed at any character boundary.
  static const CHARACTER = const SelectionGranularity_._internal(1);
}

///An iOS-specific class used to set the level of granularity with which the user can interactively select content in the web view.
///Use [SelectionGranularity] instead.
@Deprecated("Use SelectionGranularity instead")
@ExchangeableEnum()
class IOSWKSelectionGranularity_ {
  // ignore: unused_field
  final int _value;
  const IOSWKSelectionGranularity_._internal(this._value);

  ///Selection granularity varies automatically based on the selection.
  static const DYNAMIC = const IOSWKSelectionGranularity_._internal(0);

  ///Selection endpoints can be placed at any character boundary.
  static const CHARACTER = const IOSWKSelectionGranularity_._internal(1);
}
