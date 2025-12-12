import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Data source for profile photo storage operations.
///
/// Handles upload and deletion of profile photos in Firebase Cloud Storage.
/// This is the only place where Firebase Storage is imported for profile photos,
/// following Clean Architecture principles.
class ProfileStorageService {
  final FirebaseStorage _storage;

  /// Storage path for profile photos.
  static const String _profilePhotosPath = 'pfp';

  ProfileStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Uploads a profile photo to Cloud Storage.
  ///
  /// The photo is stored at `pfp/{userId}/{timestamp}.{extension}`.
  /// Returns the download URL for the uploaded image.
  Future<String> uploadProfilePhoto({
    required File imageFile,
    required String userId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = imageFile.path.split('.').last;
    final fileName = '$timestamp.$extension';
    final ref = _storage.ref().child(_profilePhotosPath).child(userId).child(fileName);

    // Set metadata for the upload
    final metadata = SettableMetadata(
      contentType: 'image/$extension',
      customMetadata: {
        'uploadedBy': userId,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );

    // Upload the file
    final uploadTask = await ref.putFile(imageFile, metadata);

    // Get and return the download URL
    return await uploadTask.ref.getDownloadURL();
  }

  /// Deletes a profile photo from Cloud Storage by its URL.
  ///
  /// Silently fails if the photo doesn't exist or URL is external.
  Future<void> deleteProfilePhoto(String? photoURL) async {
    if (photoURL == null || photoURL.isEmpty) return;
    
    // Only delete if it's from our Firebase Storage
    if (!photoURL.contains('firebase')) return;

    try {
      final ref = _storage.refFromURL(photoURL);
      await ref.delete();
    } catch (e) {
      // Photo might not exist or URL is external - ignore error
    }
  }
}
