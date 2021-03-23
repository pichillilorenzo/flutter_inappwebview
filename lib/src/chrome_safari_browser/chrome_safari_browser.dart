import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/src/util.dart';

import 'chrome_safari_browser_options.dart';

class ChromeSafariBrowserAlreadyOpenedException implements Exception {
  final dynamic message;

  ChromeSafariBrowserAlreadyOpenedException([this.message]);

  String toString() {
    Object? message = this.message;
    if (message == null) return "ChromeSafariBrowserAlreadyOpenedException";
    return "ChromeSafariBrowserAlreadyOpenedException: $message";
  }
}

class ChromeSafariBrowserNotOpenedException implements Exception {
  final dynamic message;

  ChromeSafariBrowserNotOpenedException([this.message]);

  String toString() {
    Object? message = this.message;
    if (message == null) return "ChromeSafariBrowserNotOpenedException";
    return "ChromeSafariBrowserNotOpenedException: $message";
  }
}

///This class uses native [Chrome Custom Tabs](https://developer.android.com/reference/android/support/customtabs/package-summary) on Android
///and [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) on iOS.
///
///**NOTE**: If you want to use the `ChromeSafariBrowser` class on Android 11+ you need to specify your app querying for
///`android.support.customtabs.action.CustomTabsService` in your `AndroidManifest.xml`
///(you can read more about it here: https://developers.google.com/web/android/custom-tabs/best-practices#applications_targeting_android_11_api_level_30_or_above).
class ChromeSafariBrowser {
  ///View ID used internally.
  late final String id;

  Map<int, ChromeSafariBrowserMenuItem> _menuItems = new HashMap();
  bool _isOpened = false;
  late MethodChannel _channel;
  static const MethodChannel _sharedChannel =
      const MethodChannel('com.pichillilorenzo/flutter_chromesafaribrowser');

  ChromeSafariBrowser() {
    id = IdGenerator.generate();
    this._channel =
        MethodChannel('com.pichillilorenzo/flutter_chromesafaribrowser_$id');
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
        if (this._menuItems[id] != null) {
          this._menuItems[id]!.action(url, title);
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
  }

  ///Opens the [ChromeSafariBrowser] instance with an [url].
  ///
  ///[url]: The [url] to load.
  ///
  ///[options]: Options for the [ChromeSafariBrowser].
  Future<void> open(
      {required Uri url, ChromeSafariBrowserClassOptions? options}) async {
    assert(url.toString().isNotEmpty);
    this.throwIsAlreadyOpened(message: 'Cannot open $url!');

    List<Map<String, dynamic>> menuItemList = [];
    _menuItems.forEach((key, value) {
      menuItemList.add({"id": value.id, "label": value.label});
    });

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('id', () => id);
    args.putIfAbsent('url', () => url.toString());
    args.putIfAbsent('options', () => options?.toMap() ?? {});
    args.putIfAbsent('menuItemList', () => menuItemList);
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
      throw ChromeSafariBrowserAlreadyOpenedException([
        'Error: ${(message.isEmpty) ? '' : message + ' '}The browser is already opened.'
      ]);
    }
  }

  void throwIsNotOpened({String message = ''}) {
    if (!this.isOpened()) {
      throw ChromeSafariBrowserNotOpenedException([
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
      {required this.id, required this.label, required this.action});

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
