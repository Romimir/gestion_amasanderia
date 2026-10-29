class Order {
  final int? id;
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
    this.id,
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

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'cliente': cliente,
      'contacto': contacto,
      'fecha': fecha,
      'hora': hora,
      'tipoMasa': tipoMasa,
      'medidaMasa': medidaMasa,
      'cantidad': cantidad,
      'estadoPago': estadoPago,
      'total': total,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      cliente: map['cliente'],
      contacto: map['contacto'],
      fecha: map['fecha'],
      hora: map['hora'],
      tipoMasa: map['tipoMasa'],
      medidaMasa: map['medidaMasa'],
      cantidad: map['cantidad'],
      estadoPago: map['estadoPago'],
      total: map['total'],
    );
  }
}