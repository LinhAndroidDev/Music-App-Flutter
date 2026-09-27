import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../models/home_topic.dart';

class HomeTopicTile extends StatelessWidget {
  const HomeTopicTile({
    super.key,
    required this.topic,
    required this.onTap,
  });

  final HomeTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: topic.backgroundColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (topic.iconAsset != null)
                AppIcon(topic.iconAsset!, size: 25, color: AppColors.white),
              const SizedBox(height: 15),
              Text(
                topic.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
