import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/database_helper.dart';
import '../data/services_data.dart';
import '../models/quote_request.dart';
import '../models/service.dart';
import '../utils/launcher_helper.dart';

/// Opens the saved quote requests screen.
Future<void> openMyRequestsScreen(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => const MyRequestsScreen(),
    ),
  );
}

/// Shows every quote request stored in the local database, newest first.
///
/// This is what makes the QUOTE_REQUEST entity from the schema diagram fully
/// real: rows can be created, read, updated (status) and deleted.
class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  late Future<List<QuoteRequest>> _quotesFuture;

  @override
  void initState() {
    super.initState();
    _quotesFuture = DatabaseHelper.instance.getQuotes();
  }

  void _reload() {
    setState(() {
      _quotesFuture = DatabaseHelper.instance.getQuotes();
    });
  }

  Future<void> _delete(QuoteRequest quote) async {
    final int? id = quote.quoteId;
    if (id == null) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete this request?'),
        content: Text(
          'Request #$id for ${quote.customerName} will be removed from this '
          'phone. This cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await DatabaseHelper.instance.deleteQuote(id);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not delete the request.')),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text('Request #$id deleted.')),
    );
    _reload();
  }

  Future<void> _changeStatus(QuoteRequest quote, String status) async {
    final int? id = quote.quoteId;
    if (id == null) {
      return;
    }
    try {
      await DatabaseHelper.instance.updateQuoteStatus(id, status);
    } catch (_) {
      // Ignore: the list simply will not change.
    }
    if (!mounted) {
      return;
    }
    _reload();
  }

  /// Builds the message that is sent to the shop over WhatsApp.
  String _summary(QuoteRequest quote) {
    final Service? service = ServicesData.byId(quote.serviceId);
    final String serviceName = service == null ? 'Not selected' : service.title;

    final StringBuffer buffer = StringBuffer()
      ..writeln('Quote request #${quote.quoteId ?? 0}')
      ..writeln('Name: ${quote.customerName}')
      ..writeln('Phone: ${quote.phone}');
    if (quote.email.isNotEmpty) {
      buffer.writeln('Email: ${quote.email}');
    }
    buffer.writeln('Service: $serviceName');
    if (quote.quantity.isNotEmpty) {
      buffer.writeln('Quantity: ${quote.quantity}');
    }
    buffer.writeln('Details: ${quote.projectDetails}');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<List<QuoteRequest>>(
        future: _quotesFuture,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<QuoteRequest>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const _EmptyState(
              icon: Icons.error_outline,
              title: 'Could not open the saved requests',
              message: 'Please close the app and open it again.',
            );
          }

          final List<QuoteRequest> quotes =
              snapshot.data ?? const <QuoteRequest>[];

          if (quotes.isEmpty) {
            return const _EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No requests yet',
              message:
                  'Requests you send from the Request Quote screen are saved '
                  'here so you can look them up later.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: quotes.length,
            itemBuilder: (BuildContext context, int index) {
              return _QuoteCard(
                quote: quotes[index],
                onDelete: () => _delete(quotes[index]),
                onStatusChanged: (String status) =>
                    _changeStatus(quotes[index], status),
                onSendWhatsApp: () {
                  LauncherHelper.openWhatsApp(
                    context,
                    message: _summary(quotes[index]),
                  );
                  _changeStatus(quotes[index], QuoteRequest.statusSent);
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// One saved request shown as a card.
class _QuoteCard extends StatelessWidget {
  final QuoteRequest quote;
  final VoidCallback onDelete;
  final VoidCallback onSendWhatsApp;
  final ValueChanged<String> onStatusChanged;

  const _QuoteCard({
    required this.quote,
    required this.onDelete,
    required this.onSendWhatsApp,
    required this.onStatusChanged,
  });

  Color get _statusColour {
    switch (quote.status) {
      case QuoteRequest.statusSent:
        return const Color(0xFF1565C0);
      case QuoteRequest.statusDone:
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFFEF6C00);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Service? service = ServicesData.byId(quote.serviceId);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.radius,
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    '#${quote.quoteId ?? 0}  ${service?.title ?? 'Service'}',
                    style: AppTheme.cardTitle,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColour,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    quote.status,
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'More',
                  padding: EdgeInsets.zero,
                  onSelected: (String value) {
                    if (value == 'delete') {
                      onDelete();
                    } else {
                      onStatusChanged(value);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: QuoteRequest.statusNew,
                      child: Text('Mark as New'),
                    ),
                    const PopupMenuItem<String>(
                      value: QuoteRequest.statusSent,
                      child: Text('Mark as Sent'),
                    ),
                    const PopupMenuItem<String>(
                      value: QuoteRequest.statusDone,
                      child: Text('Mark as Done'),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(quote.formattedDate, style: AppTheme.muted),
            const SizedBox(height: 8),
            _line('Name', quote.customerName),
            _line('Phone', quote.phone),
            if (quote.email.isNotEmpty) _line('Email', quote.email),
            if (quote.quantity.isNotEmpty) _line('Quantity', quote.quantity),
            _line('Details', quote.projectDetails),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onSendWhatsApp,
                icon: const Icon(Icons.chat, size: 16),
                label: const Text('Send on WhatsApp'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3, right: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 66,
            child: Text(label, style: AppTheme.muted),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

/// Shown when there is nothing to list, or when the database failed to open.
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 56, color: const Color(0xFFBDBDBD)),
            const SizedBox(height: 14),
            Text(title, style: AppTheme.sectionTitle),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: AppTheme.muted),
          ],
        ),
      ),
    );
  }
}
