/// Shared-element tags for singer list ↔ detail transitions.
abstract final class SingerSharedElement {
  static String avatarTag(String singerId) => 'singer_avatar_$singerId';

  static String nameTag(String singerId) => 'singer_name_$singerId';
}
