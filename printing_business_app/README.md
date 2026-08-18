# Advertising & Printing Business App

A Flutter Android application for an advertising and printing company. Customers
can read about the company, browse services, look at previous work, contact the
business through several channels, request a quotation that is saved on the
device, and chat with a Service Helper that can answer questions either with a
free online AI or with a built-in offline rule set.

This repository contains the finished project. See
[`MILESTONE_2.md`](MILESTONE_2.md) and [`MILESTONE_3.md`](MILESTONE_3.md) for the
two milestone reports.

---

## 1. Project

| | |
|---|---|
| Type | University Android Development course project |
| Framework | Flutter (Dart) |
| Platform | Android |
| Status | Milestone 3 — feature complete |
| Design source | Wireframe, navigation flow diagram and ER schema diagram created for this project |

The app follows the wireframe screen by screen, the navigation flow diagram for
the routes between screens, and the ER schema diagram for the database tables.

---

## 2. Features

**Screens**

| Screen | Description |
|---|---|
| Splash | Company logo and name, moves to Home automatically after 2 seconds |
| Home | Banner, About Us, quick contact buttons, "Request a Quote", Service Helper shortcut, popular services |
| Services | Services grouped into Printing and Advertising, each with an "Ask Quote" button |
| Gallery | Two column grid of previous work, preview dialog, and a full screen pinch-to-zoom viewer |
| Contact | Company details, location with "Open in Google Maps", contact buttons, social links, Share App |
| Request Quote | Validated form, saved to a local SQLite database, with an "AI Suggest a Suitable Service" helper |
| My Requests | Every saved request, with status changes, delete, and "Send on WhatsApp" |
| Service Helper | Chatbot: online Gemini AI when a key is configured, offline rules otherwise |
| About | Company summary, what the app does, and where data is stored |

**Working features**

- Call Now — opens the Android phone dialer with the configured number
- WhatsApp — opens WhatsApp, falls back to `wa.me` in a browser, and reports
  honestly when WhatsApp is not available
- Email — opens the email app with the business address and a subject
- Open in Google Maps — opens the configured map link or searches the address
- Social media — Facebook, Instagram and YouTube buttons open the configured URLs
- Share App — opens the Android share sheet with a short message
- Request Quote — full validation, saved to SQLite, confirmation with a
  reference number, and an option to send the request over WhatsApp
- My Requests — read, update status (New / Sent / Done) and delete saved requests
- Service Helper — online AI with automatic offline fallback; every exchange is
  stored in the `ai_requests` table
- Navigation — bottom navigation bar for the four main tabs plus a side menu
  reaching Request Quote, My Requests, Service Helper, Share App and About

---

## 3. Technologies

- **Flutter** 3.22 or newer, **Dart** 3.4 or newer
- **Material 3** widgets only — no custom painters, no heavy animations
- **SQLite** on the device via `sqflite`
- **Google Gemini API** (free tier) for the optional online chatbot

| Package | Version | Why it is needed |
|---|---|---|
| `url_launcher` | `^6.3.1` | Dialer, WhatsApp, email, Google Maps, social links |
| `share_plus` | `^10.1.4` | Android share sheet |
| `sqflite` | `^2.3.0` | Local database for quote requests and chatbot history |
| `path` | `^1.9.0` | Builds the database file path safely |
| `http` | `^1.2.0` | Calls the Gemini REST API |
| `flutter_lints` | `^4.0.0` | Dev dependency, standard lint rules |

No login, no payment, no server of our own, and **no API key is stored in this
repository**.

---

## 4. Installation

```bash
# 1. Check that Flutter is installed and set up for Android
flutter doctor

# 2. Get the packages
flutter pub get
```

The Gradle wrapper (`gradlew`, `gradle-wrapper.jar`) is not committed, which is
the Flutter default. Flutter recreates it automatically on the first build.

---

## 5. Running the app

**Without the online AI** (everything works; the chatbot uses the offline rules):

```bash
flutter run
```

**With the online AI:**

```bash
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```

Build a release APK:

```bash
flutter build apk --release
flutter build apk --release --dart-define=GEMINI_API_KEY=your_key_here
```

Useful checks:

```bash
flutter analyze     # static analysis
flutter test        # unit and widget tests
```

---

## 6. Turning on the online AI chatbot (optional and free)

The Service Helper works with no setup at all. Adding a key upgrades it from a
fixed question list to a real conversation.

1. Open <https://aistudio.google.com/apikey> and sign in with a Google account.
2. Click **Create API key**. The free tier is enough for this project; no credit
   card is required.
3. Copy the key and run the app with it:

   ```bash
   flutter run --dart-define=GEMINI_API_KEY=AIza...your_key...
   ```

**Why it is done this way.** `--dart-define` injects the key at build time and
`String.fromEnvironment` reads it in `lib/utils/ai_service.dart`. The key never
appears in any source file, so it can never be committed to GitHub by accident.

**What happens without a key, or with no internet.** `AiService.isEnabled` is
false, or the request times out, and `AiService.ask()` returns `null`. The
chatbot screen then falls back to the offline rule based bot. A banner at the
top of the chat always shows which mode is active, so nothing is ever pretended.

To change the model, edit one line in `lib/utils/ai_service.dart`:

```dart
static const String modelName = 'gemini-3.5-flash-lite';
```

---

## 7. Configuring company information

**All business information lives in one file:**

```
lib/data/company_info.dart
```

