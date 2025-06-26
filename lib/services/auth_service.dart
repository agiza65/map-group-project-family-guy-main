// services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  static Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    required String contactNumber,
    String? seniorId,
    String? relationship,
    String? customRelationship,
    String? condition,
    String? customCondition,
    String? allergies,
    String? medications,
  }) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'contactNumber': contactNumber,
        'createdAt': FieldValue.serverTimestamp(),
        if (role == 'Guardian') ...{
          'seniorId': seniorId,
          'relationship':
              relationship == 'Other' ? customRelationship : relationship,
        },
        if (role == 'Senior') ...{
          'existingCondition':
              condition == 'Other' ? customCondition : condition,
          'allergies': allergies,
          'medications': medications,
        },
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }
}
