import '../models/gallery_item.dart';

/// Previous work shown on the Gallery screen.
///
/// The images in assets/images/gallery/ are plain placeholders. Replace the PNG
/// files with real photos, keeping the same file names, and the gallery will
/// update automatically. See the README for details.
class GalleryData {
  GalleryData._();

  static const List<GalleryItem> all = <GalleryItem>[
    GalleryItem(
      galleryId: 1,
      serviceId: 1,
      title: 'Business Card Set',
      description: 'Double sided cards printed for a local shop.',
      imagePath: 'assets/images/gallery/project1.png',
    ),
    GalleryItem(
      galleryId: 2,
      serviceId: 2,
      title: 'Shop Front Banner',
      description: 'Large outdoor banner with a printed frame.',
      imagePath: 'assets/images/gallery/project2.png',
    ),
    GalleryItem(
      galleryId: 3,
      serviceId: 3,
      title: 'Cafe Logo',
      description: 'Logo design prepared in several colour versions.',
      imagePath: 'assets/images/gallery/project3.png',
    ),
    GalleryItem(
      galleryId: 4,
      serviceId: 4,
      title: 'Festival Advert',
      description: 'Social media advert set for a seasonal offer.',
      imagePath: 'assets/images/gallery/project4.png',
    ),
    GalleryItem(
      galleryId: 5,
      serviceId: 2,
      title: 'Event Backdrop',
      description: 'Indoor backdrop banner printed for a school event.',
      imagePath: 'assets/images/gallery/project5.png',
    ),
    GalleryItem(
      galleryId: 6,
      serviceId: 1,
      title: 'Visiting Cards',
      description: 'Simple cards printed on thick matte paper.',
      imagePath: 'assets/images/gallery/project6.png',
    ),
  ];
}
