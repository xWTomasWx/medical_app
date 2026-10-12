import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../screens/settings_screen.dart';
import '../screens/medical_history_screen.dart';

class AppDrawer extends ConsumerWidget {
  final String currentRoute;

  const AppDrawer({
    super.key,
    this.currentRoute = 'home',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // Header personalizado con información del paciente
          _buildDrawerHeader(context, settings),

          // Elementos de navegación
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: const Text('Mis Citas'),
                  selected: currentRoute == 'home',
                  selectedColor: theme.colorScheme.primary,
                  selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  onTap: () {
                    Navigator.pop(context); // Cierra el drawer
                    if (currentRoute != 'home') {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.medical_information_outlined),
                  title: const Text('Historial Clínico'),
                  selected: currentRoute == 'history',
                  selectedColor: theme.colorScheme.primary,
                  selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'history') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MedicalHistoryScreen(),
                        ),
                      );
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Configuración'),
                  selected: currentRoute == 'settings',
                  selectedColor: theme.colorScheme.primary,
                  selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'settings') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded),
                  title: const Text('Ayuda y Contacto'),
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpDialog(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
                  title: Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, SettingsState settings) {
    final theme = Theme.of(context);

    final initials = settings.userName.isNotEmpty
        ? settings.userName
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'P';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.onPrimary,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            settings.userName,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            settings.userEmail,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atención y Soporte'),
        content: const Text(
          'Línea de soporte al paciente: 0800-MEDICINA\nAtención disponible 24/7 para urgencias y consultas sobre citas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sesión cerrada correctamente')),
              );
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
