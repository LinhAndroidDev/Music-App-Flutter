import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';

class SingerDescriptionSection extends StatefulWidget {
  const SingerDescriptionSection({super.key, required this.description});

  final String description;

  static const _collapsedLines = 3;

  @override
  State<SingerDescriptionSection> createState() => _SingerDescriptionSectionState();
}

class _SingerDescriptionSectionState extends State<SingerDescriptionSection> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.description.trim();
    if (text.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.artist_info_title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          _expanded
              ? _buildExpanded(text, l10n.artist_see_less)
              : _CollapsedDescription(
                  text: text,
                  maxLines: SingerDescriptionSection._collapsedLines,
                  seeMoreLabel: l10n.artist_see_more,
                  onSeeMore: () => setState(() => _expanded = true),
                ),
        ],
      ),
    );
  }

  Widget _buildExpanded(String text, String seeLess) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$text ',
            style: const TextStyle(fontSize: 14, color: AppColors.txtHint, height: 1.4),
          ),
          TextSpan(
            text: seeLess,
            style: const TextStyle(fontSize: 14, color: AppColors.purple1),
            recognizer: TapGestureRecognizer()
              ..onTap = () => setState(() => _expanded = false),
          ),
        ],
      ),
    );
  }
}

class _CollapsedDescription extends StatelessWidget {
  const _CollapsedDescription({
    required this.text,
    required this.maxLines,
    required this.seeMoreLabel,
    required this.onSeeMore,
  });

  final String text;
  final int maxLines;
  final String seeMoreLabel;
  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final style = const TextStyle(fontSize: 14, color: AppColors.txtHint, height: 1.4);
        final span = TextSpan(text: text, style: style);
        final tp = TextPainter(
          text: span,
          maxLines: maxLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        if (!tp.didExceedMaxLines) {
          return Text(text, style: style);
        }

        final suffix = '… $seeMoreLabel';
        var end = text.length;
        while (end > 0) {
          final trial = '${text.substring(0, end).trimRight()}$suffix';
          final painter = TextPainter(
            text: TextSpan(text: trial, style: style),
            maxLines: maxLines,
            textDirection: Directionality.of(context),
          )..layout(maxWidth: constraints.maxWidth);
          if (!painter.didExceedMaxLines) break;
          end--;
        }

        final visible = text.substring(0, end).trimRight();
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '$visible… ', style: style),
              TextSpan(
                text: seeMoreLabel,
                style: const TextStyle(fontSize: 14, color: AppColors.purple1),
                recognizer: TapGestureRecognizer()..onTap = onSeeMore,
              ),
            ],
          ),
        );
      },
    );
  }
}
