import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../discover/discover_page.dart';
import '../library/library_page.dart';
import '../profile/profile_page.dart';
import '../zing_chart/zing_chart_page.dart';
import 'main_controller.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: controller.currentTab.value,
          children: const [
            LibraryPage(),
            DiscoverPage(),
            ZingChartPage(),
            ProfilePage(),
          ],
        ),
      ),
    );
  }
}
