import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/l10n/l10n.dart';

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
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.playlist_create_title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(hintText: l10n.playlist_name_hint),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.playlist_public_label),
            value: _isPublic,
            onChanged: (v) => setState(() => _isPublic = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text(l10n.playlist_cancel),
        ),
        TextButton(
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isEmpty) {
              Get.snackbar('', l10n.playlist_name_required);
              return;
            }
            Get.back(
              result: CreatePlaylistResult(title: title, isPublic: _isPublic),
            );
          },
          child: Text(l10n.playlist_create_confirm),
        ),
      ],
    );
  }
}
