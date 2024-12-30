import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../models/comment_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../profile/profile_screen.dart';

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
  final TextEditingController _commentController = TextEditingController();
  String? _replyingToId;
  String? _replyingToUsername;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _startReply(String commentId, String username) {
    setState(() {
      _replyingToId = commentId;
      _replyingToUsername = username;
      _commentController.text = '@$username ';
    });
    _commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentController.text.length),
    );
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToUsername = null;
      _commentController.clear();
    });
  }

  Widget _buildCommentTile(CommentModel comment, UserModel commenter) {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    final isLiked = comment.likes.contains(currentUser.uid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userId: commenter.id),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundImage: commenter.photoUrl != null
                      ? NetworkImage(commenter.photoUrl!)
                      : null,
                  child: commenter.photoUrl == null
                      ? Text(commenter.name[0].toUpperCase())
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onLongPress: () {
                    if (currentUser.uid == commenter.id ||
                        currentUser.uid == widget.post.userId) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.delete, color: Colors.red),
                                title: const Text(
                                  'Delete Comment',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () async {
                                  Navigator.pop(context);
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Comment'),
                                      content: const Text(
                                        'Are you sure you want to delete this comment?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    context
                                        .read<FirestoreService>()
                                        .deleteComment(comment.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            commenter.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeago.format(comment.createdAt, locale: 'en_short'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(comment.text),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          IconButton(
                            iconSize: 20,
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border_outlined,
                              color: isLiked ? Colors.red : null,
                            ),
                            onPressed: () {
                              context
                                  .read<FirestoreService>()
                                  .likeComment(comment.id, !isLiked);
                            },
                          ),
                          if (comment.likes.isNotEmpty)
                            Text(
                              comment.likes.length.toString(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          const SizedBox(width: 16),
                          TextButton(
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                            ),
                            onPressed: () => _startReply(comment.id, commenter.name),
                            child: const Text('Reply'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (comment.replyCount > 0)
          StreamBuilder<List<CommentModel>>(
            stream: context.read<FirestoreService>().getCommentReplies(comment.id),
            builder: (context, snapshot) {
              print('Reply stream for ${comment.id}: ${snapshot.hasData ? snapshot.data!.length : 'no data'}'); // Debug print
              if (!snapshot.hasData) return const SizedBox.shrink();
              
              final replies = snapshot.data!;
              if (replies.isEmpty) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.only(left: 48.0, top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: replies.map((reply) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: FutureBuilder<UserModel?>(
                        future: context.read<FirestoreService>().getUser(reply.userId),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) return const SizedBox.shrink();
                          return _buildCommentTile(reply, userSnapshot.data!);
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please sign in to view comments'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          if (_replyingToId != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Row(
                children: [
                  Text('Replying to @$_replyingToUsername'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _cancelReply,
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream:
                  context.read<FirestoreService>().getPostComments(widget.post.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return const Center(
                    child: Text('No comments yet. Be the first to comment!'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return FutureBuilder<UserModel?>(
                      future:
                          context.read<FirestoreService>().getUser(comment.userId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        return _buildCommentTile(comment, userSnapshot.data!);
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _commentController.text.trim();
                    if (text.isNotEmpty) {
                      await context.read<FirestoreService>().addComment(
                            widget.post.id,
                            text,
                            parentId: _replyingToId,
                          );
                      _commentController.clear();
                      if (_replyingToId != null) {
                        _cancelReply();
                      }
                      // Unfocus the text field
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 