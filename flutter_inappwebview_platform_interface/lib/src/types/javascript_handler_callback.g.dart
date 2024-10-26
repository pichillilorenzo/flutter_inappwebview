// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'javascript_handler_callback.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///A class that represents the data passed to a [JavaScriptHandlerFunction] added with [PlatformInAppWebViewController.addJavaScriptHandler].
class JavaScriptHandlerFunctionData {
  List<dynamic> args;
  bool isMainFrame;
  WebUri origin;
  JavaScriptHandlerFunctionData(
      {this.args = const [], required this.isMainFrame, required this.origin});

  ///Gets a possible [JavaScriptHandlerFunctionData] instance from a [Map] value.
  static JavaScriptHandlerFunctionData? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = JavaScriptHandlerFunctionData(
      isMainFrame: map['isMainFrame'],
      origin: WebUri(map['origin']),
    );
    if (map['args'] != null) {
      instance.args = List<dynamic>.from(map['args']!.cast<dynamic>());
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "args": args,
      "isMainFrame": isMainFrame,
      "origin": origin.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'JavaScriptHandlerFunctionData{args: $args, isMainFrame: $isMainFrame, origin: $origin}';
  }
}
