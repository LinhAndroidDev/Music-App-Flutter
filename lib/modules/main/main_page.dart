import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/l10n/l10n.dart';
import '../../core/navigation/app_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_bottom_bar.dart';
import '../library/library_page.dart';
import '../profile/profile_page.dart';
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
            _TabPlaceholder(tab: AppTab.discover),
            _TabPlaceholder(tab: AppTab.zingChart),
            _TabPlaceholder(tab: AppTab.radio),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: CustomBottomBar(
          currentTab: controller.currentTab.value,
          onTabSelected: controller.selectTab,
          profilePhotoUrl: controller.profilePhotoUrl.value,
        ),
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.tab});

  final int tab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = switch (tab) {
      AppTab.discover => l10n.nav_discover,
      AppTab.zingChart => l10n.nav_zingchart,
      AppTab.radio => l10n.nav_radio,
      _ => '',
    };
    return SafeArea(
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
