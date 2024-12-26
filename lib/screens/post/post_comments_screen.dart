import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../models/comment_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCommentsScreen extends StatefulWidget {
  final PostModel post;
  final UserModel author;

  const PostCommentsScreen({
    super.key,
    required this.post,
    required this.author,
  });

  @override
  State<PostCommentsScreen> createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends State<PostCommentsScreen> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty || _isSubmitting) return;

    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    try {
      final comment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: widget.post.id,
        userId: currentUser.uid,
        text: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await context.read<FirestoreService>().addComment(comment);
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting comment: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: firestoreService.getPostComments(widget.post.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return const Center(
                    child: Text('No comments yet. Be the first to comment!'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return FutureBuilder<UserModel?>(
                      future: firestoreService.getUser(comment.userId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final commentAuthor = userSnapshot.data!;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: commentAuthor.photoUrl != null
                                          ? NetworkImage(commentAuthor.photoUrl!)
                                          : null,
                                      child: commentAuthor.photoUrl == null
                                          ? Text(commentAuthor.name[0])
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            commentAuthor.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            timeago.format(comment.createdAt),
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(comment.text),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSubmitting ? null : _submitComment,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 