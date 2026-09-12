import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../core/database/database_helper.dart';
import '../models/tarea.dart';

class TareaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Tarea>> obtenerTareasPorCurso(String cursoId, {bool soloActivas = true}) async {
    final db = await _dbHelper.database;
    String where = 'curso_id = ?';
    List<dynamic> whereArgs = [cursoId];
    
    if (soloActivas) {
      where += ' AND es_activa = 1';
    }
    
    final result = await db.query(
      'tareas',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'fecha_asignacion DESC',
    );
    
    return result.map((map) => Tarea.fromMap(map)).toList();
  }

  Future<Tarea?> obtenerTarea(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query('tareas', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Tarea.fromMap(result.first);
  }

  Future<String> guardarTarea(Tarea tarea) async {
    final db = await _dbHelper.database;
    await db.insert('tareas', tarea.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return tarea.id;
  }

  Future<void> eliminarTarea(String id) async {
    final db = await _dbHelper.database;
    await db.delete('tareas', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> actualizarEstado(String id, bool activa) async {
    final db = await _dbHelper.database;
    await db.update(
      'tareas',
      {'es_activa': activa ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Tarea>> obtenerTareasPendientes() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tareas',
      where: 'es_activa = 1 AND fecha_entrega IS NOT NULL',
      orderBy: 'fecha_entrega ASC',
    );
    return result.map((map) => Tarea.fromMap(map)).toList();
  }
}
