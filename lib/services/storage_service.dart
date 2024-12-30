import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadUserProfilePhoto(dynamic file, String userId) async {
    final ref = _storage.ref().child('users/$userId/profile.jpg');
    
    UploadTask uploadTask;
    if (kIsWeb) {
      if (file is XFile) {
        final bytes = await file.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(
            contentType: 'image/jpeg',
            cacheControl: 'public, max-age=31536000',
          ),
        );
      } else {
        throw UnsupportedError('Unsupported file type for web');
      }
    } else {
      if (file is File) {
        uploadTask = ref.putFile(
          file,
          SettableMetadata(
            contentType: 'image/jpeg',
            cacheControl: 'public, max-age=31536000',
          ),
        );
      } else {
        throw UnsupportedError('Unsupported file type for mobile');
      }
    }

    try {
      final snapshot = await uploadTask;
      // Wait a bit longer after upload completes
      await Future.delayed(const Duration(seconds: 5));
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<String> uploadCatImage(dynamic file, String catId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref().child('cats/$catId/$timestamp.jpg');
    
    UploadTask uploadTask;
    if (kIsWeb) {
      if (file is XFile) {
        final bytes = await file.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(
            contentType: 'image/jpeg',
            cacheControl: 'public, max-age=31536000',
          ),
        );
      } else {
        throw UnsupportedError('Unsupported file type for web');
      }
    } else {
      if (file is File) {
        uploadTask = ref.putFile(
          file,
          SettableMetadata(
            contentType: 'image/jpeg',
            cacheControl: 'public, max-age=31536000',
          ),
        );
      } else {
        throw UnsupportedError('Unsupported file type for mobile');
      }
    }

    try {
      final snapshot = await uploadTask;
      // Wait a bit longer after upload completes
      await Future.delayed(const Duration(seconds: 5));
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<String> uploadPostImage(dynamic file) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref().child('posts/$timestamp.jpg');
    
    UploadTask uploadTask;
    if (kIsWeb) {
      if (file is XFile) {
        final bytes = await file.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(
            contentType: 'image/jpeg',
            cacheControl: 'public, max-age=31536000',
          ),
        );
      } else {
        throw UnsupportedError('Unsupported file type for web');
      }
    } else {
      if (file is File) {
        uploadTask = ref.putFile(
          file,
          SettableMetadata(
            contentType: 'image/jpeg',
            cacheControl: 'public, max-age=31536000',
          ),
        );
      } else {
        throw UnsupportedError('Unsupported file type for mobile');
      }
    }

    try {
      final snapshot = await uploadTask;
      // Wait a bit longer after upload completes
      await Future.delayed(const Duration(seconds: 5));
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
    }
  }
} 