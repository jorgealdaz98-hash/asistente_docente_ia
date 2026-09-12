import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/alumno.dart';

class StudentRollCard extends StatelessWidget {
  final Alumno alumno;
  final int numeroTurno;
  final bool escuchando;
  final String ultimoReconocido;
  final VoidCallback onEscuchar;
  final VoidCallback onRepetir;

  const StudentRollCard({
    super.key,
    required this.alumno,
    required this.numeroTurno,
    required this.escuchando,
    required this.ultimoReconocido,
    required this.onEscuchar,
    required this.onRepetir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Turno actual #$numeroTurno',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  onPressed: onEscuchar,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Auto-escucha'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.surfaceMuted,
              child: Text(
                alumno.nombre.isNotEmpty ? alumno.nombre[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(alumno.nombre, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ID: ${alumno.codigo}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.presenteBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Asistencia habitual: ${alumno.asistenciaHabitual.toStringAsFixed(0)}%',
                    style: const TextStyle(color: AppColors.presente, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    escuchando ? Icons.mic : Icons.mic_none,
                    color: escuchando ? AppColors.primary : AppColors.textSecondary,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    escuchando
                        ? 'Voz IA activa: escuchando...'
                        : (ultimoReconocido.isEmpty
                            ? 'Presiona "Auto-escucha" para pasar lista'
                            : 'Se escuchó: "$ultimoReconocido"'),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRepetir,
              icon: const Icon(Icons.replay, size: 16),
              label: const Text('Repetir nombre'),
            ),
          ],
        ),
      ),
    );
  }
}
