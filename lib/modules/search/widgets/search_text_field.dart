import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';

/// ServiceMusic [CustomSearchView] — pill field with search icon, clear, IME search.
class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final showClear = controller.text.isNotEmpty;
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
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  style: const TextStyle(fontSize: 14, color: AppColors.textBlack),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: hintText,
                    hintStyle: const TextStyle(fontSize: 14, color: AppColors.txtHint),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textInputAction: TextInputAction.search,
                ),
              ),
              if (showClear)
                InkWell(
                  onTap: onClear,
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
      },
    );
  }
}
