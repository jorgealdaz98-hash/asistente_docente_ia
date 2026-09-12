import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../core/database/database_helper.dart';
import '../models/tarea.dart';

class ContactoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<ContactoPadre>> obtenerContactosPorAlumno(String alumnoId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'contactos_padres',
      where: 'alumno_id = ?',
      whereArgs: [alumnoId],
    );
    return result.map((map) => ContactoPadre.fromMap(map)).toList();
  }

  Future<ContactoPadre?> obtenerContactoPrincipal(String alumnoId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'contactos_padres',
      where: 'alumno_id = ?',
      whereArgs: [alumnoId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return ContactoPadre.fromMap(result.first);
  }

  Future<String> guardarContacto(ContactoPadre contacto) async {
    final db = await _dbHelper.database;
    await db.insert('contactos_padres', contacto.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return contacto.id;
  }

  Future<void> eliminarContacto(String id) async {
    final db = await _dbHelper.database;
    await db.delete('contactos_padres', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ContactoPadre>> buscarContactosPorTelefono(String telefono) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'contactos_padres',
      where: 'telefono LIKE ?',
      whereArgs: ['%$telefono%'],
    );
    return result.map((map) => ContactoPadre.fromMap(map)).toList();
  }
}
