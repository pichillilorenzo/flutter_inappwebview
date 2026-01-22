// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_notification.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a web notification.
class WebNotification {
  ///The badge URI.
  WebUri? badgeUri;

  ///The body text of the notification.
  String? body;

  ///The body image URI.
  WebUri? bodyImageUri;

  ///The text direction.
  NotificationDirection? direction;

  ///The icon URI.
  WebUri? iconUri;

  ///Whether the notification is silent.
  bool? isSilent;

  ///The language of the notification.
  String? language;

  ///Whether the notification requires interaction.
  bool? requiresInteraction;

  ///Whether the notification should renotify.
  bool? shouldRenotify;

  ///The tag of the notification.
  String? tag;

  ///The timestamp of the notification, in milliseconds since UNIX epoch.
  double? timestamp;

  ///The title of the notification.
  String? title;

  ///The vibration pattern, if any.
  List<int>? vibrationPattern;
  WebNotification({
    this.badgeUri,
    this.body,
    this.bodyImageUri,
    this.direction,
    this.iconUri,
    this.isSilent,
    this.language,
    this.requiresInteraction,
    this.shouldRenotify,
    this.tag,
    this.timestamp,
    this.title,
    this.vibrationPattern,
  });

  ///Gets a possible [WebNotification] instance from a [Map] value.
  static WebNotification? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebNotification(
      badgeUri: map['badgeUri'] != null ? WebUri(map['badgeUri']) : null,
      body: map['body'],
      bodyImageUri: map['bodyImageUri'] != null
          ? WebUri(map['bodyImageUri'])
          : null,
      direction: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => NotificationDirection.fromNativeValue(
          map['direction'],
        ),
        EnumMethod.value => NotificationDirection.fromValue(map['direction']),
        EnumMethod.name => NotificationDirection.byName(map['direction']),
      },
      iconUri: map['iconUri'] != null ? WebUri(map['iconUri']) : null,
      isSilent: map['isSilent'],
      language: map['language'],
      requiresInteraction: map['requiresInteraction'],
      shouldRenotify: map['shouldRenotify'],
      tag: map['tag'],
      timestamp: map['timestamp'],
      title: map['title'],
      vibrationPattern: map['vibrationPattern'] != null
          ? List<int>.from(map['vibrationPattern']!.cast<int>())
          : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "badgeUri": badgeUri?.toString(),
      "body": body,
      "bodyImageUri": bodyImageUri?.toString(),
      "direction": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => direction?.toNativeValue(),
        EnumMethod.value => direction?.toValue(),
        EnumMethod.name => direction?.name(),
      },
      "iconUri": iconUri?.toString(),
      "isSilent": isSilent,
      "language": language,
      "requiresInteraction": requiresInteraction,
      "shouldRenotify": shouldRenotify,
      "tag": tag,
      "timestamp": timestamp,
      "title": title,
      "vibrationPattern": vibrationPattern,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebNotification{badgeUri: $badgeUri, body: $body, bodyImageUri: $bodyImageUri, direction: $direction, iconUri: $iconUri, isSilent: $isSilent, language: $language, requiresInteraction: $requiresInteraction, shouldRenotify: $shouldRenotify, tag: $tag, timestamp: $timestamp, title: $title, vibrationPattern: $vibrationPattern}';
  }
}
