import 'package:flutter/foundation.dart';
import '../services/ai_service.dart';

class MensajeChat {
  final String texto;
  final bool esUsuario;
  MensajeChat({required this.texto, required this.esUsuario});
}

class AiAssistantProvider extends ChangeNotifier {
  final List<MensajeChat> mensajes = [];
  bool enviando = false;
  String? error;

  void limpiar() {
    mensajes.clear();
    error = null;
    notifyListeners();
  }

  Future<void> enviarConsulta(
    AiService? servicio,
    String prompt, {
    String? contexto,
  }) async {
    if (prompt.trim().isEmpty) return;

    mensajes.add(MensajeChat(texto: prompt, esUsuario: true));
    error = null;
    notifyListeners();

    if (servicio == null) {
      error = 'Configura tu API key del proveedor de IA en Ajustes para usar el asistente.';
      notifyListeners();
      return;
    }

    enviando = true;
    notifyListeners();

    try {
      final respuesta = await servicio.consultar(prompt, contexto: contexto);
      mensajes.add(MensajeChat(texto: respuesta, esUsuario: false));
    } catch (e) {
      error = 'No se pudo contactar al asistente: $e';
    } finally {
      enviando = false;
      notifyListeners();
    }
  }
}
