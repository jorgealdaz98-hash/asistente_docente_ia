import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/registro_asistencia.dart';

class AsistenciaRepository {
  final _uuid = const Uuid();
  final _dbHelper = DatabaseHelper.instance;

  Future<RegistroAsistencia> registrar({
    required String alumnoId,
    required String cursoId,
    required EstadoAsistencia estado,
    MetodoRegistro metodo = MetodoRegistro.manual,
    DateTime? fecha,
  }) async {
    final db = await _dbHelper.database;
    final registro = RegistroAsistencia(
      id: _uuid.v4(),
      alumnoId: alumnoId,
      cursoId: cursoId,
      fecha: fecha ?? DateTime.now(),
      estado: estado,
      metodo: metodo,
    );
    await db.insert('asistencias', registro.toMap());
    return registro;
  }

  Future<List<RegistroAsistencia>> obtenerPorCursoYFecha(
    String cursoId,
    DateTime fecha,
  ) async {
    final db = await _dbHelper.database;
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(const Duration(days: 1));

    final maps = await db.query(
      'asistencias',
      where: 'curso_id = ? AND fecha >= ? AND fecha < ?',
      whereArgs: [cursoId, inicio.toIso8601String(), fin.toIso8601String()],
    );
    return maps.map((m) => RegistroAsistencia.fromMap(m)).toList();
  }

  Future<List<RegistroAsistencia>> obtenerPorAlumno(String alumnoId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'asistencias',
      where: 'alumno_id = ?',
      whereArgs: [alumnoId],
      orderBy: 'fecha DESC',
    );
    return maps.map((m) => RegistroAsistencia.fromMap(m)).toList();
  }
}
