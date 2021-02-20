import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;

class DatabaseUtil {
  static Future<Database> database;

  static Future<Database> getDatabase() {
    if (database == null){
      database = getDatabasesPath().then((String path) {
        return openDatabase(
          Path.join(path, 'wheel_items_database.db'),
          onCreate: (db, version) {
            //SQL Creation
            return db.execute(
              "CREATE TABLE items(id TEXT PRIMARY KEY, name TEXT);",
            );
          },
          version: 1,
        );
      },
      );
      return database;
    }else {
      return database;
    }
  }
}
