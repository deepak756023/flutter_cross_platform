import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  // Singleton
  DBHelper._();
  static final DBHelper getInstance = DBHelper._();

  // Table name and Column names
  static final String TABLE = "currency";
  static final String COLUMN_COUNTRY_NAME = "countryName";
  static final String COLUMN_CURRENCY_NAME = "currencyName";
  static final String COLUMN_EXCHANGE_RATE = "exchangeRate";

  Database? myDB;
  // Open Database (Create if not exists)
  Future<Database> getDB() async {
    myDB ??= await openDB();
    return myDB!;
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, 'currencies.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $TABLE (
            $COLUMN_COUNTRY_NAME TEXT PRIMARY KEY,
            $COLUMN_CURRENCY_NAME TEXT, 
            $COLUMN_EXCHANGE_RATE REAL
          )
        ''');
      },
    );
  }

  // CRUD Operations

  // Insert(Create)
  Future<bool> addCurrency({
    required String mCountry,
    required String mCurrency,
    required double mExchangeRate,
  }) async {
    var db = await getDB();
    int rowsEffected = await db.insert(TABLE, {
      COLUMN_COUNTRY_NAME: mCountry,
      COLUMN_CURRENCY_NAME: mCurrency,
      COLUMN_EXCHANGE_RATE: mExchangeRate,
    });
    return rowsEffected > 0;
  }

  // read all Details
  Future<List<Map<String, dynamic>>> getAllCurrencies() async {
    var db = await getDB();
    List<Map<String, dynamic>> mData = await db.query(TABLE);
    return mData;
  }

  // update
  Future<bool> updateCurrency({
    required String mCountry,
    required String mCurrency,
    required double mExchangeRate,
  }) async {
    var db = await getDB();
    int rowsEffected = await db.update(
      TABLE,
      {
        COLUMN_COUNTRY_NAME: mCountry,
        COLUMN_CURRENCY_NAME: mCurrency,
        COLUMN_EXCHANGE_RATE: mExchangeRate,
      },
      where: "$COLUMN_COUNTRY_NAME = ?",
      whereArgs: [mCountry],
    );
    return rowsEffected > 0;
  }

  // delete
  Future<bool> deleteCurrency({required String mCountry}) async {
    var db = await getDB();
    int rowsEffected = await db.delete(
      TABLE,
      where: "$COLUMN_COUNTRY_NAME = ?",
      whereArgs: [mCountry],
    );
    return rowsEffected > 0;
  }

  //get all currency names for dropdown select
  Future<List<String>> getAllCurrenciesNames() async {
    var db = await getDB();
    List<Map<String, dynamic>> result = await db.query(TABLE);
    List<String> mData =
        result.map((row) => row[COLUMN_CURRENCY_NAME] as String).toList();
    return mData;
  }

  //find out the exchange rate of a perticular currency
  Future<double> getExchangeRate(String currencyName) async {
    var db = await getDB();
    List<Map<String, dynamic>> result = await db.query(
      TABLE,
      columns: [COLUMN_EXCHANGE_RATE],
      where: "$COLUMN_CURRENCY_NAME = ?",
      whereArgs: [currencyName],
      limit: 1,
    );
    return result.first[COLUMN_EXCHANGE_RATE] as double;
  }
}
