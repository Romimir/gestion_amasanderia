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
      id: map['id'] as int?,
      cliente: map['cliente'] as String,
      contacto: map['contacto'] as String,
      fecha: map['fecha'] as String,
      hora: map['hora'] as String,
      tipoMasa: map['tipoMasa'] as String,
      medidaMasa: map['medidaMasa'] as String,
      cantidad: map['cantidad'] as int,
      estadoPago: map['estadoPago'] as String,
      total: map['total'] as int,
    );
  }

  Order copyWith({
    int? id,
    String? cliente,
    String? contacto,
    String? fecha,
    String? hora,
    String? tipoMasa,
    String? medidaMasa,
    int? cantidad,
    String? estadoPago,
    int? total,
  }) {
    return Order(
      id: id ?? this.id,
      cliente: cliente ?? this.cliente,
      contacto: contacto ?? this.contacto,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      tipoMasa: tipoMasa ?? this.tipoMasa,
      medidaMasa: medidaMasa ?? this.medidaMasa,
      cantidad: cantidad ?? this.cantidad,
      estadoPago: estadoPago ?? this.estadoPago,
      total: total ?? this.total,
    );
  }
}