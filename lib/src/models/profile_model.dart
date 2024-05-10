import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

final class Profile {
  String username;
  final String email;
  String password;
  String confirmPassword;
  String imageUrl;
  File? imageFile;

  Profile({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.imageUrl,
    required this.imageFile
  });

  factory Profile.fromDoc(DocumentSnapshot profileDoc) {
    Map profileData = profileDoc.data() as Map;
    return Profile(
      username: profileData['username'],
      email: profileData['email'],
      password: '',
      confirmPassword: '',
      imageUrl: profileData['imageUrl'],
      imageFile: null
    );
  }
}