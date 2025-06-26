import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/report_upload.dart';

class HealthDataPage extends StatefulWidget {
  const HealthDataPage({Key? key}) : super(key: key);

  @override
  State<HealthDataPage> createState() => _HealthDataPageState();
}

class _HealthDataPageState extends State<HealthDataPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _gender = 'Male';
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  File? _photo;
  String? _photoUrl;
  List<File> _bloodReports = [];
  List<File> _urineReports = [];
  List<File> _historyDocs = [];
  List<String> _bloodUrls = [];
  List<String> _urineUrls = [];
  List<String> _historyUrls = [];

  bool _isLoading = false;
  String? _docId;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = _docId ?? FirebaseFirestore.instance.collection('profiles').doc().id;

      Future<String> upload(File file, String path) async {
        final ref = FirebaseStorage.instance.ref().child(path);
        await ref.putFile(file);
        return ref.getDownloadURL();
      }

      Future<List<String>> uploadList(List<File> files, String folder) async {
        return Future.wait(files.asMap().entries.map(
          (entry) => upload(entry.value, '$folder/${entry.key}_$now'),
        ));
      }

      String? photoUrl;
      if (_photo != null) {
        photoUrl = await upload(_photo!, 'profiles/$id/photo_$now.jpg');
      }

      final bloodUrls = await uploadList(_bloodReports, 'profiles/$id/blood');
      final urineUrls = await uploadList(_urineReports, 'profiles/$id/urine');
      final historyUrls = await uploadList(_historyDocs, 'profiles/$id/history');

      await FirebaseFirestore.instance.collection('profiles').doc(id).set({
        'name': _nameCtrl.text.trim(),
        'age': int.tryParse(_ageCtrl.text) ?? 0,
        'gender': _gender,
        'contact': _contactCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
        'photoUrl': photoUrl,
        'bloodUrls': bloodUrls,
        'urineUrls': urineUrls,
        'historyUrls': historyUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _docId = id;
        _photoUrl = photoUrl;
        _bloodUrls = bloodUrls;
        _urineUrls = urineUrls;
        _historyUrls = historyUrls;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) {
      setState(() => _photo = File(picked.path));
    }
  }

  Future<void> _pickFileByLabel(String label) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      final files = result.paths.map((p) => File(p!)).toList();
      setState(() {
        switch (label) {
          case 'Blood Test':
            _bloodReports.addAll(files);
            break;
          case 'Urine Test':
            _urineReports.addAll(files);
            break;
          case 'History Docs':
            _historyDocs.addAll(files);
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField('Name', _nameCtrl),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildField('Age', _ageCtrl, isNumber: true)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildGenderDropdown()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildField('Contact No.', _contactCtrl),
                      const SizedBox(height: 12),
                      _buildField('Email', _emailCtrl, isEmail: true),
                      const SizedBox(height: 12),
                      _buildField('Notes', _notesCtrl, isMulti: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickPhoto,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _photo != null
                        ? FileImage(_photo!)
                        : (_photoUrl != null ? NetworkImage(_photoUrl!) : null)
                            as ImageProvider?,
                    child: _photo == null && _photoUrl == null
                        ? const Icon(Icons.camera_alt, color: Colors.white70, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                // ReportUpload Sections
                ReportUpload(
                  title: 'Blood Test',
                  files: _bloodReports,
                  urls: _bloodUrls,
                  onUploadTap: () => _pickFileByLabel('Blood Test'),
                  onCameraTap: () {}, // implement if needed
                ),
                const Divider(),
                ReportUpload(
                  title: 'Urine Test',
                  files: _urineReports,
                  urls: _urineUrls,
                  onUploadTap: () => _pickFileByLabel('Urine Test'),
                  onCameraTap: () {},
                ),
                const Divider(),
                ReportUpload(
                  title: 'History Docs',
                  files: _historyDocs,
                  urls: _historyUrls,
                  onUploadTap: () => _pickFileByLabel('History Docs'),
                  onCameraTap: () {},
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black45,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {bool isNumber = false, bool isEmail = false, bool isMulti = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber
          ? TextInputType.number
          : isEmail
              ? TextInputType.emailAddress
              : TextInputType.text,
      maxLines: isMulti ? 3 : 1,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      items: const ['Male', 'Female', 'Other']
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (val) => setState(() => _gender = val!),
      decoration: InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
