import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/order_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('amasanderia.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
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

  Future<List<Order>> getPedidos() async {
    final db = await instance.database;
    final result = await db.query('pedidos');
    return result.map((map) => Order.fromMap(map)).toList();
  }

  Future<int> updateEstadoPago(int id, String nuevoEstado) async {
    final db = await instance.database;
    return await db.update(
      'pedidos',
      {'estadoPago': nuevoEstado},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePedido(int id) async {
    final db = await instance.database;
    return await db.delete(
      'pedidos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}