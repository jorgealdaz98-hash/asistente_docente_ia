import 'package:flutter/foundation.dart';
import '../models/alumno.dart';
import '../models/registro_asistencia.dart';
import '../repositories/asistencia_repository.dart';
import '../repositories/alumno_repository.dart';
import '../services/voice_service.dart';

class AsistenciaProvider extends ChangeNotifier {
  final AsistenciaRepository _asistenciaRepo = AsistenciaRepository();
  final AlumnoRepository _alumnoRepo = AlumnoRepository();
  final VoiceService voiceService = VoiceService();

  List<Alumno> _lista = [];
  int _indiceActual = 0;
  final Map<String, EstadoAsistencia> _resultados = {};
  bool _sesionIniciada = false;
  bool _escuchando = false;
  String _ultimoReconocido = '';
  DateTime? _fechaSesion;

  bool get sesionIniciada => _sesionIniciada;
  bool get escuchando => _escuchando;
  String get ultimoReconocido => _ultimoReconocido;
  int get indiceActual => _indiceActual;
  int get total => _lista.length;
  Map<String, EstadoAsistencia> get resultados => _resultados;
  DateTime? get fechaSesion => _fechaSesion;

  Alumno? get alumnoActual =>
      (_indiceActual >= 0 && _indiceActual < _lista.length) ? _lista[_indiceActual] : null;

  int get procesados => _resultados.length;

  int _contarEstado(EstadoAsistencia estado) =>
      _resultados.values.where((e) => e == estado).length;

  int get presentes => _contarEstado(EstadoAsistencia.presente);
  int get retardos => _contarEstado(EstadoAsistencia.retardo);
  int get ausentes => _contarEstado(EstadoAsistencia.ausente);

  Future<void> inicializarVoz() => voiceService.inicializar();

  void iniciarSesion(List<Alumno> alumnos, {DateTime? fecha}) {
    _lista = List.of(alumnos);
    _indiceActual = 0;
    _resultados.clear();
    _sesionIniciada = true;
    _fechaSesion = fecha ?? DateTime.now();
    notifyListeners();
  }

  /// Carga el historial de asistencia de una fecha específica
  Future<void> cargarHistorial({required String cursoId, required DateTime fecha}) async {
    final registros = await _asistenciaRepo.obtenerPorCursoYFecha(cursoId, fecha);
    _resultados.clear();
    for (var reg in registros) {
      _resultados[reg.alumnoId] = reg.estado;
    }
    _fechaSesion = fecha;
    notifyListeners();
  }

  /// Dice el nombre del alumno actual y escucha si hay respuesta.
  Future<void> pasarListaAlumnoActual({required String cursoId}) async {
    final alumno = alumnoActual;
    if (alumno == null) return;

    _escuchando = true;
    _ultimoReconocido = '';
    notifyListeners();

    await voiceService.decir(alumno.nombre);

    await voiceService.escuchar(
      duracion: const Duration(seconds: 4),
      onResultado: (texto) {
        _ultimoReconocido = texto;
      },
    );

    _escuchando = false;
    // Si detectó cualquier voz, se marca Presente automáticamente.
    // Si no detectó nada, queda pendiente para que el docente decida
    // manualmente (Retardo/Ausente) con los botones.
    if (_ultimoReconocido.trim().isNotEmpty) {
      await marcar(cursoId: cursoId, estado: EstadoAsistencia.presente, metodo: MetodoRegistro.voz);
    } else {
      notifyListeners();
    }
  }

  Future<void> marcar({
    required String cursoId,
    required EstadoAsistencia estado,
    MetodoRegistro metodo = MetodoRegistro.manual,
  }) async {
    final alumno = alumnoActual;
    if (alumno == null) return;

    // Verificar si ya existe registro para hoy
    final hoy = _fechaSesion ?? DateTime.now();
    final yaExiste = await _asistenciaRepo.existeRegistro(
      alumnoId: alumno.id,
      cursoId: cursoId,
      fecha: hoy,
    );

    if (yaExiste) {
      // Obtener el registro existente y actualizarlo
      final registros = await _asistenciaRepo.obtenerPorCursoYFecha(cursoId, hoy);
      final registroExistente = registros.firstWhere((r) => r.alumnoId == alumno.id);
      await _asistenciaRepo.actualizar(
        id: registroExistente.id,
        estado: estado,
        metodo: metodo,
      );
    } else {
      // Crear nuevo registro
      await _asistenciaRepo.registrar(
        alumnoId: alumno.id,
        cursoId: cursoId,
        estado: estado,
        metodo: metodo,
        fecha: hoy,
      );
    }
    
    await _alumnoRepo.recalcularAsistenciaHabitual(alumno.id);

    _resultados[alumno.id] = estado;
    siguiente();
  }

  void siguiente() {
    if (_indiceActual < _lista.length - 1) {
      _indiceActual++;
    }
    notifyListeners();
  }

  void anterior() {
    if (_indiceActual > 0) {
      _indiceActual--;
    }
    notifyListeners();
  }

  void finalizarSesion() {
    _sesionIniciada = false;
    voiceService.detenerVoz();
    voiceService.detenerEscucha();
    notifyListeners();
  }

  @override
  void dispose() {
    voiceService.liberar();
    super.dispose();
  }
}
