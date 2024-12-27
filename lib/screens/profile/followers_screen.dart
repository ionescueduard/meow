import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'profile_screen.dart';

class FollowersScreen extends StatefulWidget {
  final UserModel user;
  final int initialTab;

  const FollowersScreen({
    super.key,
    required this.user,
    this.initialTab = 0,
  });

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildUserTile(BuildContext context, UserModel user) {
    final currentUser = context.read<AuthService>().currentUser;
    final firestoreService = context.read<FirestoreService>();

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
        child: user.photoUrl == null ? Text(user.name[0].toUpperCase()) : null,
      ),
      title: Text(user.name),
      subtitle: user.location != null ? Text(user.location!) : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: user.id),
          ),
        );
      },
      trailing: currentUser?.uid != user.id
          ? StreamBuilder<bool>(
              stream: firestoreService.isFollowing(user.id, currentUser?.uid ?? ''),
              builder: (context, snapshot) {
                final isFollowing = snapshot.data ?? false;
                return TextButton(
                  onPressed: currentUser == null
                      ? null
                      : () {
                          if (isFollowing) {
                            firestoreService.unfollowUser(
                              user.id,
                              currentUser.uid,
                            );
                          } else {
                            firestoreService.followUser(
                              user.id,
                              currentUser.uid,
                            );
                          }
                        },
                  style: TextButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.grey[200] : null,
                    foregroundColor: isFollowing ? Colors.black : null,
                  ),
                  child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                );
              },
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.name}\'s Connections'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Followers'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Followers tab
          StreamBuilder<List<UserModel>>(
            stream: firestoreService.getFollowers(widget.user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final followers = snapshot.data ?? [];
              if (followers.isEmpty) {
                return const Center(
                  child: Text('No followers yet'),
                );
              }

              return ListView.builder(
                itemCount: followers.length,
                itemBuilder: (context, index) => _buildUserTile(
                  context,
                  followers[index],
                ),
              );
            },
          ),

          // Following tab
          StreamBuilder<List<UserModel>>(
            stream: firestoreService.getFollowing(widget.user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final following = snapshot.data ?? [];
              if (following.isEmpty) {
                return const Center(
                  child: Text('Not following anyone yet'),
                );
              }

              return ListView.builder(
                itemCount: following.length,
                itemBuilder: (context, index) => _buildUserTile(
                  context,
                  following[index],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 