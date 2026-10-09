import 'dart:convert';

/// Model for saving/loading WebViewEnvironmentSettings profiles
class WebViewEnvironmentProfile {
  final String id;
  final String name;
  final DateTime createdAt;
  final Map<String, dynamic> settings;

  const WebViewEnvironmentProfile({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.settings,
  });

  /// Create a new profile with a unique ID
  factory WebViewEnvironmentProfile.create({
    required String name,
    required Map<String, dynamic> settings,
  }) {
    return WebViewEnvironmentProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
      settings: Map<String, dynamic>.from(settings),
    );
  }

  /// Create a copy with optional modifications
  WebViewEnvironmentProfile copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    Map<String, dynamic>? settings,
  }) {
    return WebViewEnvironmentProfile(
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
  factory WebViewEnvironmentProfile.fromJson(Map<String, dynamic> json) {
    return WebViewEnvironmentProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      settings: Map<String, dynamic>.from(json['settings'] as Map),
    );
  }

  /// Serialize to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory WebViewEnvironmentProfile.fromJsonString(String jsonString) {
    return WebViewEnvironmentProfile.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebViewEnvironmentProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WebViewEnvironmentProfile(id: $id, name: $name, createdAt: $createdAt, settingsCount: ${settings.length})';
  }
}
