import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../models/subscription_plan.dart';

class SubscriptionPlanCard extends StatelessWidget {
  const SubscriptionPlanCard({super.key, required this.plan});

  final SubscriptionPlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
      decoration: BoxDecoration(
        color: plan.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: plan.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                plan.brandLabel,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: plan.accentColor,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: plan.accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plan.badgeLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
              const Spacer(),
              AppIcon(AppAssets.icBack, size: 35, color: AppColors.grey1),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            plan.price,
            style: const TextStyle(
              fontSize: 18,
              height: 1.2,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            plan.note,
            style: const TextStyle(
              color: AppColors.txtHint,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < plan.features.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _FeatureColumn(
                  feature: plan.features[i],
                  accentColor: plan.accentColor,
                )),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureColumn extends StatelessWidget {
  const _FeatureColumn({
    required this.feature,
    required this.accentColor,
  });

  final SubscriptionFeature feature;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: AppIcon(feature.iconAsset, size: 25, color: accentColor),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          feature.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            height: 1.2,
            color: AppColors.grey1,
          ),
        ),
      ],
    );
  }
}
