package com.pichillilorenzo.flutter_inappwebview.CredentialDatabase;

import android.content.ContentValues;
import android.database.Cursor;

import java.util.ArrayList;
import java.util.List;

public class CredentialDao {

  CredentialDatabaseHelper credentialDatabaseHelper;
  String[] projection = {
          CredentialContract.FeedEntry._ID,
          CredentialContract.FeedEntry.COLUMN_NAME_USERNAME,
          CredentialContract.FeedEntry.COLUMN_NAME_PASSWORD,
          CredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID
  };

  public CredentialDao(CredentialDatabaseHelper credentialDatabaseHelper) {
    this.credentialDatabaseHelper = credentialDatabaseHelper;
  }

  public List<Credential> getAllByProtectionSpaceId(Long protectionSpaceId) {
    String selection = CredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID + " = ?";
    String[] selectionArgs = {protectionSpaceId.toString()};

    Cursor cursor = credentialDatabaseHelper.getReadableDatabase().query(
            CredentialContract.FeedEntry.TABLE_NAME,
            projection,
            selection,
            selectionArgs,
            null,
            null,
            null
    );

    List<Credential> credentials = new ArrayList<>();
    while (cursor.moveToNext()) {
      Long id = cursor.getLong(cursor.getColumnIndexOrThrow(CredentialContract.FeedEntry._ID));
      String username = cursor.getString(cursor.getColumnIndexOrThrow(CredentialContract.FeedEntry.COLUMN_NAME_USERNAME));
      String password = cursor.getString(cursor.getColumnIndexOrThrow(CredentialContract.FeedEntry.COLUMN_NAME_PASSWORD));
      credentials.add(new Credential(id, username, password, protectionSpaceId));
    }
    cursor.close();

    return credentials;
  }

  public Credential find(String username, String password, Long protectionSpaceId) {
    String selection = CredentialContract.FeedEntry.COLUMN_NAME_USERNAME + " = ? AND " +
            CredentialContract.FeedEntry.COLUMN_NAME_PASSWORD + " = ? AND " +
            CredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID + " = ?";
    String[] selectionArgs = {username, password, protectionSpaceId.toString()};

    Cursor cursor = credentialDatabaseHelper.getReadableDatabase().query(
            CredentialContract.FeedEntry.TABLE_NAME,
            projection,
            selection,
            selectionArgs,
            null,
            null,
            null
    );

    Credential credential = null;
    if (cursor.moveToNext()) {
      Long rowId = cursor.getLong(cursor.getColumnIndexOrThrow(CredentialContract.FeedEntry._ID));
      String rowUsername = cursor.getString(cursor.getColumnIndexOrThrow(CredentialContract.FeedEntry.COLUMN_NAME_USERNAME));
      String rowPassword = cursor.getString(cursor.getColumnIndexOrThrow(CredentialContract.FeedEntry.COLUMN_NAME_PASSWORD));
      credential = new Credential(rowId, rowUsername, rowPassword, protectionSpaceId);
    }
    cursor.close();

    return credential;
  }

  public long insert(Credential credential) {
    ContentValues credentialValues = new ContentValues();
    credentialValues.put(CredentialContract.FeedEntry.COLUMN_NAME_USERNAME, credential.username);
    credentialValues.put(CredentialContract.FeedEntry.COLUMN_NAME_PASSWORD, credential.password);
    credentialValues.put(CredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID, credential.protectionSpaceId);

    return credentialDatabaseHelper.getWritableDatabase().insert(CredentialContract.FeedEntry.TABLE_NAME, null, credentialValues);
  }

  public long update(Credential credential) {
    ContentValues credentialValues = new ContentValues();
    credentialValues.put(CredentialContract.FeedEntry.COLUMN_NAME_USERNAME, credential.username);
    credentialValues.put(CredentialContract.FeedEntry.COLUMN_NAME_PASSWORD, credential.password);

    String whereClause = CredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID + " = ?";
    String[] whereArgs = {credential.protectionSpaceId.toString()};

    return credentialDatabaseHelper.getWritableDatabase().update(CredentialContract.FeedEntry.TABLE_NAME, credentialValues, whereClause, whereArgs);
  }

  public long delete(Credential credential) {
    String whereClause = CredentialContract.FeedEntry._ID + " = ?";
    String[] whereArgs = {credential.id.toString()};

    return credentialDatabaseHelper.getWritableDatabase().delete(CredentialContract.FeedEntry.TABLE_NAME, whereClause, whereArgs);
  }

}
