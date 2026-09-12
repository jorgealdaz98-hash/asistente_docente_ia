import 'package:flutter/foundation.dart';
import '../models/curso.dart';
import '../models/alumno.dart';
import '../repositories/curso_repository.dart';
import '../repositories/alumno_repository.dart';

class CursoProvider extends ChangeNotifier {
  final CursoRepository _cursoRepo = CursoRepository();
  final AlumnoRepository _alumnoRepo = AlumnoRepository();

  List<Curso> _cursos = [];
  Curso? _cursoSeleccionado;
  List<Alumno> _alumnosDelCurso = [];
  bool cargando = false;

  List<Curso> get cursos => _cursos;
  Curso? get cursoSeleccionado => _cursoSeleccionado;
  List<Alumno> get alumnosDelCurso => _alumnosDelCurso;

  Future<void> cargarCursos() async {
    cargando = true;
    notifyListeners();
    _cursos = await _cursoRepo.obtenerTodos();
    if (_cursoSeleccionado == null && _cursos.isNotEmpty) {
      await seleccionarCurso(_cursos.first);
    }
    cargando = false;
    notifyListeners();
  }

  Future<void> seleccionarCurso(Curso curso) async {
    _cursoSeleccionado = curso;
    _alumnosDelCurso = await _alumnoRepo.obtenerPorCurso(curso.id);
    notifyListeners();
  }

  Future<void> crearCurso({
    required String nombre,
    required String paralelo,
    required String turno,
    required String aula,
    String unidadActual = '',
  }) async {
    final curso = await _cursoRepo.crear(
      nombre: nombre,
      paralelo: paralelo,
      turno: turno,
      aula: aula,
      unidadActual: unidadActual,
    );
    await cargarCursos();
    await seleccionarCurso(curso);
  }

  Future<void> actualizarCurso(Curso curso) async {
    await _cursoRepo.actualizar(curso);
    await cargarCursos();
  }

  Future<void> eliminarCurso(String id) async {
    await _cursoRepo.eliminar(id);
    if (_cursoSeleccionado?.id == id) {
      _cursoSeleccionado = null;
    }
    await cargarCursos();
  }

  Future<void> crearAlumno({
    required String nombre,
    required String codigo,
  }) async {
    if (_cursoSeleccionado == null) return;
    await _alumnoRepo.crear(
      cursoId: _cursoSeleccionado!.id,
      nombre: nombre,
      codigo: codigo,
    );
    _alumnosDelCurso = await _alumnoRepo.obtenerPorCurso(_cursoSeleccionado!.id);
    notifyListeners();
  }

  Future<void> eliminarAlumno(String alumnoId) async {
    await _alumnoRepo.eliminar(alumnoId);
    if (_cursoSeleccionado != null) {
      _alumnosDelCurso = await _alumnoRepo.obtenerPorCurso(_cursoSeleccionado!.id);
      notifyListeners();
    }
  }

  Future<void> recargarAlumnosActuales() async {
    if (_cursoSeleccionado != null) {
      _alumnosDelCurso = await _alumnoRepo.obtenerPorCurso(_cursoSeleccionado!.id);
      notifyListeners();
    }
  }
}
