import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import '../models/order_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('amasanderia.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final dbLocation = path.join(dbPath, filePath);

    return await openDatabase(
      dbLocation,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente TEXT NOT NULL,
        contacto TEXT NOT NULL,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL,
        tipoMasa TEXT NOT NULL,
        medidaMasa TEXT NOT NULL,
        cantidad INTEGER NOT NULL,
        estadoPago TEXT NOT NULL,
        total INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertPedido(Order pedido) async {
    final db = await instance.database;
    return await db.insert('pedidos', pedido.toMap());
  }

  Future<List<Order>> fetchPedidos() async {
    final db = await instance.database;
    final result = await db.query('pedidos', orderBy: 'id DESC');
    return result.map((json) => Order.fromMap(json)).toList();
  }

  Future<void> clearPedidos() async {
    final db = await instance.database;
    await db.delete('pedidos');
    await db.delete('sqlite_sequence', where: 'name = ?', whereArgs: ['pedidos']);
  }

  // Eliminar un pedido individual por ID
  Future<int> deletePedido(int id) async {
    final db = await instance.database;
    return await db.delete('pedidos', where: 'id = ?', whereArgs: [id]);
  }

  // Actualizar un pedido existente por ID
  Future<int> updatePedido(Order pedido) async {
    final db = await instance.database;
    return await db.update(
      'pedidos',
      pedido.toMap(),
      where: 'id = ?',
      whereArgs: [pedido.id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}