import 'package:flutter/material.dart';
import '../models/order_model.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final List<Order> pedidos = [
    Order(cliente: 'Rupertina', contacto: '945612378', fecha: '03/10/2026', hora: '10:00', tipoMasa: 'Horno', medidaMasa: 'Coctel', cantidad: 50, estadoPago: 'Pagado', total: 9500),
    Order(cliente: 'Ruperto', contacto: '932145687', fecha: '03/10/2026', hora: '11:00', tipoMasa: 'Frita', medidaMasa: 'Mediana', cantidad: 70, estadoPago: 'Por pagar', total: 14000),
    Order(cliente: 'Marisol', contacto: '912348765', fecha: '03/10/2026', hora: '10:00', tipoMasa: 'Horno', medidaMasa: 'Mediana', cantidad: 450, estadoPago: 'Pagado', total: 94500),
    Order(cliente: 'Juan Perez', contacto: '988776655', fecha: '03/10/2026', hora: '13:00', tipoMasa: 'Frita', medidaMasa: 'Grande', cantidad: 600, estadoPago: 'Por pagar', total: 132000),
    Order(cliente: 'Juan Gabriel', contacto: '999888777', fecha: '03/10/2026', hora: '16:00', tipoMasa: 'Horno', medidaMasa: 'Coctel', cantidad: 1000, estadoPago: 'Pagado', total: 190000),
    Order(cliente: 'Miguel Bose', contacto: '944332211', fecha: '03/10/2026', hora: '18:00', tipoMasa: 'Frita', medidaMasa: 'Mediana', cantidad: 800, estadoPago: 'Por pagar', total: 160000),

    Order(cliente: 'Lorenzo Gutierrez', contacto: '978541236', fecha: '04/10/2026', hora: '12:00', tipoMasa: 'Frita', medidaMasa: 'Coctel', cantidad: 90, estadoPago: 'Pagado', total: 16200),
    Order(cliente: 'El rey de la empanada', contacto: '911223344', fecha: '04/10/2026', hora: '14:00', tipoMasa: 'Horno', medidaMasa: 'Grande', cantidad: 800, estadoPago: 'Por pagar', total: 176000),
    Order(cliente: 'Miranda Rosa', contacto: '955443322', fecha: '04/10/2026', hora: '11:00', tipoMasa: 'Horno', medidaMasa: 'Grande', cantidad: 1200, estadoPago: 'Pagado', total: 264000),
    Order(cliente: 'Municipalidad', contacto: '922114455', fecha: '04/10/2026', hora: '14:00', tipoMasa: 'Frita', medidaMasa: 'Coctel', cantidad: 2000, estadoPago: 'Por pagar', total: 360000),
    Order(cliente: 'Club de Surf', contacto: '966554433', fecha: '04/10/2026', hora: '16:00', tipoMasa: 'Horno', medidaMasa: 'Mediana', cantidad: 500, estadoPago: 'Pagado', total: 105000),
    Order(cliente: 'Junta de Vecinos', contacto: '977889900', fecha: '04/10/2026', hora: '19:00', tipoMasa: 'Frita', medidaMasa: 'Grande', cantidad: 450, estadoPago: 'Por pagar', total: 99000),

    Order(cliente: 'El rey de la empanada', contacto: '911223344', fecha: '05/10/2026', hora: '15:00', tipoMasa: 'Horno', medidaMasa: 'Grande', cantidad: 1500, estadoPago: 'Por pagar', total: 330000),
    Order(cliente: 'Costino', contacto: '965478123', fecha: '05/10/2026', hora: '16:00', tipoMasa: 'Horno', medidaMasa: 'Mediana', cantidad: 500, estadoPago: 'Por pagar', total: 105000),
    Order(cliente: 'Pastorino', contacto: '998877665', fecha: '05/10/2026', hora: '17:00', tipoMasa: 'Horno', medidaMasa: 'Grande', cantidad: 600, estadoPago: 'Por pagar', total: 132000),
    Order(cliente: 'Carol Pino', contacto: '923456789', fecha: '05/10/2026', hora: '19:00', tipoMasa: 'Frita', medidaMasa: 'Grande', cantidad: 1200, estadoPago: 'Por pagar', total: 264000),
    Order(cliente: 'Yeri Mua', contacto: '933445566', fecha: '05/10/2026', hora: '10:00', tipoMasa: 'Horno', medidaMasa: 'Coctel', cantidad: 1800, estadoPago: 'Pagado', total: 342000),
    Order(cliente: 'Arthur Morgan', contacto: '911998877', fecha: '05/10/2026', hora: '13:00', tipoMasa: 'Frita', medidaMasa: 'Mediana', cantidad: 750, estadoPago: 'Por pagar', total: 150000),
  ];

  List<String> _fechasDisponibles = [];
  int _indiceFechaSeleccionada = 0;

  @override
  void initState() {
    super.initState();
    _fechasDisponibles = pedidos.map((p) => p.fecha).toSet().toList();
    _fechasDisponibles.sort((a, b) {
      int diaA = int.parse(a.substring(0, 2));
      int diaB = int.parse(b.substring(0, 2));
      return diaA.compareTo(diaB);
    });
  }

  void _mostrarResumenDelDia(List<Order> pedidosDelDia) {
    int hornoCoctel = 0, hornoMediana = 0, hornoGrande = 0;
    int fritaCoctel = 0, fritaMediana = 0, fritaGrande = 0;

    for (var pedido in pedidosDelDia) {
      if (pedido.tipoMasa == 'Horno') {
        if (pedido.medidaMasa == 'Coctel') hornoCoctel += pedido.cantidad;
        if (pedido.medidaMasa == 'Mediana') hornoMediana += pedido.cantidad;
        if (pedido.medidaMasa == 'Grande') hornoGrande += pedido.cantidad;
      } else if (pedido.tipoMasa == 'Frita') {
        if (pedido.medidaMasa == 'Coctel') fritaCoctel += pedido.cantidad;
        if (pedido.medidaMasa == 'Mediana') fritaMediana += pedido.cantidad;
        if (pedido.medidaMasa == 'Grande') fritaGrande += pedido.cantidad;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Total Pedidos: ${_fechasDisponibles[_indiceFechaSeleccionada]}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('HORNO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 16)),
            Text('    Cóctel: $hornoCoctel unidades'),
            Text('    Mediana: $hornoMediana unidades'),
            Text('    Grande: $hornoGrande unidades'),
            const Divider(height: 24),
            const Text('FRITA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 16)),
            Text('    Cóctel: $fritaCoctel unidades'),
            Text('    Mediana: $fritaMediana unidades'),
            Text('    Grande: $fritaGrande unidades'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_fechasDisponibles.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Historial de Pedidos')),
        body: const Center(child: Text('No hay pedidos registrados.')),
      );
    }

    String fechaActual = _fechasDisponibles[_indiceFechaSeleccionada];
    List<Order> pedidosDelDia = pedidos.where((p) => p.fecha == fechaActual).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pedidos'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_left, size: 32),
                  onPressed: _indiceFechaSeleccionada > 0 
                      ? () => setState(() => _indiceFechaSeleccionada--) 
                      : null,
                ),
                Text(
                  '  $fechaActual  ',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_right, size: 32),
                  onPressed: _indiceFechaSeleccionada < _fechasDisponibles.length - 1 
                      ? () => setState(() => _indiceFechaSeleccionada++) 
                      : null,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: pedidosDelDia.length,
              itemBuilder: (context, index) {
                final pedido = pedidosDelDia[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Icon(Icons.receipt, color: Colors.white),
                    ),
                    title: Text(pedido.cliente, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${pedido.cantidad} masas de ${pedido.tipoMasa} - \$${pedido.total}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(pedido: pedido),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _mostrarResumenDelDia(pedidosDelDia),
                  icon: const Icon(Icons.analytics),
                  label: const Text('Ver Total Pedidos del Día', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.purple,
                    side: const BorderSide(color: Colors.purple, width: 2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}