import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Encapsula todo lo relacionado a voz: que la app "diga" el nombre
/// del alumno (TTS) y que "escuche" si hay respuesta (STT), ambos de
/// forma local usando el motor de voz del sistema operativo — sin
/// depender de internet ni de un modelo de IA pesado.
class VoiceService {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  bool _sttDisponible = false;
  bool get sttDisponible => _sttDisponible;

  Future<void> inicializar() async {
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);

    _sttDisponible = await _stt.initialize(
      onError: (error) => print('Error STT: $error'),
      onStatus: (status) => print('Estado STT: $status'),
    );
  }

  Future<void> decir(String texto) async {
    await _tts.stop();
    await _tts.speak(texto);
  }

  Future<void> detenerVoz() async {
    await _tts.stop();
  }

  /// Escucha por [duracion] segundos. Llama a [onResultado] con el texto
  /// reconocido (puede venir vacío si no detectó nada — eso el llamador
  /// lo interpreta como "sin respuesta / posible ausente").
  Future<void> escuchar({
    required void Function(String texto) onResultado,
    Duration duracion = const Duration(seconds: 4),
  }) async {
    if (!_sttDisponible) {
      onResultado('');
      return;
    }

    String ultimoTexto = '';
    await _stt.listen(
      onResult: (resultado) {
        ultimoTexto = resultado.recognizedWords;
      },
      listenFor: duracion,
      pauseFor: const Duration(seconds: 2),
      localeId: 'es_ES',
    );

    await Future.delayed(duracion);
    await _stt.stop();
    onResultado(ultimoTexto);
  }

  Future<void> detenerEscucha() async {
    if (_stt.isListening) {
      await _stt.stop();
    }
  }

  void liberar() {
    _tts.stop();
    _stt.cancel();
  }
}
