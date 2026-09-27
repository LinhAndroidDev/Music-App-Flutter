import 'package:flutter/material.dart';

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.brandLabel,
    required this.badgeLabel,
    required this.price,
    required this.note,
    required this.features,
    required this.accentColor,
    required this.cardBackground,
    required this.cardBorder,
  });

  final String brandLabel;
  final String badgeLabel;
  final String price;
  final String note;
  final List<SubscriptionFeature> features;
  final Color accentColor;
  final Color cardBackground;
  final Color cardBorder;
}

class SubscriptionFeature {
  const SubscriptionFeature({required this.iconAsset, required this.label});

  final String iconAsset;
  final String label;
}
