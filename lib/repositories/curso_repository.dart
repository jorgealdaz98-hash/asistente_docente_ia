import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/curso.dart';

class CursoRepository {
  final _uuid = const Uuid();
  final _dbHelper = DatabaseHelper.instance;

  Future<List<Curso>> obtenerTodos() async {
    final db = await _dbHelper.database;
    final maps = await db.query('cursos', orderBy: 'nombre ASC');
    return maps.map((m) => Curso.fromMap(m)).toList();
  }

  Future<Curso?> obtenerPorId(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('cursos', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Curso.fromMap(maps.first);
  }

  Future<Curso> crear({
    required String nombre,
    required String paralelo,
    required String turno,
    required String aula,
    String unidadActual = '',
  }) async {
    final db = await _dbHelper.database;
    final curso = Curso(
      id: _uuid.v4(),
      nombre: nombre,
      paralelo: paralelo,
      turno: turno,
      aula: aula,
      unidadActual: unidadActual,
    );
    await db.insert('cursos', curso.toMap());
    return curso;
  }

  Future<void> actualizar(Curso curso) async {
    final db = await _dbHelper.database;
    await db.update('cursos', curso.toMap(), where: 'id = ?', whereArgs: [curso.id]);
  }

  Future<void> eliminar(String id) async {
    final db = await _dbHelper.database;
    await db.delete('cursos', where: 'id = ?', whereArgs: [id]);
  }
}
