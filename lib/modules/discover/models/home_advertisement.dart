import '../../../data/models/firestore_song.dart';

class HomeAdvertisement {
  const HomeAdvertisement({
    this.id = '',
    this.image = '',
    this.update = '',
    this.detail = '',
  });

  final String id;
  final String image;
  final String update;
  final String detail;

  factory HomeAdvertisement.fromFirestore(FirestoreAdvertisement ad) {
    return HomeAdvertisement(
      id: ad.id,
      image: ad.image,
      update: ad.update,
      detail: ad.detail,
    );
  }
}
