import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthDataPage extends StatefulWidget {
  final String? profileId;
  const HealthDataPage({Key? key, this.profileId}) : super(key: key);

  @override
  _HealthDataPageState createState() => _HealthDataPageState();
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

  @override
  void initState() {
    super.initState();
    if (widget.profileId != null) {
      _loadProfile(widget.profileId!);
    }
  }

  Future<void> _loadProfile(String id) async {
    final doc =
        await FirebaseFirestore.instance.collection('profiles').doc(id).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    setState(() {
      _docId = id;
      _nameCtrl.text = data['name'] ?? '';
      _ageCtrl.text = (data['age'] ?? '').toString();
      _gender = data['gender'] ?? 'Male';
      _contactCtrl.text = data['contact'] ?? '';
      _emailCtrl.text = data['email'] ?? '';
      _notesCtrl.text = data['notes'] ?? '';
      _photoUrl = data['photoUrl'];
      _bloodUrls = List<String>.from(data['bloodUrls'] ?? []);
      _urineUrls = List<String>.from(data['urineUrls'] ?? []);
      _historyUrls = List<String>.from(data['historyUrls'] ?? []);
    });
  }

  Future<void> _loadLastProfile() async {
    final snap =
        await FirebaseFirestore.instance
            .collection('profiles')
            .orderBy('updatedAt', descending: true)
            .limit(1)
            .get();
    if (snap.docs.isNotEmpty) {
      final doc = snap.docs.first;
      await _loadProfile(doc.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Loaded last submission')));
    }
  }

  Future<String> _uploadFile(File file, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id =
          _docId ?? FirebaseFirestore.instance.collection('profiles').doc().id;

      String? photoUrl;
      if (_photo != null) {
        photoUrl = await _uploadFile(_photo!, 'profiles/$id/photo_$now.jpg');
      }

      Future<List<String>> uploadList(List<File> list, String folder) async {
        return Future.wait(
          list.asMap().entries.map((e) async {
            return _uploadFile(e.value, '$folder/${id}_${e.key}_$now');
          }),
        );
      }

      final bloodUrls = await uploadList(_bloodReports, 'profiles/$id/blood');
      final urineUrls = await uploadList(_urineReports, 'profiles/$id/urine');
      final historyUrls = await uploadList(
        _historyDocs,
        'profiles/$id/history',
      );

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Profile'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Load Last Submission',
            onPressed: _isLoading ? null : _loadLastProfile,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCard(
                  title: 'guardian Information',
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField('Name', _nameCtrl),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'Age',
                                _ageCtrl,
                                number: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: _buildGenderDropdown()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          'Contact No.',
                          _contactCtrl,
                          number: true,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField('Email', _emailCtrl, email: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: 'Photo & Notes',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _notesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Medical History / Notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: GestureDetector(
                          onTap: _pickPhoto,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                _photo != null
                                    ? FileImage(_photo!)
                                    : (_photoUrl != null
                                            ? NetworkImage(_photoUrl!)
                                            : null)
                                        as ImageProvider<Object>?,
                            child:
                                _photo == null && _photoUrl == null
                                    ? const Icon(
                                      Icons.camera_alt,
                                      size: 32,
                                      color: Colors.white54,
                                    )
                                    : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: 'Lab Reports',
                  child: Column(
                    children: [
                      _buildReportUpload('Blood Test', _bloodReports),
                      const Divider(),
                      _buildReportUpload('Urine Test', _urineReports),
                      const Divider(),
                      _buildReportUpload('History Docs', _historyDocs),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(_isLoading ? 'Saving...' : 'Save Profile'),
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

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    bool number = false,
    bool email = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType:
          number
              ? TextInputType.number
              : (email ? TextInputType.emailAddress : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items:
          const [
            'Male',
            'Female',
            'Other',
          ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
      onChanged: (v) => setState(() => _gender = v!),
    );
  }

  Widget _buildReportUpload(String title, List<File> files) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _pickFileByLabel(title),
                  icon: const Icon(Icons.upload_file),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children:
                files.isNotEmpty
                    ? files
                        .map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child:
                                title == 'History Docs'
                                    ? const Icon(
                                      Icons.insert_drive_file,
                                      size: 50,
                                    )
                                    : Image.file(
                                      f,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        )
                        .toList()
                    : [
                      Text(
                        'No files uploaded',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
          ),
        ),
        const SizedBox(height: 8),
        ..._getUrlList(title).map(
          (url) => InkWell(
            onTap: () => _openUrl(url),
            child: Text(
              url,
              style: const TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getUrlList(String title) {
    switch (title) {
      case 'Blood Test':
        return _bloodUrls;
      case 'Urine Test':
        return _urineUrls;
      case 'History Docs':
        return _historyUrls;
      default:
        return [];
    }
  }

  Future<void> _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future<void> _pickPhoto() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (img != null) {
      setState(() => _photo = File(img.path));
    }
  }

  Future<void> _pickFileByLabel(String label) async {
    final res = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (res != null) {
      setState(() {
        final files = res.paths.whereType<String>().map((p) => File(p));
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
}
