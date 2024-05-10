import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_firebase_chat/src/models/profile_model.dart';
import 'storage_service.dart';

abstract final class AuthService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static Future<void> login(
      String email,
      String password
      ) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      String? token = await FirebaseMessaging.instance.getToken();
      await _firestore
          .collection('users')
          .doc(fetchCurrentUserId())
          .update({
        'fcm': '${token}',
      });
    } on FirebaseAuthException catch (error) {
      return Future.error(error.message!);
    }
  }

  static Future<void> register(
      String username,
      String email,
      String password,
      File imageFile
      ) async {
    UserCredential authResult = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password ,
    );
    print('dfddddddddddddddddddddddddddddddddd: ${authResult.user!.uid}, ${username}, ${email}, '
        '${await StorageService.saveFile(imageFile, _userImagePath(authResult.user!.uid))}, '
        '${_searchTermsByString(username)}');
    return _firestore
        .collection('users')
        .doc(authResult.user!.uid)
        .set({
      'username': username,
      'email': email,
      'imageUrl': await StorageService.saveFile(
          imageFile,
          _userImagePath(authResult.user!.uid)
      ),
      'fcm': 'fheiuhwer',
      'searchTerms': _searchTermsByString(username)
    });
  }

  static Future<void> logout() {
    return _firebaseAuth.signOut();
  }

  static Future<void> resetPassword(String email) {
    return _firebaseAuth.sendPasswordResetEmail(
        email: email
    );
  }

  static bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  static Future<Profile> fetchProfile() async {
    DocumentSnapshot profileDoc = await _firestore
        .collection('users')
        .doc(fetchCurrentUserId())
        .get();
    return Profile.fromDoc(profileDoc);
  }

  static Future<void> updateProfile(Profile profile) async {
    String currentUserId = fetchCurrentUserId();
    if (profile.password.isNotEmpty) {
      await _firebaseAuth.currentUser!.updatePassword(profile.password);
    }
    if (profile.imageFile != null) {
      profile.imageUrl = await StorageService.saveFile(
          profile.imageFile!,
          _userImagePath(currentUserId)
      );
    }
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .update({
      'username': profile.username,
      'imageUrl': profile.imageUrl,
      'searchTerms': _searchTermsByString(profile.username)
    });
  }

  static String fetchCurrentUserId() {
    return _firebaseAuth.currentUser!.uid;
  }

  static String _userImagePath(String userId) {
    return 'users/$userId${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  static List<String> _searchTermsByString(String source) {
    source = source.trim().toLowerCase();
    List<String> longTerms = source
        .split(' ')
        .toList();
    List<String> shortTerms = [];
    if (longTerms.length > 1) {
      shortTerms.add(source);
    }
    for (String longTerm in longTerms) {
      for (int i = 0; i < longTerm.length; i++) {
        shortTerms.add(longTerm.substring(0, i + 1));
      }
      for (int i = (longTerm.length - 1); i > 0; i--) {
        shortTerms.add(longTerm.substring(i, longTerm.length));
      }
    }
    return shortTerms;
  }
}