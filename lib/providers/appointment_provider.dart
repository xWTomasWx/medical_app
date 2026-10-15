import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';

final appointmentProvider = NotifierProvider<AppointmentNotifier, List<Appointment>>(() {
  return AppointmentNotifier();
});

DateTime _getCleanDate({required int daysOffset, required int hour, required int minute}) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + daysOffset, hour, minute);
}

final pastAppointmentsProvider = Provider<List<Appointment>>((ref) {
  return [
    Appointment(
      id: 'past-1',
      doctorName: 'Dr. Roberto Sánchez',
      specialty: 'Médico General',
      appointmentType: 'Control',
      facility: 'Cesfam Colón',
      location: 'Sector Azul',
      dateTime: _getCleanDate(daysOffset: -14, hour: 9, minute: 30),
      status: AppointmentStatus.accepted,
      note: 'N. Ficha 11111',
      indications: 'Presentar exámenes anteriores si posee.',
    ),
    Appointment(
      id: 'past-2',
      doctorName: 'Dra. María Gómez',
      specialty: 'Nutricionista',
      appointmentType: 'Consulta',
      facility: 'Cesfam Colón',
      location: 'Sector Verde',
      dateTime: _getCleanDate(daysOffset: -35, hour: 11, minute: 0),
      status: AppointmentStatus.accepted,
      note: 'N. Ficha 11111',
      indications: 'Traer registro de comidas.',
    ),
    Appointment(
      id: 'past-3',
      doctorName: 'Dr. Alejandro Morales',
      specialty: 'Kinesiólogo(a)',
      appointmentType: 'Sesión',
      facility: 'Cesfam Colón',
      location: 'Sector Amarillo',
      dateTime: _getCleanDate(daysOffset: -72, hour: 15, minute: 30),
      status: AppointmentStatus.accepted,
      note: 'N. Ficha 11111',
      indications: 'Asistir con ropa cómoda.',
    ),
  ];
});

class AppointmentNotifier extends Notifier<List<Appointment>> {
  @override
  List<Appointment> build() {
    return _mockAppointments;
  }

  static final List<Appointment> _mockAppointments = [
    Appointment(
      id: '1',
      doctorName: 'Dr. Roberto Sánchez',
      specialty: 'Médico General',
      appointmentType: 'Control',
      facility: 'Cesfam Colón',
      location: 'Sector Azul',
      dateTime: _getCleanDate(daysOffset: 1, hour: 10, minute: 30),
      status: AppointmentStatus.accepted,
      confirmedAt: DateTime.now().subtract(const Duration(hours: 3)),
      rut: '12.345.678-9',
      patientName: 'Juan P. G.',
      patientPhone: '+56 9 1234 5678',
      note: 'N. Ficha 11111',
      indications: 'Presentarse 15 minutos antes.',
    ),
    Appointment(
      id: '2',
      doctorName: 'Dra. María Gómez',
      specialty: 'Nutricionista',
      appointmentType: 'Consulta',
      facility: 'Cesfam Colón',
      location: 'Sector Verde',
      dateTime: _getCleanDate(daysOffset: 3, hour: 14, minute: 0),
      status: AppointmentStatus.pending,
      rut: '12.345.678-9',
      patientName: 'Juan P. G.',
      patientPhone: '+56 9 1234 5678',
      note: 'N. Ficha 11111',
      indications: 'Presentarse 15 minutos antes.',
    ),
    Appointment(
      id: '3',
      doctorName: 'Dr. Muñoz',
      specialty: 'Asistente social',
      appointmentType: 'Ingreso',
      facility: 'Cesfam Colón',
      location: 'Sector Rojo',
      dateTime: _getCleanDate(daysOffset: 5, hour: 11, minute: 30),
      status: AppointmentStatus.pending,
      rut: '12.345.678-9',
      patientName: 'Juan P. G.',
      patientPhone: '+56 9 1234 5678',
      note: 'N. Ficha 11111',
      indications: 'Presentarse 15 minutos antes.',
    ),
  ];

  void acceptAppointment(String id) {
    state = state.map((appointment) {
      if (appointment.id == id) {
        return appointment.copyWith(
          status: AppointmentStatus.accepted,
          confirmedAt: DateTime.now(),
          cancellationReason: null,
        );
      }
      return appointment;
    }).toList();
  }

  void cancelAppointment(String id, [String? reason]) {
    state = state.map((appointment) {
      if (appointment.id == id) {
        return appointment.copyWith(
          status: AppointmentStatus.cancelled,
          cancellationReason: reason ?? 'Inasistencia notificada por el paciente',
        );
      }
      return appointment;
    }).toList();
  }

  Appointment? getAppointmentById(String id) {
    try {
      return state.firstWhere((appointment) => appointment.id == id);
    } catch (e) {
      return null;
    }
  }
}
