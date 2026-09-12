import '../models/alumno.dart';
import '../models/calificacion.dart';
import '../models/registro_asistencia.dart';
import '../repositories/alumno_repository.dart';
import '../repositories/calificacion_repository.dart';
import '../repositories/asistencia_repository.dart';

class AnalisisService {
  final AlumnoRepository _alumnoRepo = AlumnoRepository();
  final CalificacionRepository _califRepo = CalificacionRepository();
  final AsistenciaRepository _asistRepo = AsistenciaRepository();

  /// Detecta alumnos en riesgo académico (promedio bajo y/o asistencia baja)
  Future<List<Map<String, dynamic>>> detectarAlumnosEnRiesgo(String cursoId) async {
    final alumnos = await _alumnoRepo.obtenerAlumnosPorCurso(cursoId);
    final resultados = <Map<String, dynamic>>[];

    for (final alumno in alumnos) {
      final calificaciones = await _califRepo.obtenerCalificacionesPorAlumno(alumno.id);
      final asistencias = await _asistRepo.obtenerAsistenciasPorAlumno(alumno.id);

      double promedioNotas = 0;
      if (calificaciones.isNotEmpty) {
        promedioNotas = calificaciones.map((c) => c.nota).reduce((a, b) => a + b) / calificaciones.length;
      }

      int presentes = asistencias.where((a) => a.estado == EstadoAsistencia.presente).length;
      double porcentajeAsistencia = asistencias.isNotEmpty 
          ? (presentes / asistencias.length) * 100 
          : 100;

      bool enRiesgoAcademico = promedioNotas < 60;
      bool enRiesgoAsistencia = porcentajeAsistencia < 75;

      if (enRiesgoAcademico || enRiesgoAsistencia) {
        resultados.add({
          'alumno': alumno,
          'promedioNotas': promedioNotas,
          'porcentajeAsistencia': porcentajeAsistencia,
          'riesgoAcademico': enRiesgoAcademico,
          'riesgoAsistencia': enRiesgoAsistencia,
          'factoresRiesgo': [
            if (enRiesgoAcademico) 'Bajo rendimiento académico',
            if (enRiesgoAsistencia) 'Baja asistencia',
          ],
        });
      }
    }

    // Ordenar por nivel de riesgo (más factores primero)
    resultados.sort((a, b) {
      int factoresA = (a['factoresRiesgo'] as List).length;
      int factoresB = (b['factoresRiesgo'] as List).length;
      return factoresB.compareTo(factoresA);
    });

    return resultados;
  }

  /// Genera estadísticas del curso
  Future<Map<String, dynamic>> generarEstadisticasCurso(String cursoId) async {
    final alumnos = await _alumnoRepo.obtenerAlumnosPorCurso(cursoId);
    final calificaciones = await _califRepo.obtenerCalificacionesPorCurso(cursoId);
    final asistencias = await _asistRepo.obtenerRegistrosPorCurso(cursoId);

    double promedioGeneral = 0;
    if (calificaciones.isNotEmpty) {
      promedioGeneral = calificaciones.map((c) => c.nota).reduce((a, b) => a + b) / calificaciones.length;
    }

    Map<String, int> conteoAsistencias = {
      'presente': 0,
      'retardo': 0,
      'ausente': 0,
      'pendiente': 0,
    };

    for (final asistencia in asistencias) {
      conteoAsistencias[asistencia.estado.name] = (conteoAsistencias[asistencia.estado.name] ?? 0) + 1;
    }

    int totalRegistros = asistencias.length;
    double porcentajeAsistenciaGeneral = totalRegistros > 0
        ? ((conteoAsistencias['presente']! + conteoAsistencias['retardo']!) / totalRegistros) * 100
        : 100;

    // Distribución de notas
    Map<String, int> distribucionNotas = {
      'excelente': 0, // 90-100
      'bueno': 0,     // 70-89
      'regular': 0,   // 50-69
      'deficiente': 0, // 0-49
    };

    for (final calif in calificaciones) {
      if (calif.nota >= 90) {
        distribucionNotas['excelente'] = distribucionNotas['excelente']! + 1;
      } else if (calif.nota >= 70) {
        distribucionNotas['bueno'] = distribucionNotas['bueno']! + 1;
      } else if (calif.nota >= 50) {
        distribucionNotas['regular'] = distribucionNotas['regular']! + 1;
      } else {
        distribucionNotas['deficiente'] = distribucionNotas['deficiente']! + 1;
      }
    }

    return {
      'totalAlumnos': alumnos.length,
      'totalCalificaciones': calificaciones.length,
      'promedioGeneral': promedioGeneral,
      'porcentajeAsistenciaGeneral': porcentajeAsistenciaGeneral,
      'conteoAsistencias': conteoAsistencias,
      'distribucionNotas': distribucionNotas,
    };
  }

  /// Sugiere acciones para alumnos en riesgo
  List<String> sugerirAcciones(Map<String, dynamic> alumnoRiesgo) {
    final sugerencias = <String>[];
    final riesgoAcademico = alumnoRiesgo['riesgoAcademico'] as bool;
    final riesgoAsistencia = alumnoRiesgo['riesgoAsistencia'] as bool;
    final promedioNotas = alumnoRiesgo['promedioNotas'] as double;
    final porcentajeAsistencia = alumnoRiesgo['porcentajeAsistencia'] as double;

    if (riesgoAcademico) {
      if (promedioNotas < 40) {
        sugerencias.add('Programar reunión urgente con apoderado');
        sugerencias.add('Derivar a orientación escolar');
      }
      sugerencias.add('Implementar plan de recuperación académica');
      sugerencias.add('Asignar tutoría entre pares');
    }

    if (riesgoAsistencia) {
      if (porcentajeAsistencia < 60) {
        sugerencias.add('Contactar inmediatamente al apoderado');
        sugerencias.add('Evaluar situación de salud o familiar');
      }
      sugerencias.add('Establecer compromiso de asistencia');
      sugerencias.add('Monitorear diariamente');
    }

    return sugerencias;
  }
}
