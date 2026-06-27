import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Auth repository provider.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Stream of Firebase auth state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

/// Current user model.
final currentUserProvider = Provider<UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.currentUserModel;
});

/// Whether user is signed in.
final isSignedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(data: (user) => user != null) ?? false;
});
