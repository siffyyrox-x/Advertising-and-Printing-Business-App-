# Advertising & Printing Business App

A Flutter Android application for an advertising and printing company. Customers
can read about the company, browse services, look at previous work, contact the
business through several channels, request a quotation and ask a small built-in
service helper (chatbot) simple questions.

This repository contains **Milestone 2** of an Android Development course
project. See [`MILESTONE_2.md`](MILESTONE_2.md) for the milestone report.

---

## 1. Project

| | |
|---|---|
| Type | University Android Development course project |
| Framework | Flutter (Dart) |
| Platform | Android |
| Milestone | 2 — approximately 60% of the planned application |
| Design source | Wireframe, navigation flow diagram and ER schema diagram created for this project |

The app follows the uploaded wireframe screen by screen, the navigation flow
diagram for the routes between screens, and the ER schema diagram for the shape
of the data classes.

---

## 2. Features

**Screens**

| Screen | Description |
|---|---|
| Splash | Company logo and name, moves to Home automatically after 2 seconds |
| Home | Banner, About Us, quick contact buttons, "Request a Quote", service helper shortcut, popular services |
| Services | Services grouped into Printing and Advertising, each with an "Ask Quote" button |
| Gallery | Two column grid of previous work, tap a picture for a larger preview |
| Contact | Company details, location with "Open in Google Maps", contact buttons, social links, Share App |
| Request Quote | Validated form with an "AI Suggest a Suitable Service" helper |
| Service Helper | Simple rule based chatbot with suggested questions |

**Working features**

- Call Now — opens the Android phone dialer with the configured number
- WhatsApp — opens WhatsApp with the configured number, falls back to `wa.me`
  in a browser and reports honestly when WhatsApp is not available
- Email — opens the email app with the business address and a subject
- Open in Google Maps — opens the configured address or map link in Google Maps
- Social media — Facebook, Instagram and YouTube buttons open the configured URLs
- Share App — opens the Android share sheet with a short message
- Request Quote — full form validation, in-app confirmation with a reference
  number, and an option to send the request over WhatsApp
- Service Helper — keyword based chatbot that answers common questions
- Navigation — bottom navigation bar for the four main tabs plus a side menu
  that also reaches Request Quote, Service Helper and Share App

---

## 3. Technologies

- **Flutter** 3.22 or newer, **Dart** 3.4 or newer
- **Material 3** widgets only — no custom painters or heavy animations
- Two packages:
  - [`url_launcher`](https://pub.dev/packages/url_launcher) `^6.3.1` — dialer,
    WhatsApp, email, maps and social links
  - [`share_plus`](https://pub.dev/packages/share_plus) `^10.1.4` — the Android
    share sheet
- No backend, no database, no API keys, no login

---

## 4. Installation

```bash
# 1. Check that Flutter is installed and set up for Android
flutter doctor

# 2. Get the packages
flutter pub get
```

The Gradle wrapper (`gradlew`, `gradle-wrapper.jar`) is not committed, which is
the Flutter default. Flutter recreates it automatically the first time you build.

---

## 5. Running the app

```bash
# List connected devices or emulators
flutter devices

# Run in debug mode
flutter run

# Build a release APK
flutter build apk --release
```

Useful checks:

```bash
flutter analyze     # static analysis
flutter test        # unit and widget tests
```

---

## 6. Configuring company information

**All business information lives in one file:**

```
lib/data/company_info.dart
```

Values that still start with `YOUR_` are placeholders. The real business details
were not included in the project documents, so nothing has been invented. Replace
them before the demo:

| Constant | Example value |
|---|---|
| `name` | `'ABC Printing & Advertising'` |
| `tagline` | `'Printing made simple'` |
| `phone` | `'+8801712345678'` |
| `whatsappNumber` | `'8801712345678'` (country code, no `+` and no spaces) |
| `email` | `'info@yourcompany.com'` |
| `address` | `'12 Main Road, Dhaka 1205'` |
| `mapUrl` | optional Google Maps share link, leave `''` to search the address |
| `businessHours` | `'Saturday to Thursday, 9:00 AM to 8:00 PM'` |
| `socialLinks` | the Facebook, Instagram and YouTube page URLs |

While a placeholder is still in place:

- the Contact screen shows a small yellow setup reminder, and
- the matching button shows a message naming the value to configure instead of
  silently doing nothing.

Services are listed in `lib/data/services_data.dart` and gallery projects in
`lib/data/gallery_data.dart`.

---

## 7. Replacing gallery images

The images in `assets/` are plain generated placeholders. To use real pictures,
overwrite the files and keep the same names:

```
assets/images/logo.png                     app logo (square, about 512x512)
assets/images/banner.png                   home screen banner (16:9)
assets/images/services/business_cards.png  service pictures (square)
assets/images/services/banners.png
assets/images/services/logo_design.png
assets/images/services/social_media_ads.png
assets/images/gallery/project1.png ... project6.png   previous work (square)
```

To add a **new** gallery item, drop the picture into `assets/images/gallery/` and
add one entry to the list in `lib/data/gallery_data.dart`. The whole folder is
already declared in `pubspec.yaml`, so no other change is needed.

If a file is missing, the app shows a grey placeholder box instead of crashing.

---

## 8. Chatbot implementation

The chatbot lives in `lib/data/chatbot_data.dart` and is **rule based**. It is
not machine learning and it does not call any online AI service, so there is no
API key anywhere in the project.

How it works:

1. The user's message is lowercased and padded with spaces.
2. Each `ChatRule` holds a list of keywords and one answer.
3. The rule whose keywords appear most often in the message wins.
4. If no rule matches, a friendly fallback answer is returned.

```dart
ChatRule(
  <String>['where', 'location', 'address', 'map', ...],
  'Our address is shown on the Contact page, together with an '
  '"Open in Google Maps" button that gives you directions.',
),
```

The same file also contains `ChatBot.suggestService()`, which powers the
"AI Suggest a Suitable Service" button on the quote form. It looks for service
related words in the customer's description and pre-selects the closest service.

To teach the bot something new, add one more `ChatRule` to the `_rules` list.

---

## 9. Project structure

```
lib/
├── main.dart                  app entry point and routes
├── app_theme.dart             colours and shared text styles
├── data/
│   ├── company_info.dart      ← edit this file to configure the app
│   ├── services_data.dart     the list of services
│   ├── gallery_data.dart      the list of previous work
│   └── chatbot_data.dart      chatbot rules and service suggestion
├── models/
│   ├── service.dart           SERVICE entity
│   ├── gallery_item.dart      GALLERY_ITEM entity
│   ├── social_link.dart       SOCIAL_LINK entity
│   └── quote_request.dart     QUOTE_REQUEST entity + in-memory store
├── screens/
│   ├── splash_screen.dart
│   ├── main_screen.dart       bottom navigation + side menu
│   ├── home_screen.dart
│   ├── services_screen.dart
│   ├── gallery_screen.dart
│   ├── contact_screen.dart
│   ├── quote_screen.dart
│   └── chatbot_screen.dart
├── utils/
│   └── launcher_helper.dart   dialer, WhatsApp, email, maps, share
└── widgets/
    ├── app_image.dart         asset image with a safe fallback
    ├── quick_action_button.dart
    ├── section_title.dart
    └── service_card.dart
```

---
