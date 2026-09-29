import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/search/search_query.dart';

class SearchChipSection extends StatelessWidget {
  const SearchChipSection({
    super.key,
    required this.recentQueries,
    required this.suggestions,
    required this.onRecentTap,
    required this.onRecentDelete,
    required this.onClearAllRecent,
    required this.onSuggestionTap,
  });

  final List<SearchQuery> recentQueries;
  final List<String> suggestions;
  final ValueChanged<String> onRecentTap;
  final ValueChanged<String> onRecentDelete;
  final VoidCallback onClearAllRecent;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (recentQueries.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.search_recent_title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onClearAllRecent,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      l10n.search_recent_clear_all,
                      style: const TextStyle(fontSize: 13, color: AppColors.txtHint),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentQueries
                  .map(
                    (q) => _SearchChip(
                      label: q.query,
                      showClose: true,
                      onTap: () => onRecentTap(q.query),
                      onClose: () => onRecentDelete(q.normalizedQuery),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        if (suggestions.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(15, recentQueries.isNotEmpty ? 20 : 15, 15, 0),
            child: Text(
              l10n.search_suggestions_title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions
                  .map(
                    (text) => _SearchChip(
                      label: text,
                      onTap: () => onSuggestionTap(text),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _SearchChip extends StatelessWidget {
  const _SearchChip({
    required this.label,
    this.showClose = false,
    required this.onTap,
    this.onClose,
  });

  final String label;
  final bool showClose;
  final VoidCallback onTap;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.greyLight,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 8, showClose ? 4 : 12, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.textBlack),
                ),
              ),
              if (showClose && onClose != null)
                InkWell(
                  onTap: onClose,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.close, size: 16, color: AppColors.txtHint),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
