abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> registerWithEmailAndPassword(String email, String password, String name, String? phone);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> updateUserProfile(UserModel user);
  Stream<UserModel?> get userStream;
}