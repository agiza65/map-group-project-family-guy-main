import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/appointment_model.dart';
import '../services/appointment_repository.dart';

class AppointmentViewModel extends ChangeNotifier {
  final AppointmentRepository _repo = AppointmentRepository();
  final FlutterLocalNotificationsPlugin _notifier;

  List<Appointment> appointments = [];
  bool isLoading = false;

  AppointmentViewModel(this._notifier) {
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    isLoading = true;
    notifyListeners();

    appointments = await _repo.fetchAll();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addAppointment(Appointment appt) async {
    await _repo.add(appt);

    // 1) Immediate notification
    await _notifier.show(
      appt.hashCode,
      'Appointment Created',
      'Scheduled ${appt.patientName} at ${_formatDateTime(appt.dateTime)}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'appt_channel',
          'Appointment Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );

    // 2) Scheduled notification
    final tzDate = tz.TZDateTime.from(appt.dateTime, tz.local);
    await _notifier.zonedSchedule(
      appt.hashCode,
      'Appointment Reminder',
      'It is now time for ${appt.patientName}\'s appointment',
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'appt_channel',
          'Appointment Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    await loadAppointments();
  }

  Future<void> updateAppointment(Appointment appt) async {
    await _repo.update(appt);
    await loadAppointments();
  }

  Future<void> deleteAppointment(String id) async {
    await _repo.delete(id);
    await loadAppointments();
  }

  String _formatDateTime(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}';
  }
}
