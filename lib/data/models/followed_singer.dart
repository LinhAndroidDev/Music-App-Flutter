class FollowedSinger {
  const FollowedSinger({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.createdAtMillis = 0,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final int createdAtMillis;
}
