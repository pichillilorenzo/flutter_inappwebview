package com.pichillilorenzo.flutter_inappwebview.CredentialDatabase;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import java.util.ArrayList;
import java.util.List;

public class ProtectionSpaceDao {
  CredentialDatabaseHelper credentialDatabaseHelper;
  String[] projection = {
          ProtectionSpaceContract.FeedEntry._ID,
          ProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST,
          ProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL,
          ProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM,
          ProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT
  };

  public ProtectionSpaceDao(CredentialDatabaseHelper credentialDatabaseHelper) {
    this.credentialDatabaseHelper = credentialDatabaseHelper;
  }

  public List<ProtectionSpace> getAll() {
    SQLiteDatabase readableDatabase = credentialDatabaseHelper.getReadableDatabase();

    Cursor cursor = readableDatabase.query(
            ProtectionSpaceContract.FeedEntry.TABLE_NAME,
            projection,
            null,
            null,
            null,
            null,
            null
    );

    List<ProtectionSpace> protectionSpaces = new ArrayList<>();
    while (cursor.moveToNext()) {
      Long rowId = cursor.getLong(cursor.getColumnIndexOrThrow(ProtectionSpaceContract.FeedEntry._ID));
      String rowHost = cursor.getString(cursor.getColumnIndexOrThrow(ProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST));
      String rowProtocol = cursor.getString(cursor.getColumnIndexOrThrow(ProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL));
      String rowRealm = cursor.getString(cursor.getColumnIndexOrThrow(ProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM));
      Integer rowPort = cursor.getInt(cursor.getColumnIndexOrThrow(ProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT));
      protectionSpaces.add(new ProtectionSpace(rowId, rowHost, rowProtocol, rowRealm, rowPort));
    }
    cursor.close();

    return protectionSpaces;
  }

  public ProtectionSpace find(String host, String protocol, String realm, Integer port) {
    SQLiteDatabase readableDatabase = credentialDatabaseHelper.getReadableDatabase();

    String selection = ProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST + " = ? AND " + ProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL + " = ? AND " +
            ProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM + " = ? AND " + ProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT + " = ?";
    String[] selectionArgs = {host, protocol, realm, port.toString()};

    Cursor cursor = readableDatabase.query(
            ProtectionSpaceContract.FeedEntry.TABLE_NAME,
            projection,
            selection,
            selectionArgs,
            null,
            null,
            null
    );

    ProtectionSpace protectionSpace = null;
    if (cursor.moveToNext()) {
      Long rowId = cursor.getLong(cursor.getColumnIndexOrThrow(ProtectionSpaceContract.FeedEntry._ID));
      String rowHost = cursor.getString(cursor.getColumnIndexOrThrow(ProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST));
      String rowProtocol = cursor.getString(cursor.getColumnIndexOrThrow(ProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL));
      String rowRealm = cursor.getString(cursor.getColumnIndexOrThrow(ProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM));
      Integer rowPort = cursor.getInt(cursor.getColumnIndexOrThrow(ProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT));
      protectionSpace = new ProtectionSpace(rowId, rowHost, rowProtocol, rowRealm, rowPort);
    }
    cursor.close();

    return protectionSpace;
  }

  public long insert(ProtectionSpace protectionSpace) {
    ContentValues protectionSpaceValues = new ContentValues();
    protectionSpaceValues.put(ProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST, protectionSpace.host);
    protectionSpaceValues.put(ProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL, protectionSpace.procotol);
    protectionSpaceValues.put(ProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM, protectionSpace.realm);
    protectionSpaceValues.put(ProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT, protectionSpace.port);

    return credentialDatabaseHelper.getWritableDatabase().insert(ProtectionSpaceContract.FeedEntry.TABLE_NAME, null, protectionSpaceValues);
  };

  public long delete(ProtectionSpace protectionSpace) {
    String whereClause = ProtectionSpaceContract.FeedEntry._ID + " = ?";
    String[] whereArgs = {protectionSpace.id.toString()};

    return credentialDatabaseHelper.getWritableDatabase().delete(ProtectionSpaceContract.FeedEntry.TABLE_NAME, whereClause, whereArgs);
  }
}