import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../core/database/database_helper.dart';
import '../models/tarea.dart';

class IncidenciaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Incidencia>> obtenerIncidenciasPorAlumno(String alumnoId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'incidencias',
      where: 'alumno_id = ?',
      whereArgs: [alumnoId],
      orderBy: 'fecha DESC',
    );
    return result.map((map) => Incidencia.fromMap(map)).toList();
  }

  Future<List<Incidencia>> obtenerIncidenciasPorCurso(String cursoId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'incidencias',
      where: 'curso_id = ?',
      whereArgs: [cursoId],
      orderBy: 'fecha DESC',
    );
    return result.map((map) => Incidencia.fromMap(map)).toList();
  }

  Future<String> guardarIncidencia(Incidencia incidencia) async {
    final db = await _dbHelper.database;
    await db.insert('incidencias', incidencia.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return incidencia.id;
  }

  Future<void> eliminarIncidencia(String id) async {
    final db = await _dbHelper.database;
    await db.delete('incidencias', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Incidencia>> obtenerIncidenciasGraves() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'incidencias',
      where: 'gravedad IN (?, ?)',
      whereArgs: ['grave', 'muy_grave'],
      orderBy: 'fecha DESC',
    );
    return result.map((map) => Incidencia.fromMap(map)).toList();
  }
}
