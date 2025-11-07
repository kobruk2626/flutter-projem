import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_momento/domain/repositories/auth_repository.dart';
import 'package:photo_momento/data/models/user_model.dart';
import 'package:photo_momento/core/exceptions/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserData(firebaseUser.uid);
    });
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return await _getUserData(firebaseUser.uid);
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = await _getUserData(userCredential.user!.uid);
      await _updateLastLogin(user.id);

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e));
    } catch (e) {
      throw AuthException('Giriş yapılırken bir hata oluştu: $e');
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword(
      String email, String password, String name, String? phone) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        role: UserRole.customer,
        addresses: [],
        paymentMethods: [],
      );

      await _firestore.collection('users').doc(user.id).set(user.toFirestore());

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e));
    } catch (e) {
      throw AuthException('Kayıt olurken bir hata oluştu: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Çıkış yapılırken bir hata oluştu: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e));
    } catch (e) {
      throw AuthException('Şifre sıfırlama işlemi sırasında bir hata oluştu: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toFirestore());
    } catch (e) {
      throw AuthException('Profil güncellenirken hata oluştu: $e');
    }
  }

  Future<UserModel> _getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw AuthException('Kullanıcı bulunamadı');
      }
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw AuthException('Kullanıcı verileri alınırken hata oluştu: $e');
    }
  }

  Future<void> _updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLogin': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      // Last login güncelleme hatası kritik değil, sessizce geç
      print('Last login güncellenirken hata: $e');
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Yanlış şifre';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor';
      case 'weak-password':
        return 'Şifre en az 6 karakter olmalıdır';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'network-request-failed':
        return 'İnternet bağlantısı yok';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış';
      case 'too-many-requests':
        return 'Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda etkin değil';
      default:
        return 'Bir hata oluştu: ${e.message}';
    }
  }
}