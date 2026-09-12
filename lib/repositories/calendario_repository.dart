import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../core/database/database_helper.dart';
import '../models/evento_calendario.dart';

class CalendarioRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<EventoCalendario>> obtenerEventosPorCurso(String cursoId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'calendario_eventos',
      where: 'curso_id = ?',
      whereArgs: [cursoId],
      orderBy: 'fecha_inicio ASC',
    );
    return result.map((map) => EventoCalendario.fromMap(map)).toList();
  }

  Future<List<EventoCalendario>> obtenerProximosEventos({int dias = 7}) async {
    final db = await _dbHelper.database;
    final ahora = DateTime.now();
    final finRango = ahora.add(Duration(days: dias));
    
    final result = await db.query(
      'calendario_eventos',
      where: 'fecha_inicio >= ? AND fecha_inicio <= ?',
      whereArgs: [ahora.toIso8601String(), finRango.toIso8601String()],
      orderBy: 'fecha_inicio ASC',
    );
    return result.map((map) => EventoCalendario.fromMap(map)).toList();
  }

  Future<String> guardarEvento(EventoCalendario evento) async {
    final db = await _dbHelper.database;
    await db.insert('calendario_eventos', evento.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return evento.id;
  }

  Future<void> eliminarEvento(String id) async {
    final db = await _dbHelper.database;
    await db.delete('calendario_eventos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<EventoCalendario>> obtenerEventosPorTipo(String tipo) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'calendario_eventos',
      where: 'tipo = ?',
      whereArgs: [tipo],
      orderBy: 'fecha_inicio ASC',
    );
    return result.map((map) => EventoCalendario.fromMap(map)).toList();
  }
}
