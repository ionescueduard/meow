import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../screens/post/edit_post_screen.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final UserModel author;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final bool isLiked;

  const PostCard({
    super.key,
    required this.post,
    required this.author,
    this.onLike,
    this.onComment,
    this.onShare,
    this.isLiked = false,
  });

  void _showOptionsMenu(BuildContext context) {
    final currentUser = Provider.of<AuthService>(context, listen: false).currentUser;
    final isAuthor = currentUser?.uid == author.id;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAuthor) ...[
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Post'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPostScreen(post: post),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete Post'),
                  onTap: () async {
                    Navigator.pop(context);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Post'),
                        content: const Text('Are you sure you want to delete this post?'),
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
                      await context.read<FirestoreService>().deletePost(post.id);
                    }
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share feature coming soon!'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Why are you reporting this post?'),
            const SizedBox(height: 16),
            _buildReportOption(context, 'Inappropriate content'),
            _buildReportOption(context, 'Spam'),
            _buildReportOption(context, 'Harassment'),
            _buildReportOption(context, 'False information'),
            _buildReportOption(context, 'Other'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOption(BuildContext context, String reason) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        await _submitReport(context, reason);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8,
        ),
        child: Text(reason),
      ),
    );
  }

  Future<void> _submitReport(BuildContext context, String reason) async {
    try {
      await context.read<FirestoreService>().reportPost(
        postId: post.id,
        userId: context.read<AuthService>().currentUser!.uid,
        reason: reason,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for reporting this post. We will review it.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit report. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: author.photoUrl != null
                  ? CachedNetworkImageProvider(author.photoUrl!)
                  : null,
              child: author.photoUrl == null
                  ? Text(author.name[0].toUpperCase())
                  : null,
            ),
            title: Text(
              author.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              timeago.format(post.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showOptionsMenu(context),
            ),
          ),

          // Post content
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(post.content),
            ),

          // Post media
          if (post.imageUrls.isNotEmpty)
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: post.imageUrls.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: post.imageUrls[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error),
                    ),
                  );
                },
              ),
            ),

          // Action buttons
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                ),
                onPressed: onLike,
              ),
              Text(
                post.likes.length.toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: onComment,
              ),
              Text(
                post.comments.length.toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: onShare,
              ),
            ],
          ),

          // Comments preview
          if (post.comments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comments',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...post.comments.entries.take(2).map(
                        (comment) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(comment.value),
                        ),
                      ),
                  if (post.comments.length > 2)
                    TextButton(
                      onPressed: onComment,
                      child: Text(
                        'View all ${post.comments.length} comments',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 