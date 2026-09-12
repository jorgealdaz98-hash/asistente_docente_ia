import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class MetricCard extends StatelessWidget {
  final IconData icono;
  final String etiquetaSuperior;
  final Color colorEtiqueta;
  final String titulo;
  final String subtitulo;

  const MetricCard({
    super.key,
    required this.icono,
    required this.etiquetaSuperior,
    required this.titulo,
    required this.subtitulo,
    this.colorEtiqueta = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorEtiqueta.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: colorEtiqueta, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(etiquetaSuperior,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(titulo, style: Theme.of(context).textTheme.titleLarge),
                  Text(subtitulo, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
