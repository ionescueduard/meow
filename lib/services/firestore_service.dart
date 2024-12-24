import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/cat_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import 'notification_service.dart';
import 'package:geolocator/geolocator.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService;

  FirestoreService(this._notificationService);

  // Users
  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!, doc.id) : null);
  }

  // Cats
  Future<void> saveCat(CatModel cat) async {
    await _db.collection('cats').doc(cat.id).set(cat.toMap());
  }

  Future<void> deleteCat(String catId) async {
    await _db.collection('cats').doc(catId).delete();
  }

  Stream<List<CatModel>> getUserCats(String userId) {
    return _db
        .collection('cats')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CatModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<CatModel?> getCat(String catId) async {
    final doc = await _db.collection('cats').doc(catId).get();
    if (!doc.exists) return null;
    return CatModel.fromMap(doc.data()!, doc.id);
  }

  Stream<List<CatModel>> searchCats({
    String? breed,
    String? gender,
    Map<String, dynamic>? location,
  }) {
    Query query = _db.collection('cats')
        .where('availableForBreeding', isEqualTo: true);

    if (breed != null) {
      query = query.where('breed', isEqualTo: breed);
    }
    if (gender != null) {
      query = query.where('gender', isEqualTo: gender);
    }

    return query.snapshots().map((snapshot) {
      final cats = snapshot.docs
          .map((doc) => CatModel.fromMap(doc.data(), doc.id))
          .toList();

      if (location != null) {
        final userLat = location['latitude'] as double;
        final userLng = location['longitude'] as double;
        final maxDistance = location['maxDistance'] as double;

        // Filter cats by distance
        return cats.where((cat) {
          if (cat.location == null) return false;

          final distance = Geolocator.distanceBetween(
            userLat,
            userLng,
            cat.location!.latitude,
            cat.location!.longitude,
          );

          // Convert distance from meters to kilometers
          return distance / 1000 <= maxDistance;
        }).toList();
      }

      return cats;
    });
  }

  // Posts
  Future<void> savePost(PostModel post) async {
    await _db.collection('posts').doc(post.id).set(post.toMap());
  }

  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }

  Stream<List<PostModel>> getFeedPosts() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<PostModel>> getUserPosts(String userId) {
    return _db
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<PostModel>> getCatPosts(String catId) {
    return _db
        .collection('posts')
        .where('catIds', arrayContains: catId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<PostModel?> getPost(String postId) async {
    final doc = await _db.collection('posts').doc(postId).get();
    if (!doc.exists) return null;
    return PostModel.fromMap(doc.data()!, doc.id);
  }

  // Comments
  Future<void> addComment(CommentModel comment) async {
    final doc = await _db.collection('comments').add(comment.toMap());
    
    // Get the post and commenter info
    final post = await getPost(comment.postId);
    final commenter = await getUser(comment.userId);
    
    if (post != null && commenter != null && post.userId != comment.userId) {
      await _notificationService.sendCommentNotification(
        userId: post.userId,
        postId: comment.postId,
        commentId: doc.id,
        commenter: commenter,
        commentText: comment.text,
      );
    }
  }

  Stream<List<CommentModel>> getPostComments(String postId) {
    return _db
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteComment(String commentId) async {
    await _db.collection('comments').doc(commentId).delete();
  }

  // Following/Followers
  Future<void> followUser(String userId, String followerId) async {
    final batch = _db.batch();

    batch.set(
      _db.collection('users').doc(userId).collection('followers').doc(followerId),
      {'timestamp': FieldValue.serverTimestamp()},
    );

    batch.set(
      _db.collection('users').doc(followerId).collection('following').doc(userId),
      {'timestamp': FieldValue.serverTimestamp()},
    );

    await batch.commit();

    // Send notification
    final follower = await getUser(followerId);
    if (follower != null) {
      await _notificationService.sendFollowNotification(
        userId: userId,
        follower: follower,
      );
    }
  }

  Future<void> unfollowUser(String userId, String followerId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('followers')
        .doc(followerId)
        .delete();

    await _db
        .collection('users')
        .doc(followerId)
        .collection('following')
        .doc(userId)
        .delete();
  }

  Stream<bool> isFollowing(String userId, String followerId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('followers')
        .doc(followerId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<List<UserModel>> getFollowers(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('followers')
        .snapshots()
        .asyncMap((snapshot) async {
      final followers = <UserModel>[];
      for (final doc in snapshot.docs) {
        final user = await getUser(doc.id);
        if (user != null) {
          followers.add(user);
        }
      }
      return followers;
    });
  }

  Stream<List<UserModel>> getFollowing(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('following')
        .snapshots()
        .asyncMap((snapshot) async {
      final following = <UserModel>[];
      for (final doc in snapshot.docs) {
        final user = await getUser(doc.id);
        if (user != null) {
          following.add(user);
        }
      }
      return following;
    });
  }

  Future<void> likePost(String postId, String userId) async {
    final post = await getPost(postId);
    if (post == null) return;

    final updatedPost = post.copyWith(
      likes: List.from(post.likes)..add(userId),
    );

    await savePost(updatedPost);

    // Send notification if the post is not by the liker
    if (post.userId != userId) {
      final liker = await getUser(userId);
      if (liker != null) {
        await _notificationService.sendLikeNotification(
          userId: post.userId,
          postId: postId,
          liker: liker,
        );
      }
    }
  }

  Future<void> unlikePost(String postId, String userId) async {
    final post = await getPost(postId);
    if (post == null) return;

    final updatedPost = post.copyWith(
      likes: List.from(post.likes)..remove(userId),
    );

    await savePost(updatedPost);
  }

  Stream<List<CatModel>> getUserCatsStream(String userId) {
    return _db
        .collection('cats')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CatModel.fromMap(doc.data(), doc.id))
            .toList());
  }
} 