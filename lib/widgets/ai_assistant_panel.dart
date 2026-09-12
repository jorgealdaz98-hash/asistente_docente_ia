import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/ai_assistant_provider.dart';
import '../providers/settings_provider.dart';

class AiAssistantPanel extends StatefulWidget {
  final String? contexto; // ej. datos del curso/alumno actual

  const AiAssistantPanel({super.key, this.contexto});

  @override
  State<AiAssistantPanel> createState() => _AiAssistantPanelState();
}

class _AiAssistantPanelState extends State<AiAssistantPanel> {
  final _controller = TextEditingController();

  static const _sugerencias = [
    ('📝', 'Generar reporte a Dirección'),
    ('📊', 'Alumnos en riesgo'),
    ('📋', 'Generar rúbrica'),
    ('✉️', 'Redactar nota familiar'),
  ];

  void _enviar(String texto) {
    final settings = context.read<SettingsProvider>();
    final assistant = context.read<AiAssistantProvider>();
    assistant.enviarConsulta(settings.crearServicioIA(), texto, contexto: widget.contexto);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final assistant = context.watch<AiAssistantProvider>();
    final settings = context.watch<SettingsProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Asistente Pedagógico IA', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        settings.iaConfigurada
                            ? 'Listo para redactar, resumir o analizar datos'
                            : 'Configura tu API key en Ajustes para activarlo',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (assistant.mensajes.isNotEmpty) ...[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: assistant.mensajes.length,
                  itemBuilder: (context, i) {
                    final m = assistant.mensajes[i];
                    return Align(
                      alignment: m.esUsuario ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          color: m.esUsuario ? AppColors.primary : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          m.texto,
                          style: TextStyle(color: m.esUsuario ? Colors.white : AppColors.textPrimary),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (assistant.enviando) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(minHeight: 3),
            ],
            if (assistant.error != null) ...[
              const SizedBox(height: 8),
              Text(assistant.error!, style: const TextStyle(color: AppColors.ausente, fontSize: 12)),
            ],
            const SizedBox(height: 12),
            const Text('SUGERENCIAS INMEDIATAS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sugerencias
                  .map((s) => ActionChip(
                        label: Text('${s.$1} ${s.$2}'),
                        backgroundColor: AppColors.surfaceMuted,
                        onPressed: () => _enviar(s.$2),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe una consulta pedagógica...',
                    ),
                    onSubmitted: _enviar,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _enviar(_controller.text),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
