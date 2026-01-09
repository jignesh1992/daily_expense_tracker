import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:pocketa_expense_tracker/models/expense.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expenses.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expense_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Expense CRUD
  Future<void> insertExpense(Expense expense, {bool synced = false}) async {
    final db = await database;
    await db.insert(
      'expenses',
      {
        ...expense.toJson(),
        'synced': synced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> getAllExpenses({
    DateTime? date,
    Category? category,
    String? userId,
  }) async {
    final db = await database;
    final List<String> whereConditions = [];
    final List<dynamic> whereArgs = [];

    // Filter by userId if provided, otherwise show all expenses
    // This allows showing expenses even if userId is not set or doesn't match
    if (userId != null && userId.isNotEmpty) {
      whereConditions.add('userId = ?');
      whereArgs.add(userId);
    }
    // If userId is null/empty, don't filter by userId (show all expenses)

    if (date != null) {
      // Filter by date (compare only date part, not time)
      // Use UTC dates for filtering to match how dates are stored
      final filterDateUtc = DateTime.utc(date.year, date.month, date.day);
      final startOfDay = filterDateUtc;
      final endOfDay = DateTime.utc(date.year, date.month, date.day, 23, 59, 59, 999);
      whereConditions.add('date >= ? AND date <= ?');
      whereArgs.add(startOfDay.toIso8601String());
      whereArgs.add(endOfDay.toIso8601String());
    }

    if (category != null) {
      whereConditions.add('category = ?');
      whereArgs.add(category.name);
    }

    final whereClause = whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null;
    print('Querying expenses - whereClause: $whereClause, whereArgs: $whereArgs');
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'createdAt DESC', // Order by createdAt DESC to show latest first
    );
    print('Found ${maps.length} expenses in database');
    final expenses = maps.map((map) => _mapToExpense(map)).toList();
    print('Mapped to ${expenses.length} expense objects');
    return expenses;
  }

  Future<Expense?> getExpense(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return _mapToExpense(maps.first);
  }

  Future<void> updateExpense(Expense expense, {bool synced = false}) async {
    final db = await database;
    await db.update(
      'expenses',
      {
        ...expense.toJson(),
        'synced': synced ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // Sync queue
  Future<void> addToSyncQueue(String expenseId, String operation, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('sync_queue', {
      'expense_id': expenseId,
      'operation': operation, // 'create', 'update', 'delete'
      'data': jsonEncode(data),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'created_at ASC');
  }

  Future<void> removeFromSyncQueue(int queueId) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [queueId]);
  }

  Future<void> markExpenseAsSynced(String expenseId) async {
    final db = await database;
    await db.update('expenses', {'synced': 1}, where: 'id = ?', whereArgs: [expenseId]);
  }

  Expense _mapToExpense(Map<String, dynamic> map) {
    // Parse the date string and extract date components from UTC
    final dateString = map['date'] as String;
    final parsedDate = DateTime.parse(dateString);
    
    // Extract date components from UTC to avoid timezone shifts
    final utcDate = parsedDate.isUtc ? parsedDate : parsedDate.toUtc();
    final localDate = DateTime(
      utcDate.year,
      utcDate.month,
      utcDate.day,
    );
    
    return Expense(
      id: map['id'] as String,
      userId: map['userId'] as String,
      amount: map['amount'] as double,
      category: Category.fromString(map['category'] as String),
      description: map['description'] as String?,
      date: localDate,
      createdAt: DateTime.parse(map['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(map['updatedAt'] as String).toLocal(),
    );
  }
}
