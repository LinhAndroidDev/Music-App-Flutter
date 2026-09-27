import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/l10n/l10n.dart';
import '../../core/navigation/app_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_bottom_bar.dart';
import 'main_controller.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  static const _tabs = [
    AppTab.library,
    AppTab.discover,
    AppTab.zingChart,
    AppTab.radio,
    AppTab.profile,
  ];

  String _tabLabel(BuildContext context, int tab) {
    final l10n = context.l10n;
    return switch (tab) {
      AppTab.library => l10n.nav_library,
      AppTab.discover => l10n.nav_discover,
      AppTab.zingChart => l10n.nav_zingchart,
      AppTab.radio => l10n.nav_radio,
      AppTab.profile => l10n.nav_profile,
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: controller.currentTab.value,
          children: _tabs
              .map(
                (tab) => _TabPlaceholder(label: _tabLabel(context, tab)),
              )
              .toList(),
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
  const _TabPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
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
