import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/curso.dart';
import '../providers/curso_provider.dart';
import 'alumnos_screen.dart';

class CursosScreen extends StatefulWidget {
  const CursosScreen({super.key});

  @override
  State<CursosScreen> createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CursoProvider>().cargarCursos();
    });
  }

  void _abrirFormulario({Curso? curso}) {
    final nombreCtrl = TextEditingController(text: curso?.nombre ?? '');
    final paraleloCtrl = TextEditingController(text: curso?.paralelo ?? '');
    final turnoCtrl = TextEditingController(text: curso?.turno ?? 'Matutino');
    final aulaCtrl = TextEditingController(text: curso?.aula ?? '');
    final unidadCtrl = TextEditingController(text: curso?.unidadActual ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(curso == null ? 'Nuevo curso' : 'Editar curso'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Materia')),
              const SizedBox(height: 8),
              TextField(controller: paraleloCtrl, decoration: const InputDecoration(labelText: 'Paralelo (ej. 3° B)')),
              const SizedBox(height: 8),
              TextField(controller: turnoCtrl, decoration: const InputDecoration(labelText: 'Turno')),
              const SizedBox(height: 8),
              TextField(controller: aulaCtrl, decoration: const InputDecoration(labelText: 'Aula')),
              const SizedBox(height: 8),
              TextField(controller: unidadCtrl, decoration: const InputDecoration(labelText: 'Unidad actual')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<CursoProvider>();
              if (curso == null) {
                await provider.crearCurso(
                  nombre: nombreCtrl.text,
                  paralelo: paraleloCtrl.text,
                  turno: turnoCtrl.text,
                  aula: aulaCtrl.text,
                  unidadActual: unidadCtrl.text,
                );
              } else {
                await provider.actualizarCurso(curso.copyWith(
                  nombre: nombreCtrl.text,
                  paralelo: paraleloCtrl.text,
                  turno: turnoCtrl.text,
                  aula: aulaCtrl.text,
                  unidadActual: unidadCtrl.text,
                ));
              }
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

    return Scaffold(
      appBar: AppBar(title: const Text('Cursos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: provider.cargando
          ? const Center(child: CircularProgressIndicator())
          : provider.cursos.isEmpty
              ? const Center(child: Text('No hay cursos aún. Toca + para crear uno.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.cursos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final curso = provider.cursos[i];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.surfaceMuted,
                          child: Icon(Icons.menu_book_rounded, color: AppColors.primary),
                        ),
                        title: Text(curso.nombreCompleto),
                        subtitle: Text('${curso.turno} • Aula ${curso.aula}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'editar') _abrirFormulario(curso: curso);
                            if (value == 'eliminar') {
                              context.read<CursoProvider>().eliminarCurso(curso.id);
                            }
                            if (value == 'alumnos') {
                              context.read<CursoProvider>().seleccionarCurso(curso);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AlumnosScreen()),
                              );
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'alumnos', child: Text('Ver alumnos')),
                            PopupMenuItem(value: 'editar', child: Text('Editar')),
                            PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                          ],
                        ),
                        onTap: () {
                          context.read<CursoProvider>().seleccionarCurso(curso);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AlumnosScreen()),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
