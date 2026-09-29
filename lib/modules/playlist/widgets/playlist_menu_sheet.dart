import 'package:flutter/material.dart';

import '../../../core/navigation/navigator_after_frame.dart';
import '../../../core/assets/app_assets.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';

class PlaylistMenuSheet extends StatelessWidget {
  const PlaylistMenuSheet({
    super.key,
    required this.onAddSongs,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onAddSongs;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onAddSongs,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return runNavigatorActionAfterFrame(() {
      if (!context.mounted) return null;
      return showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => PlaylistMenuSheet(
          onAddSongs: () => _popThen(ctx, onAddSongs),
          onEdit: () => _popThen(ctx, onEdit),
          onDelete: () => _popThen(ctx, onDelete),
        ),
      );
    });
  }

  static void _popThen(BuildContext sheetContext, VoidCallback next) {
    runNavigatorActionAfterFrame(() {
      if (sheetContext.mounted) {
        Navigator.pop(sheetContext);
      }
      next();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              l10n.playlist_section_title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
          ),
          const Divider(height: 0.8, thickness: 0.8, color: AppColors.greyLight, indent: 20, endIndent: 20),
          _MenuRow(
            icon: AppAssets.icAddPlaylist,
            label: l10n.playlist_menu_add,
            onTap: onAddSongs,
          ),
          _MenuRow(
            icon: AppAssets.icSetting,
            label: l10n.playlist_menu_edit,
            onTap: onEdit,
          ),
          _MenuRow(
            icon: AppAssets.icRemove,
            label: l10n.playlist_menu_delete,
            onTap: onDelete,
            bottomPadding: 24,
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.bottomPadding = 0,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPadding),
        child: Row(
          children: [
            AppIcon(icon, size: 25, color: AppColors.black),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: AppColors.textBlack),
            ),
          ],
        ),
      ),
    );
  }
}
