import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/curso.dart';
import '../providers/curso_provider.dart';
import '../providers/asistencia_provider.dart';
import '../widgets/student_roll_card.dart';
import '../widgets/attendance_toggle.dart';
import '../widgets/ai_assistant_panel.dart';
import 'historial_asistencia_screen.dart';

class AsistenciaScreen extends StatefulWidget {
  const AsistenciaScreen({super.key});

  @override
  State<AsistenciaScreen> createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cursoProvider = context.read<CursoProvider>();
      if (cursoProvider.cursos.isEmpty) {
        await cursoProvider.cargarCursos();
      }
      if (mounted) {
        await context.read<AsistenciaProvider>().inicializarVoz();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cursoProvider = context.watch<CursoProvider>();
    final asistencia = context.watch<AsistenciaProvider>();
    final curso = cursoProvider.cursoSeleccionado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistorialAsistenciaScreen()),
              );
            },
            tooltip: 'Ver historial',
          ),
          if (cursoProvider.cursos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: DropdownButton<Curso>(
                value: curso,
                underline: const SizedBox.shrink(),
                items: cursoProvider.cursos
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.nombreCompleto)))
                    .toList(),
                onChanged: (c) {
                  if (c != null) cursoProvider.seleccionarCurso(c);
                },
              ),
            ),
        ],
      ),
      body: curso == null
          ? const Center(child: Text('Crea un curso primero en la pestaña "Cursos".'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _tarjetaSesion(curso, cursoProvider.alumnosDelCurso.length),
                const SizedBox(height: 16),
                if (!asistencia.sesionIniciada)
                  ElevatedButton.icon(
                    onPressed: cursoProvider.alumnosDelCurso.isEmpty
                        ? null
                        : () => asistencia.iniciarSesion(cursoProvider.alumnosDelCurso),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Iniciar pase de lista'),
                  )
                else ...[
                  _barraProgreso(asistencia),
                  const SizedBox(height: 16),
                  if (asistencia.alumnoActual != null) ...[
                    StudentRollCard(
                      alumno: asistencia.alumnoActual!,
                      numeroTurno: asistencia.indiceActual + 1,
                      escuchando: asistencia.escuchando,
                      ultimoReconocido: asistencia.ultimoReconocido,
                      onEscuchar: () => asistencia.pasarListaAlumnoActual(cursoId: curso.id),
                      onRepetir: () => asistencia.voiceService.decir(asistencia.alumnoActual!.nombre),
                    ),
                    const SizedBox(height: 16),
                    AttendanceActionButtons(
                      onSeleccionar: (estado) => asistencia.marcar(cursoId: curso.id, estado: estado),
                    ),
                  ] else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.celebration_rounded, color: AppColors.presente, size: 40),
                            const SizedBox(height: 8),
                            const Text('¡Pase de lista completado!', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () => asistencia.finalizarSesion(),
                              child: const Text('Cerrar sesión de asistencia'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 20),
                AiAssistantPanel(
                  contexto: 'Eres un asistente pedagógico para el curso ${curso.nombreCompleto}. '
                      'Responde de forma breve, clara y accionable para un docente.',
                ),
              ],
            ),
    );
  }

  Widget _tarjetaSesion(Curso curso, int totalAlumnos) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.presente, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                const Text('SESIÓN EN CURSO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            Text(curso.nombreCompleto, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${curso.turno} • ${curso.unidadActual}', style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.meeting_room_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Aula ${curso.aula}', style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(width: 16),
                const Icon(Icons.groups_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('$totalAlumnos alumnos', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _barraProgreso(AsistenciaProvider asistencia) {
    final progreso = asistencia.total == 0 ? 0.0 : asistencia.procesados / asistencia.total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pase de Lista Inteligente', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${asistencia.procesados} de ${asistencia.total} procesados'),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: progreso, minHeight: 8),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _puntoContador('Presentes', asistencia.presentes, AppColors.presente),
                const SizedBox(width: 16),
                _puntoContador('Retardos', asistencia.retardos, AppColors.retardo),
                const SizedBox(width: 16),
                _puntoContador('Ausentes', asistencia.ausentes, AppColors.ausente),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _puntoContador(String label, int valor, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$valor $label', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
