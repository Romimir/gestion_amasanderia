class Order {
  final String cliente;
  final String contacto;
  final String fecha;
  final String hora;
  final String tipoMasa;
  final String medidaMasa;
  final int cantidad;
  final String estadoPago;
  final int total;

  Order({
    required this.cliente,
    required this.contacto,
    required this.fecha,
    required this.hora,
    required this.tipoMasa,
    required this.medidaMasa,
    required this.cantidad,
    required this.estadoPago,
    required this.total,
  });
}