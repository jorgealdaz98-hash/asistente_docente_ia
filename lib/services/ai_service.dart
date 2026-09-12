import 'dart:convert';
import 'package:http/http.dart' as http;

enum ProveedorIA { claude, openai, gemini }

/// Contrato común para cualquier proveedor de IA usado por el
/// Asistente Pedagógico. Así puedes cambiar de proveedor sin tocar
/// las pantallas ni el resto de la lógica de la app.
abstract class AiService {
  Future<String> consultar(String prompt, {String? contexto});
}

class AiException implements Exception {
  final String mensaje;
  AiException(this.mensaje);
  @override
  String toString() => mensaje;
}

/// --- Claude (Anthropic) ---
class ClaudeAiService implements AiService {
  final String apiKey;
  final String modelo;
  // Revisa docs.claude.com/en/docs/about-claude/models si quieres usar
  // otro modelo (por ejemplo uno más económico como Haiku).
  ClaudeAiService({required this.apiKey, this.modelo = 'claude-sonnet-5'});

  @override
  Future<String> consultar(String prompt, {String? contexto}) async {
    final uri = Uri.parse('https://api.anthropic.com/v1/messages');
    final mensajeCompleto = contexto == null ? prompt : '$contexto\n\n$prompt';

    final respuesta = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': modelo,
        'max_tokens': 1024,
        'messages': [
          {'role': 'user', 'content': mensajeCompleto},
        ],
      }),
    );

    if (respuesta.statusCode != 200) {
      throw AiException('Error Claude (${respuesta.statusCode}): ${respuesta.body}');
    }

    final data = jsonDecode(utf8.decode(respuesta.bodyBytes));
    final contenido = data['content'] as List<dynamic>;
    final texto = contenido
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String)
        .join('\n');
    return texto.trim();
  }
}

/// --- OpenAI (GPT) ---
class OpenAiService implements AiService {
  final String apiKey;
  final String modelo;
  OpenAiService({required this.apiKey, this.modelo = 'gpt-4o-mini'});

  @override
  Future<String> consultar(String prompt, {String? contexto}) async {
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final mensajes = <Map<String, String>>[];
    if (contexto != null) {
      mensajes.add({'role': 'system', 'content': contexto});
    }
    mensajes.add({'role': 'user', 'content': prompt});

    final respuesta = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': modelo,
        'messages': mensajes,
      }),
    );

    if (respuesta.statusCode != 200) {
      throw AiException('Error OpenAI (${respuesta.statusCode}): ${respuesta.body}');
    }

    final data = jsonDecode(utf8.decode(respuesta.bodyBytes));
    return (data['choices'][0]['message']['content'] as String).trim();
  }
}

/// --- Google Gemini ---
class GeminiAiService implements AiService {
  final String apiKey;
  final String modelo;
  GeminiAiService({required this.apiKey, this.modelo = 'gemini-2.0-flash'});

  @override
  Future<String> consultar(String prompt, {String? contexto}) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$modelo:generateContent?key=$apiKey',
    );
    final mensajeCompleto = contexto == null ? prompt : '$contexto\n\n$prompt';

    final respuesta = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': mensajeCompleto},
            ],
          },
        ],
      }),
    );

    if (respuesta.statusCode != 200) {
      throw AiException('Error Gemini (${respuesta.statusCode}): ${respuesta.body}');
    }

    final data = jsonDecode(utf8.decode(respuesta.bodyBytes));
    final texto = data['candidates'][0]['content']['parts'][0]['text'] as String;
    return texto.trim();
  }
}

/// Fábrica: construye el servicio de IA correcto según lo configurado
/// por el docente en Ajustes.
class AiServiceFactory {
  static AiService crear({
    required ProveedorIA proveedor,
    required String apiKey,
    String? modelo,
  }) {
    switch (proveedor) {
      case ProveedorIA.claude:
        return ClaudeAiService(apiKey: apiKey, modelo: modelo ?? 'claude-sonnet-5');
      case ProveedorIA.openai:
        return OpenAiService(apiKey: apiKey, modelo: modelo ?? 'gpt-4o-mini');
      case ProveedorIA.gemini:
        return GeminiAiService(apiKey: apiKey, modelo: modelo ?? 'gemini-2.0-flash');
    }
  }
}
