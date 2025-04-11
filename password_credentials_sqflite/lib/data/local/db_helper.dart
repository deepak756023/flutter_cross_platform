import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper getInstance = DBHelper._();

  // Table name and Column names
  static final String TABLE = "Credential";
  static final String COLUMN_CREDENTIAL_ID = "id";
  static final String COLUMN_TITLE_NAME = "titleName";
  static final String COLUMN_USERNAME = "userName";
  static final String COLUMN_PASSWORD = "password";

  static final String CODE_TABLE = "Auth_Code";
  static final String COLUMN_AUTH_CODE = "code";

  Database? myDB;
  // Open Database (Create if not exists)
  Future<Database> getDB() async {
    myDB ??= await openDB();
    return myDB!;
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, 'credentials.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $TABLE (
            $COLUMN_CREDENTIAL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            $COLUMN_TITLE_NAME TEXT,
            $COLUMN_USERNAME TEXT, 
            $COLUMN_PASSWORD TEXT
          )
        ''');

        db.execute('''
          CREATE TABLE $CODE_TABLE (
            $COLUMN_AUTH_CODE TEXT
        )
      ''');
      },
    );
  }

  Future<void> saveAuthCode(String code) async {
    final db = await getDB();
    await db.delete(CODE_TABLE);
    await db.insert(CODE_TABLE, {COLUMN_AUTH_CODE: code});
    print(code);
  }

  Future<String?> getAuthCode() async {
    final db = await getDB();
    final List<Map<String, dynamic>> result = await db.query(CODE_TABLE);
    if (result.isNotEmpty) {
      return result.first[DBHelper.COLUMN_AUTH_CODE] as String;
    }
    return null;
  }

  Future<void> deleteAuthCode() async {
    final db = await getDB();
    await db.delete(CODE_TABLE);
  }

  //CRUD Operations

  //Create(Insert)
  Future<bool> addCredential({
    required String mTitle,
    required String mUserName,
    required String mPassword,
  }) async {
    var db = await getDB();
    int rowsEffected = await db.insert(TABLE, {
      COLUMN_TITLE_NAME: mTitle,
      COLUMN_USERNAME: mUserName,
      COLUMN_PASSWORD: mPassword,
    });
    return rowsEffected > 0;
  }

  // Read(All)
  Future<List<Map<String, dynamic>>> getAllCredentials() async {
    var db = await getDB();
    List<Map<String, dynamic>> mData = await db.query(TABLE);
    return mData;
  }

  // update
  Future<bool> updateCredential({
    required int id,
    required String mTitle,
    required String mUserName,
    required String mPassword,
  }) async {
    var db = await getDB();
    int rowsEffected = await db.update(
      TABLE,
      {
        COLUMN_TITLE_NAME: mTitle,
        COLUMN_USERNAME: mUserName,
        COLUMN_PASSWORD: mPassword,
      },
      where: "$COLUMN_CREDENTIAL_ID = ?",
      whereArgs: [id],
    );
    return rowsEffected > 0;
  }

  // delete
  Future<bool> deleteCredential({required int id}) async {
    var db = await getDB();
    int rowsEffected = await db.delete(
      TABLE,
      where: "$COLUMN_CREDENTIAL_ID = ?",
      whereArgs: [id],
    );
    return rowsEffected > 0;
  }
}
