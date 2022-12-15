import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smartgolfportal/router.dart';
import 'package:smartgolfportal/services/db_service.dart';

import '../state/user/models/user.model.dart' as user_model;

final DBService _dbService = DBService();
final AuthService _authService = AuthService();

final authStateChangesProvider =
    StreamProvider<User?>((ref) => _authService.userStateChange());

final userStateProvider =
    StateNotifierProvider<AuthService, user_model.User>((ref) => AuthService());

class AuthService extends StateNotifier<user_model.User> {
  AuthService() : super(user_model.User());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> userStateChange() {
    return _auth.authStateChanges();
  }

  void initUser(User user) async {
    user_model.User? currentUser = await _dbService.fetchUser(user.uid);
    if (currentUser == null || currentUser.id == null) {
      _authService.signOut();
    } else {
      state = currentUser;
    }
  }

  Future<bool> signIn(
      {required String username, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: username, password: password);

      if (userCredential.user?.uid != null) {
        user_model.User? retrievedUser =
            await _dbService.fetchUser(userCredential.user!.uid);
        if (retrievedUser != null &&
            (retrievedUser.type == "Admin" || retrievedUser.type == "admin")) {
          state = retrievedUser;
          return Future.value(true);
        } else {
          throw Exception("You are not an admin!");
        }
      } else {
        throw Exception("You are not an admin!");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'invalid-email') {
        throw Exception('This is an invalid email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      } else {
        throw Exception('Something went wrong.');
      }
    }
  }

  Future signOut() async {
    Get.offNamed(AppRoutes.loginScreen);
    return await _auth.signOut();
  }
}
