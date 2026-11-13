import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../viewmodel/order_viewmodel.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late DateTime _fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    final ahora = DateTime.now();
    _fechaSeleccionada = DateTime(ahora.year, ahora.month, ahora.day);
  }

  String _formatearFecha(DateTime fecha) {
    final String dia = fecha.day.toString().padLeft(2, '0');
    final String mes = fecha.month.toString().padLeft(2, '0');
    final String anio = fecha.year.toString();
    return '$dia/$mes/$anio';
  }

  String _normalizarFecha(String fechaRaw) {
    final limpia = fechaRaw.trim();
    if (limpia.contains('/')) {
      final partes = limpia.split('/');
      if (partes.length == 3) {
        final dia = partes[0].padLeft(2, '0');
        final mes = partes[1].padLeft(2, '0');
        final anio = partes[2];
        return '$dia/$mes/$anio';
      }
    } else if (limpia.contains('-')) {
      final soloFecha = limpia.split('T').first.split(' ').first;
      final partes = soloFecha.split('-');
      if (partes.length == 3 && partes[0].length == 4) {
        final anio = partes[0];
        final mes = partes[1].padLeft(2, '0');
        final dia = partes[2].padLeft(2, '0');
        return '$dia/$mes/$anio';
      }
    }
    return limpia;
  }

  DateTime? _parseFecha(String fechaStr) {
    final normalizada = _normalizarFecha(fechaStr);
    final partes = normalizada.split('/');
    if (partes.length == 3) {
      final dia = int.tryParse(partes[0]);
      final mes = int.tryParse(partes[1]);
      final anio = int.tryParse(partes[2]);
      if (dia != null && mes != null && anio != null) {
        return DateTime(anio, mes, dia);
      }
    }
    return null;
  }

  void _cambiarDia(int dias) {
    setState(() {
      _fechaSeleccionada = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day + dias,
      );
    });
  }

  Future<void> _seleccionarFecha(Color colorPrimario, List<Order> todosLosPedidos) async {
    final Set<DateTime> fechasConPedidos = {};
    for (final pedido in todosLosPedidos) {
      final fecha = _parseFecha(pedido.fecha);
      if (fecha != null) {
        fechasConPedidos.add(DateTime(fecha.year, fecha.month, fecha.day));
      }
    }

    final ahora = DateTime.now();
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
    DateTime mesVisible = DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      1,
    );

    const List<String> meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    const List<String> diasSemana = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

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
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                final DateTime primerDiaMes =
                    DateTime(mesVisible.year, mesVisible.month, 1);
                final int diasEnMes =
                    DateTime(mesVisible.year, mesVisible.month + 1, 0).day;
                final int espaciosIniciales = primerDiaMes.weekday - 1;
                final int totalCeldas = espaciosIniciales + diasEnMes;

                return Column(
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
                              'Seleccionar fecha',
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            tooltip: 'Mes anterior',
                            onPressed: () {
                              setDialogState(() {
                                mesVisible = DateTime(
                                  mesVisible.year,
                                  mesVisible.month - 1,
                                  1,
                                );
                              });
                            },
                          ),
                          Text(
                            '${meses[mesVisible.month - 1]} ${mesVisible.year}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            tooltip: 'Mes siguiente',
                            onPressed: () {
                              setDialogState(() {
                                mesVisible = DateTime(
                                  mesVisible.year,
                                  mesVisible.month + 1,
                                  1,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: diasSemana
                            .map(
                              (dia) => Expanded(
                                child: Center(
                                  child: Text(
                                    dia,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: totalCeldas,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemBuilder: (context, index) {
                          if (index < espaciosIniciales) {
                            return const SizedBox.shrink();
                          }

                          final int diaNumero = index - espaciosIniciales + 1;
                          final DateTime fechaCelda = DateTime(
                            mesVisible.year,
                            mesVisible.month,
                            diaNumero,
                          );

                          final bool esSeleccionado =
                              fechaCelda.year == _fechaSeleccionada.year &&
                              fechaCelda.month == _fechaSeleccionada.month &&
                              fechaCelda.day == _fechaSeleccionada.day;

                          final bool esHoy = fechaCelda.year == hoy.year &&
                              fechaCelda.month == hoy.month &&
                              fechaCelda.day == hoy.day;

                          final bool tienePedidos =
                              fechasConPedidos.contains(fechaCelda);

                          return InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setState(() {
                                _fechaSeleccionada = fechaCelda;
                              });
                              Navigator.pop(dialogContext);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: esSeleccionado
                                    ? colorPrimario
                                    : (tienePedidos
                                        ? colorPrimario.withValues(alpha: 0.12)
                                        : Colors.transparent),
                                border: esSeleccionado
                                    ? null
                                    : tienePedidos
                                        ? Border.all(
                                            color: colorPrimario,
                                            width: 1.5,
                                          )
                                        : (esHoy
                                            ? Border.all(
                                                color: Colors.black54,
                                                width: 1,
                                              )
                                            : null),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$diaNumero',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: (esSeleccionado ||
                                              tienePedidos ||
                                              esHoy)
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: esSeleccionado
                                          ? Colors.white
                                          : (tienePedidos
                                              ? colorPrimario
                                              : Colors.black87),
                                    ),
                                  ),
                                  if (tienePedidos)
                                    Container(
                                      margin: const EdgeInsets.only(top: 1),
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: esSeleccionado
                                            ? Colors.white
                                            : colorPrimario,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 12, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorPrimario.withValues(alpha: 0.12),
                              border: Border.all(
                                color: colorPrimario,
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Con pedidos agendados',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _fechaSeleccionada = hoy;
                              });
                              Navigator.pop(dialogContext);
                            },
                            child: Text(
                              'Hoy',
                              style: TextStyle(
                                color: colorPrimario,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
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

  Widget _buildPedidoCard(Order pedido, Color moradoPrincipal) {
    final bool estaPagado = pedido.estadoPago == 'Pagado';
    final bool mostrarEstadoEntrega = pedido.estadoEntrega != 'Por retirar';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: moradoPrincipal,
          child: const Icon(Icons.receipt, color: Colors.white),
        ),
        title: Text(
          pedido.cliente,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '${pedido.cantidad} masas de ${pedido.tipoMasa} ${pedido.medidaMasa} \$${pedido.total}',
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: estaPagado ? Colors.black87 : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: estaPagado
                        ? null
                        : Border.all(color: Colors.black54, width: 1),
                  ),
                  child: Text(
                    estaPagado ? 'Pagado' : 'Por pagar',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: estaPagado ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                if (mostrarEstadoEntrega) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: pedido.estadoEntrega == 'Retirado'
                          ? moradoPrincipal
                          : Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      pedido.estadoEntrega,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
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
            if (mounted) {
              context.read<OrderViewModel>().cargarPedidos();
            }
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

    final viewModel = context.watch<OrderViewModel>();
    final todosLosPedidos = viewModel.pedidos;
    final cargando = viewModel.isLoading;

    final String fechaActualStr = _formatearFecha(_fechaSeleccionada);

    final List<Order> pedidosDelDia = todosLosPedidos.where((pedido) {
      final fechaPedido = _parseFecha(pedido.fecha);
      if (fechaPedido != null) {
        return fechaPedido.year == _fechaSeleccionada.year &&
            fechaPedido.month == _fechaSeleccionada.month &&
            fechaPedido.day == _fechaSeleccionada.day;
      }
      return _normalizarFecha(pedido.fecha) == fechaActualStr;
    }).toList()
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.4),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon:
                      Icon(Icons.chevron_left, color: moradoPrincipal, size: 28),
                  tooltip: 'Día anterior',
                  onPressed: () => _cambiarDia(-1),
                ),
                OutlinedButton.icon(
                  onPressed: () => _seleccionarFecha(moradoPrincipal, todosLosPedidos),
                  icon: Icon(Icons.calendar_today,
                      size: 18, color: moradoPrincipal),
                  label: Text(
                    fechaActualStr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: moradoPrincipal,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    side: BorderSide(color: moradoPrincipal, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right,
                      color: moradoPrincipal, size: 28),
                  tooltip: 'Día siguiente',
                  onPressed: () => _cambiarDia(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: cargando
                ? Center(
                    child: CircularProgressIndicator(color: moradoPrincipal),
                  )
                : pedidosDelDia.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 56,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No hay pedidos para el $fechaActualStr',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: pedidosDelDia.length,
                        itemBuilder: (context, index) {
                          return _buildPedidoCard(
                            pedidosDelDia[index],
                            moradoPrincipal,
                          );
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _mostrarResumenDelDia(pedidosDelDia, moradoPrincipal),
                  icon: Icon(Icons.assessment, color: moradoPrincipal),
                  label: Text(
                    'Ver Total Pedidos del Día',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: moradoPrincipal,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: moradoPrincipal, width: 1.5),
                    shape: const StadiumBorder(),
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