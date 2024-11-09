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
  WebUri requestUrl;
  JavaScriptHandlerFunctionData(
      {this.args = const [],
      required this.isMainFrame,
      required this.origin,
      required this.requestUrl});

  ///Gets a possible [JavaScriptHandlerFunctionData] instance from a [Map] value.
  static JavaScriptHandlerFunctionData? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = JavaScriptHandlerFunctionData(
      isMainFrame: map['isMainFrame'],
      origin: WebUri(map['origin']),
      requestUrl: WebUri(map['requestUrl']),
    );
    if (map['args'] != null) {
      instance.args = List<dynamic>.from(map['args']!.cast<dynamic>());
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "args": args,
      "isMainFrame": isMainFrame,
      "origin": origin.toString(),
      "requestUrl": requestUrl.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'JavaScriptHandlerFunctionData{args: $args, isMainFrame: $isMainFrame, origin: $origin, requestUrl: $requestUrl}';
  }
}
