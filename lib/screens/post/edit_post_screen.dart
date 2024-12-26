import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../models/cat_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel? post;

  const EditPostScreen({super.key, this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();
  List<String> _selectedCatIds = [];
  List<File> _selectedImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _contentController.text = widget.post!.content;
      _selectedCatIds = List.from(widget.post!.catIds);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _imagePicker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // if (_selectedImages.isEmpty && widget.post?.imageUrls.isEmpty != false) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please select at least one image')),
    //   );
    //   return;
    // }

    setState(() => _isLoading = true);

    try {
      final currentUser = context.read<AuthService>().currentUser;
      if (currentUser == null) return;

      final storageService = context.read<StorageService>();
      final firestoreService = context.read<FirestoreService>();

      // Upload new images
      final imageUrls = <String>[];
      for (final image in _selectedImages) {
        final url = await storageService.uploadPostImage(image);
        imageUrls.add(url);
      }

      // Create or update post
      final post = PostModel(
        id: widget.post?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser.uid,
        content: _contentController.text.trim(),
        imageUrls: [...widget.post?.imageUrls ?? [], ...imageUrls],
        catIds: _selectedCatIds,
        likes: widget.post?.likes ?? [],
        createdAt: widget.post?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestoreService.savePost(post);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving post: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final currentUser = context.read<AuthService>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? 'New Post' : 'Edit Post'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Post'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<CatModel>>(
                stream: firestoreService.getUserCats(currentUser?.uid ?? ''),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final cats = snapshot.data!;
                  if (cats.isEmpty) {
                    return const Text('Add some cats to tag them in your posts!');
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Tag your cats:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: cats.map((cat) {
                          final isSelected = _selectedCatIds.contains(cat.id);
                          return FilterChip(
                            label: Text(cat.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCatIds.add(cat.id);
                                } else {
                                  _selectedCatIds.remove(cat.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Photos'),
              ),
              const SizedBox(height: 16),
              if (_selectedImages.isNotEmpty) ...[
                const Text(
                  'Selected Images:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Image.file(
                              _selectedImages[index],
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                color: Colors.white,
                                onPressed: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (widget.post?.imageUrls.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                const Text(
                  'Current Images:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.post!.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Image.network(
                          widget.post!.imageUrls[index],
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 