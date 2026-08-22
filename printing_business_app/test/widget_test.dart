import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:printing_business_app/data/chatbot_data.dart';
import 'package:printing_business_app/data/company_info.dart';
import 'package:printing_business_app/data/services_data.dart';
import 'package:printing_business_app/main.dart';
import 'package:printing_business_app/models/ai_request.dart';
import 'package:printing_business_app/models/chat_message.dart';
import 'package:printing_business_app/models/quote_request.dart';
import 'package:printing_business_app/models/service.dart';
import 'package:printing_business_app/screens/main_screen.dart';
import 'package:printing_business_app/utils/ai_service.dart';


void main() {
  // ---------------------------------------------------------------- chatbot --
  group('Chatbot rules (offline mode)', () {
    test('every suggested question gets a real answer', () {
      for (final String question in ChatBot.suggestedQuestions) {
        final String answer = ChatBot.reply(question);
        expect(answer.isNotEmpty, isTrue);
        expect(answer.contains('did not understand'), isFalse,
            reason: 'No rule matched: "$question"');
      }
    });

    test('an unknown question gets the fallback answer', () {
      expect(ChatBot.reply('zzzz qqqq').contains('did not understand'), isTrue);
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

  // --------------------------------------------------------------- ai layer --
  group('AI service', () {
    test('is disabled when no API key was supplied at build time', () {
      // Tests run without --dart-define, so the online mode must be off and
      // every call must return null so the offline bot takes over.
      expect(AiService.isEnabled, isFalse);
    });

    test('returns null instead of throwing when disabled', () async {
      expect(await AiService.ask('What do you print?'), isNull);
    });

    test('a chat message keeps its author and AI flag', () {
      const ChatMessage fromBot =
          ChatMessage(text: 'Hello', isUser: false, fromAi: true);
      expect(fromBot.isUser, isFalse);
      expect(fromBot.fromAi, isTrue);
    });
  });

  // ------------------------------------------------------------ data models --
  group('QuoteRequest model', () {
    final QuoteRequest quote = QuoteRequest(
      quoteId: 7,
      serviceId: 1,
      customerName: 'Test Customer',
      phone: '01988058487',
      email: 'test@example.com',
      quantity: '100',
      projectDetails: '100 business cards, matte paper',
      createdAt: DateTime(2026, 8, 18, 14, 30),
    );

    test('survives a toMap / fromMap round trip', () {
      final QuoteRequest copy = QuoteRequest.fromMap(quote.toMap());
      expect(copy.quoteId, quote.quoteId);
      expect(copy.serviceId, quote.serviceId);
      expect(copy.customerName, quote.customerName);
      expect(copy.phone, quote.phone);
      expect(copy.email, quote.email);
      expect(copy.quantity, quote.quantity);
      expect(copy.projectDetails, quote.projectDetails);
      expect(copy.status, QuoteRequest.statusNew);
      expect(copy.createdAt, quote.createdAt);
    });

    test('a new request has no id until the database gives it one', () {
      final QuoteRequest draft = QuoteRequest(
        serviceId: 2,
        customerName: 'Draft',
        phone: '01988058487',
        email: '',
        quantity: '',
        projectDetails: 'One banner',
        createdAt: DateTime(2026, 8, 18),
      );
      expect(draft.quoteId, isNull);
      expect(draft.toMap().containsKey('quote_id'), isFalse);
      expect(draft.copyWith(quoteId: 12).quoteId, 12);
    });

    test('formats the date for the saved requests list', () {
      expect(quote.formattedDate, '18 Aug 2026, 14:30');
    });

    test('status changes are kept by copyWith', () {
      expect(quote.copyWith(status: QuoteRequest.statusSent).status, 'Sent');
      expect(QuoteRequest.allStatuses.length, 3);
    });
  });

  group('AiRequest model', () {
    test('survives a toMap / fromMap round trip', () {
      final AiRequest request = AiRequest(
        aiRequestId: 3,
        quoteId: null,
        customerPrompt: 'Do you print banners?',
        aiResponse: 'Yes, indoor and outdoor banners.',
        source: AiRequest.sourceOnline,
        createdAt: DateTime(2026, 8, 18, 9),
      );
      final AiRequest copy = AiRequest.fromMap(request.toMap());
      expect(copy.aiRequestId, 3);
      expect(copy.quoteId, isNull);
      expect(copy.customerPrompt, request.customerPrompt);
      expect(copy.aiResponse, request.aiResponse);
      expect(copy.source, AiRequest.sourceOnline);
      expect(copy.createdAt, request.createdAt);
    });
  });

  group('Services data', () {
    test('every service has an image and a known category', () {
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

  group('Company configuration', () {
    test('placeholder detection works', () {
      expect(CompanyInfo.isPlaceholder('YOUR_PHONE_NUMBER'), isTrue);
      expect(CompanyInfo.isPlaceholder('   '), isTrue);
      expect(CompanyInfo.isPlaceholder('01988058487'), isFalse);
    });

    test('the contact details needed for the demo are configured', () {
      expect(CompanyInfo.isPlaceholder(CompanyInfo.phone), isFalse);
      expect(CompanyInfo.isPlaceholder(CompanyInfo.whatsappNumber), isFalse);
      expect(CompanyInfo.isPlaceholder(CompanyInfo.email), isFalse);
      expect(CompanyInfo.hasLocation, isTrue);
    });
  });

  // ------------------------------------------------------------------ ui -----
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
