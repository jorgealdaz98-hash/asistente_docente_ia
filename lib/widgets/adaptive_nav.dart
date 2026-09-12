import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class NavItem {
  final IconData icono;
  final String etiqueta;
  const NavItem(this.icono, this.etiqueta);
}

const List<NavItem> navItems = [
  NavItem(Icons.home_rounded, 'Inicio'),
  NavItem(Icons.menu_book_rounded, 'Cursos'),
  NavItem(Icons.fact_check_rounded, 'Asistencia'),
  NavItem(Icons.star_rounded, 'Notas'),
  NavItem(Icons.settings_rounded, 'Ajustes'),
];

/// En pantallas anchas (escritorio Windows) usa un NavigationRail lateral;
/// en pantallas angostas usa una barra de navegación inferior, igual a la
/// maqueta original pensada para móvil/tablet.
class AdaptiveNav extends StatelessWidget {
  final int indiceSeleccionado;
  final ValueChanged<int> onSeleccionar;
  final Widget body;

  const AdaptiveNav({
    super.key,
    required this.indiceSeleccionado,
    required this.onSeleccionar,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final anchoEscritorio = MediaQuery.of(context).size.width >= 900;

    if (anchoEscritorio) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: indiceSeleccionado,
              onDestinationSelected: onSeleccionar,
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppColors.surface,
              destinations: navItems
                  .map((n) => NavigationRailDestination(
                        icon: Icon(n.icono),
                        label: Text(n.etiqueta),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1, color: AppColors.border),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: indiceSeleccionado,
        onDestinationSelected: onSeleccionar,
        destinations: navItems
            .map((n) => NavigationDestination(icon: Icon(n.icono), label: n.etiqueta))
            .toList(),
      ),
    );
  }
}
