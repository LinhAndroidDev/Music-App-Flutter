import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/song.dart';
import 'home_chart_song_row.dart';

class HomeZingChartCard extends StatelessWidget {
  const HomeZingChartCard({
    super.key,
    required this.songs,
    required this.chartDateLabel,
    required this.onSeeAll,
    required this.onSongTap,
    required this.onSongMore,
  });

  final List<Song> songs;
  final String chartDateLabel;
  final VoidCallback onSeeAll;
  final void Function(Song song) onSongTap;
  final void Function(Song song) onSongMore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Card(
        color: AppColors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 0, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.home_update_label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.txtHint,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    chartDateLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.txtHint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.blue, AppColors.bgPink, AppColors.bgOrange],
                ).createShader(bounds),
                child: Text(
                  l10n.nav_zingchart,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              for (var i = 0; i < songs.length; i++)
                HomeChartSongRow(
                  song: songs[i],
                  index: i,
                  onTap: () => onSongTap(songs[i]),
                  onMore: () => onSongMore(songs[i]),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 15),
                child: Divider(height: 0.3, color: AppColors.txtHint.withOpacity(0.6)),
              ),
              InkWell(
                onTap: onSeeAll,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 15, bottom: 4),
                  child: Center(
                    child: Text(
                      l10n.see_all,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.txtHint,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
