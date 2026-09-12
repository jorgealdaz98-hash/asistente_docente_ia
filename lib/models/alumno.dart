class Alumno {
  final String id;
  final String cursoId;
  final String nombre;
  final String codigo; // ej. MAT-2024-089
  final double asistenciaHabitual; // porcentaje 0-100, calculado o inicial

  Alumno({
    required this.id,
    required this.cursoId,
    required this.nombre,
    required this.codigo,
    this.asistenciaHabitual = 100.0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'curso_id': cursoId,
        'nombre': nombre,
        'codigo': codigo,
        'asistencia_habitual': asistenciaHabitual,
      };

  factory Alumno.fromMap(Map<String, dynamic> map) => Alumno(
        id: map['id'] as String,
        cursoId: map['curso_id'] as String,
        nombre: map['nombre'] as String,
        codigo: map['codigo'] as String,
        asistenciaHabitual: (map['asistencia_habitual'] as num?)?.toDouble() ?? 100.0,
      );

  Alumno copyWith({
    String? nombre,
    String? codigo,
    double? asistenciaHabitual,
  }) {
    return Alumno(
      id: id,
      cursoId: cursoId,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      asistenciaHabitual: asistenciaHabitual ?? this.asistenciaHabitual,
    );
  }
}
