import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/cat_model.dart';
import '../models/post_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists ? UserModel.fromMap(doc.data()!) : null;
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  // Cat operations
  Future<void> createCat(CatModel cat) async {
    await _firestore.collection('cats').doc(cat.id).set(cat.toMap());
  }

  Future<CatModel?> getCat(String catId) async {
    final doc = await _firestore.collection('cats').doc(catId).get();
    return doc.exists ? CatModel.fromMap(doc.data()!) : null;
  }

  Stream<CatModel?> getCatStream(String catId) {
    return _firestore
        .collection('cats')
        .doc(catId)
        .snapshots()
        .map((doc) => doc.exists ? CatModel.fromMap(doc.data()!) : null);
  }

  Future<List<CatModel>> getUserCats(String userId) async {
    final snapshot = await _firestore
        .collection('cats')
        .where('ownerId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => CatModel.fromMap(doc.data())).toList();
  }

  Stream<List<CatModel>> getUserCatsStream(String userId) {
    return _firestore
        .collection('cats')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CatModel.fromMap(doc.data())).toList());
  }

  Future<void> updateCat(CatModel cat) async {
    await _firestore.collection('cats').doc(cat.id).update(cat.toMap());
  }

  Future<void> deleteCat(String catId) async {
    await _firestore.collection('cats').doc(catId).delete();
  }

  // Post operations
  Future<void> createPost(PostModel post) async {
    await _firestore.collection('posts').doc(post.id).set(post.toMap());
  }

  Future<PostModel?> getPost(String postId) async {
    final doc = await _firestore.collection('posts').doc(postId).get();
    return doc.exists ? PostModel.fromMap(doc.data()!) : null;
  }

  Stream<PostModel?> getPostStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .map((doc) => doc.exists ? PostModel.fromMap(doc.data()!) : null);
  }

  Stream<List<PostModel>> getFeedPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList());
  }

  Stream<List<PostModel>> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList());
  }

  Future<void> updatePost(PostModel post) async {
    await _firestore.collection('posts').doc(post.id).update(post.toMap());
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  // Breeding-related operations
  Stream<List<CatModel>> getAvailableBreedingCats() {
    return _firestore
        .collection('cats')
        .where('breedingStatus', isEqualTo: 'available')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CatModel.fromMap(doc.data())).toList());
  }

  Future<List<CatModel>> searchBreedingCats({
    String? breed,
    CatGender? gender,
    String? location,
  }) async {
    Query query = _firestore
        .collection('cats')
        .where('breedingStatus', isEqualTo: 'available');

    if (breed != null) {
      query = query.where('breed', isEqualTo: breed);
    }
    if (gender != null) {
      query = query.where('gender', isEqualTo: gender.toString().split('.').last);
    }
    // Note: Location-based queries would require a more sophisticated approach,
    // possibly using a geolocation service

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => CatModel.fromMap(doc.data())).toList();
  }
} 