| Constant | Purpose |
|---|---|
| `name`, `tagline`, `about` | Shown on Splash, Home, About |
| `phone` | Call Now button |
| `whatsappNumber` | WhatsApp button — country code, no `+` and no spaces |
| `email` | Email button |
| `address` | Shown on Contact; used for the Maps search if `mapUrl` is empty |
| `mapUrl` | Optional Google Maps link; takes priority over `address` |
| `businessHours` | Contact screen, About screen and the chatbot |
| `socialLinks` | Facebook, Instagram and YouTube URLs |

Values that still start with `YOUR_` are placeholders. While one is in place,
the Contact screen shows a small setup reminder and the matching button explains
what to configure instead of silently doing nothing.

Services are listed in `lib/data/services_data.dart` and gallery projects in
`lib/data/gallery_data.dart`.

---

## 8. Replacing gallery images

The images in `assets/` are generated placeholders. To use real pictures,
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
already declared in `pubspec.yaml`, so nothing else changes.

If a file is missing, the app shows a grey placeholder box instead of crashing.

---

## 9. Chatbot implementation

The chatbot has two layers.

**Offline layer — `lib/data/chatbot_data.dart`.** Rule based, no network, fully
explainable. Each `ChatRule` holds a list of keywords and one answer. The user's
message is lowercased, every rule is scored by how many of its keywords appear,
and the highest scoring rule wins. If nothing matches, a fallback answer lists
what the bot can help with.

```dart
ChatRule(
  <String>['where', 'location', 'address', 'map', ...],
  'Our address is shown on the Contact page, together with an '
  '"Open in Google Maps" button that gives you directions.',
),
```

**Online layer — `lib/utils/ai_service.dart`.** When a key is configured, the
question plus the last few messages are sent to Gemini with a system instruction
built from `CompanyInfo` and `ServicesData`, so the model answers as this shop's
assistant. It is told to keep replies short and never to invent an exact price.

Every exchange is written to the `ai_requests` table with a `source` column of
`online` or `offline`, which is the `AI_REQUEST` entity from the schema diagram.

The same file also contains `ChatBot.suggestService()`, which powers the
"AI Suggest a Suitable Service" button on the quote form.

---

## 10. Database

A local SQLite database, created on first use by `lib/data/database_helper.dart`.

```sql
CREATE TABLE quote_requests (
  quote_id        INTEGER PRIMARY KEY AUTOINCREMENT,
  service_id      INTEGER NOT NULL,
  customer_name   TEXT    NOT NULL,
  phone           TEXT    NOT NULL,
  email           TEXT,
  quantity        TEXT,
  project_details TEXT    NOT NULL,
  status          TEXT    NOT NULL,
  created_at      TEXT    NOT NULL
);

CREATE TABLE ai_requests (
  ai_request_id   INTEGER PRIMARY KEY AUTOINCREMENT,
  quote_id        INTEGER,
  customer_prompt TEXT    NOT NULL,
  ai_response     TEXT    NOT NULL,
  source          TEXT    NOT NULL,
  created_at      TEXT    NOT NULL,
  FOREIGN KEY (quote_id) REFERENCES quote_requests (quote_id) ON DELETE SET NULL
);
```

Everything is stored on the phone. Nothing is uploaded anywhere, and the only
network call the app ever makes is the optional Gemini request.

---

## 11. Project structure

```
lib/
├── main.dart                      app entry point and routes
├── app_theme.dart                 colours and shared text styles
├── data/
│   ├── company_info.dart          ← edit this file to configure the app
│   ├── services_data.dart         the list of services
│   ├── gallery_data.dart          the list of previous work
│   ├── chatbot_data.dart          offline chatbot rules
│   └── database_helper.dart       SQLite tables and queries
├── models/
│   ├── service.dart               SERVICE entity
│   ├── gallery_item.dart          GALLERY_ITEM entity
│   ├── social_link.dart           SOCIAL_LINK entity
│   ├── quote_request.dart         QUOTE_REQUEST entity
│   ├── ai_request.dart            AI_REQUEST entity
│   └── chat_message.dart          one line of the chat UI
├── screens/
│   ├── splash_screen.dart
│   ├── main_screen.dart           bottom navigation + side menu
│   ├── home_screen.dart
│   ├── services_screen.dart
│   ├── gallery_screen.dart
│   ├── image_view_screen.dart     full screen zoomable picture
│   ├── contact_screen.dart
│   ├── quote_screen.dart
│   ├── my_requests_screen.dart    saved quote requests
│   ├── chatbot_screen.dart
│   └── about_screen.dart
├── utils/
│   ├── launcher_helper.dart       dialer, WhatsApp, email, maps, share
│   └── ai_service.dart            Gemini API call with offline fallback
└── widgets/
    ├── app_image.dart             asset image with a safe fallback
    ├── quick_action_button.dart
    ├── section_title.dart
    └── service_card.dart
```

---

## 12. Notes and limitations

- Quote requests are stored on the device only. Nothing is sent to the company
  automatically, and the app says so on screen; the "Send on WhatsApp" button is
  the way to actually deliver a request.
- The Contact screen shows the address and an "Open in Google Maps" button
  rather than an embedded map, because an embedded map needs a Google Maps API
  key. No keys are stored in this repository.
- The app is light themed only, for a consistent look during the demo.
- Only the Android platform folder is included. Run
  `flutter create --platforms=ios .` if an iOS build is ever needed.
- If you upgrade to `share_plus` 11 or newer, the share call in
  `lib/utils/launcher_helper.dart` becomes
  `SharePlus.instance.share(ShareParams(text: ..., subject: ...))`.
