import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'in_app_webview_controller.dart';
import 'types.dart';

///Class that provides access to the JavaScript [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API): `window.sessionStorage` and `window.localStorage`.
///It used by [InAppWebViewController.webStorage].
class WebStorage {
  ///Represents `window.localStorage`.
  LocalStorage localStorage;

  ///Represents `window.sessionStorage`.
  SessionStorage sessionStorage;

  WebStorage({@required this.localStorage, @required this.sessionStorage});
}

///Class that represents a single web storage item of the JavaScript `window.sessionStorage` and `window.localStorage` objects.
class WebStorageItem {
  ///Item key.
  String key;

  ///Item value.
  dynamic value;

  WebStorageItem({this.key, this.value});

  Map<String, dynamic> toMap() {
    return {
      "key": key,
      "value": value,
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

///Class that provides methods to manage the JavaScript [Storage](https://developer.mozilla.org/en-US/docs/Web/API/Storage) object.
///It is used by [LocalStorage] and [SessionStorage].
class Storage {
  InAppWebViewController _controller;

  ///The web storage type: `window.sessionStorage` or `window.localStorage`.
  WebStorageType webStorageType;

  Storage(InAppWebViewController controller, this.webStorageType) {
    assert(controller != null && this.webStorageType != null);
    this._controller = controller;
  }

  ///Returns an integer representing the number of data items stored in the Storage object.
  Future<int> length() async {
    var result = await _controller.evaluateJavascript(source: """
    window.$webStorageType.length;
    """);
    return result != null ? int.parse(json.decode(result)) : null;
  }

  ///When passed a [key] name and [value], will add that key to the storage, or update that key's value if it already exists.
  Future<void> setItem({@required String key, @required dynamic value}) async {
    var encodedValue = json.encode(value);
    await _controller.evaluateJavascript(source: """
    window.$webStorageType.setItem("$key", ${value is String ? encodedValue : "JSON.stringify($encodedValue)"});
    """);
  }

  ///When passed a [key] name, will return that key's value, or `null` if the key does not exist, in the given Storage object.
  Future<dynamic> getItem({@required String key}) async {
    var itemValue = await _controller.evaluateJavascript(source: """
    window.$webStorageType.getItem("$key");
    """);

    if (itemValue == null) {
      return null;
    }

    try {
      return json.decode(itemValue);
    } catch (e) {}

    return itemValue;
  }

  ///When passed a [key] name, will remove that key from the given Storage object if it exists.
  Future<void> removeItem({@required String key}) async {
    await _controller.evaluateJavascript(source: """
    window.$webStorageType.removeItem("$key");
    """);
  }

  ///Returns the list of all items from the given Storage object.
  Future<List<WebStorageItem>> getItems() async {
    var webStorageItems = <WebStorageItem>[];

    List<Map<dynamic, dynamic>> items =
        (await _controller.evaluateJavascript(source: """
(function() {
  var webStorageItems = [];
  for(var i = 0; i < window.$webStorageType.length; i++){
    var key = window.$webStorageType.key(i);
    webStorageItems.push(
      {
        key: key,
        value: window.$webStorageType.getItem(key)
      }
    );
  }
  return webStorageItems;
})();
    """)).cast<Map<dynamic, dynamic>>();

    if (items == null) {
      return webStorageItems;
    }

    for (var item in items) {
      webStorageItems
          .add(WebStorageItem(key: item["key"], value: item["value"]));
    }

    return webStorageItems;
  }

  ///Clears all keys stored in a given Storage object.
  Future<void> clear() async {
    await _controller.evaluateJavascript(source: """
    window.$webStorageType.clear();
    """);
  }

  ///When passed a number [index], returns the name of the nth key in a given Storage object.
  ///The order of keys is user-agent defined, so you should not rely on it.
  Future<String> key({@required int index}) async {
    var result = await _controller.evaluateJavascript(source: """
    window.$webStorageType.key($index);
    """);
    return result != null ? json.decode(result) : null;
  }
}

///Class that provides methods to manage the JavaScript `window.localStorage` object.
///It used by [WebStorage].
class LocalStorage extends Storage {
  LocalStorage(InAppWebViewController controller)
      : super(controller, WebStorageType.LOCAL_STORAGE);
}

///Class that provides methods to manage the JavaScript `window.sessionStorage` object.
///It used by [WebStorage].
class SessionStorage extends Storage {
  SessionStorage(InAppWebViewController controller)
      : super(controller, WebStorageType.SESSION_STORAGE);
}
