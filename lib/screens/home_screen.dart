import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/appointment_provider.dart';
import '../models/appointment.dart';
import 'notification_action_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_add),
            tooltip: 'Simular notificación entrante',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationActionScreen(appointmentId: '2'),
                ),
              );
            },
          )
        ],
      ),
      body: appointments.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                return _AppointmentCard(appointment: appointments[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 100, color: theme.colorScheme.surfaceContainerHighest),
          const SizedBox(height: 16),
          Text('No tienes citas próximas.', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Cuando solicites una cita aparecerá aquí.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
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
    String statusText;
    IconData statusIcon;

    switch (appointment.status) {
      case AppointmentStatus.accepted:
        statusColor = Colors.green;
        statusText = 'Aceptada';
        statusIcon = Icons.check_circle;
        break;
      case AppointmentStatus.cancelled:
        statusColor = theme.colorScheme.error;
        statusText = 'Cancelada';
        statusIcon = Icons.cancel;
        break;
      case AppointmentStatus.pending:
      default:
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        statusIcon = Icons.access_time_filled;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  radius: 24,
                  child: Icon(Icons.medical_services, color: theme.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.doctorName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(appointment.specialty, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: theme.textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: theme.colorScheme.secondary),
                    const SizedBox(width: 8),
                    Text(DateFormat('dd MMM yyyy', 'es_ES').format(appointment.dateTime), style: theme.textTheme.bodyMedium),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: theme.colorScheme.secondary),
                    const SizedBox(width: 8),
                    Text(DateFormat('hh:mm a', 'es_ES').format(appointment.dateTime), style: theme.textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
