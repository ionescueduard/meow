import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadUserProfilePhoto(File file, String userId) async {
    final ref = _storage.ref().child('users/$userId/profile.${path.extension(file.path)}');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadCatImage(File file, String catId) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
    final ref = _storage.ref().child('cats/$catId/$fileName');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadPostImage(File file) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
    final ref = _storage.ref().child('posts/$fileName');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Handle or log error
      print('Error deleting file: $e');
    }
  }

  Future<void> deleteUserAvatar(String userId) async {
    try {
      final ref = _storage.ref().child('users/$userId/avatar');
      await ref.delete();
    } catch (e) {
      // Handle or log error
      print('Error deleting avatar: $e');
    }
  }

  Future<void> deleteCatImages(String catId) async {
    try {
      final ref = _storage.ref().child('cats/$catId');
      final result = await ref.listAll();
      await Future.wait(result.items.map((item) => item.delete()));
    } catch (e) {
      // Handle or log error
      print('Error deleting cat images: $e');
    }
  }
} 