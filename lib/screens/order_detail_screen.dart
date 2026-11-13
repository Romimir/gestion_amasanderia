import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../viewmodel/order_viewmodel.dart';
import 'order_from_screen.dart';

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
  String _estadoEntregaSeleccionado = 'Por retirar';
  bool _huboCambios = false;
  bool _procesando = false;
  OverlayEntry? _notificacionActual;

  @override
  void initState() {
    super.initState();
    _pedido = widget.pedido;
    _estadoEntregaSeleccionado = _pedido.estadoEntrega;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarVencimientoAutomatico();
    });
  }

  @override
  void dispose() {
    if (_notificacionActual?.mounted ?? false) {
      _notificacionActual!.remove();
    }
    super.dispose();
  }

  Future<void> _verificarVencimientoAutomatico() async {
    if (_pedido.estadoEntrega != 'Por retirar' || _pedido.id == null) return;

    final viewModel = context.read<OrderViewModel>();
    final partesFecha = _pedido.fecha.trim().split('/');
    if (partesFecha.length != 3) return;

    final dia = int.tryParse(partesFecha[0]);
    final mes = int.tryParse(partesFecha[1]);
    final anio = int.tryParse(partesFecha[2]);
    if (dia == null || mes == null || anio == null) return;

    final partesHora = _pedido.hora.trim().split(':');
    final hora =
        partesHora.isNotEmpty ? (int.tryParse(partesHora[0]) ?? 20) : 20;
    final minuto =
        partesHora.length > 1 ? (int.tryParse(partesHora[1]) ?? 0) : 0;

    final fechaRetiro = DateTime(anio, mes, dia, hora, minuto);

    if (DateTime.now().isAfter(fechaRetiro.add(const Duration(days: 2)))) {
      await viewModel.actualizarEstado(_pedido.id!, 'No retirado');
      
      if (!mounted) return;
      setState(() {
        _pedido = _pedido.copyWith(estadoEntrega: 'No retirado');
        _estadoEntregaSeleccionado = 'No retirado';
        _huboCambios = true;
      });
    }
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

  Future<void> _mostrarVentanaEstadoEntrega(
    String nuevoEstado,
    Color moradoPrincipal,
  ) async {
    late final IconData icono;
    late final Color colorIcono;
    late final String titulo;
    late final String mensaje;

    if (nuevoEstado == 'Retirado') {
      if (_pedido.estadoPago == 'Por pagar') {
        icono = Icons.payments_outlined;
        colorIcono = Colors.black87;
        titulo = 'Pago pendiente';
        mensaje = 'Total del pedido: \$${_pedido.total}';
      } else {
        icono = Icons.check_circle_outline;
        colorIcono = moradoPrincipal;
        titulo = 'Pedido entregado';
        mensaje = 'El pedido de ${_pedido.cliente} ya se encuentra pagado.';
      }
    } else if (nuevoEstado == 'No retirado') {
      icono = Icons.cancel_outlined;
      colorIcono = Colors.grey.shade700;
      titulo = 'Pedido abandonado';
      mensaje =
          'El pedido de ${_pedido.cliente} ha sido marcado como no retirado.';
    } else {
      icono = Icons.schedule;
      colorIcono = moradoPrincipal;
      titulo = 'Pedido por retirar';
      mensaje = 'El pedido vuelve a estar en espera de retiro.';
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(icono, color: colorIcono, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          mensaje,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Aceptar',
              style: TextStyle(
                color: moradoPrincipal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirEdicion() async {
    if (_procesando) return;

    final Order? actualizado = await Navigator.push<Order>(
      context,
      MaterialPageRoute(
        builder: (context) => OrderFormScreen(pedidoEditar: _pedido),
      ),
    );

    if (actualizado != null && mounted) {
      setState(() {
        _pedido = actualizado;
        _estadoEntregaSeleccionado = actualizado.estadoEntrega;
        _huboCambios = true;
      });
    }
  }

  Future<void> _guardarEstadoEntrega(Color moradoPrincipal) async {
    if (_procesando ||
        _pedido.id == null ||
        _estadoEntregaSeleccionado == _pedido.estadoEntrega) {
      return;
    }

    final viewModel = context.read<OrderViewModel>();
    setState(() => _procesando = true);

    try {
      await viewModel.actualizarEstado(_pedido.id!, _estadoEntregaSeleccionado);
      
      if (!mounted) return;
      setState(() {
        _pedido = _pedido.copyWith(estadoEntrega: _estadoEntregaSeleccionado);
        _huboCambios = true;
        _procesando = false;
      });
      await _mostrarVentanaEstadoEntrega(
        _estadoEntregaSeleccionado,
        moradoPrincipal,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _procesando = false);
      _mostrarNotificacionSuperior(
        'No se pudo actualizar el estado de entrega.',
        icono: Icons.error_outline,
      );
    }
  }

  Future<void> _confirmarYEliminar(Color colorPrimario) async {
    if (_procesando || _pedido.id == null) return;

    final viewModel = context.read<OrderViewModel>();

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
      await viewModel.eliminarPedido(_pedido.id!);
      
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

  Widget _buildCampoRecuadro(
    String etiqueta,
    String valor, {
    double fontSize = 14,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: etiqueta,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      child: Text(
        valor,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildOpcionPagoSoloLectura(
    String etiqueta,
    Color moradoPrincipal,
  ) {
    final bool seleccionado = _pedido.estadoPago == etiqueta;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado ? moradoPrincipal : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionado ? moradoPrincipal : Colors.grey.shade300,
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            etiqueta,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: seleccionado ? Colors.white : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotonEntrega(
    String estado,
    IconData icono,
    Color moradoPrincipal,
  ) {
    final bool seleccionado = _estadoEntregaSeleccionado == estado;

    return Expanded(
      child: OutlinedButton(
        onPressed: _procesando
            ? null
            : () {
                setState(() {
                  _estadoEntregaSeleccionado = estado;
                });
              },
        style: OutlinedButton.styleFrom(
          backgroundColor: seleccionado ? moradoPrincipal : Colors.white,
          foregroundColor: seleccionado ? Colors.white : Colors.black87,
          side: BorderSide(
            color: seleccionado ? moradoPrincipal : Colors.grey.shade400,
            width: seleccionado ? 2 : 1,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 22),
            const SizedBox(height: 4),
            Text(
              estado,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
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
    final bool hayCambioEntrega =
        _estadoEntregaSeleccionado != _pedido.estadoEntrega;

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
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar pedido',
              onPressed: _procesando ? null : _abrirEdicion,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pedido.cliente,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Teléfono: ${_formatearContacto(_pedido.contacto)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildCampoRecuadro(
                      'Fecha',
                      _pedido.fecha,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCampoRecuadro(
                      'Hora',
                      '${_pedido.hora} hrs',
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildCampoRecuadro('Tipo de masa', _pedido.tipoMasa),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCampoRecuadro('Medida', _pedido.medidaMasa),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCampoRecuadro(
                      'Cantidad',
                      '${_pedido.cantidad} unid.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'TOTAL: \$${_pedido.total}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'ESTADO DEL PAGO',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildOpcionPagoSoloLectura('Por pagar', moradoPrincipal),
                  const SizedBox(width: 10),
                  _buildOpcionPagoSoloLectura('Pagado', moradoPrincipal),
                ],
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'ESTADO DE ENTREGA',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildBotonEntrega(
                    'Por retirar',
                    Icons.schedule,
                    moradoPrincipal,
                  ),
                  const SizedBox(width: 10),
                  _buildBotonEntrega(
                    'Retirado',
                    Icons.shopping_bag_outlined,
                    moradoPrincipal,
                  ),
                  const SizedBox(width: 10),
                  _buildBotonEntrega(
                    'No retirado',
                    Icons.close,
                    moradoPrincipal,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_procesando || !hayCambioEntrega)
                      ? null
                      : () => _guardarEstadoEntrega(moradoPrincipal),
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    hayCambioEntrega
                        ? 'Guardar Estado de Entrega'
                        : 'Estado de Entrega Guardado',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: moradoPrincipal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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