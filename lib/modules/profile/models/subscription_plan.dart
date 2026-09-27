import 'package:flutter/material.dart';

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.badgeLabel,
    required this.tierName,
    required this.price,
    required this.note,
    required this.features,
    required this.accentColor,
    required this.cardBorderColor,
  });

  final String badgeLabel;
  final String tierName;
  final String price;
  final String note;
  final List<SubscriptionFeature> features;
  final Color accentColor;
  final Color cardBorderColor;
}

class SubscriptionFeature {
  const SubscriptionFeature({required this.iconAsset, required this.label});

  final String iconAsset;
  final String label;
}
