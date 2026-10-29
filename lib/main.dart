import 'dart:math';
import 'package:flutter/material.dart';
import 'models/order_model.dart';
import 'services/database_service.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.grey,
        primary: Colors.black87,
      ),
    ),
    home: const PoCSQLiteScreen(),
  ));
}

class PoCSQLiteScreen extends StatefulWidget {
  const PoCSQLiteScreen({super.key});

  @override
  State<PoCSQLiteScreen> createState() => _PoCSQLiteScreenState();
}

class _PoCSQLiteScreenState extends State<PoCSQLiteScreen> {
  List<Order> _listaPedidos = [];
  String _estadoTecnico = "Estado: En espera de acción (SQLite Listo)";

  final List<String> _clientesGenericos = [
    'Cliente 01',
    'Cliente 02',
    'Cliente 03',
    'Cliente 04',
    'Cliente 05',
  ];
  final List<String> _medidas = ['Grande', 'Mediana', 'Cóctel'];
  final List<String> _tiposMasa = ['Horno', 'Frita'];
  final List<String> _estadosPago = ['Pagado', 'Por pagar'];

  final Map<String, Map<String, int>> _preciosUnitarios = {
    'Grande': {'Horno': 220, 'Frita': 220},
    'Mediana': {'Horno': 210, 'Frita': 200},
    'Cóctel': {'Horno': 190, 'Frita': 180},
  };

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    try {
      final pedidos = await DatabaseService.instance.fetchPedidos();
      if (!mounted) return;
      setState(() {
        _listaPedidos = pedidos;
        _estadoTecnico = "Éxito: ${pedidos.length} pedidos leídos desde SQLite";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _estadoTecnico = "Error de lectura en SQLite: $e");
    }
  }

  Future<void> _gatillarPedidoAleatorio() async {
    try {
      setState(() => _estadoTecnico = "Procesando transacción asíncrona...");

      final random = Random();
      final cliente = _clientesGenericos[random.nextInt(_clientesGenericos.length)];
      
      final tieneContacto = random.nextBool();
      final numeroAzar = 10000000 + random.nextInt(89999999);
      final contacto = tieneContacto ? '+569$numeroAzar' : 'Sin contacto';

      final medida = _medidas[random.nextInt(_medidas.length)];
      final tipoMasa = _tiposMasa[random.nextInt(_tiposMasa.length)];
      final estadoPago = _estadosPago[random.nextInt(_estadosPago.length)];
      
      final cantidad = 10 + random.nextInt(191);

      final precioUnitario = _preciosUnitarios[medida]?[tipoMasa] ?? 200;
      final totalCalculado = cantidad * precioUnitario;

      final ahora = DateTime.now();
      final fechaActual = "${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}";
      final horaActual = "${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}";

      final nuevoPedido = Order(
        cliente: cliente,
        contacto: contacto,
        fecha: fechaActual,
        hora: horaActual,
        tipoMasa: tipoMasa,
        medidaMasa: medida,
        cantidad: cantidad,
        estadoPago: estadoPago,
        total: totalCalculado,
      );

      final idInsertado = await DatabaseService.instance.insertPedido(nuevoPedido);

      if (!mounted) return;

      _cargarPedidos();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Gatillado exitoso! Pedido #$idInsertado guardado en SQLite ($cantidad u.)'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _estadoTecnico = "Error de persistencia: $e");
    }
  }

  Future<void> _vaciarBaseDatos() async {
    try {
      await DatabaseService.instance.clearPedidos();
      if (!mounted) return;
      
      _cargarPedidos();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Base de datos vaciada correctamente.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _estadoTecnico = "Error al vaciar SQLite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PoC SQLite - Agendamiento Amasandería"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _estadoTecnico,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _gatillarPedidoAleatorio,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.black87,
                backgroundColor: Colors.grey.shade200,
                elevation: 0,
              ),
              icon: const Icon(Icons.flash_on, color: Colors.black87),
              label: const Text("Hacer pedido aleatorio"),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _cargarPedidos,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.black87),
                    label: const Text("Consultar SQLite"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _vaciarBaseDatos,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    icon: const Icon(Icons.delete_outline, color: Colors.black87),
                    label: const Text("Vaciar BD"),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            const Text(
              "Pedidos guardados con éxito",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: _listaPedidos.isEmpty
                ? const Center(
                  child: Text(
                    "La base de datos SQLite está vacía.",
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : ListView.builder(
                itemCount: _listaPedidos.length,
                itemBuilder: (context, index) {
                  final p = _listaPedidos[index];
                  return Card(
                    elevation: 1,
                    color: Colors.grey.shade50,
                    child: ListTile(
                      leading: Text(
                        '#${p.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      title: Text(
                        "${p.cliente} (${p.medidaMasa} - ${p.tipoMasa})",
                        style: const TextStyle(color: Colors.black87),
                      ),
                      subtitle: Text(
                        "Tel: ${p.contacto} | Cant: ${p.cantidad} u. | ${p.fecha} ${p.hora}",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "\$${p.total}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            p.estadoPago,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}