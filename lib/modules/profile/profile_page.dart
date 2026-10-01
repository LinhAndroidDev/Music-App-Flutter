import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/assets/app_assets.dart';
import '../../core/l10n/l10n.dart';
import '../../core/navigation/app_navigate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/screen_header.dart';
import '../player/app_player_shell.dart';
import '../../data/models/auth_user.dart';
import 'models/subscription_plan.dart';
import 'profile_controller.dart';
import 'widgets/subscription_plan_card.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plans = _buildPlans(l10n);

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: AppPlayerShell.scrollBottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ScreenHeader(
                  title: l10n.nav_profile,
                  showProfileActions: true,
                  showMicrophone: false,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Obx(() => _AccountCard(
                      user: controller.auth.currentUser.value,
                      isLoading: controller.isLoading.value,
                      onAuth: controller.onAuthButtonPressed,
                    )),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  children: [
                    Text(
                      l10n.profile_upgrade_account,
                      style: _sectionTitle,
                    ),
                    Transform.rotate(
                      angle: -math.pi / 2,
                      child: const AppIcon(
                        AppAssets.icBack,
                        size: 35,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, _) {
                  final cardWidth = MediaQuery.sizeOf(context).width * 0.8;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < plans.length; i++) ...[
                          if (i > 0) const SizedBox(width: 15),
                          SizedBox(
                            width: cardWidth,
                            child: SubscriptionPlanCard(plan: plans[i]),
                          ),
                        ],
                        const SizedBox(width: 15),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(l10n.profile_premium_experience, style: _sectionTitle),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(child: _premiumTile(
                      icon: AppAssets.icSound,
                      iconBg: AppColors.blueLight,
                      iconColor: AppColors.blue,
                      label: l10n.profile_lossless,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _premiumTile(
                      icon: AppAssets.icChange,
                      iconBg: AppColors.pinkLight,
                      iconColor: AppColors.bgPink,
                      label: l10n.profile_crossfade,
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(l10n.profile_services_section, style: _sectionTitle),
              ),
              _profileRow(AppAssets.icInternet, l10n.profile_save_data),
              _profileRow(AppAssets.icEnterCode, l10n.profile_enter_code),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(l10n.nav_profile, style: _sectionTitle),
              ),
              _profileRow(
                AppAssets.icPersonChecked,
                l10n.profile_following_list,
                onTap: () => AppNavigate.toFollowedSingers(),
              ),
              _profileRow(AppAssets.icBlock, l10n.profile_block_list),
              _profileRow(AppAssets.icTemporary, l10n.profile_hidden_list),
            ],
          ),
        ),
      ),
    );
  }

  static const _sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  List<SubscriptionPlan> _buildPlans(dynamic l10n) {
    return [
      SubscriptionPlan(
        brandLabel: l10n.preview_plus_brand,
        badgeLabel: l10n.subscription_plus_name,
        price: l10n.subscription_plus_price,
        note: l10n.preview_plus_tagline,
        accentColor: AppColors.purple1,
        cardBackground: AppColors.subscriptionPlusFill,
        cardBorder: AppColors.subscriptionPlusStroke,
        features: [
          SubscriptionFeature(
            iconAsset: AppAssets.icAdvertisement,
            label: l10n.preview_plus_no_ads,
          ),
          SubscriptionFeature(
            iconAsset: AppAssets.icDownloadThin,
            label: l10n.preview_plus_storage,
          ),
          SubscriptionFeature(
            iconAsset: AppAssets.icCustom,
            label: l10n.preview_plus_playback,
          ),
        ],
      ),
      SubscriptionPlan(
        brandLabel: l10n.preview_plus_brand,
        badgeLabel: l10n.subscription_premium_name,
        price: l10n.subscription_premium_price,
        note: l10n.subscription_premium_tagline,
        accentColor: AppColors.bgOrange,
        cardBackground: AppColors.subscriptionPremiumFill,
        cardBorder: AppColors.subscriptionPremiumStroke,
        features: [
          SubscriptionFeature(
            iconAsset: AppAssets.icDiamond,
            label: l10n.subscription_premium_feature_all,
          ),
          SubscriptionFeature(
            iconAsset: AppAssets.icAdvertisement,
            label: l10n.preview_plus_no_ads,
          ),
          SubscriptionFeature(
            iconAsset: AppAssets.icDownloadThin,
            label: l10n.preview_plus_storage,
          ),
        ],
      ),
    ];
  }

  Widget _premiumTile({
    required String icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      decoration: AppDecorations.whiteCard10(),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(5),
            child: AppIcon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(label),
        ],
      ),
    );
  }

  Widget _profileRow(String icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppIcon(icon, size: 25, color: AppColors.black),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.textBlack),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.user,
    required this.isLoading,
    required this.onAuth,
  });

  final AuthUser? user;
  final bool isLoading;
  final VoidCallback onAuth;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final signedIn = user != null;

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: isLoading ? 0.55 : 1,
          child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: AppDecorations.whiteCard10(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.greyLight,
                backgroundImage: signedIn && user!.photoUrl != null
                    ? CachedNetworkImageProvider(user!.photoUrl!)
                    : null,
                child: signedIn && user!.photoUrl != null
                    ? null
                    : AppIcon(
                        AppAssets.icProfile,
                        size: 40,
                        color: AppColors.txtHint,
                      ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      signedIn
                          ? (user!.displayName.isNotEmpty
                              ? user!.displayName
                              : l10n.profile_user_fallback)
                          : l10n.profile_signed_out_title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      signedIn
                          ? user!.email
                          : l10n.profile_signed_out_subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.grey1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: isLoading ? null : onAuth,
                      child: Text(
                        signedIn
                            ? l10n.profile_sign_out
                            : l10n.profile_sign_in_google,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
        if (isLoading)
          const Positioned(child: CircularProgressIndicator()),
      ],
    );
  }
}
