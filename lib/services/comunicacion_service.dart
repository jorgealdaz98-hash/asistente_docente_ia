import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../models/tarea.dart';

class ComunicacionService {
  /// Envía mensaje WhatsApp a padre/tutor
  Future<bool> enviarWhatsApp({
    required String telefono,
    required String mensaje,
  }) async {
    try {
      // Limpiar teléfono (quitar espacios, guiones, paréntesis)
      final telefonoLimpio = telefono.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Codificar mensaje para URL
      final mensajeCodificado = Uri.encodeComponent(mensaje);
      
      final url = Uri.parse('https://wa.me/$telefonoLimpio?text=$mensajeCodificado');
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print('Error al enviar WhatsApp: $e');
      return false;
    }
  }

  /// Envía SMS (funciona en móviles)
  Future<bool> enviarSMS({
    required String telefono,
    required String mensaje,
  }) async {
    try {
      final url = Uri.parse('sms:$telefono?body=${Uri.encodeComponent(mensaje)}');
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print('Error al enviar SMS: $e');
      return false;
    }
  }

  /// Envía email
  Future<bool> enviarEmail({
    required String email,
    required String asunto,
    required String cuerpo,
  }) async {
    try {
      final url = Uri.parse(
        'mailto:$email?subject=${Uri.encodeComponent(asunto)}&body=${Uri.encodeComponent(cuerpo)}'
      );
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print('Error al enviar email: $e');
      return false;
    }
  }

  /// Genera mensaje automático de ausencia
  String generarMensajeAusencia({
    required String alumnoNombre,
    required String cursoNombre,
    required DateTime fecha,
  }) {
    final fechaStr = _formatDate(fecha);
    return '''
Estimado apoderado:

Le informamos que su pupilo $alumnoNombre del curso $cursoNombre registró inasistencia el día $fechaStr.

Si tiene alguna justificación, puede presentarla en la secretaría del establecimiento.

Atentamente,
La Dirección
''';
  }

  /// Genera mensaje de boletín semanal
  String generarBoletinSemanal({
    required String alumnoNombre,
    required double promedioNotas,
    required double porcentajeAsistencia,
    required String observaciones,
  }) {
    return '''
BOLETÍN SEMANAL - $alumnoNombre

📊 Rendimiento Académico:
Promedio de notas: $promedioNotas/100

📅 Asistencia:
Porcentaje: ${porcentajeAsistencia.toStringAsFixed(1)}%

📝 Observaciones:
$observaciones

---
Este es un reporte automático generado por el sistema de gestión docente.
''';
  }

  String _formatDate(DateTime date) {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}
