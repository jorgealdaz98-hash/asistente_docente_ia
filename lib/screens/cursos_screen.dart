import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/curso.dart';
import '../providers/curso_provider.dart';
import '../services/excel_service.dart';
import 'alumnos_screen.dart';

class CursosScreen extends StatefulWidget {
  const CursosScreen({super.key});

  @override
  State<CursosScreen> createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  final _excelService = ExcelService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CursoProvider>().cargarCursos();
    });
  }

  void _mostrarMenuExcel() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Importar desde Excel'),
        content: const Text('Selecciona una opción:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Descargar plantilla'),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _descargarPlantilla();
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload),
            label: const Text('Importar cursos y alumnos'),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _importarDesdeExcel();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _descargarPlantilla() async {
    final ruta = await _excelService.generarPlantilla();
    if (!mounted) return;
    
    if (ruta != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plantilla guardada en: $ruta'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Abrir carpeta',
            onPressed: () {
              // En Windows esto abriría el explorador
              // Por ahora solo mostramos la ruta
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al generar la plantilla')),
      );
    }
  }

  Future<void> _importarDesdeExcel() async {
    final ruta = await _excelService.seleccionarArchivo();
    if (!mounted) return;

    if (ruta == null) return;

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final resultado = await _excelService.importarCursosYAlumnos(ruta);
    
    if (!mounted) return;
    Navigator.pop(context); // Cerrar loading

    // Recargar cursos
    await context.read<CursoProvider>().cargarCursos();

    // Mostrar resultados
    if (resultado.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${resultado['error']}')),
      );
    } else {
      final creados = resultado['creados'] as int;
      final omitidos = resultado['omitidos'] as int;
      final advertencias = resultado['advertencias'] as List<String>;

      String mensaje = '✓ Importación completada\n';
      mensaje += '• Elementos creados: $creados\n';
      mensaje += '• Elementos omitidos (duplicados): $omitidos';
      
      if (advertencias.isNotEmpty) {
        mensaje += '\n\n⚠️ Advertencias:\n${advertencias.take(5).join('\n')}';
        if (advertencias.length > 5) {
          mensaje += '\n...y ${advertencias.length - 5} más';
        }
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Resumen de importación'),
          content: SingleChildScrollView(
            child: SelectableText(mensaje),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
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
      appBar: AppBar(
        title: const Text('Cursos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Importar desde Excel',
            onPressed: _mostrarMenuExcel,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_cursos_nuevo',
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
