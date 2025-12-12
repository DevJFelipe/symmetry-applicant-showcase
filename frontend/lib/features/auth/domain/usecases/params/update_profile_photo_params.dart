import 'dart:io';

import 'package:equatable/equatable.dart';

/// Parameters for updating user profile photo.
class UpdateProfilePhotoParams extends Equatable {
  final File imageFile;
  final String userId;

  const UpdateProfilePhotoParams({
    required this.imageFile,
    required this.userId,
  });

  @override
  List<Object?> get props => [imageFile, userId];
}
