import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order pedido;

  const OrderDetailScreen({
    super.key,
    required this.pedido,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order _pedido;
  bool _huboCambios = false;
  bool _procesando = false;
  OverlayEntry? _notificacionActual;

  @override
  void initState() {
    super.initState();
    _pedido = widget.pedido;
  }

  @override
  void dispose() {
    if (_notificacionActual?.mounted ?? false) {
      _notificacionActual!.remove();
    }
    super.dispose();
  }

  String _formatearContacto(String contacto) {
    final limpio = contacto.trim();
    if (limpio.isEmpty) return 'No registrado';
    if (limpio.length == 9 && limpio.startsWith('9')) {
      return '+56 9 ${limpio.substring(1)}';
    }
    return limpio;
  }

  void _mostrarNotificacionSuperior(
    String mensaje, {
    IconData icono = Icons.info_outline,
  }) {
    if (!mounted) return;

    if (_notificacionActual?.mounted ?? false) {
      _notificacionActual!.remove();
    }
    _notificacionActual = null;

    final mediaQuery = MediaQuery.of(context);
    final double espacioSuperior = mediaQuery.padding.top + kToolbarHeight;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: espacioSuperior + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.black,
          elevation: 6,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icono, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    mensaje,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _notificacionActual = entry;
    Overlay.of(context).insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) {
        entry.remove();
      }
      if (_notificacionActual == entry) {
        _notificacionActual = null;
      }
    });
  }

  Future<void> _alternarEstadoPago() async {
    if (_procesando || _pedido.id == null) return;

    final String nuevoEstado =
        _pedido.estadoPago == 'Pagado' ? 'Por pagar' : 'Pagado';

    setState(() => _procesando = true);

    try {
      await DatabaseHelper.instance.updateEstadoPago(_pedido.id!, nuevoEstado);
      if (!mounted) return;
      setState(() {
        _pedido = _pedido.copyWith(estadoPago: nuevoEstado);
        _huboCambios = true;
        _procesando = false;
      });
      _mostrarNotificacionSuperior(
        'Estado actualizado a "$nuevoEstado"',
        icono: Icons.check_circle_outline,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _procesando = false);
      _mostrarNotificacionSuperior(
        'No se pudo actualizar el estado del pago.',
        icono: Icons.error_outline,
      );
    }
  }

  Future<void> _confirmarYEliminar(Color colorPrimario) async {
    if (_procesando || _pedido.id == null) return;

    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Eliminar Pedido',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Seguro que deseas eliminar el pedido de ${_pedido.cliente}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Eliminar',
              style: TextStyle(
                color: colorPrimario,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _procesando = true);

    try {
      await DatabaseHelper.instance.deletePedido(_pedido.id!);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _procesando = false);
      _mostrarNotificacionSuperior(
        'No se pudo eliminar el pedido.',
        icono: Icons.error_outline,
      );
    }
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moradoPrincipal =
        theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary;
    final bool estaPagado = _pedido.estadoPago == 'Pagado';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _huboCambios);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Detalle del Pedido',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildInfoCard('Cliente', _pedido.cliente),
              _buildInfoCard('Contacto', _formatearContacto(_pedido.contacto)),
              _buildInfoCard('Fecha', _pedido.fecha),
              _buildInfoCard('Hora', '${_pedido.hora} hrs'),
              _buildInfoCard('Tipo de masa', _pedido.tipoMasa),
              _buildInfoCard('Medida', _pedido.medidaMasa),
              _buildInfoCard('Cantidad', '${_pedido.cantidad} unidades'),
              _buildInfoCard('Estado del pago', _pedido.estadoPago),
              _buildInfoCard('Total', '\$${_pedido.total}'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _procesando ? null : _alternarEstadoPago,
                  icon: Icon(
                    estaPagado ? Icons.undo : Icons.check_circle_outline,
                  ),
                  label: Text(
                    estaPagado
                        ? 'Marcar como Por pagar'
                        : 'Marcar como Pagado',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        estaPagado ? Colors.black87 : moradoPrincipal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _procesando
                      ? null
                      : () => _confirmarYEliminar(moradoPrincipal),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(
                    'Eliminar Pedido',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black54, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}