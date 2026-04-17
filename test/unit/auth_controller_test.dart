import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:technical_test/data/repositories/auth_repository_impl.dart';
import 'package:technical_test/presentation/auth/auth_controller.dart';

import 'auth_controller_test.mocks.dart';

@GenerateMocks([AuthRepositoryImpl])
void main() {
  late AuthController controller;
  late MockAuthRepositoryImpl mockRepo;

  setUp(() {
    mockRepo = MockAuthRepositoryImpl();
    controller = AuthController(mockRepo);
    Get.testMode = true;
  });

  tearDown(() => Get.reset());

  group('AuthController', () {
    test('isLoading awalnya false', () {
      expect(controller.isLoading.value, false);
    });

    test('errorMessage awalnya kosong', () {
      expect(controller.errorMessage.value, isEmpty);
    });

    test('signInAsGuest berhasil — isLoading jadi true lalu false', () async {
      when(mockRepo.signInAsGuest()).thenAnswer((_) async => null);

      final future = controller.signInAsGuest();
      expect(controller.isLoadingAnn.value, true);

      await future;
      expect(controller.isLoadingAnn.value, false);
    });

    test('signInAsGuest gagal — errorMessage terisi', () async {
      when(mockRepo.signInAsGuest()).thenThrow(Exception('Firebase error'));

      await controller.signInAsGuest();

      expect(controller.errorMessageAnn.value, isNotEmpty);
      expect(controller.isLoadingAnn.value, false);
    });
  });
}
