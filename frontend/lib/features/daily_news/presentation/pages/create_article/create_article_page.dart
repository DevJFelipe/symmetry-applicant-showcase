import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_cubit.dart';

/// Page for creating new articles.
///
/// Allows authenticated users to create articles with:
/// - Title, description, and content
/// - Thumbnail image (from gallery or camera)
/// - Optional external URL
class CreateArticlePage extends StatefulWidget {
  const CreateArticlePage({Key? key}) : super(key: key);

  @override
  State<CreateArticlePage> createState() => _CreateArticlePageState();
}

class _CreateArticlePageState extends State<CreateArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Article',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<CreateArticleCubit, CreateArticleState>(
        listener: (context, state) {
          if (state is CreateArticleSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Article created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          } else if (state is CreateArticleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildImagePicker(context, state),
                      const SizedBox(height: 24),
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildContentField(),
                      const SizedBox(height: 16),
                      _buildUrlField(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(state is CreateArticleLoading),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              if (state is CreateArticleLoading)
                _buildLoadingOverlay(state.message),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context, CreateArticleState state) {
    final cubit = context.read<CreateArticleCubit>();
    final selectedImage = cubit.selectedImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thumbnail Image *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showImageSourceDialog(context),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: selectedImage != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          selectedImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => cubit.clearImage(),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add thumbnail',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    final cubit = context.read<CreateArticleCubit>();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext dialogContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  cubit.pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  cubit.pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      textCapitalization: TextCapitalization.sentences,
      maxLength: 200,
      decoration: InputDecoration(
        labelText: 'Title *',
        hintText: 'Enter article title',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        if (value.trim().length < 5) {
          return 'Title must be at least 5 characters';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
      maxLength: 500,
      decoration: InputDecoration(
        labelText: 'Description *',
        hintText: 'Brief summary for the feed',
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a description';
        }
        if (value.trim().length < 10) {
          return 'Description must be at least 10 characters';
        }
        return null;
      },
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 8,
      decoration: InputDecoration(
        labelText: 'Content *',
        hintText: 'Full article body',
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the article content';
        }
        if (value.trim().length < 50) {
          return 'Content must be at least 50 characters';
        }
        return null;
      },
    );
  }

  Widget _buildUrlField() {
    return TextFormField(
      controller: _urlController,
      keyboardType: TextInputType.url,
      decoration: InputDecoration(
        labelText: 'External URL (optional)',
        hintText: 'https://example.com/article',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final uri = Uri.tryParse(value);
          if (uri == null || !uri.hasScheme) {
            return 'Please enter a valid URL';
          }
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Publish Article',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ElevatedButton(
          onPressed: isLoading ? null : () => _onSubmit(authState),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Publish Article',
            style: TextStyle(fontSize: 16),
          ),
        );
      },
    );
  }

  Widget _buildLoadingOverlay(String message) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit(AuthAuthenticated authState) {
    if (_formKey.currentState?.validate() ?? false) {
      final user = authState.user;
      if (user == null) return;
      
      context.read<CreateArticleCubit>().createArticle(
            title: _titleController.text,
            description: _descriptionController.text,
            content: _contentController.text,
            currentUser: user,
            url: _urlController.text,
          );
    }
  }
}
