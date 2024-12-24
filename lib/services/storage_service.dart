import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadFile(File file, String folder) async {
    final String fileName = '${_uuid.v4()}${path.extension(file.path)}';
    final Reference ref = _storage.ref().child('$folder/$fileName');
    
    final UploadTask uploadTask = ref.putFile(
      file,
      SettableMetadata(
        contentType: 'image/${path.extension(file.path).replaceAll('.', '')}',
      ),
    );

    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<List<String>> uploadFiles(List<File> files, String folder) async {
    final List<String> downloadUrls = [];
    
    for (final file in files) {
      final url = await uploadFile(file, folder);
      downloadUrls.add(url);
    }
    
    return downloadUrls;
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      // Handle or rethrow the error
      rethrow;
    }
  }

  Future<void> deleteFiles(List<String> fileUrls) async {
    for (final url in fileUrls) {
      await deleteFile(url);
    }
  }

  // Helper method to generate storage paths for different types of content
  String getStoragePath(String userId, String type) {
    switch (type) {
      case 'profile':
        return 'users/$userId/profile';
      case 'cat':
        return 'users/$userId/cats';
      case 'post':
        return 'users/$userId/posts';
      default:
        return 'users/$userId/misc';
    }
  }
} 