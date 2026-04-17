import 'package:technical_test/data/database/dao/user_dao.dart';
import 'package:technical_test/data/models/user_model.dart';

abstract class UserLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser(String uid);
  Future<UserModel?> getLastLoggedInUser();
  Future<void> deleteUser(String uid);
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final UserDao _userDao;
  UserLocalDataSourceImpl(this._userDao);

  @override
  Future<void> saveUser(UserModel user) => _userDao.insertOrUpdate(user);

  @override
  Future<UserModel?> getUser(String uid) => _userDao.getUser(uid);

  @override
  Future<UserModel?> getLastLoggedInUser() => _userDao.getLastLoggedInUser();

  @override
  Future<void> deleteUser(String uid) => _userDao.deleteUser(uid);
}
