import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/alumno.dart';

class AlumnoRepository {
  final _uuid = const Uuid();
  final _dbHelper = DatabaseHelper.instance;

  Future<List<Alumno>> obtenerPorCurso(String cursoId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'alumnos',
      where: 'curso_id = ?',
      whereArgs: [cursoId],
      orderBy: 'nombre ASC',
    );
    return maps.map((m) => Alumno.fromMap(m)).toList();
  }

  Future<Alumno> crear({
    required String cursoId,
    required String nombre,
    required String codigo,
    double asistenciaHabitual = 100.0,
  }) async {
    final db = await _dbHelper.database;
    final alumno = Alumno(
      id: _uuid.v4(),
      cursoId: cursoId,
      nombre: nombre,
      codigo: codigo,
      asistenciaHabitual: asistenciaHabitual,
    );
    await db.insert('alumnos', alumno.toMap());
    return alumno;
  }

  Future<void> actualizar(Alumno alumno) async {
    final db = await _dbHelper.database;
    await db.update('alumnos', alumno.toMap(), where: 'id = ?', whereArgs: [alumno.id]);
  }

  Future<void> eliminar(String id) async {
    final db = await _dbHelper.database;
    await db.delete('alumnos', where: 'id = ?', whereArgs: [id]);
  }

  /// Recalcula el % de asistencia habitual de un alumno en base a su
  /// historial de registros de asistencia.
  Future<void> recalcularAsistenciaHabitual(String alumnoId) async {
    final db = await _dbHelper.database;
    final registros = await db.query(
      'asistencias',
      where: 'alumno_id = ?',
      whereArgs: [alumnoId],
    );
    if (registros.isEmpty) return;

    final presentesOTarde = registros.where((r) => r['estado'] != 'ausente').length;
    final porcentaje = (presentesOTarde / registros.length) * 100;

    await db.update(
      'alumnos',
      {'asistencia_habitual': porcentaje},
      where: 'id = ?',
      whereArgs: [alumnoId],
    );
  }
}
