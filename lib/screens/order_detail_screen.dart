import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order pedido;

  const OrderDetailScreen({
    super.key,
    required this.pedido,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del pedido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildInfoCard('Cliente', pedido.cliente),
            _buildInfoCard('Contacto', pedido.contacto),
            _buildInfoCard('Fecha', pedido.fecha),
            _buildInfoCard('Hora', pedido.hora),
            _buildInfoCard('Tipo de masa', pedido.tipoMasa),
            _buildInfoCard('Medida', pedido.medidaMasa),
            _buildInfoCard('Cantidad', '${pedido.cantidad}'),
            _buildInfoCard('Estado del pago', pedido.estadoPago),
            _buildInfoCard('Total', '\$${pedido.total}'),
          ],
        ),
      ),
    );
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
}
