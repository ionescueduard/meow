import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/cat_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/breeding_request_model.dart';
import 'notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:geolocator/geolocator.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
    double? minAge,
    double? maxAge,
    Map<String, dynamic>? location,
  }) {
    Query query = _db.collection('cats');

    if (breed != null) {
      query = query.where('breed', isEqualTo: breed.toString());
    }

    if (gender != null) {
      query = query.where('gender', isEqualTo: gender.toString());
    }

    if (breedingStatus != null) {
      query = query.where('breedingStatus', isEqualTo: breedingStatus.toString());
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

    return query.snapshots().map((snapshot) {
      final cats = snapshot.docs
          .map((doc) => CatModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      if (minAge != null || maxAge != null) {
        final now = DateTime.now();
        return cats.where((cat) {
          final ageInYears = (now.difference(cat.birthDate).inDays / 365);
          return (minAge == null || ageInYears >= minAge) &&
              (maxAge == null || ageInYears <= maxAge);
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
  Future<void> addComment(String postId, String text, {String? parentId}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _db.batch();
    final commentRef = _db.collection('comments').doc();
    final comment = CommentModel(
      id: commentRef.id,
      postId: postId,
      userId: user.uid,
      text: text,
      createdAt: DateTime.now(),
      parentId: parentId,
    );

    // Add the new comment
    batch.set(commentRef, comment.toMap());

    // Update post's comment count using FieldValue
    final postRef = _db.collection('posts').doc(postId);
    batch.update(postRef, {
      'commentsCount': FieldValue.increment(1),
    });

    // If this is a reply, update parent comment's reply count
    if (parentId != null) {
      final parentCommentRef = _db.collection('comments').doc(parentId);
      final parentDoc = await parentCommentRef.get();
      if (parentDoc.exists) {
        final parentComment = CommentModel.fromMap(parentDoc.data()!);
        final updatedParentComment = parentComment.copyWith(
          replyCount: parentComment.replyCount + 1,
        );
        batch.set(parentCommentRef, updatedParentComment.toMap());
      }
    }

    // Commit all changes
    await batch.commit();

    // Send notification
    final post = await getPost(postId);
    if (post != null && post.userId != user.uid) {
      final commenter = await getUser(user.uid);
      if (commenter != null) {
        await _notificationService.sendCommentNotification(
          userId: post.userId,
          postId: postId,
          commentId: commentRef.id,
          commenter: commenter,
          commentText: text,
        );
      }
    }
  }

  Stream<List<CommentModel>> getPostComments(String postId) {
    return _db
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .where('parentId', isNull: true) // Only get top-level comments
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<CommentModel>> getCommentReplies(String commentId) {
    print('Fetching replies for comment: $commentId'); // Debug print
    return _db
        .collection('comments')
        .where('parentId', isEqualTo: commentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('Found ${snapshot.docs.length} replies'); // Debug print
          return snapshot.docs
              .map((doc) => CommentModel.fromMap(doc.data()))
              .toList();
        });
  }

  Future<void> deleteComment(String commentId) async {
    await _db.collection('comments').doc(commentId).delete();
  }

  Future<void> likeComment(String commentId, bool like) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final commentRef = _db.collection('comments').doc(commentId);
    final doc = await commentRef.get();
    if (!doc.exists) return;

    final comment = CommentModel.fromMap(doc.data()!);
    if (like) {
      comment.addLike(user.uid);
    } else {
      comment.removeLike(user.uid);
    }
    await commentRef.update({'likes': comment.likes});

    if (like) {
      if (comment.userId != user.uid) {
        final liker = await getUser(user.uid);
        if (liker != null) {
          await _notificationService.sendCommentLikeNotification(
            userId: comment.userId,
            postId: comment.postId,
            commentId: commentId,
            liker: liker,
          );
        }
      }
    }
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
    final cat = await getCat(catId);
    if (cat == null) return;

    final request = BreedingRequest(
      id: _db.collection('breedingRequests').doc().id,
      catId: catId,
      requesterId: requesterId,
      requesterCatId: requesterCatId,
      receiverId: cat.ownerId,
      message: requestMessage,
      status: 'pending',
      seen: false,
      createdAt: DateTime.now(),
    );

    await createBreedingRequest(request);

    // Send notification
    final requester = await getUser(requesterId);
    if (requester != null) {
      await _notificationService.sendBreedingRequestNotification(
        userId: cat.ownerId,
        catId: catId,
        requester: requester,
      );
    }
  }

  Future<void> createBreedingRequest(BreedingRequest request) async {
    final doc = _db.collection('breedingRequests').doc(request.id);
    final data = request.copyWith(
      status: 'pending',
      seen: false,
    ).toMap();
    await doc.set(data);
  }

  Future<void> updateBreedingRequestStatus(String requestId, String status) async {
    await _db.collection('breedingRequests').doc(requestId).update({
      'status': status,
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

  // Breeding Requests
  Stream<List<BreedingRequest>> getReceivedBreedingRequests(String userId) async* {
    final catIds = await _getCatIds(userId);
    if (catIds.isEmpty) {
      yield [];
      return;
    }

    yield* _db
        .collection('breedingRequests')
        .where('catId', whereIn: catIds)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BreedingRequest.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<BreedingRequest>> getSentBreedingRequests(String userId) {
    return _db
        .collection('breedingRequests')
        .where('requesterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BreedingRequest.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<String>> _getCatIds(String userId) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    if (!userDoc.exists) return [];
    final userData = userDoc.data()!;
    return List<String>.from(userData['catIds'] ?? []);
  }

  Future<CommentModel?> getComment(String commentId) async {
    final doc = await _db.collection('comments').doc(commentId).get();
    if (!doc.exists) return null;
    return CommentModel.fromMap(doc.data()! as Map<String, dynamic>);
  }

  // Add this method to track unseen requests
  Stream<int> getUnseenBreedingRequestsCount(String userId) {
    return _db
        .collection('breedingRequests')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .where('seen', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Add this method to mark a single request as seen
  Future<void> markBreedingRequestAsSeen(String requestId) async {
    await _db
        .collection('breedingRequests')
        .doc(requestId)
        .update({'seen': true});
  }
} 