import 'package:get/get.dart';
import 'package:technical_test/data/datasources/remote/auth_remote_datasource.dart';
import 'package:technical_test/data/repositories/auth_repository_impl.dart';
import 'package:technical_test/presentation/auth/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(),
      fenix: true,
    );
    Get.lazyPut(
      () => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut(
      () => AuthController(Get.find<AuthRepositoryImpl>()),
      fenix: true,
    );
  }
}
