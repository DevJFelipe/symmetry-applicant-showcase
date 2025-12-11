import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/toggle_reaction_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/edit/edit_article_state.dart';

export 'edit_article_state.dart';

/// Cubit for managing article editing state.
///
/// Handles image selection, form updates, and article update submission
/// to Firestore with optional image upload to Cloud Storage.
class EditArticleCubit extends Cubit<EditArticleState> {
  final UpdateArticleUseCase _updateArticleUseCase;
  final ImagePicker _imagePicker;

  String? _newImagePath;
  ArticleEntity? _originalArticle;

  EditArticleCubit({
    required UpdateArticleUseCase updateArticleUseCase,
    ImagePicker? imagePicker,
  })  : _updateArticleUseCase = updateArticleUseCase,
        _imagePicker = imagePicker ?? ImagePicker(),
        super(const EditArticleLoading());

  /// Returns the path to the newly selected image, if any.
  String? get newImagePath => _newImagePath;

  /// Returns the original article being edited.
  ArticleEntity? get originalArticle => _originalArticle;

  /// Loads an article for editing.
  void loadArticle(ArticleEntity article) {
    _originalArticle = article;
    _newImagePath = null;
    emit(EditArticleInitial(article));
  }

  /// Picks a new image from the device gallery.
  Future<void> pickImageFromGallery() async {
    final article = _originalArticle;
    if (article == null) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _newImagePath = pickedFile.path;
        emit(EditArticleImagePicked(
          article: article,
          newImagePath: pickedFile.path,
        ));
      }
    } catch (e) {
      emit(EditArticleError(
        article: article,
        message: 'Failed to pick image: $e',
        newImagePath: _newImagePath,
      ));
    }
  }

  /// Picks a new image from the device camera.
  Future<void> pickImageFromCamera() async {
    final article = _originalArticle;
    if (article == null) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _newImagePath = pickedFile.path;
        emit(EditArticleImagePicked(
          article: article,
          newImagePath: pickedFile.path,
        ));
      }
    } catch (e) {
      emit(EditArticleError(
        article: article,
        message: 'Failed to capture image: $e',
        newImagePath: _newImagePath,
      ));
    }
  }

  /// Clears the newly selected image, reverting to the original.
  void clearNewImage() {
    final article = _originalArticle;
    if (article == null) return;

    _newImagePath = null;
    emit(EditArticleInitial(article));
  }

  /// Updates the article with the provided data.
  ///
  /// Only fields that differ from the original will be sent to the server.
  /// [title], [description], [content] - Updated text fields
  Future<void> updateArticle({
    required String title,
    required String description,
    required String content,
  }) async {
    final article = _originalArticle;
    if (article == null || article.documentId == null) {
      return;
    }

    // Validate required fields
    if (title.trim().isEmpty) {
      emit(EditArticleError(
        article: article,
        message: 'Please enter a title',
        newImagePath: _newImagePath,
      ));
      return;
    }
    if (description.trim().isEmpty) {
      emit(EditArticleError(
        article: article,
        message: 'Please enter a description',
        newImagePath: _newImagePath,
      ));
      return;
    }
    if (content.trim().isEmpty) {
      emit(EditArticleError(
        article: article,
        message: 'Please enter the article content',
        newImagePath: _newImagePath,
      ));
      return;
    }

    // Determine what changed
    final titleChanged = title.trim() != article.title;
    final descriptionChanged = description.trim() != article.description;
    final contentChanged = content.trim() != article.content;
    final imageChanged = _newImagePath != null;

    // Check if anything actually changed
    if (!titleChanged && !descriptionChanged && !contentChanged && !imageChanged) {
      emit(EditArticleError(
        article: article,
        message: 'No changes detected',
        newImagePath: _newImagePath,
      ));
      return;
    }

    emit(EditArticleLoading(
      message: imageChanged ? 'Uploading image...' : 'Saving changes...',
    ));

    try {
      final params = UpdateArticleParams(
        articleId: article.documentId!,
        title: titleChanged ? title.trim() : null,
        description: descriptionChanged ? description.trim() : null,
        content: contentChanged ? content.trim() : null,
        newThumbnailPath: _newImagePath,
      );

      final updatedArticle = await _updateArticleUseCase.call(params: params);

      // Clear the new image path after successful update
      _newImagePath = null;
      _originalArticle = updatedArticle;

      emit(EditArticleSuccess(updatedArticle));
    } catch (e) {
      emit(EditArticleError(
        article: article,
        message: 'Failed to update article: $e',
        newImagePath: _newImagePath,
      ));
    }
  }

  /// Resets the cubit state to allow editing again after an error.
  void resetError() {
    final article = _originalArticle;
    if (article == null) return;

    if (_newImagePath != null) {
      emit(EditArticleImagePicked(
        article: article,
        newImagePath: _newImagePath!,
      ));
    } else {
      emit(EditArticleInitial(article));
    }
  }
}
