package com.pichillilorenzo.flutter_inappwebview.CredentialDatabase;

import java.util.HashMap;
import java.util.Map;

public class ProtectionSpace {
  public Long id;
  public String host;
  public String procotol;
  public String realm;
  public Integer port;

  public ProtectionSpace (Long id, String host, String protocol, String realm, Integer port) {
    this.id = id;
    this.host = host;
    this.procotol = protocol;
    this.realm = realm;
    this.port = port;
  }

  public Map<String, Object> toMap() {
    Map<String, Object> protectionSpaceMap = new HashMap<>();
    protectionSpaceMap.put("host", host);
    protectionSpaceMap.put("protocol", procotol);
    protectionSpaceMap.put("realm", realm);
    protectionSpaceMap.put("port", port);
    return protectionSpaceMap;
  }
}
