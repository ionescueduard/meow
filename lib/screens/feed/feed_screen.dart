import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final currentUser = context.read<AuthService>().currentUser;

    return StreamBuilder<List<PostModel>>(
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
                      if (currentUser == null) return;

                      final updatedPost = post.copyWith(
                        likes: List.from(post.likes)
                          ..removeWhere((id) => id == currentUser.uid),
                      );

                      if (!post.likes.contains(currentUser.uid)) {
                        updatedPost.likes.add(currentUser.uid);
                      }

                      await firestoreService.updatePost(updatedPost);
                    },
                    onComment: () {
                      // TODO: Navigate to comments screen
                    },
                    onShare: () {
                      // TODO: Implement sharing functionality
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
} 