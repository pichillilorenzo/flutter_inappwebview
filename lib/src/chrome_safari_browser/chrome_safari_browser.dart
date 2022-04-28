import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
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

  ChromeSafariBrowserActionButton? _actionButton;
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
      case "onChromeSafariBrowserItemActionPerform":
        String url = call.arguments["url"];
        String title = call.arguments["title"];
        int id = call.arguments["id"].toInt();
        if (this._actionButton?.id == id) {
          this._actionButton?.action(url, title);
        } else if (this._menuItems[id] != null) {
          this._menuItems[id]?.action(url, title);
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
  }

  ///Opens the [ChromeSafariBrowser] instance with an [url].
  ///
  ///[url]: The [url] to load. On iOS, the [url] must use the `http` or `https` scheme.
  ///
  ///[options]: Options for the [ChromeSafariBrowser].
  Future<void> open(
      {required Uri url, ChromeSafariBrowserClassOptions? options}) async {
    assert(url.toString().isNotEmpty);
    this.throwIsAlreadyOpened(message: 'Cannot open $url!');
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      assert(['http', 'https'].contains(url.scheme),
          'The specified URL has an unsupported scheme. Only HTTP and HTTPS URLs are supported on iOS.');
    }

    List<Map<String, dynamic>> menuItemList = [];
    _menuItems.forEach((key, value) {
      menuItemList.add(value.toMap());
    });

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('id', () => id);
    args.putIfAbsent('url', () => url.toString());
    args.putIfAbsent('options', () => options?.toMap() ?? {});
    args.putIfAbsent('actionButton', () => _actionButton?.toMap());
    args.putIfAbsent('menuItemList', () => menuItemList);
    await _sharedChannel.invokeMethod('open', args);
    this._isOpened = true;
  }

  ///Closes the [ChromeSafariBrowser] instance.
  Future<void> close() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod("close", args);
  }

  ///Set a custom action button.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsIntent.Builder.setActionButton ](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsIntent.Builder#setActionButton(android.graphics.Bitmap,%20java.lang.String,%20android.app.PendingIntent,%20boolean)))
  void setActionButton(ChromeSafariBrowserActionButton actionButton) {
    this._actionButton = actionButton;
  }

  ///Adds a [ChromeSafariBrowserMenuItem] to the menu.
  ///
  ///**NOTE**: Not available in an Android Trusted Web Activity.
  void addMenuItem(ChromeSafariBrowserMenuItem menuItem) {
    this._menuItems[menuItem.id] = menuItem;
  }

  ///Adds a list of [ChromeSafariBrowserMenuItem] to the menu.
  ///
  ///**NOTE**: Not available in an Android Trusted Web Activity.
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

///Class that represents a custom action button for a [ChromeSafariBrowser] instance.
///
///**NOTE**: Not available in an Android Trusted Web Activity.
class ChromeSafariBrowserActionButton {
  ///The action button id. It should be different from the [ChromeSafariBrowserMenuItem.id].
  int id;

  ///The icon byte data.
  Uint8List icon;

  ///The description for the button. To be used for accessibility.
  String description;

  ///Whether the action button should be tinted.
  bool shouldTint;

  ///Callback function to be invoked when the menu item is clicked
  final void Function(String url, String title) action;

  ChromeSafariBrowserActionButton(
      {required this.id,
      required this.icon,
      required this.description,
      required this.action,
      this.shouldTint = false});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "icon": icon,
      "description": description,
      "shouldTint": shouldTint
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents a custom menu item for a [ChromeSafariBrowser] instance.
///
///**NOTE**: Not available in an Android Trusted Web Activity.
class ChromeSafariBrowserMenuItem {
  ///The menu item id. It should be different from [ChromeSafariBrowserActionButton.id].
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
