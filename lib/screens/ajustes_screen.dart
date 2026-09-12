import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../providers/license_provider.dart';
import '../services/ai_service.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _cargoCtrl;
  late TextEditingController _apiKeyCtrl;
  ProveedorIA _proveedor = ProveedorIA.claude;
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_iniciado) {
      final settings = context.read<SettingsProvider>();
      _nombreCtrl = TextEditingController(text: settings.nombreDocente);
      _cargoCtrl = TextEditingController(text: settings.cargoDocente);
      _apiKeyCtrl = TextEditingController(text: settings.apiKey);
      _proveedor = settings.proveedorIA;
      _iniciado = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final license = context.watch<LicenseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Perfil del docente', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                  const SizedBox(height: 8),
                  TextField(controller: _cargoCtrl, decoration: const InputDecoration(labelText: 'Cargo')),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => settings.guardarPerfil(
                        nombre: _nombreCtrl.text,
                        cargo: _cargoCtrl.text,
                      ),
                      child: const Text('Guardar perfil'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Asistente Pedagógico IA', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Proveedor', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SegmentedButton<ProveedorIA>(
                    segments: const [
                      ButtonSegment(value: ProveedorIA.claude, label: Text('Claude')),
                      ButtonSegment(value: ProveedorIA.openai, label: Text('OpenAI')),
                      ButtonSegment(value: ProveedorIA.gemini, label: Text('Gemini')),
                    ],
                    selected: {_proveedor},
                    onSelectionChanged: (s) => setState(() => _proveedor = s.first),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _apiKeyCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'API key'),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tu API key se guarda solo en este equipo y se usa únicamente para '
                    'llamar al proveedor de IA elegido.',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => settings.guardarConfigIA(
                        proveedor: _proveedor,
                        apiKey: _apiKeyCtrl.text.trim(),
                      ),
                      child: const Text('Guardar configuración de IA'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Licencia', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        license.licenciaValida ? Icons.verified_rounded : Icons.error_outline_rounded,
                        color: license.licenciaValida ? AppColors.presente : AppColors.ausente,
                      ),
                      const SizedBox(width: 8),
                      Text(license.licenciaValida ? 'Licencia activa' : 'Licencia inválida',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('HWID de este equipo: ${license.hwid}',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                  if (license.expiracion != null)
                    Text('Vigente hasta: ${license.expiracion!.toLocal()}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
