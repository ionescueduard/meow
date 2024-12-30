import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/cat_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import 'notification_service.dart';
//import 'package:geolocator/geolocator.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService;

  FirestoreService(this._notificationService);

  // Users
  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  Future<bool> isUsernameAvailable(String username) async {
    final snapshot = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return snapshot.docs.isEmpty;
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? UserModel.fromMap(doc.data()!) : null;
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map(
        (doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }

  // Cats
  Future<void> saveCat(CatModel cat) async {
    // Save the cat
    await _db.collection('cats').doc(cat.id).set(cat.toMap());

    // Update user's catIds
    final userDoc = await _db.collection('users').doc(cat.ownerId).get();
    if (userDoc.exists) {
      final userData = userDoc.data()!;
      final currentCatIds = List<String>.from(userData['catIds'] ?? []);
      if (!currentCatIds.contains(cat.id)) {
        currentCatIds.add(cat.id);
        await _db.collection('users').doc(cat.ownerId).update({
          'catIds': currentCatIds,
        });
      }
    }
  }

  Future<void> deleteCat(String catId) async {
    // Get the cat to find the owner
    final catDoc = await _db.collection('cats').doc(catId).get();
    if (catDoc.exists) {
      final cat = CatModel.fromMap(catDoc.data()!);
      
      // Remove cat from user's catIds
      final userDoc = await _db.collection('users').doc(cat.ownerId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final currentCatIds = List<String>.from(userData['catIds'] ?? []);
        currentCatIds.remove(catId);
        await _db.collection('users').doc(cat.ownerId).update({
          'catIds': currentCatIds,
        });
      }
    }

    // Delete the cat
    await _db.collection('cats').doc(catId).delete();
  }

  Stream<List<CatModel>> getUserCats(String userId) {
    return _db
        .collection('cats')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CatModel.fromMap(doc.data()))
            .toList());
  }

  Future<CatModel?> getCat(String catId) async {
    final doc = await _db.collection('cats').doc(catId).get();
    if (!doc.exists) return null;
    return CatModel.fromMap(doc.data()!);
  }

  Stream<List<CatModel>> searchCats({
    CatBreed? breed,
    CatGender? gender,
    BreedingStatus? breedingStatus,
    Map<String, dynamic>? location,
  }) {
    Query query = _db.collection('cats');

    if (breed != null) {
      query = query.where('breed', isEqualTo: breed.toString().split('.').last);
    }
    if (gender != null) {
      query = query.where('gender', isEqualTo: gender.toString().split('.').last);
    }
    if (breedingStatus != null) {
      query = query.where('breedingStatus', isEqualTo: breedingStatus.toString().split('.').last);
    }

      if (location != null) {
      print('Searching by location not yet implemented');

    //import 'package:geolocator/geolocator.dart';
    // return query.snapshots().map((snapshot) {
    //   final cats = snapshot.docs
    //       .map((doc) => CatModel.fromMap(doc.data() as Map<String, dynamic>))
    //       .toList();

    //   if (location != null) {
    //     final userLat = location['latitude'] as double;
    //     final userLng = location['longitude'] as double;
    //     final maxDistance = location['maxDistance'] as double;

    //     // Filter cats by distance
    //     return cats.where((cat) {
    //       if (cat.location == null) return false;

    //       final distance = Geolocator.distanceBetween(
    //         userLat,
    //         userLng,
    //         cat.location!.latitude,
    //         cat.location!.longitude,
    //       );

    //       // Convert distance from meters to kilometers
    //       return distance / 1000 <= maxDistance;
    //     }).toList();
    //   }

    //   return cats;
    // });
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CatModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
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
            .map((doc) => PostModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<PostModel>> getUserPosts(String userId) {
    return _db
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<PostModel>> getCatPosts(String catId) {
    return _db
        .collection('posts')
        .where('catIds', arrayContains: catId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data()))
            .toList());
  }

  Future<PostModel?> getPost(String postId) async {
    final doc = await _db.collection('posts').doc(postId).get();
    if (!doc.exists) return null;
    return PostModel.fromMap(doc.data()!);
  }

  // Comments
  Future<void> addComment(CommentModel comment) async {
    // Add the comment
    final doc = await _db.collection('comments').add(comment.toMap());
    
    // Update the comment with the generated ID
    final updatedComment = CommentModel(
      id: doc.id,
      postId: comment.postId,
      userId: comment.userId,
      text: comment.text,
      createdAt: comment.createdAt,
    );
    await doc.update(updatedComment.toMap());
    
    // Get and update the post
    final post = await getPost(comment.postId);
    if (post != null) {
      post.addComment(doc.id, comment.text);
      await savePost(post);
      
      // Send notification if the commenter is not the post author
      if (post.userId != comment.userId) {
        final commenter = await getUser(comment.userId);
        if (commenter != null) {
          await _notificationService.sendCommentNotification(
            userId: post.userId,
            postId: comment.postId,
            commentId: doc.id,
            commenter: commenter,
            commentText: comment.text,
          );
        }
      }
    }
  }

  Stream<List<CommentModel>> getPostComments(String postId) {
    return _db
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> deleteComment(String commentId) async {
    await _db.collection('comments').doc(commentId).delete();
  }

  Future<void> likeComment(String commentId, String userId) async {
    final doc = await _db.collection('comments').doc(commentId).get();
    if (!doc.exists) return;

    final comment = CommentModel.fromMap(doc.data()!);
    comment.addLike(userId);
    await _db.collection('comments').doc(commentId).update(comment.toMap());

    // Send notification if the comment is not by the liker
    if (comment.userId != userId) {
      final liker = await getUser(userId);
      final post = await getPost(comment.postId);
      if (liker != null && post != null) {
        await _notificationService.sendCommentLikeNotification(
          userId: comment.userId,
          postId: comment.postId,
          commentId: commentId,
          liker: liker,
        );
      }
    }
  }

  Future<void> unlikeComment(String commentId, String userId) async {
    final doc = await _db.collection('comments').doc(commentId).get();
    if (!doc.exists) return;

    final comment = CommentModel.fromMap(doc.data()!);
    comment.removeLike(userId);
    await _db.collection('comments').doc(commentId).update(comment.toMap());
  }

  // Following/Followers
  Future<void> followUser(String userId, String followerId) async {
    final batch = _db.batch();
    
    // Get both users
    final userDoc = await _db.collection('users').doc(userId).get();
    final followerDoc = await _db.collection('users').doc(followerId).get();
    
    if (!userDoc.exists || !followerDoc.exists) return;
    
    final user = UserModel.fromMap(userDoc.data()!);
    final follower = UserModel.fromMap(followerDoc.data()!);
    
    // Update the target user's followers list
    final updatedUser = user.copyWith(
      followers: List.from(user.followers)..add(followerId),
    );
    
    // Update the follower's following list
    final updatedFollower = follower.copyWith(
      following: List.from(follower.following)..add(userId),
    );
    
    batch.set(_db.collection('users').doc(userId), updatedUser.toMap());
    batch.set(_db.collection('users').doc(followerId), updatedFollower.toMap());
    
    await batch.commit();

    // Send notification
    await _notificationService.sendFollowNotification(
      userId: userId,
      follower: follower,
    );
  }

  Future<void> unfollowUser(String userId, String followerId) async {
    final batch = _db.batch();
    
    // Get both users
    final userDoc = await _db.collection('users').doc(userId).get();
    final followerDoc = await _db.collection('users').doc(followerId).get();
    
    if (!userDoc.exists || !followerDoc.exists) return;
    
    final user = UserModel.fromMap(userDoc.data()!);
    final follower = UserModel.fromMap(followerDoc.data()!);
    
    // Update the target user's followers list
    final updatedUser = user.copyWith(
      followers: List.from(user.followers)..remove(followerId),
    );
    
    // Update the follower's following list
    final updatedFollower = follower.copyWith(
      following: List.from(follower.following)..remove(userId),
    );
    
    batch.set(_db.collection('users').doc(userId), updatedUser.toMap());
    batch.set(_db.collection('users').doc(followerId), updatedFollower.toMap());
    
    await batch.commit();
  }

  Stream<bool> isFollowing(String userId, String followerId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return false;
          final user = UserModel.fromMap(doc.data()!);
          return user.followers.contains(followerId);
        });
  }

  Stream<List<UserModel>> getFollowers(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((doc) async {
          if (!doc.exists) return [];
          final user = UserModel.fromMap(doc.data()!);
          final followers = <UserModel>[];
          for (final followerId in user.followers) {
            final follower = await getUser(followerId);
            if (follower != null) {
              followers.add(follower);
            }
          }
          return followers;
        });
  }

  Stream<List<UserModel>> getFollowing(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((doc) async {
          if (!doc.exists) return [];
          final user = UserModel.fromMap(doc.data()!);
          final following = <UserModel>[];
          for (final followingId in user.following) {
            final followedUser = await getUser(followingId);
            if (followedUser != null) {
              following.add(followedUser);
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

  // Breeding Requests
  Future<void> sendBreedingRequest({
    required String catId,
    required String requesterId,
    required String requestMessage,
    required String requesterCatId,
  }) async {
    final batch = _db.batch();
    final requestId = _db.collection('breedingRequests').doc().id;

    final request = {
      'id': requestId,
      'catId': catId,
      'requesterId': requesterId,
      'requesterCatId': requesterCatId,
      'message': requestMessage,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    batch.set(
      _db.collection('breedingRequests').doc(requestId),
      request,
    );

    await batch.commit();

    // Get cat and requester info for notification
    final cat = await getCat(catId);
    final requester = await getUser(requesterId);
    
    if (cat != null && requester != null) {
      await _notificationService.sendBreedingRequestNotification(
        userId: cat.ownerId,
        catId: catId,
        requester: requester,
      );
    }
  }

  Stream<List<Map<String, dynamic>>> getBreedingRequests(String userId) {
    return _db
        .collection('breedingRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snapshot) async {
      final requests = <Map<String, dynamic>>[];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final cat = await getCat(data['catId']);
        final requester = await getUser(data['requesterId']);
        final requesterCat = await getCat(data['requesterCatId']);
        
        if (cat != null && requester != null && requesterCat != null) {
          if (cat.ownerId == userId || data['requesterId'] == userId) {
            requests.add({
              ...data,
              'cat': cat,
              'requester': requester,
              'requesterCat': requesterCat,
            });
          }
        }
      }
      
      return requests;
    });
  }

  Future<void> updateBreedingRequestStatus(String requestId, String status) async {
    await _db.collection('breedingRequests').doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> reportPost({ // handle these better in the future
    required String postId,
    required String userId,
    required String reason,
  }) async {
    final reportId = _db.collection('reports').doc().id;

    final report = {
      'id': reportId,
      'postId': postId,
      'userId': userId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _db.collection('reports').doc(reportId).set(report);
  }
} 