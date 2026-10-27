import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/appointment_provider.dart';
import '../models/appointment.dart';
import 'notification_action_screen.dart';
import 'tutorial_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bar_logo_title.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentProvider);
    final pendingAppointments = appointments
        .where((a) => a.status == AppointmentStatus.pending)
        .toList();

    return Scaffold(
      drawer: const AppDrawer(currentRoute: 'home'),
      appBar: AppBar(
        title: const AppBarLogoTitle('Mis Citas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_add),
            tooltip: 'Simular notificación entrante',
            onPressed: () {
              // Simular apertura directa de la cita pendiente
              final targetId = pendingAppointments.isNotEmpty
                  ? pendingAppointments.first.id
                  : '2';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      NotificationActionScreen(appointmentId: targetId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.event_busy_outlined),
            tooltip: 'Simular aviso de profesional no disponible',
            onPressed: () {
              _simulateProfessionalUnavailable(context, ref, appointments);
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const TutorialScreen()),
            );
          },
          icon: const Icon(Icons.play_circle_outline),
          label: const Text('Ver tutorial para confirmar citas'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildRescheduleOption(context),
          if (appointments.isEmpty)
            _buildEmptyState(context)
          else ...[
            if (pendingAppointments.isNotEmpty)
              _buildPendingNoticeBanner(context, pendingAppointments.length),
            ...appointments.map(
              (appointment) => _AppointmentCard(appointment: appointment),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRescheduleOption(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.event_repeat,
          color: theme.colorScheme.primary,
          size: 30,
        ),
        title: const Text('Agendar'),
        subtitle: const Text('Agenda en el sitio de Telesalud'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showRescheduleDialog(context),
      ),
    );
  }

  void _simulateProfessionalUnavailable(
    BuildContext context,
    WidgetRef ref,
    List<Appointment> appointments,
  ) {
    final appointment = appointments.cast<Appointment?>().firstWhere(
      (item) => item?.status == AppointmentStatus.accepted,
      orElse: () => appointments.cast<Appointment?>().firstWhere(
        (item) => item?.status == AppointmentStatus.pending,
        orElse: () => null,
      ),
    );

    if (appointment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay citas activas para simular el aviso.'),
        ),
      );
      return;
    }

    ref
        .read(appointmentProvider.notifier)
        .cancelAppointment(
          appointment.id,
          'Cancelada por el profesional debido a un inconveniente de horario.',
        );
    _showRescheduleDialog(
      context,
      title: 'Cambio en tu cita',
      message:
          'El profesional ${appointment.doctorName} no estará disponible a la hora de tu cita. Para elegir otro horario, visita el sitio de Telesalud.',
    );
  }

  Widget _buildPendingNoticeBanner(BuildContext context, int count) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notification_important,
            color: Colors.orange.shade800,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count == 1
                      ? '1 Turno pendiente de confirmación'
                      : '$count Turnos pendientes de confirmación',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Por favor confirma tu asistencia o libera el turno para que otro paciente pueda utilizarlo.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes citas asignadas.',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando el centro médico programe tus turnos desde el sistema, recibirás una notificación para confirmar tu asistencia.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCancelledByProfessional =
        appointment.status == AppointmentStatus.cancelled &&
        (appointment.cancellationReason?.startsWith(
              'Cancelada por el profesional',
            ) ??
            false);

    Color statusColor;
    IconData statusIcon;

    switch (appointment.status) {
      case AppointmentStatus.accepted:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case AppointmentStatus.cancelled:
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.cancel;
        break;
      case AppointmentStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time_filled;
        break;
    }

    return Card(
      elevation: 0.5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      NotificationActionScreen(appointmentId: appointment.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila superior: Doctor (Destacado) + Ícono de estado
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.doctorName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isCancelledByProfessional
                                  ? 'Cancelada por el profesional'
                                  : _statusLabel(appointment.status),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(statusIcon, color: statusColor, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Barra inferior de Fecha y Hora
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 15,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat(
                                'dd MMM yyyy',
                                'es_ES',
                              ).format(appointment.dateTime),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 15,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat(
                                'hh:mm a',
                                'es_ES',
                              ).format(appointment.dateTime),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCancelledByProfessional) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                appointment.cancellationReason!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: OutlinedButton.icon(
                onPressed: () => _showRescheduleDialog(
                  context,
                  title: 'Agendar nuevamente',
                  message:
                      'Contacta con ${appointment.facility} para elegir un nuevo horario.',
                ),
                icon: const Icon(Icons.event_repeat),
                label: const Text('Agendar nuevamente'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.accepted:
        return 'Confirmada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
      case AppointmentStatus.pending:
        return 'Pendiente de confirmación';
    }
  }
}

void _showRescheduleDialog(
  BuildContext context, {
  String title = 'Agendar cita',
  String? message,
}) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (message != null) ...[Text(message), const SizedBox(height: 16)],
          const Text(
            'Si necesitas agendar una cita, visita el sitio de Telesalud.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final launched = await launchUrl(
                Uri.parse('https://telesalud.gob.cl/'),
                mode: LaunchMode.externalApplication,
              );
              if (!launched && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo abrir el sitio de Telesalud.'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Visitar Telesalud'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}
