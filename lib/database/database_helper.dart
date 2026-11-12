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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
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
        estadoEntrega TEXT NOT NULL DEFAULT 'Por retirar',
        total INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE pedidos ADD COLUMN estadoEntrega TEXT NOT NULL DEFAULT 'Por retirar'",
      );
    }
  }

  Future<int> insertPedido(Order pedido) async {
    final db = await instance.database;
    return await db.insert('pedidos', pedido.toMap());
  }

  Future<List<Order>> getPedidos() async {
    final db = await instance.database;
    await _marcarVencidosComoNoRetirados(db);
    final result = await db.query('pedidos');
    return result.map((map) => Order.fromMap(map)).toList();
  }

  Future<void> _marcarVencidosComoNoRetirados(Database db) async {
    final pendientes = await db.query(
      'pedidos',
      where: 'estadoEntrega = ?',
      whereArgs: ['Por retirar'],
    );

    final ahora = DateTime.now();

    for (final map in pendientes) {
      final int? id = map['id'] as int?;
      final String fechaStr = (map['fecha'] as String?) ?? '';
      final String horaStr = (map['hora'] as String?) ?? '20:00';
      if (id == null) continue;

      final fechaRetiro = _combinarFechaYHora(fechaStr, horaStr);
      if (fechaRetiro != null &&
          ahora.isAfter(fechaRetiro.add(const Duration(days: 2)))) {
        await db.update(
          'pedidos',
          {'estadoEntrega': 'No retirado'},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }
  }

  DateTime? _combinarFechaYHora(String fechaStr, String horaStr) {
    final partesFecha = fechaStr.trim().split('/');
    if (partesFecha.length != 3) return null;

    final dia = int.tryParse(partesFecha[0]);
    final mes = int.tryParse(partesFecha[1]);
    final anio = int.tryParse(partesFecha[2]);
    if (dia == null || mes == null || anio == null) return null;

    final partesHora = horaStr.trim().split(':');
    final hora =
        partesHora.isNotEmpty ? (int.tryParse(partesHora[0]) ?? 20) : 20;
    final minuto =
        partesHora.length > 1 ? (int.tryParse(partesHora[1]) ?? 0) : 0;

    return DateTime(anio, mes, dia, hora, minuto);
  }

  Future<int> updatePedido(Order pedido) async {
    final db = await instance.database;
    return await db.update(
      'pedidos',
      pedido.toMap(),
      where: 'id = ?',
      whereArgs: [pedido.id],
    );
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

  Future<int> updateEstadoEntrega(int id, String nuevoEstado) async {
    final db = await instance.database;
    return await db.update(
      'pedidos',
      {'estadoEntrega': nuevoEstado},
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