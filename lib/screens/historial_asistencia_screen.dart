import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../models/curso.dart';
import '../models/alumno.dart';
import '../models/registro_asistencia.dart';
import '../providers/curso_provider.dart';
import '../providers/asistencia_provider.dart';
import '../repositories/asistencia_repository.dart';
import '../services/exportacion_excel_service.dart';
import '../services/reporte_pdf_service.dart';

class HistorialAsistenciaScreen extends StatefulWidget {
  const HistorialAsistenciaScreen({super.key});

  @override
  State<HistorialAsistenciaScreen> createState() => _HistorialAsistenciaScreenState();
}

class _HistorialAsistenciaScreenState extends State<HistorialAsistenciaScreen> {
  final _asistenciaRepo = AsistenciaRepository();
  final _exportacionService = ExportacionExcelService();
  final _reportePdfService = ReportePdfService();
  
  DateTime _fechaSeleccionada = DateTime.now();
  List<RegistroAsistencia> _registros = [];
  bool _cargando = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargarRegistros();
  }

  Future<void> _cargarRegistros() async {
    setState(() => _cargando = true);
    final curso = context.read<CursoProvider>().cursoSeleccionado;
    if (curso != null) {
      final registros = await _asistenciaRepo.obtenerPorCursoYFecha(curso.id, _fechaSeleccionada);
      if (mounted) {
        setState(() {
          _registros = registros;
          _cargando = false;
        });
      }
    } else {
      setState(() => _cargando = false);
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (fecha != null && fecha != _fechaSeleccionada) {
      setState(() => _fechaSeleccionada = fecha);
      await _cargarRegistros();
    }
  }

  void _exportarExcel() async {
    final curso = context.read<CursoProvider>().cursoSeleccionado;
    if (curso == null) return;

    try {
      final alumnos = context.read<CursoProvider>().alumnosDelCurso;
      final file = await _exportacionService.exportarAsistencia(
        curso: curso,
        alumnos: alumnos,
        registros: _registros,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo guardado: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    }
  }

  void _generarPDF() async {
    final curso = context.read<CursoProvider>().cursoSeleccionado;
    if (curso == null) return;

    try {
      final alumnos = context.read<CursoProvider>().alumnosDelCurso;
      final file = await _reportePdfService.generarReporteAsistencia(
        curso: curso,
        alumnos: alumnos,
        registros: _registros,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF generado: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final curso = context.watch<CursoProvider>().cursoSeleccionado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Asistencia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _seleccionarFecha,
            tooltip: 'Seleccionar fecha',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: curso == null ? null : _exportarExcel,
            tooltip: 'Exportar a Excel',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: curso == null ? null : _generarPDF,
            tooltip: 'Generar PDF',
          ),
        ],
      ),
      body: curso == null
          ? const Center(child: Text('Selecciona un curso primero.'))
          : _cargando
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _tarjetaFecha(curso),
                    Expanded(
                      child: _listaAlumnos(curso),
                    ),
                  ],
                ),
    );
  }

  Widget _tarjetaFecha(Curso curso) {
    // Inicializar formato de fecha para español
    Intl.defaultLocale = 'es_ES';
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(_fechaSeleccionada),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _seleccionarFecha,
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text('Cambiar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(curso.nombreCompleto, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: [
                _indicadorEstado('Presentes', _registros.where((r) => r.estado == EstadoAsistencia.presente).length, AppColors.presente),
                const SizedBox(width: 16),
                _indicadorEstado('Retardos', _registros.where((r) => r.estado == EstadoAsistencia.retardo).length, AppColors.retardo),
                const SizedBox(width: 16),
                _indicadorEstado('Ausentes', _registros.where((r) => r.estado == EstadoAsistencia.ausente).length, AppColors.ausente),
                const SizedBox(width: 16),
                _indicadorEstado('Pendientes', _registros.where((r) => r.estado == EstadoAsistencia.pendiente).length, AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _indicadorEstado(String label, int valor, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$valor $label', style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _listaAlumnos(Curso curso) {
    final alumnos = context.watch<CursoProvider>().alumnosDelCurso;
    
    if (alumnos.isEmpty) {
      return const Center(child: Text('No hay alumnos en este curso.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: alumnos.length,
      itemBuilder: (context, index) {
        final alumno = alumnos[index];
        final registro = _registros.firstWhere(
          (r) => r.alumnoId == alumno.id,
          orElse: () => RegistroAsistencia(
            id: '',
            alumnoId: alumno.id,
            cursoId: curso.id,
            fecha: _fechaSeleccionada,
            estado: EstadoAsistencia.pendiente,
          ),
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(alumno.nombre),
            subtitle: Text(alumno.codigo ?? ''),
            trailing: DropdownButton<EstadoAsistencia>(
              value: registro.estado,
              items: EstadoAsistencia.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(),
              onChanged: (nuevoEstado) async {
                if (nuevoEstado == null) return;
                
                // Actualizar o crear registro
                if (registro.id.isNotEmpty) {
                  await _asistenciaRepo.actualizar(
                    id: registro.id,
                    estado: nuevoEstado,
                  );
                } else {
                  await _asistenciaRepo.registrar(
                    alumnoId: alumno.id,
                    cursoId: curso.id,
                    estado: nuevoEstado,
                    fecha: _fechaSeleccionada,
                  );
                }
                
                await _cargarRegistros();
              },
            ),
          ),
        );
      },
    );
  }
}
