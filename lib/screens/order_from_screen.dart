import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';

class OrderFormScreen extends StatefulWidget {
  final Order? pedidoEditar;

  const OrderFormScreen({super.key, this.pedidoEditar});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _contactoController = TextEditingController();
  final TextEditingController _cantidadController =
      TextEditingController(text: '0');

  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  String _tipoMasa = 'Horno';
  String _medidaMasa = 'Coctel';
  String _estadoPago = 'Por pagar';
  String _estadoEntrega = 'Por retirar';
  bool _guardando = false;

  OverlayEntry? _notificacionActual;

  bool get _esEdicion => widget.pedidoEditar != null;

  @override
  void initState() {
    super.initState();

    final pedido = widget.pedidoEditar;
    if (pedido != null) {
      _clienteController.text = pedido.cliente;

      final tel = pedido.contacto.trim();
      if (tel.length == 9 && tel.startsWith('9')) {
        _contactoController.text = tel.substring(1);
      } else {
        _contactoController.text = tel;
      }

      _fechaController.text = pedido.fecha;
      _fechaSeleccionada = _parseFecha(pedido.fecha);

      _horaController.text = pedido.hora;
      _horaSeleccionada = _parseHora(pedido.hora);

      _tipoMasa = pedido.tipoMasa;
      _medidaMasa = pedido.medidaMasa;
      _cantidadController.text = pedido.cantidad.toString();
      _estadoPago = pedido.estadoPago;
      _estadoEntrega = pedido.estadoEntrega;
    }

    _cantidadController.addListener(() => setState(() {}));
    _clienteController.addListener(() => setState(() {}));
  }

