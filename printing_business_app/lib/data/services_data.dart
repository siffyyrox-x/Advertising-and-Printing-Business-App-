import '../models/service.dart';

/// The list of services shown on the Services screen and in the quote form.
/// Add or remove entries here to change what the app offers.
class ServicesData {
  ServicesData._();

  static const List<Service> all = <Service>[
    Service(
      serviceId: 1,
      title: 'Business Cards',
      description: 'Card design and printing on good quality paper.',
      priceNote: 'Price depends on quantity and paper type.',
      imagePath: 'assets/images/services/business_cards.png',
      category: 'Printing',
    ),
    Service(
      serviceId: 2,
      title: 'Banners',
      description: 'Indoor and outdoor banners in any size.',
      priceNote: 'Price depends on size and material.',
      imagePath: 'assets/images/services/banners.png',
      category: 'Printing',
    ),
    Service(
      serviceId: 3,
      title: 'Logo Design',
      description: 'Basic company logo design with source files.',
      priceNote: 'Fixed package price. Ask for details.',
      imagePath: 'assets/images/services/logo_design.png',
      category: 'Advertising',
    ),
    Service(
      serviceId: 4,
      title: 'Social Media Ads',
      description: 'Post design and advert design for social media.',
      priceNote: 'Priced per design or as a monthly package.',
      imagePath: 'assets/images/services/social_media_ads.png',
      category: 'Advertising',
    ),
  ];

  /// Only the services that are currently offered.
  static List<Service> get active =>
      all.where((Service s) => s.isActive).toList();

  /// The service categories, in the order they should be displayed.
  static const List<String> categories = <String>['Printing', 'Advertising'];

  static List<Service> byCategory(String category) =>
      active.where((Service s) => s.category == category).toList();

  /// Returns the service with [id], or null when it does not exist.
  static Service? byId(int id) {
    for (final Service service in all) {
      if (service.serviceId == id) {
        return service;
      }
    }
    return null;
  }
}
