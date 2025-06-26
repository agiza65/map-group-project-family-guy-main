import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../viewmodels/appointment_viewmodel.dart';
import '../../models/appointment_model.dart';

class AppointmentEditPage extends StatefulWidget {
  final Appointment? appt;
  const AppointmentEditPage({this.appt, super.key});

  @override
  State<AppointmentEditPage> createState() => _AppointmentEditPageState();
}

class _AppointmentEditPageState extends State<AppointmentEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  DateTime? _picked;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.appt?.patientName);
    _picked = widget.appt?.dateTime;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppointmentViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.appt == null ? 'Add Appointment' : 'Edit Appointment',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Patient Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _picked == null
                      ? 'Select Date & Time'
                      : DateFormat('yyyy-MM-dd HH:mm').format(_picked!),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _picked ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date == null) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(
                      _picked ?? DateTime.now(),
                    ),
                  );
                  if (time == null) return;
                  setState(() {
                    _picked = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate() || _picked == null) {
                    return;
                  }
                  final appt = Appointment(
                    id: widget.appt?.id,
                    patientName: _nameCtrl.text,
                    dateTime: _picked!,
                    note: '',
                  );
                  if (widget.appt == null) {
                    await vm.addAppointment(appt);
                  } else {
                    await vm.updateAppointment(appt);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.appt == null
                            ? 'Added successfully'
                            : 'Updated successfully',
                      ),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
