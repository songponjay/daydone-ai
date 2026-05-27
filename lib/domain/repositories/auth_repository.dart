

import 'package:daydone_ai/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});
  
  Future<void> signOut();
  Stream<AppUser?> get authStateChanges;

  Future<AppUser?> getCurrentUser();
  /*Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
  });*/
}