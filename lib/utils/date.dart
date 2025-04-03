String formatDate(DateTime fecha) {
  final dias = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 
    'Viernes', 'Sábado', 'Domingo'
  ];
  final meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];

  String diaSemana = dias[fecha.weekday - 1];
  String mes = meses[fecha.month - 1];

  return '$diaSemana ${fecha.day} $mes ${fecha.year}';
}