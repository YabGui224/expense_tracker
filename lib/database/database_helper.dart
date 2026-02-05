import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/category.dart';

/// DatabaseHelper class manages all database operations
/// Uses SQLite for local storage of expenses
/// Implements Singleton pattern to ensure only one database instance
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Private constructor for Singleton pattern
  DatabaseHelper._init();

  /// Gets the database instance, creating it if it doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  /// Initializes the database
  /// Creates the database file at the specified path
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Creates the expenses table in the database
  /// Called automatically when the database is first created
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category INTEGER NOT NULL
      )
    ''');
  }

  /// Inserts a new expense into the database
  /// Returns the ID of the newly inserted expense
  Future<int> createExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  /// Retrieves a single expense by its ID
  /// Returns null if no expense with that ID exists
  Future<Expense?> getExpense(int id) async {
    final db = await database;
    final maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves all expenses from the database
  /// Returns them sorted by date (newest first)
  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  /// Updates an existing expense in the database
  /// Returns the number of rows affected (should be 1)
  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  /// Deletes an expense from the database
  /// Returns the number of rows affected (should be 1)
  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes all expenses from the database
  /// Useful for testing or resetting the app
  Future<int> deleteAllExpenses() async {
    final db = await database;
    return await db.delete('expenses');
  }

  /// Gets expenses filtered by date range
  /// Useful for calculating daily, weekly, or monthly totals
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  /// Gets the total amount spent by category
  /// Returns a Map with category as key and total amount as value
  Future<Map<ExpenseCategory, double>> getTotalByCategory() async {
    final db = await database;
    final Map<ExpenseCategory, double> categoryTotals = {};

    // Initialize all categories with 0
    for (var category in ExpenseCategory.values) {
      categoryTotals[category] = 0.0;
    }

    // Get all expenses
    final result = await db.query('expenses');
    for (var map in result) {
      final expense = Expense.fromMap(map);
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals;
  }

  /// Closes the database connection
  /// Should be called when the app is being terminated
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
