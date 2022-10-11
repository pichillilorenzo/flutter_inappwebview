import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

/// Returns a matcher that matches the isNullOrEmpty property.
const Matcher isNullOrEmpty = _NullOrEmpty();

class _NullOrEmpty extends Matcher {
  const _NullOrEmpty();

  @override
  bool matches(Object? item, Map matchState) =>
      item == null || (item as dynamic).isEmpty;

  @override
  Description describe(Description description) =>
      description.add('null or empty');
}

class Foo {
  String? bar;
  String? baz;

  Foo({this.bar, this.baz});

  Map<String, dynamic> toJson() {
    return {'bar': this.bar, 'baz': this.baz};
  }
}

class MyInAppBrowser extends InAppBrowser {
  final Completer<void> browserCreated = Completer<void>();
  final Completer<void> firstPageLoaded = Completer<void>();

  MyInAppBrowser(
      {int? windowId, UnmodifiableListView<UserScript>? initialUserScripts})
      : super(windowId: windowId, initialUserScripts: initialUserScripts);

  @override
  Future onBrowserCreated() async {
    browserCreated.complete();
  }

  @override
  void onLoadStop(Uri? url) {
    super.onLoadStop(url);

    if (!firstPageLoaded.isCompleted) {
      firstPageLoaded.complete();
    }
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  final Completer<void> browserCreated = Completer<void>();
  final Completer<void> firstPageLoaded = Completer<void>();
  final Completer<void> browserClosed = Completer<void>();

  @override
  void onOpened() {
    browserCreated.complete();
  }

  @override
  void onCompletedInitialLoad() {
    firstPageLoaded.complete();
  }

  @override
  void onClosed() {
    browserClosed.complete();
  }
}
