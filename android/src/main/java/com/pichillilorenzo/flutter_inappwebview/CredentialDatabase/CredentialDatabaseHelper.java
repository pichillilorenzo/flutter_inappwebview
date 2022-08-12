package com.pichillilorenzo.flutter_inappwebview.CredentialDatabase;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class CredentialDatabaseHelper extends SQLiteOpenHelper {

  private static final String SQL_CREATE_PROTECTION_SPACE_TABLE =
          "CREATE TABLE " + ProtectionSpaceContract.FeedEntry.TABLE_NAME + " (" +
                  ProtectionSpaceContract.FeedEntry._ID + " INTEGER PRIMARY KEY," +
                  ProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST + " TEXT NOT NULL," +
                  ProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL + " TEXT," +
                  ProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM + " TEXT," +
                  ProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT + " INTEGER," +
                  "UNIQUE(" + ProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST + ", " + ProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL + ", " +
                  ProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM + ", " + ProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT +
                  ")" +
          ");";

  private static final String SQL_CREATE_CREDENTIAL_TABLE =
          "CREATE TABLE " + CredentialContract.FeedEntry.TABLE_NAME + " (" +
                  CredentialContract.FeedEntry._ID + " INTEGER PRIMARY KEY," +
                  CredentialContract.FeedEntry.COLUMN_NAME_USERNAME + " TEXT NOT NULL," +
                  CredentialContract.FeedEntry.COLUMN_NAME_PASSWORD + " TEXT NOT NULL," +
                  CredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID + " INTEGER NOT NULL," +
                  "UNIQUE(" + CredentialContract.FeedEntry.COLUMN_NAME_USERNAME + ", " + CredentialContract.FeedEntry.COLUMN_NAME_PASSWORD + ", " +
                  CredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID +
                  ")," +
                  "FOREIGN KEY (" + CredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID + ") REFERENCES " +
                  ProtectionSpaceContract.FeedEntry.TABLE_NAME + " (" + ProtectionSpaceContract.FeedEntry._ID + ") ON DELETE CASCADE" +
          ");";

  private static final String SQL_DELETE_PROTECTION_SPACE_TABLE =
          "DROP TABLE IF EXISTS " + ProtectionSpaceContract.FeedEntry.TABLE_NAME;

  private static final String SQL_DELETE_CREDENTIAL_TABLE =
          "DROP TABLE IF EXISTS " + CredentialContract.FeedEntry.TABLE_NAME;

  public CredentialDatabaseHelper(Context context) {
    super(context, CredentialDatabase.DATABASE_NAME, null, CredentialDatabase.DATABASE_VERSION);
  }

  public void onCreate(SQLiteDatabase db) {
    db.execSQL(SQL_CREATE_PROTECTION_SPACE_TABLE);
    db.execSQL(SQL_CREATE_CREDENTIAL_TABLE);
  }

  public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
    // This database is only a cache for online data, so its upgrade policy is
    // to simply to discard the data and start over
    db.execSQL(SQL_DELETE_PROTECTION_SPACE_TABLE);
    db.execSQL(SQL_DELETE_CREDENTIAL_TABLE);
    onCreate(db);
  }

  public void onDowngrade(SQLiteDatabase db, int oldVersion, int newVersion) {
    onUpgrade(db, oldVersion, newVersion);
  }

  public void clearAllTables(SQLiteDatabase db) {
    db.execSQL(SQL_DELETE_PROTECTION_SPACE_TABLE);
    db.execSQL(SQL_DELETE_CREDENTIAL_TABLE);
    onCreate(db);
  }
}
