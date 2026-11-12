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
  Set<String> _fechasConPedidosSet = {};
  int _indiceFechaSeleccionada = 0;

  @override
  void initState() {
    super.initState();
    _fechasConPedidosSet = pedidos.map((p) => p.fecha).toSet();
    _fechasDisponibles = _fechasConPedidosSet.toList()
      ..sort((a, b) => _parseFecha(a).compareTo(_parseFecha(b)));
  }

  DateTime _parseFecha(String fechaStr) {
    final partes = fechaStr.split('/');
    return DateTime(
      int.parse(partes[2]),
      int.parse(partes[1]),
      int.parse(partes[0]),
    );
  }

  String _formatFecha(DateTime fecha) {
    final String dia = fecha.day.toString().padLeft(2, '0');
    final String mes = fecha.month.toString().padLeft(2, '0');
    final String anio = fecha.year.toString();
    return '$dia/$mes/$anio';
  }

  Future<void> _abrirCalendarioFiltrado(Color colorPrimario) async {
    final DateTime fechaInicial = _parseFecha(_fechasDisponibles[_indiceFechaSeleccionada]);
    final DateTime primeraFecha = _parseFecha(_fechasDisponibles.first);
    final DateTime ultimaFecha = _parseFecha(_fechasDisponibles.last);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 328,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: colorPrimario,
                  onPrimary: Colors.white,
                  onSurface: Colors.black87,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                    decoration: BoxDecoration(
                      color: colorPrimario,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Días con pedidos agendados',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          tooltip: 'Cerrar',
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 330,
                    child: CalendarDatePicker(
                      initialDate: fechaInicial,
                      currentDate: fechaInicial,
                      firstDate: primeraFecha,
                      lastDate: ultimaFecha,
                      selectableDayPredicate: (day) {
                        return _fechasConPedidosSet.contains(_formatFecha(day));
                      },
                      onDateChanged: (fechaElegida) {
                        final String fechaFormateada = _formatFecha(fechaElegida);
                        final int nuevoIndice = _fechasDisponibles.indexOf(fechaFormateada);
                        if (nuevoIndice != -1) {
                          setState(() => _indiceFechaSeleccionada = nuevoIndice);
                        }
                        Navigator.pop(dialogContext);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarResumenDelDia(List<Order> pedidosDelDia, Color colorPrimario) {
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
          'Total Pedidos: ${pedidosDelDia.length}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HORNO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorPrimario,
                fontSize: 16,
              ),
            ),
            Text('    Cóctel: $hornoCoctel unidades'),
            Text('    Mediana: $hornoMediana unidades'),
            Text('    Grande: $hornoGrande unidades'),
            const Divider(height: 24),
            Text(
              'FRITA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorPrimario,
                fontSize: 16,
              ),
            ),
            Text('    Cóctel: $fritaCoctel unidades'),
            Text('    Mediana: $fritaMediana unidades'),
            Text('    Grande: $fritaGrande unidades'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: TextStyle(
                color: colorPrimario,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorFechaBar(String fechaActual, Color moradoPrincipal) {
    final bool hayAnterior = _indiceFechaSeleccionada > 0;
    final bool haySiguiente = _indiceFechaSeleccionada < _fechasDisponibles.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              size: 32,
              color: hayAnterior ? moradoPrincipal : Colors.grey.shade400,
            ),
            tooltip: 'Día anterior con pedidos',
            onPressed: hayAnterior
                ? () => setState(() => _indiceFechaSeleccionada--)
                : null,
          ),
          InkWell(
            onTap: () => _abrirCalendarioFiltrado(moradoPrincipal),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: moradoPrincipal.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month, size: 20, color: moradoPrincipal),
                  const SizedBox(width: 8),
                  Text(
                    fechaActual,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: moradoPrincipal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_right,
              size: 32,
              color: haySiguiente ? moradoPrincipal : Colors.grey.shade400,
            ),
            tooltip: 'Día siguiente con pedidos',
            onPressed: haySiguiente
                ? () => setState(() => _indiceFechaSeleccionada++)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPedidoCard(Order pedido, Color moradoPrincipal) {
    final bool estaPagado = pedido.estadoPago == 'Pagado';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: moradoPrincipal,
          child: const Icon(Icons.receipt, color: Colors.white),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                pedido.cliente,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (estaPagado) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Pagado',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${pedido.cantidad} masas de ${pedido.tipoMasa} - \$${pedido.total}',
        ),
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moradoPrincipal =
        theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary;

    if (_fechasDisponibles.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Historial de Pedidos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(child: Text('No hay pedidos registrados.')),
      );
    }

    final String fechaActual = _fechasDisponibles[_indiceFechaSeleccionada];
    final List<Order> pedidosDelDia = pedidos
        .where((p) => p.fecha == fechaActual)
        .toList()
      ..sort((a, b) => a.hora.compareTo(b.hora));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de Pedidos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildSelectorFechaBar(fechaActual, moradoPrincipal),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: pedidosDelDia.length,
              itemBuilder: (context, index) {
                return _buildPedidoCard(pedidosDelDia[index], moradoPrincipal);
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _mostrarResumenDelDia(pedidosDelDia, moradoPrincipal),
                  icon: const Icon(Icons.analytics),
                  label: const Text(
                    'Ver Total Pedidos del Día',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: moradoPrincipal,
                    side: BorderSide(color: moradoPrincipal, width: 2),
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