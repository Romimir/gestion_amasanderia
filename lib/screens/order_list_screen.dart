import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<Order> _pedidos = [];
  List<String> _fechasDisponibles = [];
  Set<String> _fechasConPedidosSet = {};
  int _indiceFechaSeleccionada = 0;
  bool _cargando = true;
  String? _errorCarga;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  /// Convierte cualquier fecha (ej. 2026-10-29) al formato chileno dd/mm/aaaa
  String _normalizarFecha(String raw) {
    final limpia = raw.trim();
    if (limpia.contains('-')) {
      final partes = limpia.split('-');
      if (partes.length == 3 && partes[0].length == 4) {
        final dia = partes[2].padLeft(2, '0');
        final mes = partes[1].padLeft(2, '0');
        final anio = partes[0];
        return '$dia/$mes/$anio';
      }
    }
    return limpia;
  }

  DateTime _parseFecha(String fechaStr) {
    final normalizada = _normalizarFecha(fechaStr);
    final partes = normalizada.split('/');
    if (partes.length == 3) {
      return DateTime(
        int.tryParse(partes[2]) ?? 2000,
        int.tryParse(partes[1]) ?? 1,
        int.tryParse(partes[0]) ?? 1,
      );
    }
    return DateTime(2000);
  }

  String _formatFecha(DateTime fecha) {
    final String dia = fecha.day.toString().padLeft(2, '0');
    final String mes = fecha.month.toString().padLeft(2, '0');
    final String anio = fecha.year.toString();
    return '$dia/$mes/$anio';
  }

  Future<void> _cargarPedidos() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });

    try {
      final String? fechaPrevia = _fechasDisponibles.isNotEmpty
          ? _fechasDisponibles[_indiceFechaSeleccionada]
          : null;

      final lista = await DatabaseHelper.instance.getPedidos();

      if (!mounted) return;

      final fechasSet = lista.map((p) => _normalizarFecha(p.fecha)).toSet();
      final fechasOrdenadas = fechasSet.toList()
        ..sort((a, b) => _parseFecha(a).compareTo(_parseFecha(b)));

      int nuevoIndice = 0;
      if (fechasOrdenadas.isNotEmpty) {
        if (fechaPrevia != null && fechasOrdenadas.contains(fechaPrevia)) {
          nuevoIndice = fechasOrdenadas.indexOf(fechaPrevia);
        } else if (_indiceFechaSeleccionada < fechasOrdenadas.length) {
          nuevoIndice = _indiceFechaSeleccionada;
        }
      }

      setState(() {
        _pedidos = lista;
        _fechasConPedidosSet = fechasSet;
        _fechasDisponibles = fechasOrdenadas;
        _indiceFechaSeleccionada = nuevoIndice;
        _cargando = false;
      });
    } catch (e, stack) {
      debugPrint('Error cargando pedidos desde SQLite: $e\n$stack');
      if (!mounted) return;
      setState(() {
        _errorCarga = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _abrirCalendarioFiltrado(Color colorPrimario) async {
    final String fechaActualStr = _fechasDisponibles[_indiceFechaSeleccionada];
    final DateTime fechaInicial = _parseFecha(fechaActualStr);
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
                        final int nuevoIndice =
                            _fechasDisponibles.indexOf(fechaFormateada);
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

    final int totalHorno = hornoCoctel + hornoMediana + hornoGrande;
    final int totalFrita = fritaCoctel + fritaMediana + fritaGrande;
    final int totalMasas = totalHorno + totalFrita;

    const TextStyle estiloTitulo = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Pedidos: ${pedidosDelDia.length}',
              style: estiloTitulo,
            ),
            const SizedBox(height: 4),
            Text(
              'Total masas: $totalMasas',
              style: estiloTitulo,
            ),
            const Divider(height: 20, thickness: 1),
          ],
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
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: $totalHorno',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 20),
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
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: $totalFrita',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
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
    final bool haySiguiente =
        _indiceFechaSeleccionada < _fechasDisponibles.length - 1;

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
        onTap: () async {
          final pedidoNormalizado =
              pedido.copyWith(fecha: _normalizarFecha(pedido.fecha));
          final bool? huboCambios = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderDetailScreen(pedido: pedidoNormalizado),
            ),
          );
          if (huboCambios == true) {
            _cargarPedidos();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moradoPrincipal =
        theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary;

    if (_cargando) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Historial de Pedidos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: moradoPrincipal),
        ),
      );
    }

    if (_errorCarga != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Historial de Pedidos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Error al leer la base de datos:\n$_errorCarga',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 15),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _cargarPedidos,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_fechasDisponibles.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Historial de Pedidos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No hay pedidos registrados.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      );
    }

    final String fechaActual = _fechasDisponibles[_indiceFechaSeleccionada];
    final List<Order> pedidosDelDia = _pedidos
        .where((p) => _normalizarFecha(p.fecha) == fechaActual)
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
                  onPressed: () =>
                      _mostrarResumenDelDia(pedidosDelDia, moradoPrincipal),
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