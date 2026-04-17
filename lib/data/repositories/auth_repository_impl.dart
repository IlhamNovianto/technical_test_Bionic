import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<User?> signInWithGoogle() => _remoteDataSource.signInWithGoogle();

  @override
  Future<User?> signInAsGuest() => _remoteDataSource.signInAsGuest();

  @override
  Future<void> signOut() => _remoteDataSource.signOut();

  @override
  User? getCurrentUser() => _remoteDataSource.getCurrentUser();
}
