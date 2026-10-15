import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/appointment_provider.dart';
import '../models/appointment.dart';
import '../widgets/decline_reason_dialog.dart';

class NotificationActionScreen extends ConsumerWidget {
  final String appointmentId;

  const NotificationActionScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentProvider);
    final appointment = appointments.cast<Appointment?>().firstWhere(
          (a) => a?.id == appointmentId,
          orElse: () => null,
        );

    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Cita')),
        body: const Center(child: Text('Cita no encontrada o expirada.')),
      );
    }

    final theme = Theme.of(context);
    final isPending = appointment.status == AppointmentStatus.pending;
    final isAccepted = appointment.status == AppointmentStatus.accepted;
    final isCancelled = appointment.status == AppointmentStatus.cancelled;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Confirmar Turno'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header de estado
              _buildStatusHeader(context, appointment),
              const SizedBox(height: 20),

              // Tarjeta de detalles del turno
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        context,
                        icon: Icons.local_hospital_outlined,
                        label: 'Establecimiento',
                        value: appointment.facility,
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        context,
                        icon: Icons.category_outlined,
                        label: 'Tipo de atención',
                        value: '${appointment.appointmentType} • ${appointment.specialty}',
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        context,
                        icon: Icons.person_outline,
                        label: 'Profesional',
                        value: appointment.doctorName,
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        context,
                        icon: Icons.calendar_today_outlined,
                        label: 'Fecha',
                        value: DateFormat('EEEE, dd MMMM yyyy', 'es_ES').format(appointment.dateTime),
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        context,
                        icon: Icons.access_time_outlined,
                        label: 'Hora',
                        value: DateFormat('hh:mm a', 'es_ES').format(appointment.dateTime),
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        context,
                        icon: Icons.location_on_outlined,
                        label: 'Sector de atención',
                        value: appointment.location,
                      ),
                      if (appointment.note != null && appointment.note!.isNotEmpty) ...[
                        const Divider(height: 20),
                        _buildDetailRow(
                          context,
                          icon: Icons.badge_outlined,
                          label: 'Ficha Clínica / Registro',
                          value: appointment.note!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sección de Indicaciones (si vienen en el Excel)
              if (appointment.indications != null && appointment.indications!.isNotEmpty) ...[
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notes_rounded, size: 20, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Indicaciones',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            appointment.indications!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Si fue cancelada, mostrar el motivo registrado
              if (isCancelled && appointment.cancellationReason != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cancel_outlined, size: 20, color: theme.colorScheme.error),
                          const SizedBox(width: 8),
                          Text(
                            'Inasistencia notificada',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Motivo: ${appointment.cancellationReason}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tu aviso oportuno permitió que el centro médico libere este horario para otro paciente en lista de espera.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Botones de acción según el estado
              if (isPending) ...[
                FilledButton.icon(
                  onPressed: () {
                    ref.read(appointmentProvider.notifier).acceptAppointment(appointmentId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ ¡Asistencia confirmada! El centro médico ha sido notificado.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 24),
                  label: const Text(
                    'Confirmar Asistencia',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final reason = await DeclineReasonDialog.show(
                      context,
                      doctorName: appointment.doctorName,
                      specialty: appointment.specialty,
                    );
                    if (reason != null && context.mounted) {
                      ref.read(appointmentProvider.notifier).cancelAppointment(appointmentId, reason);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Turno liberado. Gracias por avisar oportunamente.'),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.event_busy, size: 24),
                  label: const Text(
                    'No podré asistir (Liberar turno)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ] else if (isAccepted) ...[
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Cita con ${appointment.doctorName} añadida al calendario de tu dispositivo.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.calendar_month, size: 24),
                  label: const Text(
                    'Añadir a mi Calendario',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () async {
                    final reason = await DeclineReasonDialog.show(
                      context,
                      doctorName: appointment.doctorName,
                      specialty: appointment.specialty,
                    );
                    if (reason != null && context.mounted) {
                      ref.read(appointmentProvider.notifier).cancelAppointment(appointmentId, reason);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Inasistencia registrada. El turno ha sido liberado.'),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                  icon: const Icon(Icons.close),
                  label: const Text('¿Cambio de planes? Avisar inasistencia'),
                ),
              ] else if (isCancelled) ...[
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(appointmentProvider.notifier).acceptAppointment(appointmentId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Turno recuperado y asistencia confirmada!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.restore, color: Colors.green),
                  label: const Text(
                    'Cambié de opinión: Sí podré asistir',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, Appointment appointment) {
    final theme = Theme.of(context);
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                child: Icon(Icons.priority_high),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirmación Requerida',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Por favor confirma tu presencia para asegurar el turno.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case AppointmentStatus.accepted:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                child: Icon(Icons.check),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Asistencia Confirmada',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'El centro médico te espera en la fecha indicada.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case AppointmentStatus.cancelled:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                child: const Icon(Icons.close),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Turno Cancelado / Liberado',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Has indicado que no asistirás a esta cita médica.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
