import 'package:flutter/material.dart';
import 'package:heart_beat_monitor/models/session.dart';
import 'package:heart_beat_monitor/models/user.dart';
import 'package:heart_beat_monitor/utils/constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBService {
  Future<Database> initializeDB() async {
    String path = '${await getDatabasesPath()}heart_monitor_database.db';
    return openDatabase(
      join(path),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE $kDBTableUserName(id INTEGER PRIMARYKEY, name TEXT, age INTEGER, userDisease TEXT, emergencyNumber INTEGER, isAthlete TEXT)',
        );
        db.execute(
          'CREATE TABLE $kDBTableSessionName(id INTEGER PRIMARYKEY, dateTime TEXT, bpm INTEGER, userID INTEGER NOT NULL, FOREIGN KEY (userID) REFERENCES $kDBTableUserName (id) ON UPDATE CASCADE ON DELETE CASCADE)',
        );
      },
      version: 1,
    );
  }

  // Delete the Database
  Future<void> deleteDatabase() async {
    String path = '${await getDatabasesPath()}heart_monitor_database.db';
    databaseFactory.deleteDatabase(path);
  }

  // User
  Future<List<User>> getUsers() async {
    debugPrint('getting all users');
    Database db = await initializeDB();
    List<Map<String, dynamic>> maps = await db.query(kDBTableUserName);
    return maps.map((e) => User.fromMap(e)).toList();
  }

  Future<User> getUserByID(int id) async {
    debugPrint('getting user by id $id');
    Database db = await initializeDB();
    List<Map<String, dynamic>> map =
        await db.query(kDBTableUserName, where: 'id = ?', whereArgs: [id]);
    return map.map((e) => User.fromMap(e)).toList().first;
  }

  Future<void> deleteUsers() async {
    debugPrint('deleting all users');
    Database db = await initializeDB();
    await db.delete(kDBTableUserName, where: null);
  }

  Future<void> deleteUserByID(int id) async {
    debugPrint('deleting user by id');
    Database db = await initializeDB();
    await db.delete(kDBTableUserName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertUser(User user) async {
    debugPrint('inserting a user');
    Database db = await initializeDB();
    await db.insert(
      kDBTableUserName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUser(User user) async {
    debugPrint('updating a user ${user.id}');
    Database db = await initializeDB();
    await db.update(
      kDBTableUserName,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

// Sessions
  Future<List<Session>> getSessions(int userID) async {
    debugPrint('getting all sessions');
    Database db = await initializeDB();
    List<Map<String, dynamic>> maps = await db
        .query(kDBTableSessionName, where: 'userID = ?', whereArgs: [userID]);
    return maps.map((e) => Session.fromMap(e)).toList();
  }

  Future<int> deleteSessions() async {
    debugPrint('deleting all sessions');
    Database db = await initializeDB();
    return await db.delete(kDBTableSessionName, where: null);
  }

  Future<void> deleteSessionByID(int id) async {
    debugPrint('deleting session by id');
    Database db = await initializeDB();
    await db.delete(kDBTableSessionName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertSession(Session session) async {
    debugPrint('inserting a session');
    Database db = await initializeDB();
    return await db.insert(
      kDBTableSessionName,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
