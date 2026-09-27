import 'package:flutter/material.dart';

import '../assets/app_assets.dart';
import '../l10n/l10n.dart';
import '../navigation/app_route.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.profilePhotoUrl,
  });

  final int currentTab;
  final ValueChanged<int> onTabSelected;
  final String? profilePhotoUrl;

  static const _iconSize = 25.0;
  static const _labelSize = 10.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <_BottomItem>[
      _BottomItem(AppTab.library, AppAssets.icLibraryMusic, l10n.nav_library),
      _BottomItem(AppTab.discover, AppAssets.icDiscover, l10n.nav_discover),
      _BottomItem(AppTab.zingChart, AppAssets.icZingChart, l10n.nav_zingchart),
      _BottomItem(AppTab.radio, AppAssets.icRadio, l10n.nav_radio),
      _BottomItem(AppTab.profile, AppAssets.icProfile, l10n.nav_profile),
    ];

    return Material(
      color: AppColors.white,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 0.5, color: const Color(0xFFE8E8E8)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: items.map((item) {
                  final selected = currentTab == item.tab;
                  final color =
                      selected ? AppColors.bgPurple : AppColors.txtHint;
                  return Expanded(
                    child: InkWell(
                      onTap: () => onTabSelected(item.tab),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.tab == AppTab.profile &&
                              profilePhotoUrl != null &&
                              profilePhotoUrl!.isNotEmpty)
                            CircleAvatar(
                              radius: _iconSize / 2,
                              backgroundImage: NetworkImage(profilePhotoUrl!),
                            )
                          else
                            AppIcon(
                              item.icon,
                              size: _iconSize,
                              color: color,
                            ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: _labelSize,
                              color: color,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomItem {
  const _BottomItem(this.tab, this.icon, this.label);

  final int tab;
  final String icon;
  final String label;
}
