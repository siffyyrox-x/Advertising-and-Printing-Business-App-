/// Matches the SERVICE entity from the project schema diagram.
class Service {
  final int serviceId;
  final String title;
  final String description;
  final String priceNote;
  final String imagePath;
  final String category; // "Printing" or "Advertising"
  final bool isActive;

  const Service({
    required this.serviceId,
    required this.title,
    required this.description,
    required this.priceNote,
    required this.imagePath,
    required this.category,
    this.isActive = true,
  });
}
