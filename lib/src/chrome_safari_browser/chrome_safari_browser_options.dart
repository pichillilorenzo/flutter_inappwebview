import 'package:flutter/foundation.dart';

import 'android/chrome_custom_tabs_options.dart';
import 'ios/safari_options.dart';

class ChromeSafariBrowserOptions {
  Map<String, dynamic> toMap() {
    return {};
  }

  static ChromeSafariBrowserOptions fromMap(Map<String, dynamic> map) {
    return new ChromeSafariBrowserOptions();
  }

  ChromeSafariBrowserOptions copy() {
    return ChromeSafariBrowserOptions.fromMap(this.toMap());
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the options that can be used for an [ChromeSafariBrowser] window.
class ChromeSafariBrowserClassOptions {
  ///Android-specific options.
  AndroidChromeCustomTabsOptions? android;

  ///iOS-specific options.
  IOSSafariOptions? ios;

  ChromeSafariBrowserClassOptions({this.android, this.ios}) {
    this.android = this.android ?? AndroidChromeCustomTabsOptions();
    this.ios = this.ios ?? IOSSafariOptions();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> options = {};
    if (defaultTargetPlatform == TargetPlatform.android)
      options.addAll(this.android?.toMap() ?? {});
    else if (defaultTargetPlatform == TargetPlatform.iOS)
      options.addAll(this.ios?.toMap() ?? {});

    return options;
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
