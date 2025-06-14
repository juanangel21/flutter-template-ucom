class Pago {
  String codigoPago;
  String codigoReservaAsociada;
  double montoPagado;
  DateTime fechaPago;
  String estado;

  Pago({
    required this.codigoPago,
    required this.codigoReservaAsociada,
    required this.montoPagado,
    required this.fechaPago,
    required this.estado, //
  });

  factory Pago.fromJson(Map<String, dynamic> json) => Pago(
    codigoPago: json['codigoPago'],
    codigoReservaAsociada: json['codigoReservaAsociada'],
    montoPagado: json['montoPagado'].toDouble(),
    fechaPago: DateTime.parse(json['fechaPago']),
    estado: json['estado'] ?? 'PENDIENTE', // ← valor por defecto
  );

  Map<String, dynamic> toJson() => {
    'codigoPago': codigoPago,
    'codigoReservaAsociada': codigoReservaAsociada,
    'montoPagado': montoPagado,
    'fechaPago': fechaPago.toIso8601String(),
    'estado': estado, // ← guardar estado
  };
}
