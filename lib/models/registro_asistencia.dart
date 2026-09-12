enum EstadoAsistencia { presente, retardo, ausente, pendiente }

enum MetodoRegistro { voz, manual }

extension EstadoAsistenciaLabel on EstadoAsistencia {
  String get label {
    switch (this) {
      case EstadoAsistencia.presente:
        return 'Presente';
      case EstadoAsistencia.retardo:
        return 'Retardo';
      case EstadoAsistencia.ausente:
        return 'Ausente';
      case EstadoAsistencia.pendiente:
        return 'Pendiente';
    }
  }
}

EstadoAsistencia estadoFromString(String value) {
  return EstadoAsistencia.values.firstWhere(
    (e) => e.name == value,
    orElse: () => EstadoAsistencia.pendiente,
  );
}

MetodoRegistro metodoFromString(String value) {
  return MetodoRegistro.values.firstWhere(
    (e) => e.name == value,
    orElse: () => MetodoRegistro.manual,
  );
}

class RegistroAsistencia {
  final String id;
  final String alumnoId;
  final String cursoId;
  final DateTime fecha;
  final EstadoAsistencia estado;
  final MetodoRegistro metodo;

  RegistroAsistencia({
    required this.id,
    required this.alumnoId,
    required this.cursoId,
    required this.fecha,
    required this.estado,
    this.metodo = MetodoRegistro.manual,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'alumno_id': alumnoId,
        'curso_id': cursoId,
        'fecha': fecha.toIso8601String(),
        'estado': estado.name,
        'metodo': metodo.name,
      };

  factory RegistroAsistencia.fromMap(Map<String, dynamic> map) => RegistroAsistencia(
        id: map['id'] as String,
        alumnoId: map['alumno_id'] as String,
        cursoId: map['curso_id'] as String,
        fecha: DateTime.parse(map['fecha'] as String),
        estado: estadoFromString(map['estado'] as String),
        metodo: metodoFromString(map['metodo'] as String? ?? 'manual'),
      );
}
