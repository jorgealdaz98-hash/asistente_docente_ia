import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/calificacion.dart';

class CalificacionRepository {
  final _uuid = const Uuid();
  final _dbHelper = DatabaseHelper.instance;

  Future<Calificacion> crear({
    required String alumnoId,
    required String cursoId,
    required String titulo,
    required double nota,
    DateTime? fecha,
  }) async {
    final db = await _dbHelper.database;
    final calificacion = Calificacion(
      id: _uuid.v4(),
      alumnoId: alumnoId,
      cursoId: cursoId,
      titulo: titulo,
      nota: nota,
      fecha: fecha ?? DateTime.now(),
    );
    await db.insert('calificaciones', calificacion.toMap());
    return calificacion;
  }

  Future<List<Calificacion>> obtenerPorCurso(String cursoId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'calificaciones',
      where: 'curso_id = ?',
      whereArgs: [cursoId],
      orderBy: 'fecha DESC',
    );
    return maps.map((m) => Calificacion.fromMap(m)).toList();
  }

  Future<List<Calificacion>> obtenerPorAlumno(String alumnoId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'calificaciones',
      where: 'alumno_id = ?',
      whereArgs: [alumnoId],
      orderBy: 'fecha DESC',
    );
    return maps.map((m) => Calificacion.fromMap(m)).toList();
  }

  Future<double> promedioCurso(String cursoId) async {
    final calificaciones = await obtenerPorCurso(cursoId);
    if (calificaciones.isEmpty) return 0.0;
    final suma = calificaciones.fold<double>(0, (acc, c) => acc + c.nota);
    return suma / calificaciones.length;
  }

  Future<void> eliminar(String id) async {
    final db = await _dbHelper.database;
    await db.delete('calificaciones', where: 'id = ?', whereArgs: [id]);
  }
}
