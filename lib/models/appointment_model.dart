class Appointment {
  String? id;
  String patientName;
  DateTime dateTime;
  String note;

  Appointment({
    this.id,
    required this.patientName,
    required this.dateTime,
    required this.note,
  });

  Map<String, dynamic> toMap() => {
        'patientName': patientName,
        'dateTime': dateTime.toIso8601String(),
        'note': note,
      };

  factory Appointment.fromMap(String id, Map<String, dynamic> m) =>
      Appointment(
        id: id,
        patientName: m['patientName'],
        dateTime: DateTime.parse(m['dateTime']),
        note: m['note'],
      );
}
