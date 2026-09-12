import 'package:flutter/foundation.dart';
import '../services/license_service.dart';

class LicenseProvider extends ChangeNotifier {
  final LicenseService _service = LicenseService();

  bool cargando = true;
  bool licenciaValida = false;
  String mensaje = '';
  String hwid = '';
  DateTime? expiracion;

  Future<void> verificarAlIniciar() async {
    cargando = true;
    notifyListeners();

    hwid = await _service.obtenerHwid();
    final resultado = await _service.verificarAlIniciar();
    licenciaValida = resultado.valida;
    mensaje = resultado.mensaje;
    expiracion = resultado.expiracion;

    cargando = false;
    notifyListeners();
  }

  Future<bool> activarLicencia(String claveLicencia) async {
    final resultado = await _service.validarLicencia(claveLicencia);
    if (resultado.valida) {
      await _service.guardarLicencia(claveLicencia);
      licenciaValida = true;
      mensaje = resultado.mensaje;
      expiracion = resultado.expiracion;
      notifyListeners();
      return true;
    }
    mensaje = resultado.mensaje;
    notifyListeners();
    return false;
  }
}
