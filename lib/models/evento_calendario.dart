class EventoCalendario {
  final String id;
  final String? cursoId;
  final String titulo;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final String tipo; // 'examen', 'tarea', 'reunion', 'evento_escolar', 'otro'
  final bool recordatorio;

  EventoCalendario({
    required this.id,
    this.cursoId,
    required this.titulo,
    this.descripcion,
    required this.fechaInicio,
    this.fechaFin,
    required this.tipo,
    this.recordatorio = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'curso_id': cursoId,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin?.toIso8601String(),
        'tipo': tipo,
        'recordatorio': recordatorio ? 1 : 0,
      };

  factory EventoCalendario.fromMap(Map<String, dynamic> map) => EventoCalendario(
        id: map['id'] as String,
        cursoId: map['curso_id'] as String?,
        titulo: map['titulo'] as String,
        descripcion: map['descripcion'] as String?,
        fechaInicio: DateTime.parse(map['fecha_inicio'] as String),
        fechaFin: map['fecha_fin'] != null 
            ? DateTime.parse(map['fecha_fin'] as String) 
            : null,
        tipo: map['tipo'] as String,
        recordatorio: (map['recordatorio'] as int?) == 1,
      );

  EventoCalendario copyWith({
    String? titulo,
    String? descripcion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? tipo,
    bool? recordatorio,
  }) {
    return EventoCalendario(
      id: id,
      cursoId: cursoId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      tipo: tipo ?? this.tipo,
      recordatorio: recordatorio ?? this.recordatorio,
    );
  }
}
