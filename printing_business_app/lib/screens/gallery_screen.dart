import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/gallery_data.dart';
import '../data/services_data.dart';
import '../models/gallery_item.dart';
import '../models/service.dart';
import '../utils/launcher_helper.dart';
import '../widgets/app_image.dart';
import 'image_view_screen.dart';

/// The Gallery tab. Shows previous work in a two column grid. Tapping a picture
/// opens a larger preview with the project name and description.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<GalleryItem> items = GalleryData.all;

    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Previous Work', style: AppTheme.sectionTitle),
              SizedBox(height: 2),
              Text('Tap an item to view it larger', style: AppTheme.muted),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (BuildContext context, int index) {
              return _GalleryTile(item: items[index]);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => LauncherHelper.shareApp(context),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share App'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final GalleryItem item;

  const _GalleryTile({required this.item});

  void _openPreview(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        final Service? service = ServicesData.byId(item.serviceId);
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          title: Text(item.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: AppImage(path: item.imagePath),
                  ),
                ),
                const SizedBox(height: 12),
                Text(item.description),
                if (service != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text('Service: ${service.title}', style: AppTheme.muted),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                openImageViewScreen(context, item);
              },
              icon: const Icon(Icons.zoom_in, size: 18),
              label: const Text('View full screen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openPreview(context),
      borderRadius: AppTheme.radius,
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.radius,
          side: const BorderSide(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(child: AppImage(path: item.imagePath)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
