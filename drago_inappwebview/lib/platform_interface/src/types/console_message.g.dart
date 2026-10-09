// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'console_message.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing a JavaScript console message from WebCore.
///This could be a issued by a call to one of the console logging functions (e.g. console.log('...')) or a JavaScript error on the page.
///
///To receive notifications of these messages, use the [PlatformWebViewCreationParams.onConsoleMessage] event.
class ConsoleMessage {
  ///Console message
  String message;

  ///Console message level
  ConsoleMessageLevel messageLevel;
  ConsoleMessage({this.message = "", ConsoleMessageLevel? messageLevel})
    : messageLevel = messageLevel ?? ConsoleMessageLevel.LOG;

  ///Gets a possible [ConsoleMessage] instance from a [Map] value.
  static ConsoleMessage? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = ConsoleMessage();
    if (map['message'] != null) {
      instance.message = map['message'];
    }
    if (map['messageLevel'] != null) {
      instance.messageLevel = switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => ConsoleMessageLevel.fromNativeValue(
          map['messageLevel'],
        ),
        EnumMethod.value => ConsoleMessageLevel.fromValue(map['messageLevel']),
        EnumMethod.name => ConsoleMessageLevel.byName(map['messageLevel']),
      }!;
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "message": message,
      "messageLevel": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => messageLevel.toNativeValue(),
        EnumMethod.value => messageLevel.toValue(),
        EnumMethod.name => messageLevel.name(),
      },
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ConsoleMessage{message: $message, messageLevel: $messageLevel}';
  }
}
