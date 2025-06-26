import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Care_Plus/widgets/profile_text_box.dart';

class ProfileEditScreen extends StatefulWidget {
  final bool isGuardian;
  const ProfileEditScreen({Key? key, this.isGuardian = false}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: "John Doe");
  final _dobController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController(text: "john.doe@example.com");
  final _phoneController = TextEditingController(text: "+60123456789");
  final _icController = TextEditingController(text: "A1234567");
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _otherInsuranceController = TextEditingController();
  final _familyDoctorController = TextEditingController(text: "Dr. Smith");
  final _emergencyContactController = TextEditingController(text: "Jane Doe (+60198765432)");
  final _medicalController = TextEditingController(text: "Diabetes, Hypertension");
  final _allergyController = TextEditingController();

  DateTime? _selectedDOB;
  String? _selectedInsurance;

  File? _avatarImageFile;
  final ImagePicker _picker = ImagePicker();

  final List<String> _insuranceOptions = ['AIA', 'Great Eastern', 'Prudential', 'Etiqa', 'AXA', 'Others'];

  bool _showEditIcon = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _icController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _otherInsuranceController.dispose();
    _familyDoctorController.dispose();
    _emergencyContactController.dispose();
    _medicalController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600, maxHeight: 600);
    if (pickedFile != null) {
      setState(() {
        _avatarImageFile = File(pickedFile.path);
      });
    }
  }

  void _pickDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDOB ?? DateTime(1950),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4CAF50),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDOB = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
        _ageController.text = _calculateAge(picked).toString();
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully"), backgroundColor: Color(0xFF4CAF50)),
      );
      Navigator.pop(context);
    }
  }

  Widget _avatarPicker() {
    return Center(
      child: MouseRegion(
        onEnter: (_) => setState(() => _showEditIcon = true),
        onExit: (_) => setState(() => _showEditIcon = false),
        child: GestureDetector(
          onTap: _pickImage,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: Colors.teal.shade100,
                backgroundImage: _avatarImageFile != null
                    ? FileImage(_avatarImageFile!)
                    : const AssetImage('assets/images/profile_avatar.png') as ImageProvider,
              ),
              AnimatedOpacity(
                opacity: _showEditIcon ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.edit, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGuardian = widget.isGuardian;

    return Scaffold(
      backgroundColor: const Color(0xFFF1FDF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text("Edit Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: _save, icon: const Icon(Icons.check))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            _avatarPicker(),
            const SizedBox(height: 24),
            _buildCard(ProfileTextBox(controller: _nameController, label: "Name", validator: (val) => val!.isEmpty ? "Required" : null)),
            _buildCard(ProfileTextBox(controller: _dobController, label: "Date of Birth", readOnly: true, onTap: _pickDOB, validator: (val) => val!.isEmpty ? "Required" : null)),
            _buildCard(ProfileTextBox(controller: _ageController, label: "Age", readOnly: true)),
            _buildCard(ProfileTextBox(controller: _emailController, label: "Email", validator: (val) => val!.contains('@') ? null : "Invalid email")),
            _buildCard(ProfileTextBox(controller: _phoneController, label: "Phone", keyboardType: TextInputType.phone, validator: (val) => val!.length < 10 ? "Invalid number" : null)),
            if (!isGuardian) _buildCard(ProfileTextBox(controller: _icController, label: "IC/Passport", readOnly: true)),
            _buildCard(
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedInsurance,
                      decoration: const InputDecoration(labelText: "Insurance Plan"),
                      items: _insuranceOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedInsurance = val;
                          if (val != 'Others') _otherInsuranceController.clear();
                        });
                      },
                      validator: (val) => val == null ? "Select insurance" : null,
                    ),
                  ),
                  if (_selectedInsurance == 'Others') const SizedBox(width: 8),
                  if (_selectedInsurance == 'Others')
                    Expanded(
                      child: ProfileTextBox(
                        controller: _otherInsuranceController,
                        label: "Specify Insurance",
                        validator: (val) => val!.isEmpty ? "Required" : null,
                      ),
                    ),
                ],
              ),
            ),
            _buildCard(ProfileTextBox(controller: _heightController, label: "Height (cm)", keyboardType: TextInputType.number, validator: (val) => double.tryParse(val!) != null ? null : "Invalid")),

            _buildCard(ProfileTextBox(controller: _weightController, label: "Weight (kg)", keyboardType: TextInputType.number, validator: (val) => double.tryParse(val!) != null ? null : "Invalid")),

            _buildCard(ProfileTextBox(controller: _familyDoctorController, label: "Family Doctor")),
            _buildCard(ProfileTextBox(controller: _emergencyContactController, label: "Emergency Contact")),
            if (!isGuardian) _buildCard(ProfileTextBox(controller: _medicalController, label: "Medical History", maxLines: 3)),
            _buildCard(ProfileTextBox(controller: _allergyController, label: "Allergy History", maxLines: 3)),

            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text("Save Changes", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
