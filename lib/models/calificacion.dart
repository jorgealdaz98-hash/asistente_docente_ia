class Calificacion {
  final String id;
  final String alumnoId;
  final String cursoId;
  final String titulo; // ej. "Examen Álgebra Lineal"
  final double nota; // 0-10 o 0-100 según prefieras
  final DateTime fecha;

  Calificacion({
    required this.id,
    required this.alumnoId,
    required this.cursoId,
    required this.titulo,
    required this.nota,
    required this.fecha,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'alumno_id': alumnoId,
        'curso_id': cursoId,
        'titulo': titulo,
        'nota': nota,
        'fecha': fecha.toIso8601String(),
      };

  factory Calificacion.fromMap(Map<String, dynamic> map) => Calificacion(
        id: map['id'] as String,
        alumnoId: map['alumno_id'] as String,
        cursoId: map['curso_id'] as String,
        titulo: map['titulo'] as String,
        nota: (map['nota'] as num).toDouble(),
        fecha: DateTime.parse(map['fecha'] as String),
      );
}
