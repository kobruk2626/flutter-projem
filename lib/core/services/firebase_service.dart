import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  static late FirebaseApp app;
  static late FirebaseAuth auth;
  static late FirebaseFirestore firestore;
  static late FirebaseStorage storage;
  static late FirebaseMessaging messaging;

  static Future<void> initialize() async {
    app = await Firebase.initializeApp();
    auth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;
    messaging = FirebaseMessaging.instance;

    // Configure settings
    await _configureFirestore();
    await _configureMessaging();
  }

  static Future<void> _configureFirestore() async {
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  static Future<void> _configureMessaging() async {
    await messaging.requestPermission();
    final token = await messaging.getToken();
    print('FCM Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
    });

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Background message: ${message.notification?.title}');
  }

  // Storage methods for photo uploads
  static Future<String> uploadPhoto({
    required String userId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final Reference storageRef = storage
          .ref()
          .child('user_photos')
          .child(userId)
          .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final UploadTask uploadTask = storageRef.putFile(File(filePath));
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Fotoğraf yükleme başarısız: $e');
    }
  }

  static Future<void> deletePhoto(String imageUrl) async {
    try {
      final Reference storageRef = storage.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      throw Exception('Fotoğraf silme başarısız: $e');
    }
  }

  static Future<List<String>> uploadMultiplePhotos({
    required String userId,
    required List<String> filePaths,
  }) async {
    final List<String> imageUrls = [];

    for (final filePath in filePaths) {
      final fileName = filePath.split('/').last;
      final imageUrl = await uploadPhoto(
        userId: userId,
        filePath: filePath,
        fileName: fileName,
      );
      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }

  // Get current user ID
  static String? get currentUserId {
    return auth.currentUser?.uid;
  }

  // Check if user is logged in
  static bool get isLoggedIn {
    return auth.currentUser != null;
  }

  // Get current user email
  static String? get currentUserEmail {
    return auth.currentUser?.email;
  }

  // Sign out user
  static Future<void> signOut() async {
    await auth.signOut();
  }

  // Get user document reference
  static DocumentReference getUserDocument(String userId) {
    return firestore.collection('users').doc(userId);
  }

  // Get products collection reference
  static CollectionReference get productsCollection {
    return firestore.collection('products');
  }

  // Get orders collection reference
  static CollectionReference get ordersCollection {
    return firestore.collection('orders');
  }

  // Get user orders query
  static Query getUserOrdersQuery(String userId) {
    return ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);
  }

  // Get all orders query (for admin)
  static Query getAllOrdersQuery({String? status}) {
    Query query = ordersCollection.orderBy('createdAt', descending: true);
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query;
  }
}