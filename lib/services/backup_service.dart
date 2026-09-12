import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/database/database_helper.dart';

class BackupService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Crea backup completo de la base de datos en archivo JSON
  Future<String> crearBackup() async {
    try {
      final db = await _dbHelper.database;
      
      // Obtener todas las tablas
      final tablas = [
        'cursos', 'alumnos', 'asistencias', 'calificaciones',
        'tareas', 'incidencias', 'contactos_padres', 'calendario_eventos'
      ];

      final backupData = <String, dynamic>{};
      
      for (final tabla in tablas) {
        final resultados = await db.query(tabla);
        backupData[tabla] = resultados;
      }

      // Guardar en archivo JSON
      final directorio = await _obtenerDirectorioBackup();
      final fecha = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
      final nombreArchivo = 'backup_eduai_$fecha.json';
      final rutaCompleta = '${directorio.path}/$nombreArchivo';
      
      final archivo = File(rutaCompleta);
      await archivo.writeAsString(jsonEncode(backupData), encoding: utf8);
      
      return rutaCompleta;
    } catch (e) {
      print('Error al crear backup: $e');
      rethrow;
    }
  }

  /// Restaura backup desde archivo JSON
  Future<bool> restaurarBackup(String rutaArchivo) async {
    try {
      final archivo = File(rutaArchivo);
      if (!await archivo.exists()) {
        throw Exception('El archivo de backup no existe');
      }

      final contenido = await archivo.readAsString(encoding: utf8);
      final backupData = jsonDecode(contenido) as Map<String, dynamic>;
      
      final db = await _dbHelper.database;
      
      // Limpiar tablas existentes (en orden correcto por foreign keys)
      await db.delete('calendario_eventos');
      await db.delete('contactos_padres');
      await db.delete('incidencias');
      await db.delete('tareas');
      await db.delete('calificaciones');
      await db.delete('asistencias');
      await db.delete('alumnos');
      await db.delete('cursos');
      
      // Restaurar datos (en orden inverso)
      final tablasOrden = [
        'cursos', 'alumnos', 'asistencias', 'calificaciones',
        'tareas', 'incidencias', 'contactos_padres', 'calendario_eventos'
      ];

      for (final tabla in tablasOrden) {
        if (backupData.containsKey(tabla)) {
          final datos = List<Map<String, dynamic>>.from(backupData[tabla]);
          for (final dato in datos) {
            await db.insert(tabla, dato, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      }
      
      return true;
    } catch (e) {
      print('Error al restaurar backup: $e');
      return false;
    }
  }

  /// Lista backups disponibles
  Future<List<File>> listarBackups() async {
    try {
      final directorio = await _obtenerDirectorioBackup();
      if (!await directorio.exists()) {
        return [];
      }
      
      final archivos = directorio
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json') && f.path.contains('backup_eduai'))
          .toList();
      
      archivos.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      
      return archivos;
    } catch (e) {
      print('Error al listar backups: $e');
      return [];
    }
  }

  /// Elimina backup antiguo
  Future<void> eliminarBackupAntiguo({int diasMaximos = 30}) async {
    try {
      final backups = await listarBackups();
      final ahora = DateTime.now();
      
      for (final backup in backups) {
        final estadisticas = await backup.stat();
        final diferencia = ahora.difference(estadisticas.modified);
        
        if (diferencia.inDays > diasMaximos) {
          await backup.delete();
        }
      }
    } catch (e) {
      print('Error al eliminar backups antiguos: $e');
    }
  }

  Future<Directory> _obtenerDirectorioBackup() async {
    Directory directorio;
    try {
      directorio = await getApplicationDocumentsDirectory();
    } catch (_) {
      directorio = Directory.current;
    }
    
    final carpetaBackup = Directory('${directorio.path}/EDUAI_Backups');
    if (!await carpetaBackup.exists()) {
      await carpetaBackup.create(recursive: true);
    }
    
    return carpetaBackup;
  }
}
