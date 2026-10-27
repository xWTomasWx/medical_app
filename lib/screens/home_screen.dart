import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/appointment_provider.dart';
import '../models/appointment.dart';
import 'notification_action_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bar_logo_title.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentProvider);
    final pendingAppointments = appointments.where((a) => a.status == AppointmentStatus.pending).toList();

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
              final targetId = pendingAppointments.isNotEmpty ? pendingAppointments.first.id : '2';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationActionScreen(appointmentId: targetId),
                ),
              );
            },
          )
        ],
      ),
      body: appointments.isEmpty
          ? _buildEmptyState(context)
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (pendingAppointments.isNotEmpty)
                  _buildPendingNoticeBanner(context, pendingAppointments.length),
                ...appointments.map((appointment) => _AppointmentCard(appointment: appointment)),
              ],
            ),
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
          Icon(Icons.notification_important, color: Colors.orange.shade800, size: 26),
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
            Icon(Icons.event_busy, size: 80, color: theme.colorScheme.surfaceContainerHighest),
            const SizedBox(height: 16),
            Text('No tienes citas asignadas.', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Cuando el centro médico programe tus turnos desde el sistema, recibirás una notificación para confirmar tu asistencia.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotificationActionScreen(appointmentId: appointment.id),
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
                    child: Icon(Icons.person, color: theme.colorScheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      appointment.doctorName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 15, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM yyyy', 'es_ES').format(appointment.dateTime),
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 15, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('hh:mm a', 'es_ES').format(appointment.dateTime),
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
    );
  }
}
