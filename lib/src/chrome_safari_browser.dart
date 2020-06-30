import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'types.dart';
import 'in_app_browser.dart';

///This class uses native [Chrome Custom Tabs](https://developer.android.com/reference/android/support/customtabs/package-summary) on Android
///and [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) on iOS.
///
///[browserFallback] represents the [InAppBrowser] instance fallback in case `Chrome Custom Tabs`/`SFSafariViewController` is not available.
class ChromeSafariBrowser {
  String uuid;
  InAppBrowser browserFallback;
  Map<int, ChromeSafariBrowserMenuItem> _menuItems = new HashMap();
  bool _isOpened = false;
  MethodChannel _channel;
  static const MethodChannel _sharedChannel =
      const MethodChannel('com.pichillilorenzo/flutter_chromesafaribrowser');

  ///Initialize the [ChromeSafariBrowser] instance with an [InAppBrowser] fallback instance or `null`.
  ChromeSafariBrowser({bFallback}) {
    uuid = uuidGenerator.v4();
    browserFallback = bFallback;
    this._channel =
        MethodChannel('com.pichillilorenzo/flutter_chromesafaribrowser_$uuid');
    this._channel.setMethodCallHandler(handleMethod);
    _isOpened = false;
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onChromeSafariBrowserOpened":
        onOpened();
        break;
      case "onChromeSafariBrowserCompletedInitialLoad":
        onCompletedInitialLoad();
        break;
      case "onChromeSafariBrowserClosed":
        onClosed();
        this._isOpened = false;
        break;
      case "onChromeSafariBrowserMenuItemActionPerform":
        String url = call.arguments["url"];
        String title = call.arguments["title"];
        int id = call.arguments["id"].toInt();
        this._menuItems[id].action(url, title);
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
  }

  ///Opens an [url] in a new [ChromeSafariBrowser] instance.
  ///
  ///[url]: The [url] to load. Call [encodeUriComponent()] on this if the [url] contains Unicode characters.
  ///
  ///[options]: Options for the [ChromeSafariBrowser].
  ///
  ///[headersFallback]: The additional header of the [InAppBrowser] instance fallback to be used in the HTTP request for this URL, specified as a map from name to value.
  ///
  ///[optionsFallback]: Options used by the [InAppBrowser] instance fallback.
  ///
  ///[contextMenuFallback]: Context Menu used by the [InAppBrowser] instance fallback.
  Future<void> open(
      {@required String url,
      ChromeSafariBrowserClassOptions options,
      Map<String, String> headersFallback = const {},
      InAppBrowserClassOptions optionsFallback}) async {
    assert(url != null && url.isNotEmpty);
    this.throwIsAlreadyOpened(message: 'Cannot open $url!');

    List<Map<String, dynamic>> menuItemList = new List();
    _menuItems.forEach((key, value) {
      menuItemList.add({"id": value.id, "label": value.label});
    });

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('options', () => options?.toMap() ?? {});
    args.putIfAbsent('menuItemList', () => menuItemList);
    args.putIfAbsent('uuidFallback', () => browserFallback?.uuid);
    args.putIfAbsent('headersFallback', () => headersFallback ?? {});
    args.putIfAbsent('optionsFallback', () => optionsFallback?.toMap() ?? {});
    args.putIfAbsent('contextMenuFallback',
        () => browserFallback?.contextMenu?.toMap() ?? {});
    await _sharedChannel.invokeMethod('open', args);
    this._isOpened = true;
  }

  ///Closes the [ChromeSafariBrowser] instance.
  Future<void> close() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod("close", args);
  }

  ///Adds a [ChromeSafariBrowserMenuItem] to the menu.
  void addMenuItem(ChromeSafariBrowserMenuItem menuItem) {
    this._menuItems[menuItem.id] = menuItem;
  }

  ///Adds a list of [ChromeSafariBrowserMenuItem] to the menu.
  void addMenuItems(List<ChromeSafariBrowserMenuItem> menuItems) {
    menuItems.forEach((menuItem) {
      this._menuItems[menuItem.id] = menuItem;
    });
  }

  ///On Android, returns `true` if Chrome Custom Tabs is available.
  ///On iOS, returns `true` if SFSafariViewController is available.
  ///Otherwise returns `false`.
  static Future<bool> isAvailable() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _sharedChannel.invokeMethod("isAvailable", args);
  }

  ///Event fires when the [ChromeSafariBrowser] is opened.
  void onOpened() {}

  ///Event fires when the initial URL load is complete.
  void onCompletedInitialLoad() {}

  ///Event fires when the [ChromeSafariBrowser] is closed.
  void onClosed() {}

  ///Returns `true` if the [ChromeSafariBrowser] instance is opened, otherwise `false`.
  bool isOpened() {
    return this._isOpened;
  }

  void throwIsAlreadyOpened({String message = ''}) {
    if (this.isOpened()) {
      throw Exception([
        'Error: ${(message.isEmpty) ? '' : message + ' '}The browser is already opened.'
      ]);
    }
  }

  void throwIsNotOpened({String message = ''}) {
    if (!this.isOpened()) {
      throw Exception([
        'Error: ${(message.isEmpty) ? '' : message + ' '}The browser is not opened.'
      ]);
    }
  }
}

///Class that represents a custom menu item for a [ChromeSafariBrowser] instance.
class ChromeSafariBrowserMenuItem {
  ///The menu item id
  int id;

  ///The label of the menu item
  String label;

  ///Callback function to be invoked when the menu item is clicked
  final void Function(String url, String title) action;

  ChromeSafariBrowserMenuItem(
      {@required this.id, @required this.label, @required this.action});

  Map<String, dynamic> toMap() {
    return {"id": id, "label": label};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
