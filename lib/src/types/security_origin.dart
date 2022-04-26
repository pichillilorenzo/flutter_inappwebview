///An object that identifies the origin of a particular resource.
class SecurityOrigin {
  ///The security origin’s host.
  String host;

  ///The security origin's port.
  int port;

  ///The security origin's protocol.
  String protocol;

  SecurityOrigin(
      {required this.host, required this.port, required this.protocol});

  ///Gets a possible [SecurityOrigin] instance from a [Map] value.
  static SecurityOrigin? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return SecurityOrigin(
        host: map["host"], port: map["port"], protocol: map["protocol"]);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"host": host, "port": port, "protocol": protocol};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///An object that identifies the origin of a particular resource.
///
///**NOTE**: available only on iOS 9.0+.
///
///Use [SecurityOrigin] instead.
@Deprecated("Use SecurityOrigin instead")
class IOSWKSecurityOrigin {
  ///The security origin’s host.
  String host;

  ///The security origin's port.
  int port;

  ///The security origin's protocol.
  String protocol;

  IOSWKSecurityOrigin(
      {required this.host, required this.port, required this.protocol});

  ///Gets a possible [IOSWKSecurityOrigin] instance from a [Map] value.
  static IOSWKSecurityOrigin? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return IOSWKSecurityOrigin(
        host: map["host"], port: map["port"], protocol: map["protocol"]);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"host": host, "port": port, "protocol": protocol};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}