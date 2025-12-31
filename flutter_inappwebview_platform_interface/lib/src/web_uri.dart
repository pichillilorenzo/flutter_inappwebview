///Class that implements the [Uri] interface to maintain also the raw string value used by [Uri.parse].
///
///This class is used because some strings coming from the native platform side
///are not parsed correctly or could lose letter case information,
///so [rawValue] can be used as a fallback value.
///
///Examples:
///```dart
///  // InAppWebView example
///  InAppWebView(
///    initialUrlRequest:
///      URLRequest(url: WebUri('https://flutter.dev'))
///  )
///
///  // example of letter case difference
///  final uri = WebUri('scheme://customHostValue', forceToStringRawValue: false);
///  print(uri.rawValue); // scheme://customHostValue
///  print(uri.isValidUri); // true
///  print(uri.uriValue.toString()); // scheme://customhostvalue
///  print(uri.toString()); // scheme://customhostvalue
///
///  uri.forceToStringRawValue = true;
///  print(uri.toString()); // scheme://customHostValue
///
///  // example of a not valid URI
///  // Uncaught Error: FormatException: Invalid port (at character 14)
///  final invalidUri = WebUri('intent://not:valid_uri');
///  print(invalidUri.rawValue); // intent://not:valid_uri
///  print(invalidUri.isValidUri); // false
///  print(invalidUri.uriValue.toString()); // ''
///  print(invalidUri.toString()); // intent://not:valid_uri
///```
class WebUri implements Uri {
  Uri _uri = Uri();
  String _rawValue = '';
  bool _isValidUri = false;

  ///Whether to force the usage of [rawValue] when calling [toString] or not.
  ///Because [toString] is used to send URI strings to the native platform side,
  ///this flag is useful when you want to send [rawValue] instead of [uriValue]`.toString()`.
  ///
  ///The default value is `false`.
  bool forceToStringRawValue = false;

  ///Initialize a [WebUri] using a raw string value.
  ///In this case, [uriValue]`.toString()` and [rawValue] could not have the same value.
  WebUri(String source, {this.forceToStringRawValue = false}) {
    _rawValue = source;
    try {
      _uri = Uri.parse(this._rawValue);
      _isValidUri = true;
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }
  }

  ///Initialize a [WebUri] using an [Uri] instance.
  ///In this case, [uriValue]`.toString()` and [rawValue] will have the same value.
  WebUri.uri(Uri uri) {
    _uri = uri;
    _rawValue = uri.toString();
    _isValidUri = true;
  }

  ///Raw string value used by [Uri.parse].
  String get rawValue => _rawValue;

  ///Uri parsed value. If [isValidUri] is `false`, the value will be `Uri()`.
  Uri get uriValue => _uri;

  ///`true` if [rawValue] has been parsed correctly, otherwise `false`.
  bool get isValidUri => _isValidUri;

  @override
  String get authority => _uri.authority;

  @override
  UriData? get data => _uri.data;

  @override
  String get fragment => _uri.fragment;

  @override
  bool get hasAbsolutePath => _uri.hasAbsolutePath;

  @override
  bool get hasAuthority => _uri.hasAuthority;

  @override
  bool get hasEmptyPath => _uri.hasEmptyPath;

  @override
  bool get hasFragment => _uri.hasFragment;

  @override
  bool get hasPort => _uri.hasPort;

  @override
  bool get hasQuery => _uri.hasQuery;

  @override
  bool get hasScheme => _uri.hasScheme;

  @override
  String get host => _uri.host;

  @override
  bool get isAbsolute => _uri.isAbsolute;

  @override
  bool isScheme(String scheme) {
    return _uri.isScheme(scheme);
  }

  @override
  Uri normalizePath() {
    return _uri.normalizePath();
  }

  @override
  String get origin => _uri.origin;

  @override
  String get path => _uri.path;

  @override
  List<String> get pathSegments => _uri.pathSegments;

  @override
  int get port => _uri.port;

  @override
  String get query => _uri.query;

  @override
  Map<String, String> get queryParameters => _uri.queryParameters;

  @override
  Map<String, List<String>> get queryParametersAll => _uri.queryParametersAll;

  @override
  Uri removeFragment() {
    return _uri.removeFragment();
  }

  @override
  Uri replace({
    String? scheme,
    String? userInfo,
    String? host,
    int? port,
    String? path,
    Iterable<String>? pathSegments,
    String? query,
    Map<String, dynamic>? queryParameters,
    String? fragment,
  }) {
    return _uri.replace(
      scheme: scheme,
      userInfo: userInfo,
      host: host,
      port: port,
      path: path,
      pathSegments: pathSegments,
      query: query,
      queryParameters: queryParameters,
      fragment: fragment,
    );
  }

  @override
  Uri resolve(String reference) {
    return _uri.resolve(reference);
  }

  @override
  Uri resolveUri(Uri reference) {
    return _uri.resolveUri(reference);
  }

  @override
  String get scheme => _uri.scheme;

  @override
  String toFilePath({bool? windows}) {
    return _uri.toFilePath(windows: windows);
  }

  @override
  String get userInfo => _uri.userInfo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebUri &&
          runtimeType == other.runtimeType &&
          _uri == other._uri &&
          _rawValue == other._rawValue &&
          _isValidUri == other._isValidUri &&
          forceToStringRawValue == other.forceToStringRawValue;

  @override
  int get hashCode =>
      _uri.hashCode ^
      _rawValue.hashCode ^
      _isValidUri.hashCode ^
      forceToStringRawValue.hashCode;

  ///If [forceToStringRawValue] is `true` or [isValidUri] is `false`, it returns [rawValue],
  ///otherwise the value of [uriValue]`.toString()`.
  @override
  String toString() {
    return forceToStringRawValue || !_isValidUri ? _rawValue : _uri.toString();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
