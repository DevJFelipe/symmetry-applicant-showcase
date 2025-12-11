import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_state.dart';

export 'create_article_state.dart';

/// Cubit for managing article creation state.
///
/// Handles image selection, form validation, and article submission
/// to Firestore with image upload to Cloud Storage.
class CreateArticleCubit extends Cubit<CreateArticleState> {
  final CreateArticleUseCase _createArticleUseCase;
  final ImagePicker _imagePicker;

  File? _selectedImage;

  CreateArticleCubit({
    required CreateArticleUseCase createArticleUseCase,
    ImagePicker? imagePicker,
  })  : _createArticleUseCase = createArticleUseCase,
        _imagePicker = imagePicker ?? ImagePicker(),
        super(const CreateArticleInitial());

  /// Returns the currently selected image file.
  File? get selectedImage => _selectedImage;

  /// Picks an image from the device gallery.
  Future<void> pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        emit(CreateArticleImageSelected(pickedFile.path));
      }
    } catch (e) {
      emit(CreateArticleError('Failed to pick image: $e'));
    }
  }

  /// Picks an image from the device camera.
  Future<void> pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        emit(CreateArticleImageSelected(pickedFile.path));
      }
    } catch (e) {
      emit(CreateArticleError('Failed to capture image: $e'));
    }
  }

  /// Clears the selected image.
  void clearImage() {
    _selectedImage = null;
    emit(const CreateArticleInitial());
  }

  /// Creates a new article with the provided data.
  ///
  /// [title] - Article headline
  /// [description] - Brief summary for the feed
  /// [content] - Full article body
  /// [currentUser] - The authenticated user creating the article
  /// [url] - Optional external URL
  Future<void> createArticle({
    required String title,
    required String description,
    required String content,
    required UserEntity currentUser,
    String? url,
  }) async {
    // Validate image selection
    if (_selectedImage == null) {
      emit(const CreateArticleError('Please select a thumbnail image'));
      return;
    }

    // Validate required fields
    if (title.trim().isEmpty) {
      emit(const CreateArticleError('Please enter a title'));
      return;
    }
    if (description.trim().isEmpty) {
      emit(const CreateArticleError('Please enter a description'));
      return;
    }
    if (content.trim().isEmpty) {
      emit(const CreateArticleError('Please enter the article content'));
      return;
    }

    emit(const CreateArticleLoading(message: 'Uploading image...'));

    try {
      final params = CreateArticleParams(
        title: title.trim(),
        description: description.trim(),
        content: content.trim(),
        thumbnailFile: _selectedImage!,
        url: url?.trim().isNotEmpty == true ? url!.trim() : null,
      );

      emit(const CreateArticleLoading(message: 'Saving article...'));

      final article = await _createArticleUseCase.createWithUserData(
        params: params,
        userId: currentUser.uid,
        authorName: currentUser.displayName ?? currentUser.email,
      );

      // Clear selected image after successful creation
      _selectedImage = null;

      emit(CreateArticleSuccess(article));
    } catch (e) {
      emit(CreateArticleError('Failed to create article: $e'));
    }
  }

  /// Resets the cubit to its initial state.
  void reset() {
    _selectedImage = null;
    emit(const CreateArticleInitial());
  }
}
