import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/service_music_dialog.dart';

class CreatePlaylistResult {
  const CreatePlaylistResult({required this.title, required this.isPublic});

  final String title;
  final bool isPublic;
}

class CreatePlaylistDialog extends StatefulWidget {
  const CreatePlaylistDialog({super.key});

  @override
  State<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  final _titleController = TextEditingController();
  var _isPublic = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  final _focusNode = FocusNode();

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      showAppToast(l10n.playlist_name_required, category: AppToastCategory.playlist);
      return;
    }
    Get.back(result: CreatePlaylistResult(title: title, isPublic: _isPublic));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ServiceMusicDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ServiceMusicDialogTitle(l10n.playlist_create_title),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: TextField(
              controller: _titleController,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 16, color: AppColors.textBlack),
              decoration: InputDecoration(
                hintText: l10n.playlist_name_hint,
                hintStyle: const TextStyle(fontSize: 16, color: AppColors.txtHint),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.greyLight, width: 0.8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.greyLight, width: 0.8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.playlist_public_label,
                    style: const TextStyle(fontSize: 16, color: AppColors.textBlack),
                  ),
                ),
                Switch(
                  value: _isPublic,
                  activeColor: AppColors.purple1,
                  onChanged: (v) => setState(() => _isPublic = v),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ServiceMusicDialogPrimaryButton(
              label: l10n.playlist_create_confirm,
              onTap: _submit,
            ),
          ),
          ServiceMusicDialogCancelButton(
            label: l10n.playlist_cancel,
            onTap: Get.back,
          ),
        ],
      ),
    );
  }
}
