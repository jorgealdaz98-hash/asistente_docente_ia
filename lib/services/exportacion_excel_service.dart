import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../models/alumno.dart';
import '../models/curso.dart';
import '../models/registro_asistencia.dart';
import '../models/calificacion.dart';

/// Servicio para exportar datos de asistencia y notas a Excel
class ExportacionExcelService {
  /// Exporta el historial de asistencia de un curso a Excel
  Future<File> exportarAsistencia({
    required Curso curso,
    required List<Alumno> alumnos,
    required List<RegistroAsistencia> registros,
  }) async {
    var excel = Excel.createExcel();
    var sheet = excel['Asistencia'];
    
    // Encabezados
    sheet.appendRow([
      TextCellValue('Curso'),
      TextCellValue(curso.nombreCompleto),
    ]);
    sheet.appendRow([
      TextCellValue('Turno'),
      TextCellValue(curso.turno),
    ]);
    sheet.appendRow([
      TextCellValue('Fecha de exportación'),
      TextCellValue(DateTime.now().toString()),
    ]);
    sheet.appendRow([]);
    
    // Encabezados de la tabla
    sheet.appendRow([
      TextCellValue('Alumno', style: CellStyle(bold: true)),
      TextCellValue('Código', style: CellStyle(bold: true)),
      TextCellValue('Total Presentes', style: CellStyle(bold: true)),
      TextCellValue('Total Retardos', style: CellStyle(bold: true)),
      TextCellValue('Total Ausentes', style: CellStyle(bold: true)),
      TextCellValue('% Asistencia', style: CellStyle(bold: true)),
    ]);
    
    // Calcular estadísticas por alumno
    for (var alumno in alumnos) {
      var registrosAlumno = registros.where((r) => r.alumnoId == alumno.id).toList();
      int presentes = registrosAlumno.where((r) => r.estado == EstadoAsistencia.presente).length;
      int retardos = registrosAlumno.where((r) => r.estado == EstadoAsistencia.retardo).length;
      int ausentes = registrosAlumno.where((r) => r.estado == EstadoAsistencia.ausente).length;
      int total = presentes + retardos + ausentes;
      double porcentaje = total > 0 ? (presentes / total) * 100 : 0;
      
      sheet.appendRow([
        TextCellValue(alumno.nombre),
        TextCellValue(alumno.codigo ?? ''),
        IntCellValue(presentes),
        IntCellValue(retardos),
        IntCellValue(ausentes),
        DoubleCellValue(porcentaje, decimalDigits: 1),
      ]);
    }
    
    // Guardar archivo
    final directorio = await getApplicationDocumentsDirectory();
    final nombreArchivo = 'asistencia_${curso.nombre.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final ruta = '${directorio.path}/$nombreArchivo';
    final file = File(ruta);
    
    await file.writeAsBytes(excel.encode()!);
    return file;
  }
  
  /// Exporta las calificaciones de un curso a Excel
  Future<File> exportarNotas({
    required Curso curso,
    required List<Alumno> alumnos,
    required List<Calificacion> calificaciones,
  }) async {
    var excel = Excel.createExcel();
    var sheet = excel['Notas'];
    
    // Encabezados
    sheet.appendRow([
      TextCellValue('Curso'),
      TextCellValue(curso.nombreCompleto),
    ]);
    sheet.appendRow([
      TextCellValue('Fecha de exportación'),
      TextCellValue(DateTime.now().toString()),
    ]);
    sheet.appendRow([]);
    
    // Encabezados de la tabla
    sheet.appendRow([
      TextCellValue('Alumno', style: CellStyle(bold: true)),
      TextCellValue('Código', style: CellStyle(bold: true)),
      TextCellValue('Actividad/Examen', style: CellStyle(bold: true)),
      TextCellValue('Nota', style: CellStyle(bold: true)),
      TextCellValue('Fecha', style: CellStyle(bold: true)),
    ]);
    
    // Agrupar calificaciones por alumno
    Map<String, List<Calificacion>> porAlumno = {};
    for (var calif in calificaciones) {
      porAlumno.putIfAbsent(calif.alumnoId, () => []).add(calif);
    }
    
    // Escribir datos
    for (var alumno in alumnos) {
      var califsAlumno = porAlumno[alumno.id] ?? [];
      if (califsAlumno.isEmpty) {
        sheet.appendRow([
          TextCellValue(alumno.nombre),
          TextCellValue(alumno.codigo ?? ''),
          TextCellValue('Sin calificaciones'),
          TextCellValue(''),
          TextCellValue(''),
        ]);
      } else {
        bool primerFila = true;
        for (var calif in califsAlumno) {
          sheet.appendRow([
            TextCellValue(primerFila ? alumno.nombre : ''),
            TextCellValue(primerFila ? (alumno.codigo ?? '') : ''),
            TextCellValue(calif.titulo),
            DoubleCellValue(calif.nota, decimalDigits: 1),
            TextCellValue('${calif.fecha.day}/${calif.fecha.month}/${calif.fecha.year}'),
          ]);
          primerFila = false;
        }
      }
    }
    
    // Guardar archivo
    final directorio = await getApplicationDocumentsDirectory();
    final nombreArchivo = 'notas_${curso.nombre.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final ruta = '${directorio.path}/$nombreArchivo';
    final file = File(ruta);
    
    await file.writeAsBytes(excel.encode()!);
    return file;
  }
}
