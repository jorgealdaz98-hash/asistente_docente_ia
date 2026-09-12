import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/database/database_helper.dart';
import 'core/theme/app_theme.dart';
import 'providers/curso_provider.dart';
import 'providers/asistencia_provider.dart';
import 'providers/ai_assistant_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/license_provider.dart';
import 'screens/license_activation_screen.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper.initFfi(); // Necesario para Windows/Linux/macOS (sqflite_common_ffi)
  runApp(const AsistenteDocenteApp());
}

class AsistenteDocenteApp extends StatelessWidget {
  const AsistenteDocenteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CursoProvider()),
        ChangeNotifierProvider(create: (_) => AsistenciaProvider()),
        ChangeNotifierProvider(create: (_) => AiAssistantProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..cargar()),
        ChangeNotifierProvider(create: (_) => LicenseProvider()..verificarAlIniciar()),
      ],
      child: MaterialApp(
        title: 'EDUAI Docente - Asistente Docente IA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _ArranqueApp(),
      ),
    );
  }
}

/// Decide si mostrar la pantalla de activación de licencia o la app
/// principal, según el estado de LicenseProvider.
class _ArranqueApp extends StatelessWidget {
  const _ArranqueApp();

  @override
  Widget build(BuildContext context) {
    return Consumer<LicenseProvider>(
      builder: (context, license, _) {
        if (license.cargando) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!license.licenciaValida) {
          return const LicenseActivationScreen();
        }
        return const MainShell();
      },
    );
  }
}
