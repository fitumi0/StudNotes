import 'dart:async';
import 'dart:io';

import 'package:flutter_proj/database/models/student.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'models/lesson.dart';
import 'models/DropDownListModel.dart';

class DatabaseHelper {
  static int currentTimeInSeconds() {
    var ms = (DateTime.now()).millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'studNotes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS lessons(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        groupp TEXT NOT NULL,
        course INTEGER NOT NULL,
        date INTEGER NOT NULL,
        start INTEGER NOT NULL,
        type TEXT NOT NULL,
        state INTEGER NOT NULL)''');

    await db.execute('''CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        secondname TEXT NOT NULL,
        firstname TEXT NOT NULL,
        groupp TEXT NOT NULL,
        course INT NOT NULL,
        social TEXT,
        rating INT)''');

    await db.execute('''CREATE TABLE IF NOT EXISTS lessons_list(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE IF NOT EXISTS groups_list(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE IF NOT EXISTS course_list(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE IF NOT EXISTS startTime_list(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE IF NOT EXISTS lessonTypes_list(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL)''');
  }

  Future<bool> isInTable(String firstname, String secondname, String group, String course) async{
    Database db = await instance.database;
    var result = await db.rawQuery('SELECT * FROM students WHERE firstname=\'${firstname}\' AND secondname=\'${secondname}\' AND groupp=\'${group}\' AND course=${course}');
    return result.isNotEmpty;
  }


  ///
  ///
  /// DROPDOWN

  Future<List<DropDownListModel>> getLessonsDropDownList() async {
    Database db = await instance.database;
    var lessons = await db.query('lessons_list', orderBy: 'name');
    List<DropDownListModel> LessonList = lessons.isNotEmpty
        ? lessons.map((c) => DropDownListModel.fromMap(c)).toList()
        : [];
    return LessonList;
  }

  Future<int> insertIntoLessonsDropDownList(DropDownListModel lesson) async {
    Database db = await instance.database;
    return await db.insert('lessons_list', lesson.toMap());
  }

  Future<int> removeFromLessonsDropDownList(int id) async {
    Database db = await instance.database;
    return await db.delete('lessons_list', where: 'id = ?', whereArgs: [id]);
  }
  /// ===============================================================
  
  Future<List<DropDownListModel>> getGroupsDropDownList() async {
    Database db = await instance.database;
    var lessons = await db.query('groups_list', orderBy: 'name');
    List<DropDownListModel> LessonList = lessons.isNotEmpty
        ? lessons.map((c) => DropDownListModel.fromMap(c)).toList()
        : [];
    return LessonList;
  }

  Future<int> insertIntoGroupsDropDownList(DropDownListModel lesson) async {
    Database db = await instance.database;
    return await db.insert('groups_list', lesson.toMap());
  }

  Future<int> removeFromGroupsDropDownList(int id) async {
    Database db = await instance.database;
    return await db.delete('groups_list', where: 'id = ?', whereArgs: [id]);
  }
  /// ===============================================================

  Future<List<Student>> getStudentsDropDownList() async {
    Database db = await instance.database;
    var student = await db.query('students', orderBy: 'secondname');
    List<Student> StudentList = student.isNotEmpty
        ? student.map((c) => Student.fromMap(c)).toList()
        : [];
    return StudentList;
  }

  Future<int> insertIntoStudentsDropDownList(Student student) async {
    Database db = await instance.database;
    return await db.insert('students', student.toMap());
  }

  Future<int> removeFromStudentsDropDownList(int id) async {
    Database db = await instance.database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  /// END DROPDOWNS
  ///
  /// LESSONS

  Future<List<Lesson>> getLessons() async {
    Database db = await instance.database;
    var lessons = await db.query('lessons', orderBy: 'name');
    List<Lesson> LessonList = lessons.isNotEmpty
        ? lessons.map((c) => Lesson.fromMap(c)).toList()
        : [];
    return LessonList;
  }

  Future<int> insertLesson(Lesson lesson) async {
    Database db = await instance.database;
    return await db.insert('lessons', lesson.toMap());
  }

  Future<int> removeLesson(int id) async {
    Database db = await instance.database;
    return await db.delete('lessons', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateLesson(Lesson lesson) async {
    Database db = await instance.database;
    return await db.update('lessons', lesson.toMap(),
        where: "id = ?", whereArgs: [lesson.id]);
  }

  /// END LESSONS
  ///
  /// STUDENTS

  Future<List<Student>> getStudents(String group) async {
    Database db = await instance.database;
    var students = await db.rawQuery("SELECT * FROM students WHERE groupp=\'${group}\' ORDER BY secondname ASC");
    print(students);
    List<Student> StudentList = students.isNotEmpty
        ? students.map((c) => Student.fromMap(c)).toList()
        : [];
    return StudentList;
  }

  Future<int> insertStudents(Student student) async {
    Database db = await instance.database;
    return await db.insert('students', student.toMap());
  }

  Future<int> removeStudents(int id) async {
    Database db = await instance.database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateStudents(Student student) async {
    Database db = await instance.database;
    return await db.update('students', student.toMap(),
        where: "id = ?", whereArgs: [student.id]);
  }

  /// END STUDENTS
  ///
  ///

}
