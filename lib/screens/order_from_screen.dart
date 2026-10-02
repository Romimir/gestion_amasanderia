import 'package:flutter/material.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _contactoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController(text: '0');
  
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();

  String _tipoMasa = 'Horno'; 
  String _medidaMasa = 'Coctel'; 
  String _estadoPago = 'Por pagar';

  @override
  void initState() {
    super.initState();
    _cantidadController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
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

  @override
  Widget build(BuildContext context) {
    int cantidad = int.tryParse(_cantidadController.text) ?? 0;
    int precioUnidad = _getPrecioUnidad(_tipoMasa, _medidaMasa);
    int totalMasas = cantidad * precioUnidad;
    int totalAPagar = _estadoPago == 'Pagado' ? 0 : totalMasas;

    final tema = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Pedido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Registrar encargo para la amasandería',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

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
                          labelText: 'Nombre del cliente (Obligatorio)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
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
                        decoration: const InputDecoration(
                          labelText: 'Numero de contacto (Opcional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                          prefixText: '+56 9 ',
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          if (value.length != 8) return 'Debe tener 8 dígitos';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- FECHA Y HORA DE RETIRO SIMPLIFICADA ---
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
                          keyboardType: TextInputType.datetime,
                          decoration: const InputDecoration(
                            labelText: 'Fecha',
                            hintText: 'dd/mm/aaaa',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Falta fecha' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _horaController,
                          keyboardType: TextInputType.datetime,
                          decoration: const InputDecoration(
                            labelText: 'Hora',
                            hintText: '10:00 a 20:00',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Falta';
                            if (!value.contains(':')) return 'Usa formato HH:MM';
                            
                            List<String> partes = value.split(':');
                            int? hora = int.tryParse(partes[0]);
                            
                            if (hora == null || hora < 10 || hora >= 21) {
                              return 'Fuera de horario';
                            }
                            return null;
                          },
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
                      const Text('Tipo de masa:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                title: const Text('Horno'),
                                value: 'Horno',
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Frita'),
                                value: 'Frita',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      const Text('Tamaño:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      const Text('Cantidad:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: tema.primary, size: 40),
                            onPressed: _decrementarCantidad,
                          ),
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              controller: _cantidadController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderSide: BorderSide(color: tema.primary)),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle, color: tema.primary, size: 40),
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

              // --- RESUMEN FINAL ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tema.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: tema.primary),
                ),
                child: Column(
                  children: [
                    Text('Total de masas: \$${totalMasas.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16)),
                    const Divider(),
                    Text(
                      'TOTAL A PAGAR AL RETIRAR: \$${totalAPagar.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tema.primary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- BOTÓN GUARDAR ---
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Pedido registrado con éxito!')),
                    );
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Guardar Pedido'),
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