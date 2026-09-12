import 'package:flutter/material.dart';
import '../widgets/adaptive_nav.dart';
import 'inicio_screen.dart';
import 'cursos_screen.dart';
import 'asistencia_screen.dart';
import 'notas_screen.dart';
import 'ajustes_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _indice = 2; // abre directo en Asistencia, como la maqueta original

  static const _pantallas = [
    InicioScreen(),
    CursosScreen(),
    AsistenciaScreen(),
    NotasScreen(),
    AjustesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveNav(
      indiceSeleccionado: _indice,
      onSeleccionar: (i) => setState(() => _indice = i),
      body: IndexedStack(
        index: _indice,
        children: _pantallas,
      ),
    );
  }
}
