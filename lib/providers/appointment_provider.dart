import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';

final appointmentProvider = NotifierProvider<AppointmentNotifier, List<Appointment>>(() {
  return AppointmentNotifier();
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
      specialty: 'Cardiología',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      status: AppointmentStatus.accepted,
    ),
    Appointment(
      id: '2',
      doctorName: 'Dra. María Gómez',
      specialty: 'Dermatología',
      dateTime: DateTime.now().add(const Duration(days: 3, hours: 4)),
      status: AppointmentStatus.pending,
    ),
  ];

  void acceptAppointment(String id) {
    state = state.map((appointment) {
      if (appointment.id == id) {
        return appointment.copyWith(status: AppointmentStatus.accepted);
      }
      return appointment;
    }).toList();
  }

  void cancelAppointment(String id) {
    state = state.map((appointment) {
      if (appointment.id == id) {
        return appointment.copyWith(status: AppointmentStatus.cancelled);
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
