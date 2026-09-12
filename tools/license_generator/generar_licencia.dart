// Herramienta de línea de comandos para GENERAR licencias.
// Esto es lo que tú (el desarrollador/administrador) usas — NO se distribuye
// dentro de la app final que reciben los docentes.
//
// USO:
//   dart run generar_licencia.dart <HWID> <dias_validez>
//
// Ejemplo:
//   dart run generar_licencia.dart A1B2C3D4E5F6A7B8 365
//
// El HWID se lo pide el docente a su app en la pantalla de activación
// (se muestra ahí mismo) y te lo envía (por correo, WhatsApp, etc.).
//
// IMPORTANTE: la constante _claveSecreta y el IV deben ser IDÉNTICOS
// a los de lib/services/license_service.dart. Si cambias uno, cambia el otro.

import 'package:encrypt/encrypt.dart' as enc;

const String _claveSecreta = 'CAMBIA_ESTA_CLAVE_32_CARACTERES!'; // debe medir 32 caracteres
final enc.Key _key = enc.Key.fromUtf8(_claveSecreta);
final enc.IV _iv = enc.IV.fromUtf8('EDUAI_IV_16BYTES'); // debe medir 16 caracteres, igual que en la app

String generarLicencia({required String hwid, required int diasValidez}) {
  final expiracion = DateTime.now().add(Duration(days: diasValidez));
  final payload = '$hwid|${expiracion.toIso8601String()}';
  final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
  return encrypter.encrypt(payload, iv: _iv).base64;
}

void main(List<String> args) {
  if (args.length < 2) {
    // ignore: avoid_print
    print('Uso: dart run generar_licencia.dart <HWID> <dias_validez>');
    return;
  }

  final hwid = args[0].trim().toUpperCase();
  final dias = int.tryParse(args[1]) ?? 365;

  final licencia = generarLicencia(hwid: hwid, diasValidez: dias);

  // ignore: avoid_print
  print('--------------------------------------------------');
  // ignore: avoid_print
  print('HWID:            $hwid');
  // ignore: avoid_print
  print('Válida por:      $dias día(s)');
  // ignore: avoid_print
  print('Clave de licencia (envíasela al docente):');
  // ignore: avoid_print
  print(licencia);
  // ignore: avoid_print
  print('--------------------------------------------------');
}
