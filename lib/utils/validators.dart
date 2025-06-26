// utils/validators.dart

bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  return emailRegex.hasMatch(email);
}

String? validateNotEmpty(String? value, String message) =>
    (value == null || value.isEmpty) ? message : null;

String? validatePassword(String? value) =>
    (value != null && value.length >= 6) ? null : 'Password must be at least 6 characters';

String? validateConfirmPassword(String? value, String original) =>
    value == original ? null : 'Passwords do not match';

String? validatePhone(String? value) {
  if (value == null || value.isEmpty) return 'Enter phone number';
  if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) return 'Invalid phone number';
  return null;
}
