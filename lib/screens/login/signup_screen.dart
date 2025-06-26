import 'package:flutter/material.dart';
import 'package:Care_Plus/services/auth_service.dart';
import 'package:Care_Plus/utils/validators.dart';
import 'package:Care_Plus/utils/dialog_util.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final contactNumberController = TextEditingController();
  final existingConditionsController = TextEditingController();
  final allergiesController = TextEditingController();
  final medicationsController = TextEditingController();
  final seniorIdController = TextEditingController();
  final customRelationshipController = TextEditingController();

  String? selectedRole;
  String? selectedRelationship;
  String? selectedCondition;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final roles = ['Senior', 'Guardian'];
  final relationships = ['Spouse', 'Child', 'Sibling', 'Friend', 'Caregiver', 'Other'];
  final conditions = ['Diabetes', 'Hypertension', 'Arthritis', 'Heart Disease', 'Dementia', 'Parkinson\'s', 'Stroke', 'Asthma', 'Osteoporosis', 'Cancer', 'Other'];

  Future<void> handleSignUp() async {
    if (!_formKey.currentState!.validate() || selectedRole == null) {
      showInfoDialog(context, "Error", "Please fill all required fields.");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showInfoDialog(context, "Error", "Passwords do not match.");
      return;
    }

    setState(() => _isLoading = true);

    final error = await AuthService.signUp(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      role: selectedRole!,
      contactNumber: contactNumberController.text.trim(),
      seniorId: seniorIdController.text.trim(),
      relationship: selectedRelationship,
      customRelationship: customRelationshipController.text.trim(),
      condition: selectedCondition,
      customCondition: existingConditionsController.text.trim(),
      allergies: allergiesController.text.trim(),
      medications: medicationsController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      showInfoDialog(context, "Success", "Registration successful. Please login.");
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      showInfoDialog(context, "Error", error);
    }
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width < 400 ? 16 : 18;

    InputDecoration _decoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        labelStyle: TextStyle(fontSize: fontSize),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      );
    }

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text("CARE PLUS REGISTER", style: TextStyle(fontSize: fontSize + 4)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r, style: TextStyle(fontSize: fontSize)))).toList(),
                onChanged: (v) => setState(() => selectedRole = v),
                decoration: _decoration("Select Role", Icons.person),
                validator: (v) => v == null ? 'Please select a role' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: nameController,
                decoration: _decoration("Full Name", Icons.person_outline),
                validator: (v) => validateNotEmpty(v, 'Enter your name'),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration("Email", Icons.email_outlined),
                validator: (v) => isValidEmail(v ?? '') ? null : 'Invalid email',
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: _decoration("Password", Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: validatePassword,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: _decoration("Confirm Password", Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                validator: (v) => validateConfirmPassword(v, passwordController.text),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: contactNumberController,
                keyboardType: TextInputType.phone,
                decoration: _decoration("Contact Number", Icons.phone),
                validator: validatePhone,
              ),

              if (selectedRole == 'Guardian') ...[
                const SizedBox(height: 15),
                TextFormField(
                  controller: seniorIdController,
                  decoration: _decoration("Senior ID", Icons.qr_code),
                  validator: (v) => validateNotEmpty(v, 'Enter Senior ID'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedRelationship,
                  items: relationships.map((r) => DropdownMenuItem(value: r, child: Text(r, style: TextStyle(fontSize: fontSize)))).toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedRelationship = v;
                      if (v != 'Other') customRelationshipController.clear();
                    });
                  },
                  decoration: _decoration("Relationship", Icons.group),
                  validator: (v) => v == null ? 'Select relationship' : null,
                ),
                if (selectedRelationship == "Other")
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      controller: customRelationshipController,
                      decoration: _decoration("Custom Relationship", Icons.edit),
                      validator: (v) => validateNotEmpty(v, 'Enter relationship'),
                    ),
                  ),
              ],

              if (selectedRole == 'Senior') ...[
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedCondition,
                  items: conditions.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(fontSize: fontSize)))).toList(),
                  onChanged: (v) => setState(() => selectedCondition = v),
                  decoration: _decoration("Condition", Icons.medical_services),
                  validator: (v) => v == null ? 'Select condition' : null,
                ),
                if (selectedCondition == 'Other')
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      controller: existingConditionsController,
                      decoration: _decoration("Other Condition", Icons.description),
                      validator: (v) => validateNotEmpty(v, 'Enter condition'),
                    ),
                  ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: allergiesController,
                  decoration: _decoration("Allergies", Icons.warning),
                  validator: (v) => validateNotEmpty(v, 'Enter allergies'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: medicationsController,
                  decoration: _decoration("Medications", Icons.local_pharmacy),
                  validator: (v) => validateNotEmpty(v, 'Enter medications'),
                ),
              ],

              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_add, color: Colors.white),
                          const SizedBox(width: 10),
                          Text("Register", style: TextStyle(color: Colors.white, fontSize: fontSize + 2)),
                        ],
                      ),
                    ),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Text("Already have an account? Login", style: TextStyle(fontSize: fontSize)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
