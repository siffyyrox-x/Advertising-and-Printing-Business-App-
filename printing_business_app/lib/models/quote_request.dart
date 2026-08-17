/// Matches the QUOTE_REQUEST entity from the project schema diagram.
///
/// Milestone 2 keeps quote requests in memory only (see [QuoteStore] below).
/// No server or database is used yet, so nothing is sent anywhere.
class QuoteRequest {
  final int quoteId;
  final int serviceId; // FK -> Service.serviceId
  final String customerName;
  final String phone;
  final String email;
  final String projectDetails;
  final String quantity;
  final String status;
  final DateTime createdAt;

  const QuoteRequest({
    required this.quoteId,
    required this.serviceId,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.projectDetails,
    required this.quantity,
    required this.createdAt,
    this.status = 'New',
  });
}

/// A very small in-memory list of submitted quotes.
///
/// This exists so the Request Quote screen has somewhere to put the data during
/// Milestone 2. The list is cleared every time the app restarts.
class QuoteStore {
  QuoteStore._();

  static final List<QuoteRequest> _quotes = <QuoteRequest>[];

  static List<QuoteRequest> get quotes => List.unmodifiable(_quotes);

  static QuoteRequest add({
    required int serviceId,
    required String customerName,
    required String phone,
    required String email,
    required String projectDetails,
    required String quantity,
  }) {
    final QuoteRequest quote = QuoteRequest(
      quoteId: _quotes.length + 1,
      serviceId: serviceId,
      customerName: customerName,
      phone: phone,
      email: email,
      projectDetails: projectDetails,
      quantity: quantity,
      createdAt: DateTime.now(),
    );
    _quotes.add(quote);
    return quote;
  }
}
