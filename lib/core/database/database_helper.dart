import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Helper central de base de datos. Usa sqflite_common_ffi para que
/// funcione en Windows/Linux/macOS de escritorio (no solo Android/iOS).
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  static const int _version = 1;
  static const String _dbName = 'asistente_docente_ia.db';

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  /// Debe llamarse una sola vez en main() antes de usar la base de datos,
  /// para inicializar el motor FFI en plataformas de escritorio.
  static void initFfi() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  Future<Database> _initDb() async {
    Directory appDir;
    try {
      appDir = await getApplicationSupportDirectory();
    } catch (_) {
      appDir = Directory.current;
    }
    final dbPath = join(appDir.path, _dbName);

    return databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _version,
        onCreate: _onCreate,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cursos (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        paralelo TEXT NOT NULL,
        turno TEXT NOT NULL,
        aula TEXT NOT NULL,
        unidad_actual TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE alumnos (
        id TEXT PRIMARY KEY,
        curso_id TEXT NOT NULL,
        nombre TEXT NOT NULL,
        codigo TEXT NOT NULL,
        asistencia_habitual REAL NOT NULL DEFAULT 100,
        FOREIGN KEY (curso_id) REFERENCES cursos (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE asistencias (
        id TEXT PRIMARY KEY,
        alumno_id TEXT NOT NULL,
        curso_id TEXT NOT NULL,
        fecha TEXT NOT NULL,
        estado TEXT NOT NULL,
        metodo TEXT NOT NULL DEFAULT 'manual',
        FOREIGN KEY (alumno_id) REFERENCES alumnos (id) ON DELETE CASCADE,
        FOREIGN KEY (curso_id) REFERENCES cursos (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE calificaciones (
        id TEXT PRIMARY KEY,
        alumno_id TEXT NOT NULL,
        curso_id TEXT NOT NULL,
        titulo TEXT NOT NULL,
        nota REAL NOT NULL,
        fecha TEXT NOT NULL,
        FOREIGN KEY (alumno_id) REFERENCES alumnos (id) ON DELETE CASCADE,
        FOREIGN KEY (curso_id) REFERENCES cursos (id) ON DELETE CASCADE
      );
    ''');

    // Tablas nuevas para funcionalidades extendidas
    await db.execute('''
      CREATE TABLE tareas (
        id TEXT PRIMARY KEY,
        curso_id TEXT NOT NULL,
        titulo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        fecha_asignacion TEXT NOT NULL,
        fecha_entrega TEXT,
        es_activa INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (curso_id) REFERENCES cursos (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE incidencias (
        id TEXT PRIMARY KEY,
        alumno_id TEXT NOT NULL,
        curso_id TEXT NOT NULL,
        tipo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        fecha TEXT NOT NULL,
        gravedad TEXT,
        FOREIGN KEY (alumno_id) REFERENCES alumnos (id) ON DELETE CASCADE,
        FOREIGN KEY (curso_id) REFERENCES cursos (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE contactos_padres (
        id TEXT PRIMARY KEY,
        alumno_id TEXT NOT NULL,
        nombre TEXT NOT NULL,
        parentesco TEXT NOT NULL,
        telefono TEXT,
        email TEXT,
        prefiere_whatsapp INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (alumno_id) REFERENCES alumnos (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE calendario_eventos (
        id TEXT PRIMARY KEY,
        curso_id TEXT,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        fecha_inicio TEXT NOT NULL,
        fecha_fin TEXT,
        tipo TEXT NOT NULL,
        recordatorio INTEGER NOT NULL DEFAULT 0
      );
    ''');
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
