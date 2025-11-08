
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mentorloop_new/utils/email_service.dart';

class AuthService {
  AuthService._();
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role, // 'student' | 'teacher' | 'parent'
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      // Students and parents require admin approval
      'approved': (role == 'student' || role == 'parent') ? false : true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return cred;
  }

  static Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> loginWithTeacherInviteFallback({
    required String email,
    required String password,
  }) async {
    try {
      return await loginWithEmail(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      final code = e.code;
      if (code != 'user-not-found' &&
          code != 'wrong-password' &&
          code != 'invalid-credential') {
        rethrow;
      }
      final invites = await _db
          .collection('teacher_invites')
          .where('email', isEqualTo: email)
          .where('tempPassword', isEqualTo: password)
          .limit(1)
          .get();
      if (invites.docs.isEmpty) rethrow;
      final name = email.split('@').first;
      await registerWithEmail(
        name: name,
        email: email,
        password: password,
        phone: '',
        role: 'teacher',
      );
      await _db
          .collection('teacher_invites')
          .doc(invites.docs.first.id)
          .delete();
      return await loginWithEmail(email: email, password: password);
    }
  }

  static Future<void> updateCurrentUserProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    final Map<String, dynamic> updates = {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (updates.length > 1) {
      await _db.collection('users').doc(user.uid).update(updates);
    }
  }

  static Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    await user.updatePassword(newPassword);
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  static Future<void> sendOtp({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: onError,
      codeSent: (String verificationId, int? resendToken) =>
          onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  static Future<void> verifyOtpAndResetPassword({
    required String verificationId,
    required String smsCode,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  static Future<void> approveStudent(String uid) async {
    await _db.collection('users').doc(uid).update({'approved': true});
  }

  static Future<void> createParentVerificationRequest({
    required String parentId,
    required String parentEmail,
    required String studentEmail,
    required String idUrl,
  }) async {
    await _db.collection('parent_verifications').add({
      'parentId': parentId,
      'parentEmail': parentEmail,
      'studentEmail': studentEmail,
      'idUrl': idUrl,
      'status': 'pending', // pending | approved | rejected
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> issueTeacherCredentials(
    String email,
    String tempPassword,
  ) async {
    await _db.collection('teacher_invites').add({
      'email': email,
      'tempPassword': tempPassword,
      'createdAt': FieldValue.serverTimestamp(),
    });
    try {
      await EmailService.sendEmail(
        templateParams: {
          'to_email': email,
          'subject': 'Your MentorLoop teacher account',
          'message':
              'Welcome to MentorLoop!\nEmail: $email\nTemporary Password: $tempPassword\nPlease log in and change your password.',
        },
      );
    } catch (_) {
      // Silently ignore email errors so UI can still show credentials in Snackbar
    }
  }

  static Future<Map<String, dynamic>> signInWithGoogleAndEnsureProfile() async {
    UserCredential credential;
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      googleProvider.setCustomParameters({'prompt': 'select_account'});
      credential = await _auth.signInWithPopup(googleProvider);
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In aborted');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final oauthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      credential = await _auth.signInWithCredential(oauthCredential);
    }
    final String uid = credential.user!.uid;
    final String? email = credential.user!.email;
    final String? displayName = credential.user!.displayName;
    final userRef = _db.collection('users').doc(uid);
    final doc = await userRef.get();
    if (!doc.exists) {
      await userRef.set({
        'name': displayName ?? '',
        'email': email ?? '',
        'phone': '',
        'role': 'student',
        'approved': false,
        'createdAt': FieldValue.serverTimestamp(),
        'authProvider': 'google',
      });
    }
    final profile = (await userRef.get()).data() ?? <String, dynamic>{};
    return profile;
  }
}
