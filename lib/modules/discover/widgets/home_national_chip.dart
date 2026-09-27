import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomeNationalChip extends StatelessWidget {
  const HomeNationalChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
            decoration: BoxDecoration(
              color: selected ? AppColors.purple1 : AppColors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: selected ? AppColors.purple1 : AppColors.grey1,
                width: 0.8,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? AppColors.textWhite : AppColors.textBlack,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
