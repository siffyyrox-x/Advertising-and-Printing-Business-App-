import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:printing_business_app/data/chatbot_data.dart';
import 'package:printing_business_app/data/company_info.dart';
import 'package:printing_business_app/data/services_data.dart';
import 'package:printing_business_app/main.dart';
import 'package:printing_business_app/models/quote_request.dart';
import 'package:printing_business_app/models/service.dart';
import 'package:printing_business_app/screens/main_screen.dart';

void main() {
  group('Chatbot rules', () {
    test('every suggested question gets a real answer', () {
      for (final String question in ChatBot.suggestedQuestions) {
        final String answer = ChatBot.reply(question);
        expect(answer.isNotEmpty, isTrue);
        expect(answer.contains('did not understand'), isFalse,
            reason: 'No rule matched: "$question"');
      }
    });

    test('an unknown question gets the fallback answer', () {
      final String answer = ChatBot.reply('zzzz qqqq');
      expect(answer.contains('did not understand'), isTrue);
    });

    test('an empty message gets the fallback answer', () {
      expect(ChatBot.reply('   ').contains('did not understand'), isTrue);
    });
  });

  group('Service suggestion', () {
    test('business card wording suggests Business Cards', () {
      final Service? service =
          ChatBot.suggestService('I need 100 business cards for my shop');
      expect(service, isNotNull);
      expect(service!.title, 'Business Cards');
    });

    test('banner wording suggests Banners', () {
      final Service? service =
          ChatBot.suggestService('a big outdoor banner for my shop front');
      expect(service?.title, 'Banners');
    });

    test('unrelated wording suggests nothing', () {
      expect(ChatBot.suggestService('hello how are you today'), isNull);
    });
  });

  group('Services data', () {
    test('every service has an image and belongs to a known category', () {
      expect(ServicesData.active, isNotEmpty);
      for (final Service service in ServicesData.active) {
        expect(service.imagePath.startsWith('assets/images/'), isTrue);
        expect(ServicesData.categories.contains(service.category), isTrue);
      }
    });

    test('byId finds a service and returns null for a missing id', () {
      expect(ServicesData.byId(1)?.title, 'Business Cards');
      expect(ServicesData.byId(999), isNull);
    });
  });

  group('Quote store', () {
    test('a submitted quote is stored with an increasing reference', () {
      final int before = QuoteStore.quotes.length;
      final QuoteRequest quote = QuoteStore.add(
        serviceId: 1,
        customerName: 'Test Customer',
        phone: '0123456789',
        email: '',
        projectDetails: '100 business cards',
        quantity: '100',
      );
      expect(QuoteStore.quotes.length, before + 1);
      expect(quote.quoteId, before + 1);
      expect(quote.status, 'New');
    });
  });

  testWidgets('Splash screen appears and then the Home screen loads',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PrintingBusinessApp());

   
    expect(find.text(CompanyInfo.name), findsOneWidget);

   
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.text('About Us'), findsOneWidget);
    expect(find.text('Request a Quote'), findsOneWidget);
  });

  testWidgets('The bottom navigation bar has the four main tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Services'), findsWidgets);
    expect(find.text('Gallery'), findsWidgets);
    expect(find.text('Contact'), findsWidgets);
  });
}
