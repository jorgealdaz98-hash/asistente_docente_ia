class Curso {
  final String id;
  final String nombre; // ej. "Matemáticas"
  final String paralelo; // ej. "3° B"
  final String turno; // Matutino / Vespertino
  final String aula;
  final String unidadActual;

  Curso({
    required this.id,
    required this.nombre,
    required this.paralelo,
    required this.turno,
    required this.aula,
    this.unidadActual = '',
  });

  String get nombreCompleto => '$nombre $paralelo';

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'paralelo': paralelo,
        'turno': turno,
        'aula': aula,
        'unidad_actual': unidadActual,
      };

  factory Curso.fromMap(Map<String, dynamic> map) => Curso(
        id: map['id'] as String,
        nombre: map['nombre'] as String,
        paralelo: map['paralelo'] as String,
        turno: map['turno'] as String,
        aula: map['aula'] as String,
        unidadActual: map['unidad_actual'] as String? ?? '',
      );

  Curso copyWith({
    String? nombre,
    String? paralelo,
    String? turno,
    String? aula,
    String? unidadActual,
  }) {
    return Curso(
      id: id,
      nombre: nombre ?? this.nombre,
      paralelo: paralelo ?? this.paralelo,
      turno: turno ?? this.turno,
      aula: aula ?? this.aula,
      unidadActual: unidadActual ?? this.unidadActual,
    );
  }

  @override
  bool operator ==(Object other) => other is Curso && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
