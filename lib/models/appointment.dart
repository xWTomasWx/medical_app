enum AppointmentStatus { pending, accepted, cancelled }

class Appointment {
  final String id;
  final String doctorName; // Profesional
  final String specialty; // Prestacion
  final DateTime dateTime; // Fecha + Hora
  final AppointmentStatus status;
  final String location; // Consultorio específico o sala
  final String facility; // Establecimiento (Cesfam, Cecosf, Centro)
  final String appointmentType; // Tipo (Consulta, Examen, Control, Ingreso, etc.)
  final String? rut; // RUT del paciente
  final String? patientName; // Nombre
  final String? patientPhone; // Teléfono
  final String? patientEmail; // Email
  final String? indications; // Indicaciones del Excel
  final String? note; // Nota (ej: N. Ficha)
  final List<String> preparations; // Lista parseada o formateada
  final String? cancellationReason;
  final DateTime? confirmedAt;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    this.status = AppointmentStatus.pending,
    this.location = 'Sector de Atención',
    this.facility = 'Cesfam Colón',
    this.appointmentType = 'Control',
    this.rut,
    this.patientName,
    this.patientPhone,
    this.patientEmail,
    this.indications,
    this.note,
    this.preparations = const [],
    this.cancellationReason,
    this.confirmedAt,
  });

  Appointment copyWith({
    String? id,
    String? doctorName,
    String? specialty,
    DateTime? dateTime,
    AppointmentStatus? status,
    String? location,
    String? facility,
    String? appointmentType,
    String? rut,
    String? patientName,
    String? patientPhone,
    String? patientEmail,
    String? indications,
    String? note,
    List<String>? preparations,
    String? cancellationReason,
    DateTime? confirmedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      location: location ?? this.location,
      facility: facility ?? this.facility,
      appointmentType: appointmentType ?? this.appointmentType,
      rut: rut ?? this.rut,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      patientEmail: patientEmail ?? this.patientEmail,
      indications: indications ?? this.indications,
      note: note ?? this.note,
      preparations: preparations ?? this.preparations,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      confirmedAt: confirmedAt ?? this.confirmedAt,
    );
  }
}
