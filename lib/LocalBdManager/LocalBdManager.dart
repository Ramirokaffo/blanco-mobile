import 'dart:async';

import 'package:path/path.Dart';
import 'package:sqflite/sqflite.dart';

class LocalBdManager {
  static Future localBdChangeSetting(
      String settingName, String newSettingValue) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'local.db');
    var database = await openDatabase(path);
    await database.rawUpdate('UPDATE setting SET valeur = ? WHERE name = ?',
        [newSettingValue, settingName]);
    await database.close();
  }

  static Future localBdInsertSetting(String settingName, String settingValue) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'local.db');
    var database = await openDatabase(path);
    await database.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO setting (name, valeur) VALUES("$settingName", "$settingValue")');
    });
    await database.close();
  }

  Future<bool> localBdIsThisSettingAvailable(String settingName) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'local.db');
    var database = await openDatabase(path);
    List<Map> result = await database
        .rawQuery('SELECT * FROM setting WHERE name = ?;', [settingName]);
    await database.close();
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  static Future initializeBD() async {
    print('Bd initialization.....');
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'local.db');

  // await deleteDatabase(path);
// return;
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              'CREATE TABLE setting (`id` INTEGER NOT NULL , `name` VARCHAR(45) NULL, `valeur` VARCHAR(500) NULL, PRIMARY KEY (`id`));');
          await db.execute(
          'CREATE TABLE product (`id` INTEGER NOT NULL , '
              '`code` VARCHAR(45) NULL, '
              '`name` VARCHAR(500) NULL, '
              '`brand` VARCHAR(500) NULL, '
              '`stock` INTEGER NULL, '
              '`supplyId` INTEGER NULL, '
              '`description` VARCHAR(5000) NULL, '
              '`color` VARCHAR(50) NULL, '
              '`grammage` FLOAT NULL, '
              '`unitPrice` FLOAT NULL, '
              '`unitCoast` FLOAT NULL, '
              '`maxSalablePrice` FLOAT NULL, '
              '`expAlertPeriod` FLOAT NULL, '
              '`isPriceReducible` INTEGER NULL, '
              'PRIMARY KEY (`id`));');
      await db.transaction((txn) async {
        await txn.rawInsert(
            'INSERT INTO setting (name, valeur) VALUES ("account", "0"), '
                '("user", "none"), ("serverUri", "none"), ("login", "none"), ("password", "0") ');
        // await txn.rawInsert(
        //     'INSERT INTO product (id, valeur) VALUES("user", "none")');
        // await txn.rawInsert(
        //     'INSERT INTO setting (name, valeur) VALUES("token", "none")');
      });
    });
    // database.isOpen
    await database.close();
  }

  static Future localBdSelectSetting(String settingName) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'local.db');
    var database = await openDatabase(path);
    List<Map> list = await database
        .rawQuery('SELECT valeur FROM setting WHERE name = ?', [settingName]);
    await database.close();
    return list[0]["valeur"];
  }

  // static Future getUserLocalLogin(String settingName) async {
  //   var databasesPath = await getDatabasesPath();
  //   String path = join(databasesPath, 'local.db');
  //   var database = await openDatabase(path);
  //   List<Map> list = await database
  //       .rawQuery('SELECT valeur FROM setting WHERE name = ?', [settingName]);
  //   return list[0]["valeur"];
  // }
}
