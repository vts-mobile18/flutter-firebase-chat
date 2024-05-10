import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

abstract final class StorageService {
  static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  static Future<String> saveFile(
    File file,
    String filePath
  ) async {
    Reference fileRef = _firebaseStorage.ref().child(filePath);
    TaskSnapshot fileSnapshot = await fileRef.putFile(file);
    return fileSnapshot.ref.getDownloadURL();
  }
}