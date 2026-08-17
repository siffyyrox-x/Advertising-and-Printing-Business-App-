import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/company_info.dart';
import '../utils/launcher_helper.dart';
import '../widgets/app_image.dart';
import 'chatbot_screen.dart';
import 'contact_screen.dart';
import 'gallery_screen.dart';
import 'home_screen.dart';
import 'quote_screen.dart';
import 'services_screen.dart';

/// Holds the four main tabs (Home, Services, Gallery, Contact) and the
/// bottom navigation bar, as drawn in the wireframe.
///
/// The Request Quote and Service Helper screens are opened on top of this
/// screen with Navigator.push, so the user can go back to the tab they were on.
class MainScreen extends StatefulWidget {
  static const String routeName = '/home';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const List<String> _titles = <String>[
    'Home',
    'Services',
    'Gallery',
    'Contact',
  ];

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
  }

  /// Closes the drawer (if it is open) and shows the tab at [index].
  void _selectTabFromDrawer(int index) {
    Navigator.of(context).pop();
    _selectTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        leading: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const AppImage(
              path: 'assets/images/logo.png',
              width: 34,
              height: 34,
            ),
          ),
        ),
      ),
      // An end drawer keeps the logo on the left and the menu button on the
      // right, matching the wireframe. Flutter adds the menu button itself.
      endDrawer: _buildDrawer(context),
      body: IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          HomeScreen(onOpenTab: _selectTab),
          ServicesScreen(onOpenTab: _selectTab),
          const GalleryScreen(),
          const ContactScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _selectTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: const Color(0xFF757575),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services_outlined),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call_outlined),
            label: 'Contact',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              width: double.infinity,
              color: AppTheme.primary,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const AppImage(
                      path: 'assets/images/logo.png',
                      width: 56,
                      height: 56,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    CompanyInfo.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    CompanyInfo.tagline,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            for (int i = 0; i < _titles.length; i++)
              ListTile(
                leading: Icon(_drawerIcons[i]),
                title: Text(_titles[i]),
                selected: _currentIndex == i,
                onTap: () => _selectTabFromDrawer(i),
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.request_quote_outlined),
              title: const Text('Request a Quote'),
              onTap: () {
                Navigator.of(context).pop();
                openQuoteScreen(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Service Helper'),
              onTap: () {
                Navigator.of(context).pop();
                openChatbotScreen(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share App'),
              onTap: () {
                Navigator.of(context).pop();
                LauncherHelper.shareApp(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  static const List<IconData> _drawerIcons = <IconData>[
    Icons.home_outlined,
    Icons.design_services_outlined,
    Icons.photo_library_outlined,
    Icons.call_outlined,
  ];
}
