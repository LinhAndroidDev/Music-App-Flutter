import 'package:get/get.dart';

/// Full-screen player visibility (reliable vs modal bottom sheet on [MainPage] + IndexedStack).
class MusicPlayerCoordinator extends GetxService {
  final isOpen = false.obs;

  void show() => isOpen.value = true;

  void hide() {
    if (isOpen.value) isOpen.value = false;
  }
}
