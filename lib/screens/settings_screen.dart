import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Perfil del paciente
          _buildSectionHeader(
            context,
            'Perfil del Paciente',
            Icons.person_outline,
          ),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  settings.userName.isNotEmpty
                      ? settings.userName
                            .split(' ')
                            .map((e) => e.isNotEmpty ? e[0] : '')
                            .take(2)
                            .join()
                            .toUpperCase()
                      : 'P',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(
                settings.userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${settings.userEmail}\n${settings.userPhone}'),
            ),
          ),

          const SizedBox(height: 12),

          // Apariencia y Tema
          _buildSectionHeader(context, 'Apariencia', Icons.palette_outlined),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tamaño del texto',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elige el tamaño que te resulte más cómodo:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<AppTextSize>(
                    initialValue: settings.textSize,
                    decoration: const InputDecoration(
                      labelText: 'Selecciona tamaño',
                      border: OutlineInputBorder(),
                    ),
                    items: AppTextSize.values
                        .map(
                          (textSize) => DropdownMenuItem<AppTextSize>(
                            value: textSize,
                            child: Text(textSize.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        notifier.setTextSize(value);
                      }
                    },
                  ),
                  const Divider(height: 24),
                  Text(
                    'Tema de la aplicación',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona cómo deseas ver la interfaz:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text('Sistema'),
                          icon: Icon(Icons.brightness_auto),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text('Claro'),
                          icon: Icon(Icons.light_mode),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text('Oscuro'),
                          icon: Icon(Icons.dark_mode),
                        ),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        notifier.setThemeMode(newSelection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Notificaciones
          _buildSectionHeader(
            context,
            'Notificaciones',
            Icons.notifications_none_outlined,
          ),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Notificaciones push'),
                  subtitle: const Text(
                    'Recibir avisos sobre el estado de tus citas',
                  ),
                  value: settings.notificationsEnabled,
                  onChanged: (value) => notifier.toggleNotifications(value),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  secondary: const Icon(Icons.alarm_outlined),
                  title: const Text('Recordatorio de 24 horas'),
                  subtitle: const Text(
                    'Aviso previo al día de tu consulta médica',
                  ),
                  value: settings.appointmentReminders,
                  onChanged: settings.notificationsEnabled
                      ? (value) => notifier.toggleAppointmentReminders(value)
                      : null,
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_outlined),
                  title: const Text('Sonido y vibración'),
                  subtitle: const Text('Emitir alertas sonoras en avisos'),
                  value: settings.soundEnabled,
                  onChanged: settings.notificationsEnabled
                      ? (value) => notifier.toggleSound(value)
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Seguridad
          _buildSectionHeader(
            context,
            'Seguridad y Privacidad',
            Icons.security_outlined,
          ),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.fingerprint_rounded),
              title: const Text('Bloqueo biométrico'),
              subtitle: const Text(
                'Requerir huella dactilar o reconocimiento facial',
              ),
              value: settings.biometricEnabled,
              onChanged: (value) => notifier.toggleBiometric(value),
            ),
          ),

          const SizedBox(height: 12),

          // Soporte y Datos
          _buildSectionHeader(
            context,
            'Información y Soporte',
            Icons.info_outline,
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Centro de ayuda'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Centro de Ayuda'),
                        content: const Text(
                          'Para asistencia inmediata o consultas sobre citas médicas, comunícate con soporte al 0800-MEDICINA o a soporte@citasmedicas.com.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.policy_outlined),
                  title: const Text('Políticas y Privacidad'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Políticas de Privacidad'),
                        content: const Text(
                          'Tus datos médicos y personales están protegidos con cifrado de grado médico y no son compartidos con terceros sin tu consentimiento explícito.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Entendido'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(
                    Icons.restart_alt,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    'Restablecer ajustes',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  subtitle: const Text(
                    'Volver a la configuración predeterminada',
                  ),
                  onTap: () => _confirmResetSettings(context, notifier),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResetSettings(BuildContext context, SettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restablecer Configuración'),
        content: const Text(
          '¿Estás seguro de que deseas restablecer todos los ajustes a los valores por defecto?',
        ),
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
              notifier.resetSettings();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración restablecida')),
              );
            },
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }
}
