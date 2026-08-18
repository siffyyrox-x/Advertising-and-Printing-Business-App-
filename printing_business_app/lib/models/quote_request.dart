/// Matches the QUOTE_REQUEST entity from the project schema diagram.
///
/// Milestone 3: quote requests are now saved in a local SQLite database
/// (see lib/data/database_helper.dart), so they survive an app restart.
class QuoteRequest {
  /// Null before the row is inserted. SQLite fills it in with AUTOINCREMENT.
  final int? quoteId;
  final int serviceId; // FK -> Service.serviceId
  final String customerName;
  final String phone;
  final String email;
  final String quantity;
  final String projectDetails;
  final String status;
  final DateTime createdAt;

  const QuoteRequest({
    this.quoteId,
    required this.serviceId,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.quantity,
    required this.projectDetails,
    required this.createdAt,
    this.status = statusNew,
  });

  static const String statusNew = 'New';
  static const String statusSent = 'Sent';
  static const String statusDone = 'Done';

  /// The three values the status column is allowed to hold.
  static const List<String> allStatuses = <String>[
    statusNew,
    statusSent,
    statusDone,
  ];

  /// Converts this object into a row for the database.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      if (quoteId != null) 'quote_id': quoteId,
      'service_id': serviceId,
      'customer_name': customerName,
      'phone': phone,
      'email': email,
      'quantity': quantity,
      'project_details': projectDetails,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Builds an object from a database row.
  factory QuoteRequest.fromMap(Map<String, Object?> map) {
    return QuoteRequest(
      quoteId: map['quote_id'] as int?,
      serviceId: (map['service_id'] as int?) ?? 0,
      customerName: (map['customer_name'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      quantity: (map['quantity'] as String?) ?? '',
      projectDetails: (map['project_details'] as String?) ?? '',
      status: (map['status'] as String?) ?? statusNew,
      createdAt:
          DateTime.tryParse((map['created_at'] as String?) ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Returns a copy with some fields changed.
  QuoteRequest copyWith({int? quoteId, String? status}) {
    return QuoteRequest(
      quoteId: quoteId ?? this.quoteId,
      serviceId: serviceId,
      customerName: customerName,
      phone: phone,
      email: email,
      quantity: quantity,
      projectDetails: projectDetails,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  /// A short date like "18 Aug 2026, 14:30" for the saved requests list.
  String get formattedDate {
    const List<String> months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final String day = createdAt.day.toString().padLeft(2, '0');
    final String month = months[createdAt.month - 1];
    final String hour = createdAt.hour.toString().padLeft(2, '0');
    final String minute = createdAt.minute.toString().padLeft(2, '0');
    return '$day $month ${createdAt.year}, $hour:$minute';
  }
}
