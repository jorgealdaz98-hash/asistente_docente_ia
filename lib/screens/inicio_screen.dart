import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/curso_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/ai_assistant_panel.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CursoProvider>().cargarCursos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cursoProvider = context.watch<CursoProvider>();
    final settings = context.watch<SettingsProvider>();
    final cursoActual = cursoProvider.cursoSeleccionado;
    final alumnos = cursoProvider.alumnosDelCurso;

    // Calcular métricas para contexto de IA
    Map<String, dynamic>? datosContexto;
    if (cursoActual != null) {
      datosContexto = {
        'curso': cursoActual.nombreCompleto,
        'totalAlumnos': alumnos.length,
      };
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: RefreshIndicator(
        onRefresh: () => context.read<CursoProvider>().cargarCursos(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Hola, ${settings.nombreDocente} 👋', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('${cursoProvider.cursos.length} curso(s) activos',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            MetricCard(
              icono: Icons.menu_book_rounded,
              etiquetaSuperior: 'Cursos',
              titulo: '${cursoProvider.cursos.length}',
              subtitulo: 'Cursos registrados',
              colorEtiqueta: AppColors.primary,
            ),
            const SizedBox(height: 12),
            MetricCard(
              icono: Icons.groups_rounded,
              etiquetaSuperior: 'Curso actual',
              titulo: cursoActual?.nombreCompleto ?? 'Ninguno seleccionado',
              subtitulo: '${alumnos.length} alumnos',
              colorEtiqueta: AppColors.retardo,
            ),
            const SizedBox(height: 12),
            MetricCard(
              icono: Icons.auto_awesome,
              etiquetaSuperior: 'Asistente IA',
              titulo: settings.iaConfigurada ? 'Configurado' : 'Sin configurar',
              subtitulo: settings.iaConfigurada
                  ? 'Proveedor: ${settings.proveedorIA.name}'
                  : 'Ve a Ajustes para activarlo',
              colorEtiqueta: settings.iaConfigurada ? AppColors.presente : AppColors.ausente,
            ),
            const SizedBox(height: 24),
            AiAssistantPanel(
              contexto: 'Eres un asistente pedagógico experto. Responde de forma breve, clara y accionable para un docente.',
              datosContexto: datosContexto,
            ),
          ],
        ),
      ),
    );
  }
}
