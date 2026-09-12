import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';

/// Guarda la configuración del docente y del proveedor de IA elegido
/// en Ajustes. La API key se guarda con shared_preferences; si más
/// adelante quieres mayor seguridad, se puede migrar a flutter_secure_storage
/// sin cambiar el resto de la app (mismo contrato de SettingsProvider).
class SettingsProvider extends ChangeNotifier {
  static const _kNombreDocente = 'nombre_docente';
  static const _kCargoDocente = 'cargo_docente';
  static const _kProveedorIA = 'proveedor_ia';
  static const _kApiKey = 'api_key_ia';
  static const _kModeloIA = 'modelo_ia';

  String nombreDocente = 'Prof. Sofia Mendoza';
  String cargoDocente = 'Docente';
  ProveedorIA proveedorIA = ProveedorIA.claude;
  String apiKey = '';
  String? modeloIA;

  bool _cargado = false;
  bool get cargado => _cargado;

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    nombreDocente = prefs.getString(_kNombreDocente) ?? nombreDocente;
    cargoDocente = prefs.getString(_kCargoDocente) ?? cargoDocente;
    apiKey = prefs.getString(_kApiKey) ?? '';
    modeloIA = prefs.getString(_kModeloIA);

    final proveedorGuardado = prefs.getString(_kProveedorIA);
    if (proveedorGuardado != null) {
      proveedorIA = ProveedorIA.values.firstWhere(
        (p) => p.name == proveedorGuardado,
        orElse: () => ProveedorIA.claude,
      );
    }
    _cargado = true;
    notifyListeners();
  }

  Future<void> guardarPerfil({required String nombre, required String cargo}) async {
    nombreDocente = nombre;
    cargoDocente = cargo;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNombreDocente, nombre);
    await prefs.setString(_kCargoDocente, cargo);
    notifyListeners();
  }

  Future<void> guardarConfigIA({
    required ProveedorIA proveedor,
    required String apiKey,
    String? modelo,
  }) async {
    proveedorIA = proveedor;
    this.apiKey = apiKey;
    modeloIA = modelo;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProveedorIA, proveedor.name);
    await prefs.setString(_kApiKey, apiKey);
    if (modelo != null) await prefs.setString(_kModeloIA, modelo);
    notifyListeners();
  }

  bool get iaConfigurada => apiKey.trim().isNotEmpty;

  AiService? crearServicioIA() {
    if (!iaConfigurada) return null;
    return AiServiceFactory.crear(proveedor: proveedorIA, apiKey: apiKey, modelo: modeloIA);
  }
}
