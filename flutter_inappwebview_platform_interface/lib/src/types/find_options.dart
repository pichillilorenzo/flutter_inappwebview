import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';

part 'find_options.g.dart';

///Class that represents find options for find-on-page operations.
@ExchangeableObject()
class FindOptions_ {
  ///The text to find.
  String? findTerm;

  ///Whether to match case.
  bool? shouldMatchCase;

  ///Whether to match whole word only.
  bool? shouldMatchWord;

  ///Whether to highlight all matches.
  bool? shouldHighlightAllMatches;

  ///Whether to suppress the default find dialog.
  bool? suppressDefaultFindDialog;

  FindOptions_({
    this.findTerm,
    this.shouldMatchCase,
    this.shouldMatchWord,
    this.shouldHighlightAllMatches,
    this.suppressDefaultFindDialog,
  });
}
