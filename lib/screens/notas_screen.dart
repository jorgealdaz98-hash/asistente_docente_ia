import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/calificacion.dart';
import '../providers/curso_provider.dart';
import '../repositories/calificacion_repository.dart';

class NotasScreen extends StatefulWidget {
  const NotasScreen({super.key});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  final _repo = CalificacionRepository();
  List<Calificacion> _calificaciones = [];
  double _promedio = 0;
  bool _cargando = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargar();
  }

  Future<void> _cargar() async {
    final curso = context.read<CursoProvider>().cursoSeleccionado;
    if (curso == null) {
      setState(() => _cargando = false);
      return;
    }
    final lista = await _repo.obtenerPorCurso(curso.id);
    final promedio = await _repo.promedioCurso(curso.id);
    if (mounted) {
      setState(() {
        _calificaciones = lista;
        _promedio = promedio;
        _cargando = false;
      });
    }
  }

  void _abrirFormulario() {
    final cursoProvider = context.read<CursoProvider>();
    final curso = cursoProvider.cursoSeleccionado;
    final alumnos = cursoProvider.alumnosDelCurso;
    if (curso == null || alumnos.isEmpty) return;

    var alumnoSeleccionado = alumnos.first;
    final tituloCtrl = TextEditingController();
    final notaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Nueva calificación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                value: alumnoSeleccionado,
                items: alumnos.map((a) => DropdownMenuItem(value: a, child: Text(a.nombre))).toList(),
                onChanged: (v) => setStateDialog(() => alumnoSeleccionado = v!),
                decoration: const InputDecoration(labelText: 'Alumno'),
              ),
              const SizedBox(height: 8),
              TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Actividad / examen')),
              const SizedBox(height: 8),
              TextField(
                controller: notaCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Nota (0-10)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final nota = double.tryParse(notaCtrl.text.replaceAll(',', '.')) ?? 0;
                await _repo.crear(
                  alumnoId: alumnoSeleccionado.id,
                  cursoId: curso.id,
                  titulo: tituloCtrl.text,
                  nota: nota,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                _cargar();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final curso = context.watch<CursoProvider>().cursoSeleccionado;

    return Scaffold(
      appBar: AppBar(title: const Text('Notas')),
      floatingActionButton: FloatingActionButton(
        onPressed: curso == null ? null : _abrirFormulario,
        child: const Icon(Icons.add),
      ),
      body: curso == null
          ? const Center(child: Text('Selecciona un curso primero.'))
          : _cargando
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Promedio de ${curso.nombreCompleto}',
                                style: Theme.of(context).textTheme.titleMedium),
                            Text(
                              _promedio.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_calificaciones.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: Text('No hay calificaciones registradas aún.')),
                      )
                    else
                      ..._calificaciones.map((c) => Card(
                            child: ListTile(
                              title: Text(c.titulo),
                              subtitle: Text('${c.fecha.day}/${c.fecha.month}/${c.fecha.year}'),
                              trailing: Text(
                                c.nota.toStringAsFixed(1),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          )),
                  ],
                ),
    );
  }
}