  DateTime? _parseFecha(String fechaStr) {
    final partes = fechaStr.trim().split('/');
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

  TimeOfDay? _parseHora(String horaStr) {
    final partes = horaStr.trim().split(':');
    if (partes.length == 2) {
      final hora = int.tryParse(partes[0]);
      final minuto = int.tryParse(partes[1]);
      if (hora != null && minuto != null) {
        return TimeOfDay(hour: hora, minute: minuto);
      }
    }
    return null;
  }

  @override
  void dispose() {
    if (_notificacionActual?.mounted ?? false) {
      _notificacionActual!.remove();
    }
    _clienteController.dispose();
    _contactoController.dispose();
    _cantidadController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  int _getPrecioUnidad(String tipoMasa, String medidaMasa) {
    if (medidaMasa == 'Coctel') return tipoMasa == 'Horno' ? 190 : 180;
    if (medidaMasa == 'Mediana') return tipoMasa == 'Horno' ? 210 : 200;
    return 220;
  }

  String _getDiametro(String medidaMasa) {
    if (medidaMasa == 'Coctel') return '11 cm de diametro';
    if (medidaMasa == 'Mediana') return '15 cm de diametro';
    return '20 cm de diametro';
  }

  void _incrementarCantidad() {
    int actual = int.tryParse(_cantidadController.text) ?? 0;
    int siguiente = ((actual ~/ 10) + 1) * 10;
    _cantidadController.text = siguiente.toString();
  }

  void _decrementarCantidad() {
    int actual = int.tryParse(_cantidadController.text) ?? 0;
    int anterior = ((actual - 1) ~/ 10) * 10;
    if (anterior < 0) anterior = 0;
    _cantidadController.text = anterior.toString();
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

  Future<void> _seleccionarFecha(
      BuildContext context, Color colorPrimario) async {
    final DateTime hoy = DateTime.now();
    final DateTime hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
    final DateTime fechaInicial = _fechaSeleccionada ?? hoySinHora;
    final DateTime primeraFecha =
        fechaInicial.isBefore(hoySinHora) ? fechaInicial : hoySinHora;

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
                            'Seleccionar fecha de retiro',
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
                    height: 305,
                    child: CalendarDatePicker(
                      initialDate: fechaInicial,
                      firstDate: primeraFecha,
                      lastDate: DateTime(hoy.year + 1),
                      onDateChanged: (fechaElegida) {
                        final String dia =
                            fechaElegida.day.toString().padLeft(2, '0');
                        final String mes =
                            fechaElegida.month.toString().padLeft(2, '0');
                        final String anio = fechaElegida.year.toString();

                        setState(() {
                          _fechaSeleccionada = fechaElegida;
                          _fechaController.text = '$dia/$mes/$anio';
                        });
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

  Future<void> _seleccionarHora(
      BuildContext context, Color colorPrimario) async {
    final TimeOfDay? horaElegida = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? const TimeOfDay(hour: 10, minute: 0),
      helpText: 'Horario de retiro: 10:00 a 20:00 hrs',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorPrimario,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );

    if (horaElegida != null) {
      final bool dentroDeHorario =
          (horaElegida.hour >= 10 && horaElegida.hour < 20) ||
              (horaElegida.hour == 20 && horaElegida.minute == 0);

      if (!dentroDeHorario) {
        _mostrarNotificacionSuperior(
          'Horario no disponible. Solo se agendan pedidos entre 10:00 y 20:00 hrs.',
          icono: Icons.access_time_filled,
        );
        return;
      }

      final String hora = horaElegida.hour.toString().padLeft(2, '0');
      final String minuto = horaElegida.minute.toString().padLeft(2, '0');

      setState(() {
        _horaSeleccionada = horaElegida;
        _horaController.text = '$hora:$minuto';
      });
    }
  }

  Future<void> _guardarPedido(int cantidad, int totalMasas) async {
    if (_guardando) return;

    final bool formularioValido = _formKey.currentState!.validate();
    final List<String> faltantes = [];

    if (_clienteController.text.trim().isEmpty) {
      faltantes.add('Nombre del cliente');
    }
    if (_fechaController.text.isEmpty) {
      faltantes.add('Fecha');
    }
    if (_horaController.text.isEmpty) {
      faltantes.add('Hora');
    }
    if (cantidad <= 0) {
      faltantes.add('Cantidad de masas');
    }

    if (!formularioValido || faltantes.isNotEmpty) {
      final String mensaje = faltantes.isNotEmpty
          ? 'No se puede guardar el pedido. Faltan datos: ${faltantes.join(', ')}.'
          : 'No se puede guardar el pedido. El teléfono debe tener 8 dígitos.';

      _mostrarNotificacionSuperior(
        mensaje,
        icono: Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final String telefonoDigitos = _contactoController.text.trim();
      final String contactoCompleto =
          telefonoDigitos.isNotEmpty ? '9$telefonoDigitos' : '';

      if (_esEdicion) {
        final Order pedidoActualizado = widget.pedidoEditar!.copyWith(
          cliente: _clienteController.text.trim(),
          contacto: contactoCompleto,
          fecha: _fechaController.text,
          hora: _horaController.text,
          tipoMasa: _tipoMasa,
          medidaMasa: _medidaMasa,
          cantidad: cantidad,
          estadoPago: _estadoPago,
          estadoEntrega: _estadoEntrega,
          total: totalMasas,
        );

        await DatabaseHelper.instance.updatePedido(pedidoActualizado);

        if (!mounted) return;
        _mostrarNotificacionSuperior(
          'Pedido actualizado con éxito',
          icono: Icons.check_circle_outline,
        );
        Navigator.pop(context, pedidoActualizado);
      } else {
        final Order nuevoPedido = Order(
          cliente: _clienteController.text.trim(),
          contacto: contactoCompleto,
          fecha: _fechaController.text,
          hora: _horaController.text,
          tipoMasa: _tipoMasa,
          medidaMasa: _medidaMasa,
          cantidad: cantidad,
          estadoPago: _estadoPago,
          estadoEntrega: 'Por retirar',
          total: totalMasas,
        );

        await DatabaseHelper.instance.insertPedido(nuevoPedido);

        if (!mounted) return;
        _mostrarNotificacionSuperior(
          'Pedido registrado con éxito',
          icono: Icons.check_circle_outline,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      _mostrarNotificacionSuperior(
        'Ocurrió un error al guardar el pedido.',
        icono: Icons.error_outline,
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTamanoOption(String medida) {
    int precio = _getPrecioUnidad(_tipoMasa, medida);
    String descripcion = _getDiametro(medida);

    return RadioListTile<String>(
      title: Text(medida, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('$descripcion\nPrecio: \$$precio c/u'),
      value: medida,
    );
  }

  Widget _buildDetalleFila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$etiqueta: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int cantidad = int.tryParse(_cantidadController.text) ?? 0;
    int precioUnidad = _getPrecioUnidad(_tipoMasa, _medidaMasa);
    int totalMasas = cantidad * precioUnidad;
    int totalAPagar = _estadoPago == 'Pagado' ? 0 : totalMasas;

    final theme = Theme.of(context);
    final tema = theme.colorScheme;
    final moradoPrincipal =
        theme.appBarTheme.backgroundColor ?? tema.primary;

    final String nombreResumen = _clienteController.text.trim();

    String retiroResumen = '';
    if (_fechaController.text.isNotEmpty && _horaController.text.isNotEmpty) {
      retiroResumen = '${_fechaController.text} a las ${_horaController.text} hrs';
    } else if (_fechaController.text.isNotEmpty) {
      retiroResumen = _fechaController.text;
    } else if (_horaController.text.isNotEmpty) {
      retiroResumen = '${_horaController.text} hrs';
    }

    final String encargoResumen =
        cantidad > 0 ? '$cantidad masas de $_tipoMasa - $_medidaMasa' : '';

    final String subtotalResumen = cantidad > 0
        ? '\$${totalMasas.toStringAsFixed(0)} - $_estadoPago'
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEdicion ? 'Editar Pedido' : 'Nuevo Pedido',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- DATOS DEL CLIENTE ---
              _buildSectionTitle('DATOS DEL CLIENTE'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _clienteController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del cliente',
                          hintText: 'Obligatorio',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa el nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactoController,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          hintText: 'Opcional',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(),
                          counterText: '',
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 12, right: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.phone),
                                SizedBox(width: 12),
                                Text(
                                  '+56 9 ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          if (value.length != 8) {
                            final int faltan = 8 - value.length;
                            return 'Ingresa 8 dígitos, faltan $faltan ${faltan == 1 ? "dígito" : "dígitos"}';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- FECHA Y HORA DE RETIRO ---
              _buildSectionTitle('FECHA Y HORA DE RETIRO'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _fechaController,
                          readOnly: true,
                          onTap: () =>
                              _seleccionarFecha(context, moradoPrincipal),
                          decoration: const InputDecoration(
                            labelText: 'Fecha',
                            hintText: 'dd/mm/aaaa',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Falta fecha'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _horaController,
                          readOnly: true,
                          onTap: () =>
                              _seleccionarHora(context, moradoPrincipal),
                          decoration: const InputDecoration(
                            labelText: 'Hora',
                            hintText: '10:00 - 20:00',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Falta hora' : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- DETALLES DEL PRODUCTO ---
              _buildSectionTitle('DETALLES DEL PRODUCTO'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo de masa:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      RadioGroup<String>(
                        groupValue: _tipoMasa,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _tipoMasa = value);
                          }
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text(
                                  'Horno',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: 'Horno',
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text(
                                  'Frita',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: 'Frita',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      const Text(
                        'Tamaño:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      RadioGroup<String>(
                        groupValue: _medidaMasa,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _medidaMasa = value);
                          }
                        },
                        child: Column(
                          children: [
                            _buildTamanoOption('Coctel'),
                            _buildTamanoOption('Mediana'),
                            _buildTamanoOption('Grande'),
                          ],
                        ),
                      ),
                      const Divider(),
                      const Text(
                        'Cantidad:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle,
                              color: moradoPrincipal,
                              size: 40,
                            ),
                            onPressed: _decrementarCantidad,
                          ),
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              controller: _cantidadController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: moradoPrincipal),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle,
                              color: moradoPrincipal,
                              size: 40,
                            ),
                            onPressed: _incrementarCantidad,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- ESTADO DE PAGO ---
              _buildSectionTitle('ESTADO DE PAGO'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RadioGroup<String>(
                    groupValue: _estadoPago,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _estadoPago = value);
                      }
                    },
                    child: const Column(
                      children: [
                        RadioListTile<String>(
                          title: Text('Por pagar'),
                          value: 'Por pagar',
                        ),
                        RadioListTile<String>(
                          title: Text('Pagado'),
                          value: 'Pagado',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- RESUMEN / DETALLES DEL PEDIDO ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tema.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: moradoPrincipal),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'DETALLES DEL PEDIDO',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: moradoPrincipal,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetalleFila('Cliente', nombreResumen),
                    _buildDetalleFila('Retiro', retiroResumen),
                    _buildDetalleFila('Encargo', encargoResumen),
                    _buildDetalleFila('Subtotal', subtotalResumen),
                    const Divider(),
                    Center(
                      child: Text(
                        'TOTAL A PAGAR AL RETIRAR: \$${totalAPagar.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: moradoPrincipal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- BOTÓN GUARDAR ---
              ElevatedButton.icon(
                onPressed: _guardando
                    ? null
                    : () => _guardarPedido(cantidad, totalMasas),
                icon: const Icon(Icons.save),
                label: Text(
                  _guardando
                      ? 'Guardando...'
                      : (_esEdicion ? 'Guardar Cambios' : 'Guardar Pedido'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}