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

void skippableGroup(Object description, void Function() body,
    {bool skip = false}) {
  if (!skip) {
    group(description.toString(), body, skip: skip);
  }
}

void skippableTest(
  Object description,
  dynamic Function() body, {
  String? testOn,
  Timeout? timeout = const Timeout(Duration(seconds: 60)),
  bool skip = false,
  dynamic tags,
  Map<String, dynamic>? onPlatform,
  int? retry,
}) {
  if (!skip) {
    test(
      description.toString(),
      body,
      testOn: testOn,
      timeout: timeout,
      skip: skip,
      onPlatform: onPlatform,
      tags: tags,
      retry: retry,
    );
  }
}

void skippableTestWidgets(
  String description,
  WidgetTesterCallback callback, {
  bool skip = false,
  Timeout? timeout = const Timeout(Duration(seconds: 60)),
  bool semanticsEnabled = true,
  TestVariant<Object?> variant = const DefaultTestVariant(),
  dynamic tags,
}) {
  if (!skip) {
    testWidgets(description, callback,
        skip: skip,
        timeout: timeout,
        semanticsEnabled: semanticsEnabled,
        variant: variant,
        tags: tags);
  }
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
  final Completer<void> browserClosed = Completer<void>();

  MyInAppBrowser(
      {int? windowId, UnmodifiableListView<UserScript>? initialUserScripts})
      : super(windowId: windowId, initialUserScripts: initialUserScripts);

  @override
  Future onBrowserCreated() async {
    browserCreated.complete();
  }

  @override
  void onLoadStop(WebUri? url) {
    super.onLoadStop(url);

    if (!firstPageLoaded.isCompleted) {
      firstPageLoaded.complete();
    }
  }

  @override
  void onExit() {
    if (!browserClosed.isCompleted) {
      browserClosed.complete();
    }
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  final Completer<void> serviceConnected = Completer<void>();
  final Completer<void> opened = Completer<void>();
  final Completer<bool?> firstPageLoaded = Completer<bool?>();
  final Completer<void> closed = Completer<void>();
  final Completer<CustomTabsNavigationEventType?> navigationEvent =
      Completer<CustomTabsNavigationEventType?>();
  final Completer<void> navigationFinished = Completer<void>();
  final Completer<void> messageChannelReady = Completer<void>();
  final Completer<String> postMessageReceived = Completer<String>();
  final Completer<bool> relationshipValidationResult = Completer<bool>();

  @override
  void onServiceConnected() {
    serviceConnected.complete();
  }

  @override
  void onOpened() {
    opened.complete();
  }

  @override
  void onCompletedInitialLoad(didLoadSuccessfully) {
    firstPageLoaded.complete(didLoadSuccessfully);
  }

  @override
  void onNavigationEvent(CustomTabsNavigationEventType? type) {
    if (!navigationEvent.isCompleted) {
      navigationEvent.complete(type);
    }
    if (!navigationFinished.isCompleted &&
        type == CustomTabsNavigationEventType.FINISHED) {
      navigationFinished.complete();
    }
  }

  @override
  void onMessageChannelReady() async {
    if (!messageChannelReady.isCompleted) {
      messageChannelReady.complete();
    }
  }

  @override
  void onPostMessage(String message) {
    if (!postMessageReceived.isCompleted) {
      postMessageReceived.complete(message);
    }
  }

  @override
  void onRelationshipValidationResult(
      CustomTabsRelationType? relation, Uri? requestedOrigin, bool result) {
    relationshipValidationResult.complete(result);
  }

  @override
  void onBrowserNotSupported() {}

  @override
  void onClosed() {
    closed.complete();
  }
}
