import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:chatify/models/log.dart';
import 'package:chatify/resources/local_db/interface/log_interface.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../constants/constants.dart';

class SqliteMethods implements LogInterface {
  Database? _db;
  String databaseName = "";

  Future<Database> get db async {
    print("db was null, now awaiting it");
    _db = await init();
    return _db!;
  }

  @override
  openDb(dbName) => (databaseName = dbName);

  @override
  init() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, databaseName);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(final Database db, final int version) async {
    final String createTableQuery =
        "CREATE TABLE ${Constants.CALL_LOGS_TABLE_NAME} (${Constants.LOG_ID} INTEGER PRIMARY KEY, ${Constants.CALLER_NAME} TEXT, ${Constants.CALLER_PIC} TEXT, ${Constants.RECEIVER_NAME} TEXT, ${Constants.RECEIVER_PIC} TEXT, ${Constants.CALL_STATUS} TEXT, ${Constants.TIMESTAMP} TEXT)";

    await db.execute(createTableQuery);
    print("table created");
  }

  @override
  addLogs(Log log) async {
    var dbClient = await db;
    print("the log has been added in sqlite db");
    await dbClient.insert(Constants.CALL_LOGS_TABLE_NAME, log.toMap(log));
  }

  updateLogs(Log log) async {
    var dbClient = await db;
    await dbClient.update(
      Constants.CALL_LOGS_TABLE_NAME,
      log.toMap(log),
      where: '${Constants.LOG_ID} = ?',
      whereArgs: [log.logId],
    );
  }

  @override
  Future<List<Log>> getLogs() async {
    try {
      var dbClient = await db;
      List<Map> maps = await dbClient.query(
        Constants.CALL_LOGS_TABLE_NAME,
        columns: [
          Constants.LOG_ID,
          Constants.CALLER_NAME,
          Constants.CALLER_PIC,
          Constants.RECEIVER_NAME,
          Constants.RECEIVER_PIC,
          Constants.CALL_STATUS,
          Constants.TIMESTAMP,
        ],
      );

      List<Log> logList = [];

      if (maps.isNotEmpty) {
        for (Map map in maps) {
          logList.add(Log.fromMap(map));
        }
      }

      return logList;
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  deleteLogs(int logId) async {
    var client = await db;
    return await client.delete(Constants.CALL_LOGS_TABLE_NAME,
        where: '${Constants.LOG_ID} = ?', whereArgs: [logId + 1]);
  }

  @override
  close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
