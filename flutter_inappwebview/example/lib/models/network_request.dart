/// Represents a network request with its metadata and response
class NetworkRequest {
  final String id;
  final String method;
  final String url;
  final DateTime timestamp;
  final Map<String, String>? headers;
  final String? body;
  final String? response;
  final int? statusCode;
  final Duration? duration;

  const NetworkRequest({
    required this.id,
    required this.method,
    required this.url,
    required this.timestamp,
    this.headers,
    this.body,
    this.response,
    this.statusCode,
    this.duration,
  });

  /// Create a copy with updated fields
  NetworkRequest copyWith({
    String? id,
    String? method,
    String? url,
    DateTime? timestamp,
    Map<String, String>? headers,
    String? body,
    String? response,
    int? statusCode,
    Duration? duration,
  }) {
    return NetworkRequest(
      id: id ?? this.id,
      method: method ?? this.method,
      url: url ?? this.url,
      timestamp: timestamp ?? this.timestamp,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      response: response ?? this.response,
      statusCode: statusCode ?? this.statusCode,
      duration: duration ?? this.duration,
    );
  }

  /// Serialize to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'method': method,
      'url': url,
      'timestamp': timestamp.millisecondsSinceEpoch,
      if (headers != null) 'headers': headers,
      if (body != null) 'body': body,
      if (response != null) 'response': response,
      if (statusCode != null) 'statusCode': statusCode,
      if (duration != null) 'duration': duration!.inMilliseconds,
    };
  }

  /// Deserialize from map
  factory NetworkRequest.fromMap(Map<String, dynamic> map) {
    return NetworkRequest(
      id: map['id'] as String,
      method: map['method'] as String,
      url: map['url'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      headers: map['headers'] != null
          ? Map<String, String>.from(map['headers'] as Map)
          : null,
      body: map['body'] as String?,
      response: map['response'] as String?,
      statusCode: map['statusCode'] as int?,
      duration: map['duration'] != null
          ? Duration(milliseconds: map['duration'] as int)
          : null,
    );
  }
}
