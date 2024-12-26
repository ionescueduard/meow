import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/post_card.dart';
import '../post/edit_post_screen.dart';
import '../post/post_comments_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final currentUser = context.read<AuthService>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditPostScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: firestoreService.getFeedPosts(),
        builder: (context, postsSnapshot) {
          if (postsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (postsSnapshot.hasError) {
            return Center(
              child: Text('Error: ${postsSnapshot.error}'),
            );
          }

          final posts = postsSnapshot.data ?? [];
          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No posts yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start by following some cat lovers\nor create your first post!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // The stream will automatically refresh the data
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return FutureBuilder<UserModel?>(
                  future: firestoreService.getUser(post.userId),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final author = userSnapshot.data!;
                    return PostCard(
                      post: post,
                      author: author,
                      isLiked: post.likes.contains(currentUser?.uid),
                      onLike: () async {
                        if (currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please sign in to like posts'),
                            ),
                          );
                          return;
                        }

                        if (post.likes.contains(currentUser.uid)) {
                          await firestoreService.unlikePost(
                            post.id,
                            currentUser.uid,
                          );
                        } else {
                          await firestoreService.likePost(
                            post.id,
                            currentUser.uid,
                          );
                        }
                      },
                      onComment: () {
                        if (currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please sign in to comment'),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostCommentsScreen(
                              post: post,
                              author: author,
                            ),
                          ),
                        );
                      },
                      onShare: () {
                        // TODO: Implement sharing functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sharing coming soon!')),
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
} 