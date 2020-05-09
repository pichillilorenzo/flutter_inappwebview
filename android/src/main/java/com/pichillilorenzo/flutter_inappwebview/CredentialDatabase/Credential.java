package com.pichillilorenzo.flutter_inappwebview.CredentialDatabase;

import java.util.HashMap;
import java.util.Map;

public class Credential {
  public Long id;
  public String username;
  public String password;
  public Long protectionSpaceId;

  public Credential (Long id, String username, String password, Long protectionSpaceId) {
    this.id = id;
    this.username = username;
    this.password = password;
    this.protectionSpaceId = protectionSpaceId;
  }

  public Map<String, Object> toMap() {
    Map<String, Object> credentialMap = new HashMap<>();
    credentialMap.put("username", username);
    credentialMap.put("password", password);
    return credentialMap;
  }
}
