/// Matches the GALLERY_ITEM entity from the project schema diagram.
class GalleryItem {
  final int galleryId;
  final int serviceId; // FK -> Service.serviceId
  final String title;
  final String description;
  final String imagePath;

  const GalleryItem({
    required this.galleryId,
    required this.serviceId,
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
