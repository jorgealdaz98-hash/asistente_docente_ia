class Tarea {
  final String id;
  final String cursoId;
  final String titulo;
  final String descripcion;
  final DateTime fechaAsignacion;
  final DateTime? fechaEntrega;
  final bool esActiva;

  Tarea({
    required this.id,
    required this.cursoId,
    required this.titulo,
    required this.descripcion,
    required this.fechaAsignacion,
    this.fechaEntrega,
    this.esActiva = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'curso_id': cursoId,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha_asignacion': fechaAsignacion.toIso8601String(),
        'fecha_entrega': fechaEntrega?.toIso8601String(),
        'es_activa': esActiva ? 1 : 0,
      };

  factory Tarea.fromMap(Map<String, dynamic> map) => Tarea(
        id: map['id'] as String,
        cursoId: map['curso_id'] as String,
        titulo: map['titulo'] as String,
        descripcion: map['descripcion'] as String,
        fechaAsignacion: DateTime.parse(map['fecha_asignacion'] as String),
        fechaEntrega: map['fecha_entrega'] != null 
            ? DateTime.parse(map['fecha_entrega'] as String) 
            : null,
        esActiva: (map['es_activa'] as int?) == 1,
      );

  Tarea copyWith({
    String? titulo,
    String? descripcion,
    DateTime? fechaEntrega,
    bool? esActiva,
  }) {
    return Tarea(
      id: id,
      cursoId: cursoId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaAsignacion: fechaAsignacion,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      esActiva: esActiva ?? this.esActiva,
    );
  }
}

class Incidencia {
  final String id;
  final String alumnoId;
  final String cursoId;
  final String tipo; // 'conducta', 'merito', 'observacion'
  final String descripcion;
  final DateTime fecha;
  final String? gravedad; // 'leve', 'grave', 'muy_grave'

  Incidencia({
    required this.id,
    required this.alumnoId,
    required this.cursoId,
    required this.tipo,
    required this.descripcion,
    required this.fecha,
    this.gravedad,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'alumno_id': alumnoId,
        'curso_id': cursoId,
        'tipo': tipo,
        'descripcion': descripcion,
        'fecha': fecha.toIso8601String(),
        'gravedad': gravedad,
      };

  factory Incidencia.fromMap(Map<String, dynamic> map) => Incidencia(
        id: map['id'] as String,
        alumnoId: map['alumno_id'] as String,
        cursoId: map['curso_id'] as String,
        tipo: map['tipo'] as String,
        descripcion: map['descripcion'] as String,
        fecha: DateTime.parse(map['fecha'] as String),
        gravedad: map['gravedad'] as String?,
      );
}

class ContactoPadre {
  final String id;
  final String alumnoId;
  final String nombre;
  final String parentesco; // 'padre', 'madre', 'tutor'
  final String? telefono;
  final String? email;
  final bool prefiereWhatsApp;

  ContactoPadre({
    required this.id,
    required this.alumnoId,
    required this.nombre,
    required this.parentesco,
    this.telefono,
    this.email,
    this.prefiereWhatsApp = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'alumno_id': alumnoId,
        'nombre': nombre,
        'parentesco': parentesco,
        'telefono': telefono,
        'email': email,
        'prefiere_whatsapp': prefiereWhatsApp ? 1 : 0,
      };

  factory ContactoPadre.fromMap(Map<String, dynamic> map) => ContactoPadre(
        id: map['id'] as String,
        alumnoId: map['alumno_id'] as String,
        nombre: map['nombre'] as String,
        parentesco: map['parentesco'] as String,
        telefono: map['telefono'] as String?,
        email: map['email'] as String?,
        prefiereWhatsApp: (map['prefiere_whatsapp'] as int?) == 1,
      );
}
