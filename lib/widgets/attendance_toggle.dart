import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/registro_asistencia.dart';

class AttendanceActionButtons extends StatelessWidget {
  final void Function(EstadoAsistencia estado) onSeleccionar;

  const AttendanceActionButtons({super.key, required this.onSeleccionar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _boton(
            label: 'Presente',
            icon: Icons.check_circle,
            color: AppColors.presente,
            onTap: () => onSeleccionar(EstadoAsistencia.presente),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _boton(
            label: 'Retardo',
            icon: Icons.access_time_filled,
            color: AppColors.retardo,
            onTap: () => onSeleccionar(EstadoAsistencia.retardo),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _boton(
            label: 'Ausente',
            icon: Icons.cancel,
            color: AppColors.ausente,
            onTap: () => onSeleccionar(EstadoAsistencia.ausente),
          ),
        ),
      ],
    );
  }

  Widget _boton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
