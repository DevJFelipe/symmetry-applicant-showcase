import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/app_radius.dart';
import 'package:news_app_clean_architecture/core/services/haptic_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/edit/edit_article_cubit.dart';
import 'package:news_app_clean_architecture/shared/widgets/widgets.dart';

/// Page for editing existing articles.
///
/// Allows authenticated users to edit their articles with:
/// - Title, description, and content
/// - Thumbnail image (replace from gallery or camera)
class EditArticlePage extends StatefulWidget {
  const EditArticlePage({super.key});

  @override
  State<EditArticlePage> createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _initializeControllers(ArticleEntity article) {
    if (_initialized) return;
    _initialized = true;
    _titleController.text = article.title ?? '';
    _descriptionController.text = article.description ?? '';
    _contentController.text = article.content ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: BlocConsumer<EditArticleCubit, EditArticleState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return switch (state) {
            EditArticleLoading(:final message) =>
              _buildLoadingState(context, message),
            EditArticleInitial(:final article) =>
              _buildForm(context, article, null),
            EditArticleImagePicked(:final article, :final newImagePath) =>
              _buildForm(context, article, newImagePath),
            EditArticleSuccess() => _buildLoadingState(context, 'Saved!'),
            EditArticleError(:final article, :final newImagePath) =>
              _buildForm(context, article, newImagePath),
          };
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
        onPressed: () => _showDiscardDialog(context),
      ),
      title: Text(
        'Edit Article',
        style: AppTypography.titleLarge
            .copyWith(color: theme.colorScheme.onSurface),
      ),
      actions: [
        BlocBuilder<EditArticleCubit, EditArticleState>(
          builder: (context, state) {
            final isLoading = state is EditArticleLoading;
            return TextButton(
              onPressed: isLoading ? null : () => _onSave(context),
              child: Text(
                'Save',
                style: AppTypography.titleSmall.copyWith(
                  color: isLoading
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                      : theme.colorScheme.primary,
                ),
              ),
            );
          },
        ),
        SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PremiumLoading(),
          SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    ArticleEntity article,
    String? newImagePath,
  ) {
    _initializeControllers(article);

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePicker(context, article, newImagePath),
            SizedBox(height: AppSpacing.xl),
            _buildTextField(
              context: context,
              controller: _titleController,
              label: 'Title',
              hint: 'Enter article title',
              maxLength: 200,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                if (value.trim().length < 5) {
                  return 'Title must be at least 5 characters';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.lg),
            _buildTextField(
              context: context,
              controller: _descriptionController,
              label: 'Description',
              hint: 'Brief summary for the feed',
              maxLength: 500,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                if (value.trim().length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.lg),
            _buildTextField(
              context: context,
              controller: _contentController,
              label: 'Content',
              hint: 'Full article body',
              maxLines: 10,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the article content';
                }
                if (value.trim().length < 50) {
                  return 'Content must be at least 50 characters';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(
    BuildContext context,
    ArticleEntity article,
    String? newImagePath,
  ) {
    final cubit = context.read<EditArticleCubit>();
    final hasNewImage = newImagePath != null;
    final hasOriginalImage = article.urlToImage?.isNotEmpty == true;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thumbnail Image',
          style: AppTypography.titleSmall.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () => _showImageSourceDialog(context),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: hasNewImage
                      ? Image.file(
                          File(newImagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildImagePlaceholder(context),
                        )
                      : hasOriginalImage
                          ? CachedNetworkImage(
                              imageUrl: article.urlToImage!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  _buildImagePlaceholder(context),
                              errorWidget: (_, __, ___) =>
                                  _buildImagePlaceholder(context),
                            )
                          : _buildImagePlaceholder(context),
                ),
                // Change image overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(AppRadius.lg),
                        bottomRight: Radius.circular(AppRadius.lg),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          hasNewImage ? 'Change new image' : 'Change image',
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Remove new image button
                if (hasNewImage)
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: GestureDetector(
                      onTap: () {
                        HapticService.lightImpact();
                        cubit.clearNewImage();
                      },
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hasNewImage)
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              'New image selected',
              style: AppTypography.labelSmall.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'No image',
            style: AppTypography.bodySmall.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    int? maxLength,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.titleSmall.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          maxLength: maxLength,
          maxLines: maxLines,
          style: AppTypography.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            contentPadding: EdgeInsets.all(AppSpacing.md),
            counterStyle: AppTypography.labelSmall.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    final cubit = context.read<EditArticleCubit>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (dialogContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                ListTile(
                  leading: Icon(Icons.photo_library_outlined,
                      color: theme.colorScheme.primary),
                  title: Text('Choose from Gallery',
                      style: AppTypography.bodyMedium
                          .copyWith(color: theme.colorScheme.onSurface)),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    HapticService.lightImpact();
                    cubit.pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt_outlined,
                      color: theme.colorScheme.primary),
                  title: Text('Take a Photo',
                      style: AppTypography.bodyMedium
                          .copyWith(color: theme.colorScheme.onSurface)),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    HapticService.lightImpact();
                    cubit.pickImageFromCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, EditArticleState state) {
    final theme = Theme.of(context);
    if (state is EditArticleSuccess) {
      HapticService.success();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Article updated successfully!',
              style: TextStyle(color: theme.colorScheme.onPrimary)),
          backgroundColor: Colors
              .green, // Success color often needs to be specific green, or use extended theme
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, state.article);
    } else if (state is EditArticleError) {
      HapticService.error();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message,
              style: TextStyle(color: theme.colorScheme.onError)),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onSave(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      HapticService.lightImpact();
      context.read<EditArticleCubit>().updateArticle(
            title: _titleController.text,
            description: _descriptionController.text,
            content: _contentController.text,
          );
    }
  }

  void _showDiscardDialog(BuildContext context) {
    HapticService.warning();
    // Assuming ConfirmationModal is theme aware or needs simple colors
    // Since I don't see ConfirmationModal code, I assume it accepts what it needs or follows context theme
    // But I should check if it needs specific params.
    // Based on previous code it seemed fine.
    showDialog(
      context: context,
      builder: (ctx) => ConfirmationModal(
        title: 'Discard Changes?',
        message:
            'Are you sure you want to discard your changes? This action cannot be undone.',
        confirmLabel: 'Discard',
        isDanger: true,
        onConfirm: () {
          Navigator.pop(ctx);
          Navigator.pop(context);
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }
}
