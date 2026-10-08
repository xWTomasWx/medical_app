enum AppointmentStatus { pending, accepted, cancelled }

class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final AppointmentStatus status;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    this.status = AppointmentStatus.pending,
  });

  Appointment copyWith({
    String? id,
    String? doctorName,
    String? specialty,
    DateTime? dateTime,
    AppointmentStatus? status,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
    );
  }
}
