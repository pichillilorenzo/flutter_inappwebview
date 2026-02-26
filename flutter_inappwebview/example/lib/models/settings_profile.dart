import 'dart:convert';

/// Model for saving/loading InAppWebViewSettings profiles
class SettingsProfile {
  final String id;
  final String name;
  final DateTime createdAt;
  final Map<String, dynamic> settings;

  const SettingsProfile({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.settings,
  });

  /// Create a new profile with a unique ID
  factory SettingsProfile.create({
    required String name,
    required Map<String, dynamic> settings,
  }) {
    return SettingsProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
      settings: Map<String, dynamic>.from(settings),
    );
  }

  /// Create a copy with optional modifications
  SettingsProfile copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    Map<String, dynamic>? settings,
  }) {
    return SettingsProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? Map<String, dynamic>.from(this.settings),
    );
  }

  /// Convert to JSON map for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'settings': settings,
    };
  }

  /// Create from JSON map
  factory SettingsProfile.fromJson(Map<String, dynamic> json) {
    return SettingsProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      settings: Map<String, dynamic>.from(json['settings'] as Map),
    );
  }

  /// Serialize to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory SettingsProfile.fromJsonString(String jsonString) {
    return SettingsProfile.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SettingsProfile(id: $id, name: $name, createdAt: $createdAt, settingsCount: ${settings.length})';
  }
}
