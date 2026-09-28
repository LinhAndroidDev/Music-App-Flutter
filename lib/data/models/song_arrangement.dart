/// Favourite list sort order (ServiceMusic [ArrangeMusic]).
enum SongArrangement {
  newest(0),
  oldest(1),
  bySongName(2),
  byArtistName(3);

  const SongArrangement(this.storedIndex);

  final int storedIndex;

  static SongArrangement fromStored(int? index) {
    if (index == null) return SongArrangement.newest;
    return SongArrangement.values.firstWhere(
      (e) => e.storedIndex == index,
      orElse: () => SongArrangement.newest,
    );
  }
}
