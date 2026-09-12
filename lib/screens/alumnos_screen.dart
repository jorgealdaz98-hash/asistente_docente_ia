import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/curso_provider.dart';

class AlumnosScreen extends StatelessWidget {
  const AlumnosScreen({super.key});

  void _abrirFormularioAlumno(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final codigoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nuevo alumno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre completo')),
            const SizedBox(height: 8),
            TextField(controller: codigoCtrl, decoration: const InputDecoration(labelText: 'Código / ID')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await context.read<CursoProvider>().crearAlumno(
                    nombre: nombreCtrl.text,
                    codigo: codigoCtrl.text,
                  );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CursoProvider>();
    final curso = provider.cursoSeleccionado;

    return Scaffold(
      appBar: AppBar(title: Text(curso?.nombreCompleto ?? 'Alumnos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioAlumno(context),
        child: const Icon(Icons.person_add),
      ),
      body: provider.alumnosDelCurso.isEmpty
          ? const Center(child: Text('Aún no hay alumnos registrados en este curso.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.alumnosDelCurso.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final alumno = provider.alumnosDelCurso[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surfaceMuted,
                      child: Text(alumno.nombre.isNotEmpty ? alumno.nombre[0] : '?'),
                    ),
                    title: Text(alumno.nombre),
                    subtitle: Text('ID: ${alumno.codigo} • Asistencia: ${alumno.asistenciaHabitual.toStringAsFixed(0)}%'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.ausente),
                      onPressed: () => context.read<CursoProvider>().eliminarAlumno(alumno.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
