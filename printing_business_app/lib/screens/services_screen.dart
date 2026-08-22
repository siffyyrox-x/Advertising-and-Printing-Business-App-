import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/services_data.dart';
import '../models/service.dart';
import '../widgets/section_title.dart';
import '../widgets/service_card.dart';
import 'quote_screen.dart';

class ServicesScreen extends StatelessWidget {
  final ValueChanged<int> onOpenTab;

  const ServicesScreen({super.key, required this.onOpenTab});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: <Widget>[
        const Text(
          'Available printing and advertising services',
          style: AppTheme.muted,
        ),
        for (final String category in ServicesData.categories) ...<Widget>[
          SectionTitle('$category Services'),
          for (final Service service in ServicesData.byCategory(category))
            ServiceCard(
              service: service,
              onAskQuote: () => openQuoteScreen(context, service: service),
            ),
        ],
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () => onOpenTab(2),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('See examples in the Gallery'),
          ),
        ),
      ],
    );
  }
}
