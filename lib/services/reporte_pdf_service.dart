import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/alumno.dart';
import '../models/curso.dart';
import '../models/registro_asistencia.dart';
import '../models/calificacion.dart';

/// Servicio para generar reportes en PDF
class ReportePdfService {
  /// Genera un reporte de asistencia en PDF
  Future<File> generarReporteAsistencia({
    required Curso curso,
    required List<Alumno> alumnos,
    required List<RegistroAsistencia> registros,
  }) async {
    final pdf = pw.Document();
    
    // Calcular estadísticas por alumno
    Map<String, Map<String, int>> statsPorAlumno = {};
    for (var alumno in alumnos) {
      var registrosAlumno = registros.where((r) => r.alumnoId == alumno.id).toList();
      int presentes = registrosAlumno.where((r) => r.estado == EstadoAsistencia.presente).length;
      int retardos = registrosAlumno.where((r) => r.estado == EstadoAsistencia.retardo).length;
      int ausentes = registrosAlumno.where((r) => r.estado == EstadoAsistencia.ausente).length;
      
      statsPorAlumno[alumno.id] = {
        'presentes': presentes,
        'retardos': retardos,
        'ausentes': ausentes,
      };
    }
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Reporte de Asistencia', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Curso: ${curso.nombreCompleto}', style: const pw.TextStyle(fontSize: 14)),
              pw.Text('Turno: ${curso.turno}', style: const pw.TextStyle(fontSize: 14)),
              pw.Text('Fecha de generación: ${DateTime.now().toString()}', style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Alumno', 'Código', 'Presentes', 'Retardos', 'Ausentes', '% Asistencia'],
                data: alumnos.map((alumno) {
                  var stats = statsPorAlumno[alumno.id] ?? {'presentes': 0, 'retardos': 0, 'ausentes': 0};
                  int total = stats['presentes']! + stats['retardos']! + stats['ausentes']!;
                  double porcentaje = total > 0 ? (stats['presentes']! / total) * 100 : 0;
                  
                  return [
                    alumno.nombre,
                    alumno.codigo ?? '',
                    stats['presentes'].toString(),
                    stats['retardos'].toString(),
                    stats['ausentes'].toString(),
                    '${porcentaje.toStringAsFixed(1)}%',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                  5: pw.Alignment.center,
                },
              ),
            ],
          );
        },
      ),
    );
    
    // Guardar archivo
    final directorio = await getApplicationDocumentsDirectory();
    final nombreArchivo = 'reporte_asistencia_${curso.nombre.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final ruta = '${directorio.path}/$nombreArchivo';
    final file = File(ruta);
    
    await file.writeAsBytes(await pdf.save());
    return file;
  }
  
  /// Genera un boletín de notas en PDF para un alumno específico
  Future<File> generarBoletinNotas({
    required Alumno alumno,
    required Curso curso,
    required List<Calificacion> calificaciones,
  }) async {
    final pdf = pw.Document();
    
    // Calcular promedio
    double promedio = calificaciones.isEmpty 
        ? 0 
        : calificaciones.map((c) => c.nota).reduce((a, b) => a + b) / calificaciones.length;
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Boletín de Calificaciones', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Alumno: ${alumno.nombre}', style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Código: ${alumno.codigo ?? "N/A"}', style: const pw.TextStyle(fontSize: 14)),
              pw.Text('Curso: ${curso.nombreCompleto}', style: const pw.TextStyle(fontSize: 14)),
              pw.Text('Turno: ${curso.turno}', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Promedio General:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                      promedio.toStringAsFixed(1),
                      style: pw.TextStyle(
                        fontSize: 20, 
                        fontWeight: pw.FontWeight.bold,
                        color: promedio >= 6 ? PdfColors.green : PdfColors.red,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Detalle de Calificaciones:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Actividad/Examen', 'Nota', 'Fecha'],
                data: calificaciones.map((calif) => [
                  calif.titulo,
                  calif.nota.toStringAsFixed(1),
                  '${calif.fecha.day}/${calif.fecha.month}/${calif.fecha.year}',
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                },
              ),
              pw.Spacer(),
              pw.Text(
                'Este documento es un comprobante oficial de las calificaciones del estudiante.',
                style: const pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
              ),
            ],
          );
        },
      ),
    );
    
    // Guardar archivo
    final directorio = await getApplicationDocumentsDirectory();
    final nombreArchivo = 'boletin_${alumno.nombre.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final ruta = '${directorio.path}/$nombreArchivo';
    final file = File(ruta);
    
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
