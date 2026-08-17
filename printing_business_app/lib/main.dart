import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'data/company_info.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const PrintingBusinessApp());
}

class PrintingBusinessApp extends StatelessWidget {
  const PrintingBusinessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: CompanyInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: SplashScreen.routeName,
      routes: <String, WidgetBuilder>{
        SplashScreen.routeName: (BuildContext context) => const SplashScreen(),
        MainScreen.routeName: (BuildContext context) => const MainScreen(),
      },
    );
  }
}
