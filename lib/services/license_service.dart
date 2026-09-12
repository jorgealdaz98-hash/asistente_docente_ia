import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:shared_preferences/shared_preferences.dart';

/// Resultado de validar una licencia.
class ResultadoLicencia {
  final bool valida;
  final String mensaje;
  final DateTime? expiracion;

  ResultadoLicencia({required this.valida, required this.mensaje, this.expiracion});
}

/// Sistema de licenciamiento local basado en:
///  1. Un HWID (huella del equipo) generado a partir de datos del sistema.
///  2. Una clave de licencia = AES-256("HWID|fechaExpiracionISO") en base64.
///
/// IMPORTANTE (seguridad):
/// - `_claveSecreta` debe ser la MISMA en este servicio y en el generador de
///   licencias (tools/license_generator). Cámbiala por una propia antes de
///   distribuir la app, y considera ofuscarla (no dejarla en texto plano en
///   un binario público) para producción real.
/// - Este esquema es equivalente en espíritu al que ya usas en tu app de
///   veterinaria (HWID + AES-256).
class LicenseService {
  static const String _claveSecreta = 'CAMBIA_ESTA_CLAVE_32_CARACTERES!'; // exactamente 32 chars para AES-256
  static const String _prefsLicenciaKey = 'licencia_key_guardada';

  final enc.Key _key = enc.Key.fromUtf8(_claveSecreta);
  // IV fijo y determinista (16 bytes) para que la app y el generador de
  // licencias (que corren en procesos distintos) siempre cifren/descifren
  // de forma compatible. Debe ser idéntico en tools/license_generator.
  final enc.IV _iv = enc.IV.fromUtf8('EDUAI_IV_16BYTES');

  /// Genera un identificador único y estable del equipo (HWID).
  /// Combina variables de entorno del sistema operativo que no cambian
  /// entre reinicios, y las reduce con SHA-256.
  Future<String> obtenerHwid() async {
    final datos = <String>[
      Platform.operatingSystem,
      Platform.numberOfProcessors.toString(),
      Platform.localHostname,
      Platform.environment['COMPUTERNAME'] ?? '',
      Platform.environment['USERDOMAIN'] ?? '',
      Platform.environment['PROCESSOR_IDENTIFIER'] ?? '',
      Platform.environment['USERNAME'] ?? Platform.environment['USER'] ?? '',
    ];
    final crudo = datos.join('|');
    final hash = sha256.convert(utf8.encode(crudo));
    // Se toma un HWID legible de 16 caracteres hex en mayúsculas.
    return hash.toString().substring(0, 16).toUpperCase();
  }

  String _encriptar(String texto) {
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
    return encrypter.encrypt(texto, iv: _iv).base64;
  }

  String? _desencriptar(String textoCifrado) {
    try {
      final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
      return encrypter.decrypt64(textoCifrado, iv: _iv);
    } catch (_) {
      return null;
    }
  }

  /// Usado por la herramienta generadora de licencias (o aquí mismo en modo
  /// de pruebas) para crear una clave de licencia para un HWID dado.
  String generarLicencia({required String hwid, required int diasValidez}) {
    final expiracion = DateTime.now().add(Duration(days: diasValidez));
    final payload = '$hwid|${expiracion.toIso8601String()}';
    return _encriptar(payload);
  }

  /// Valida una clave de licencia contra el HWID de este equipo.
  Future<ResultadoLicencia> validarLicencia(String claveLicencia) async {
    final payload = _desencriptar(claveLicencia.trim());
    if (payload == null || !payload.contains('|')) {
      return ResultadoLicencia(valida: false, mensaje: 'Clave de licencia inválida.');
    }

    final partes = payload.split('|');
    final hwidLicencia = partes[0];
    final fechaExpiracion = DateTime.tryParse(partes[1]);

    if (fechaExpiracion == null) {
      return ResultadoLicencia(valida: false, mensaje: 'Clave de licencia corrupta.');
    }

    final hwidActual = await obtenerHwid();
    if (hwidLicencia != hwidActual) {
      return ResultadoLicencia(
        valida: false,
        mensaje: 'Esta licencia no corresponde a este equipo.',
      );
    }

    if (DateTime.now().isAfter(fechaExpiracion)) {
      return ResultadoLicencia(
        valida: false,
        mensaje: 'La licencia expiró el ${fechaExpiracion.toLocal()}.',
        expiracion: fechaExpiracion,
      );
    }

    return ResultadoLicencia(valida: true, mensaje: 'Licencia activa.', expiracion: fechaExpiracion);
  }

  Future<void> guardarLicencia(String claveLicencia) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsLicenciaKey, claveLicencia);
  }

  Future<String?> obtenerLicenciaGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsLicenciaKey);
  }

  /// Verifica, al iniciar la app, si ya hay una licencia guardada y válida.
  Future<ResultadoLicencia> verificarAlIniciar() async {
    final guardada = await obtenerLicenciaGuardada();
    if (guardada == null) {
      return ResultadoLicencia(valida: false, mensaje: 'Sin licencia activada.');
    }
    return validarLicencia(guardada);
  }
}
