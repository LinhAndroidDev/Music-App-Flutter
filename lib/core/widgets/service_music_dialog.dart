import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// White rounded card used by ServiceMusic [layout_dialog_confirm] / [layout_dialog_create_playlist].
class ServiceMusicDialog extends StatelessWidget {
  const ServiceMusicDialog({
    super.key,
    required this.child,
  });

  final Widget child;

  static Future<T?> show<T>(BuildContext context, {required Widget child}) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => ServiceMusicDialog(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

class ServiceMusicDialogTitle extends StatelessWidget {
  const ServiceMusicDialogTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textBlack,
        ),
      ),
    );
  }
}

class ServiceMusicDialogMessage extends StatelessWidget {
  const ServiceMusicDialogMessage(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: AppColors.txtHint),
      ),
    );
  }
}

class ServiceMusicDialogPrimaryButton extends StatelessWidget {
  const ServiceMusicDialogPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Material(
        color: AppColors.purple1,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ServiceMusicDialogCancelButton extends StatelessWidget {
  const ServiceMusicDialogCancelButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, color: AppColors.purple1),
          ),
        ),
      ),
    );
  }
}
