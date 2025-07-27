import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  ///Singleton
  DBHelper._();

  static final DBHelper getInstance = DBHelper._();

  static final String TABLE_NOTE = "note";
  static final String COLUMN_NOTE_SNO = "s_no";
  static final String COLUMN_NOTE_TITLE = "title";
  static final String COLUMN_NOTE_DESC = "desc";

  Database? myDB;

  /// DB Open (path -> if exists then open else create DB)
  Future<Database> getDB() async {
    myDB ??= await openDB();
    return myDB!;

    // myDB =  myDB ?? await openDB();

    // if (myDB != null) {
    //   return myDB!;
    // } else {
    //   myDB = await openDB();
    //   return myDB!;
    // }
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();

    String dbPath = join(appDir.path, "noteDB.db");

    return await openDatabase(
      dbPath,
      onCreate: (db, version) {
        ///create all the tables here
        db.execute(
          "create table $TABLE_NOTE($COLUMN_NOTE_SNO integer primary key autoincrement, $COLUMN_NOTE_TITLE text, $COLUMN_NOTE_DESC text)",
        );
      },
      version: 1,
    );
  }

  /// all queries

  /// 1. Insertion
  Future<bool> addNote({required String mTitle, required String mDesc}) async {
    var db = await getDB();
    int rowsEffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: mTitle,
      COLUMN_NOTE_DESC: mDesc,
    });

    return rowsEffected > 0;
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();
    //Select * from note
    List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);

    return mData;
  }


}
