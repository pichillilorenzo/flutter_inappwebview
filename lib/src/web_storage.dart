import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'in_app_webview_controller.dart';
import 'types.dart';

class WebStorage {
  LocalStorage localStorage;
  SessionStorage sessionStorage;

  WebStorage({@required this.localStorage, @required this.sessionStorage});
}

class WebStorageItem {
  String key;
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

class Storage {
  InAppWebViewController _controller;
  WebStorageType webStorageType;

  Storage(InAppWebViewController controller, this.webStorageType) {
    assert(controller != null && this.webStorageType != null);
    this._controller = controller;
  }

  Future<int> length() async {
    var result = await _controller.evaluateJavascript(source: """
    window.$webStorageType.length;
    """);
    return result != null ? int.parse(json.decode(result)) : null;
  }

  Future<void> setItem({@required String key, @required dynamic value}) async {
    var encodedValue = json.encode(value);
    await _controller.evaluateJavascript(source: """
    window.$webStorageType.setItem("$key", ${value is String ? encodedValue : "JSON.stringify($encodedValue)"});
    """);
  }

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

  Future<void> removeItem({@required String key}) async {
    await _controller.evaluateJavascript(source: """
    window.$webStorageType.removeItem("$key");
    """);
  }

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

  Future<void> clear() async {
    await _controller.evaluateJavascript(source: """
    window.$webStorageType.clear();
    """);
  }

  Future<String> key({@required int index}) async {
    var result = await _controller.evaluateJavascript(source: """
    window.$webStorageType.key($index);
    """);
    return result != null ? json.decode(result) : null;
  }
}

class LocalStorage extends Storage {
  LocalStorage(InAppWebViewController controller)
      : super(controller, WebStorageType.LOCAL_STORAGE);
}

class SessionStorage extends Storage {
  SessionStorage(InAppWebViewController controller)
      : super(controller, WebStorageType.SESSION_STORAGE);
}
