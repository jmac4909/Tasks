import 'package:flutter/material.dart';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Category {
  final int id;

  final String title;
  final String description;

  Category({this.id, this.title, this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}

class Thing {
  final int id;
  final int categoryId;
  final String title;
  final String description;

  Thing({this.id, this.categoryId, this.title, this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'title': title,
      'description': description,
    };
  }
}

class Task {
  final int id;
  final int categoryId;
  final int thingId;
  final int parentTaskId;
  final int isSubtask;

  final String title;
  final String description;
  final String date;
  final String remindPref;
  final double workloadMinutues;
  final int priority;
  int completed;
  var data = {};

  Task({
    this.id,
    this.categoryId,
    this.thingId,
    this.parentTaskId,
    this.isSubtask,
    this.title,
    this.description,
    this.date,
    this.remindPref,
    this.workloadMinutues,
    this.priority,
    this.completed,
    this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'thingId': thingId,
      'parentTaskId': parentTaskId,
      'isSubtask': isSubtask,
      'title': title,
      'description': description,
      'date': date,
      'reminderPref': remindPref,
      'workloadMinutues': workloadMinutues,
      'priority': priority,
      'completed': completed
    };
  }

  set setcompleted(int newCompleted) {
    completed = newCompleted;
  }
}

void startDB() async {
  // Avoid errors caused by flutter upgrade.
// Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
// Open the database and store the reference.
  final Future<Database> database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'task_database.db'),
    // When the database is first created, create a table to store dogs.
    onCreate: (db, version) async {
      // Run the CREATE TABLE statement on the database.
      await db.execute('PRAGMA foreign_keys = ON');

      await db.execute(
        "CREATE TABLE category(id INTEGER PRIMARY KEY, title TEXT, description TEXT)",
      );
      await db.execute(
        "CREATE TABLE thing(id INTEGER PRIMARY KEY, categoryId INTEGER, title TEXT, description TEXT, FOREIGN KEY(categoryId) REFERENCES category(id))",
      );
      return await db.execute(
        "CREATE TABLE task(id INTEGER PRIMARY KEY, categoryId INTEGER, thingId INTEGER, parentTaskId INTEGER, title TEXT, description TEXT, date TEXT, reminderPref TEXT, workloadMinutues REAL, priority INTEGER, completed INTEGER, isSubtask INTEGER, FOREIGN KEY(thingId) REFERENCES thing(id), FOREIGN KEY(categoryId) REFERENCES category(id), FOREIGN KEY(parentTaskId) REFERENCES task(id))",
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
}

// Define a function that inserts dogs into the database
Future<void> insertCategory(String categoryString) async {
  // Get a reference to the database.
  final Database db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'task_database.db'),
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  final category = Category(
    title: categoryString,
    description: '',
  );
  // Insert the Dog into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same dog is inserted twice.
  //
  // In this case, replace any previous data.
  await db.insert(
    'category',
    category.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Category>> categorys() async {
  // Get a reference to the database.
  final Database db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'task_database.db'),
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  // Query the table for all The Dogs.
  final List<Map<String, dynamic>> maps = await db.query('category');

  // Convert the List<Map<String, dynamic> into a List<Dog>.
  return List.generate(maps.length, (i) {
    return Category(
      id: maps[i]['id'],
      title: maps[i]['title'],
      description: maps[i]['description'],
    );
  });
}

// Define a function that inserts dogs into the database
Future<void> insertThing(String thingString, int catId) async {
  // Get a reference to the database.
  final Database db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'task_database.db'),
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  final thing = Thing(
    title: thingString,
    categoryId: catId,
    description: '',
  );
  // Insert the Dog into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same dog is inserted twice.
  //
  // In this case, replace any previous data.
  await db.insert(
    'thing',
    thing.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Thing>> things() async {
  // Get a reference to the database.
  final Database db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'task_database.db'),
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  // Query the table for all The Dogs.
  final List<Map<String, dynamic>> maps = await db.query('thing');

  // Convert the List<Map<String, dynamic> into a List<Dog>.
  return List.generate(maps.length, (i) {
    return Thing(
      id: maps[i]['id'],
      title: maps[i]['title'],
      categoryId: maps[i]['categoryId'],
      description: maps[i]['description'],
    );
  });
}

// Define a function that inserts dogs into the database
Future<void> insertTask(Task task) async {
  // Get a reference to the database.
  final Database db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'task_database.db'),
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );

  // Insert the Dog into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same dog is inserted twice.
  //
  // In this case, replace any previous data.
  await db.insert(
    'task',
    task.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> updateTasks(Map<dynamic, dynamic> tasks) async {
  // Update some record
  final Database db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'task_database.db'),
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  for (var task in tasks.keys) {
    int count = await db.rawUpdate(
        'UPDATE task SET completed = ? WHERE id = ?', [tasks[task], task]);
    // print('updated: $count');
  }
}

Future<List<Task>> tasks() async {
  // Get a reference to the database.
  final Database db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'task_database.db'),
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  // Query the table for all The Dogs.
  final List<Map<String, dynamic>> maps = await db.query('task');
  // SELECT a.* FROM actor a;
  // db.rawQuery('SELECT * FROM "table"');

  // Convert the List<Map<String, dynamic> into a List<Dog>.
  return List.generate(maps.length, (i) {
    return Task(
      id: maps[i]['id'],
      categoryId: maps[i]['categoryId'],
      thingId: maps[i]['thingId'],
      parentTaskId: maps[i]['parentTaskId'],
      isSubtask: maps[i]['isSubtask'],
      title: maps[i]['title'],
      description: maps[i]['description'],
      date: maps[i]['date'],
      remindPref: maps[i]['reminderPref'],
      workloadMinutues: maps[i]['workloadMinutues'],
      priority: maps[i]['priority'],
      completed: maps[i]['completed'],
    );
  });
}

Future<List<Task>> taskWithCatAndThingNames() async {
  // Get a reference to the database.
  final Database db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'task_database.db'),
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  // Query the table for all The Dogs.
  final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT t.*, c.title AS catTitle, th.title AS thingTitle  FROM "task" t LEFT JOIN "category" c ON t.categoryId=c.id LEFT JOIN "thing" th ON t.thingId=th.id');
  // SELECT a.* FROM actor a;
  // db.rawQuery('SELECT * FROM "table"');

  // Convert the List<Map<String, dynamic> into a List<Dog>.
  return List.generate(maps.length, (i) {
    return Task(
      id: maps[i]['id'],
      categoryId: maps[i]['categoryId'],
      thingId: maps[i]['thingId'],
      parentTaskId: maps[i]['parentTaskId'],
      isSubtask: maps[i]['isSubtask'],
      title: maps[i]['title'],
      description: maps[i]['description'],
      date: maps[i]['date'],
      remindPref: maps[i]['reminderPref'],
      workloadMinutues: maps[i]['workloadMinutues'],
      priority: maps[i]['priority'],
      completed: maps[i]['completed'],
      data: {
        'thingTitle': maps[i]['thingTitle'],
        'catTitle': maps[i]['catTitle'],
      },
    );
  });
}

Future<List<Task>> taskForSubtasks(int taskId) async {
  // Get a reference to the database.
  final Database db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'task_database.db'),
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  // Query the table for all The Dogs.
  // final List<Map<String, dynamic>> maps =
  // await db.query('task', where: 'id = ?', whereArgs: [taskId], );
  // SELECT a.* FROM actor a;
  final List<Map<String, dynamic>> maps = await db
      .rawQuery('SELECT * FROM "task" WHERE parentTaskId = ?', [taskId]);

  // Convert the List<Map<String, dynamic> into a List<Task>.
  return List.generate(maps.length, (i) {
    return Task(
      id: maps[i]['id'],
      categoryId: maps[i]['categoryId'],
      thingId: maps[i]['thingId'],
      parentTaskId: maps[i]['parentTaskId'],
      isSubtask: maps[i]['isSubtask'],
      title: maps[i]['title'],
      description: maps[i]['description'],
      date: maps[i]['date'],
      remindPref: maps[i]['reminderPref'],
      workloadMinutues: maps[i]['workloadMinutues'],
      priority: maps[i]['priority'],
      completed: maps[i]['completed'],
    );
  });
}
