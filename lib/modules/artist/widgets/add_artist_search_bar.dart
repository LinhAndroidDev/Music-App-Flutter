import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';

/// Matches ServiceMusic [custom_search_view.xml] (pill grey background).
class AddArtistSearchBar extends StatefulWidget {
  const AddArtistSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  State<AddArtistSearchBar> createState() => _AddArtistSearchBarState();
}

class _AddArtistSearchBarState extends State<AddArtistSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final showClear = _controller.text.isNotEmpty;
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(45),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, right: 5),
            child: AppIcon(AppAssets.icSearchThin, size: 20, color: AppColors.txtHint),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (v) {
                widget.onChanged(v);
                setState(() {});
              },
              style: const TextStyle(fontSize: 14, color: AppColors.textBlack),
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hintText,
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.txtHint),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          if (showClear)
            InkWell(
              onTap: _clear,
              child: const Padding(
                padding: EdgeInsets.only(right: 10, left: 4),
                child: AppIcon(AppAssets.icRemove, size: 20, color: AppColors.txtHint),
              ),
            )
          else
            const SizedBox(width: 10),
        ],
      ),
    );
  }
}
