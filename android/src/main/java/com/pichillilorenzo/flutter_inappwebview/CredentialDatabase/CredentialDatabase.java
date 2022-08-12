package com.pichillilorenzo.flutter_inappwebview.CredentialDatabase;

import android.content.Context;

import java.util.ArrayList;
import java.util.List;

public class CredentialDatabase {

  private static CredentialDatabase instance;
  static final String LOG_TAG = "CredentialDatabase";

  // If you change the database schema, you must increment the database version.
  public static final int DATABASE_VERSION = 2;
  public static final String DATABASE_NAME = "CredentialDatabase.db";

  public ProtectionSpaceDao protectionSpaceDao;
  public CredentialDao credentialDao;
  public CredentialDatabaseHelper db;

  private CredentialDatabase() {}

  private CredentialDatabase(CredentialDatabaseHelper db, ProtectionSpaceDao protectionSpaceDao, CredentialDao credentialDao) {
    this.db = db;
    this.protectionSpaceDao = protectionSpaceDao;
    this.credentialDao = credentialDao;
  }

  public static CredentialDatabase getInstance(Context context) {
    if (instance != null)
      return instance;
    CredentialDatabaseHelper db = new CredentialDatabaseHelper(context);
    instance = new CredentialDatabase(db, new ProtectionSpaceDao(db), new CredentialDao(db));
    return instance;
  }

  public List<Credential> getHttpAuthCredentials(String host, String protocol, String realm, Integer port) {
    List<Credential> credentialList = new ArrayList<>();
    ProtectionSpace protectionSpace = protectionSpaceDao.find(host, protocol, realm, port);
    if (protectionSpace != null) {
      credentialList = credentialDao.getAllByProtectionSpaceId(protectionSpace.id);
    }
    return credentialList;
  }

  public void clearAllAuthCredentials() {
    db.clearAllTables(db.getWritableDatabase());
  }

  public void removeHttpAuthCredentials(String host, String protocol, String realm, Integer port) {
    ProtectionSpace protectionSpace = protectionSpaceDao.find(host, protocol, realm, port);
    if (protectionSpace != null) {
      protectionSpaceDao.delete(protectionSpace);
    }
  }

  public void removeHttpAuthCredential(String host, String protocol, String realm, Integer port, String username, String password) {
    ProtectionSpace protectionSpace = protectionSpaceDao.find(host, protocol, realm, port);
    if (protectionSpace != null) {
      Credential credential = credentialDao.find(username, password, protectionSpace.id);
      credentialDao.delete(credential);
    }
  }

  public void setHttpAuthCredential(String host, String protocol, String realm, Integer port, String username, String password) {
    ProtectionSpace protectionSpace = protectionSpaceDao.find(host, protocol, realm, port);
    Long protectionSpaceId;
    if (protectionSpace == null) {
      protectionSpaceId = protectionSpaceDao.insert(new ProtectionSpace(null, host, protocol, realm, port));
    } else {
      protectionSpaceId = protectionSpace.id;
    }

    Credential credential = credentialDao.find(username, password, protectionSpaceId);
    if (credential != null) {
      boolean needUpdate = false;
      if (!credential.username.equals(username)) {
        credential.username = username;
        needUpdate = true;
      }
      if (!credential.password.equals(password)) {
        credential.password = password;
        needUpdate = true;
      }
      if (needUpdate)
        credentialDao.update(credential);
    } else {
      credential = new Credential(null, username, password, protectionSpaceId);
      credential.id = credentialDao.insert(credential);
    }
  }
}