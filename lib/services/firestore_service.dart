import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/cat_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
    return _db.collection('users').doc(userId).snapshots().map(
        (doc) => doc.exists ? UserModel.fromMap(doc.data()!, doc.id) : null);
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
    bool? availableForBreeding,
  }) {
    Query query = _db.collection('cats');

    if (breed != null) {
      query = query.where('breed', isEqualTo: breed);
    }
    if (gender != null) {
      query = query.where('gender', isEqualTo: gender);
    }
    if (availableForBreeding != null) {
      query = query.where('availableForBreeding', isEqualTo: availableForBreeding);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CatModel.fromMap(doc.data(), doc.id))
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
    await _db.collection('comments').add(comment.toMap());
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
    await _db
        .collection('users')
        .doc(userId)
        .collection('followers')
        .doc(followerId)
        .set({'timestamp': FieldValue.serverTimestamp()});

    await _db
        .collection('users')
        .doc(followerId)
        .collection('following')
        .doc(userId)
        .set({'timestamp': FieldValue.serverTimestamp()});
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
} 