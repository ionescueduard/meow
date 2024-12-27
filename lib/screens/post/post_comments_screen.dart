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
                        return GestureDetector(
                          onLongPress: () {
                            final currentUser = context.read<AuthService>().currentUser;
                            if (currentUser == null) return;
                            
                            // Only show delete option if user is comment author or post owner
                            if (comment.userId == currentUser.uid ||
                                widget.post.userId == currentUser.uid) {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.delete_outline),
                                        title: const Text('Delete Comment'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Comment'),
                                              content: const Text('Are you sure you want to delete this comment?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            await firestoreService.deleteComment(comment.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundImage: commentAuthor.photoUrl != null
                                            ? NetworkImage(commentAuthor.photoUrl!)
                                            : null,
                                        child: commentAuthor.photoUrl == null
                                            ? Text(commentAuthor.name[0])
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(
                                              commentAuthor.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              timeago.format(comment.createdAt,
                                                  locale: 'en_short'),
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          if (comment.likes.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(right: 4),
                                              child: Text(
                                                comment.likes.length.toString(),
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                            ),
                                          IconButton(
                                            icon: Icon(
                                              comment.likes.contains(context.read<AuthService>().currentUser?.uid)
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              size: 16,
                                              color: comment.likes.contains(context.read<AuthService>().currentUser?.uid)
                                                  ? Colors.red
                                                  : null,
                                            ),
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              final currentUser = context.read<AuthService>().currentUser;
                                              if (currentUser == null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Please sign in to like comments'),
                                                  ),
                                                );
                                                return;
                                              }
                                              
                                              if (comment.likes.contains(currentUser.uid)) {
                                                firestoreService.unlikeComment(
                                                  comment.id,
                                                  currentUser.uid,
                                                );
                                              } else {
                                                firestoreService.likeComment(
                                                  comment.id,
                                                  currentUser.uid,
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 40),
                                    child: Text(comment.text),
                                  ),
                                ],
                              ),
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