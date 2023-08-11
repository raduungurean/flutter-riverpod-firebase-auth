import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageStorageServiceProvider = Provider<ImageStorageService>((ref) {
  return ImageStorageService(FirebaseStorage.instance);
});

class ImageStorageService {
  final FirebaseStorage _storage;

  ImageStorageService(this._storage);

  Future<String> uploadUserImage(String userId, File imageFile) async {
    try {
      String filePath = 'userImages/$userId/${DateTime.now()}.png';

      Reference ref = _storage.ref().child(filePath);

      UploadTask uploadTask = ref.putFile(imageFile);

      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Failed to upload image to Firebase Storage: $e');
      throw e;
    }
  }

  Future<String> uploadUserImageBytes(String userId, Uint8List bytes) async {
    try {
      String filePath = 'userImages/$userId/${DateTime.now()}.png';
      Reference ref = _storage.ref().child(filePath);

      UploadTask uploadTask = ref.putData(bytes);

      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Failed to upload image bytes to Firebase Storage: $e');
      throw e;
    }
  }
}
