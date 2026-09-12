import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/license_provider.dart';
import 'main_shell.dart';

class LicenseActivationScreen extends StatefulWidget {
  const LicenseActivationScreen({super.key});

  @override
  State<LicenseActivationScreen> createState() => _LicenseActivationScreenState();
}

class _LicenseActivationScreenState extends State<LicenseActivationScreen> {
  final _controller = TextEditingController();
  bool _validando = false;
  String? _errorLocal;

  Future<void> _activar() async {
    setState(() {
      _validando = true;
      _errorLocal = null;
    });

    final licenseProvider = context.read<LicenseProvider>();
    final ok = await licenseProvider.activarLicencia(_controller.text.trim());

    setState(() => _validando = false);

    if (ok && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      setState(() => _errorLocal = licenseProvider.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    final licenseProvider = context.watch<LicenseProvider>();

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 20),
                Text('Activar EDUAI Docente', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                const Text(
                  'Ingresa tu clave de licencia para activar la aplicación en este equipo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ID de este equipo (HWID)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        SelectableText(
                          licenseProvider.hwid.isEmpty ? 'Generando...' : licenseProvider.hwid,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 16, letterSpacing: 1),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Envía este código a soporte para que te generen la clave de licencia.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Pega aquí tu clave de licencia'),
                ),
                if (_errorLocal != null) ...[
                  const SizedBox(height: 8),
                  Text(_errorLocal!, style: const TextStyle(color: AppColors.ausente)),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _validando ? null : _activar,
                  child: _validando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Activar licencia'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
