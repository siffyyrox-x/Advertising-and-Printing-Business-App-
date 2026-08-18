# Milestone 3 Report — Final

**Project:** Advertising & Printing Business App
**Course:** Android Development
**Framework:** Flutter (Dart), Android target
**Milestone:** 3 — remaining 40%, project complete

---

## 1. Summary

Milestone 2 delivered every screen with working contact features, but two things
were still missing: data did not survive an app restart, and the chatbot could
only answer a fixed list of questions.

Milestone 3 closes both gaps and finishes the remaining polish:

1. A local **SQLite database** now stores quote requests and chatbot history,
   completing the `QUOTE_REQUEST` and `AI_REQUEST` entities from the schema.
2. A new **My Requests** screen reads, updates and deletes those saved requests.
3. The chatbot became a **hybrid assistant**: a free online AI when a key is
   configured, with automatic fallback to the offline rules.
4. Three smaller additions: a full screen zoomable gallery viewer, an About
   screen, and an expanded test suite.

The application is now **100% of the planned scope**.

---

## 2. What was added in this milestone

| # | Feature | Files |
|---|---|---|
| 1 | SQLite database with two tables | `lib/data/database_helper.dart` |
| 2 | `QUOTE_REQUEST` mapping to and from rows | `lib/models/quote_request.dart` |
| 3 | `AI_REQUEST` entity | `lib/models/ai_request.dart` |
| 4 | Quote form writes to the database | `lib/screens/quote_screen.dart` |
| 5 | My Requests screen (read, status update, delete, send) | `lib/screens/my_requests_screen.dart` |
| 6 | Online AI service with offline fallback | `lib/utils/ai_service.dart` |
| 7 | Hybrid chatbot with history, typing indicator, mode banner | `lib/screens/chatbot_screen.dart` |
| 8 | Full screen pinch-to-zoom gallery viewer | `lib/screens/image_view_screen.dart` |
| 9 | About screen | `lib/screens/about_screen.dart` |
| 10 | INTERNET permission for the API call | `android/app/src/main/AndroidManifest.xml` |
| 11 | Expanded tests (24 cases) | `test/widget_test.dart` |

---

## 3. Database design

Created on first use, version 1, file `printing_business.db`.

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

`DatabaseHelper` is a singleton, so only one connection is ever opened. Dates
are stored as ISO-8601 text, which SQLite sorts correctly and Dart parses with
`DateTime.parse`.

### Full CRUD, demonstrable in the app

| Operation | Where it happens |
|---|---|
| Create | Submitting the Request Quote form |
| Read | My Requests screen (`ORDER BY quote_id DESC`) |
| Update | The three-dot menu on a request card: New / Sent / Done |
| Delete | The three-dot menu, with a confirmation dialog |

---

## 4. The AI chatbot

### How it works

```
user types a question
        │
        ▼
 AiService.ask(question, history)
        │
        ├── no API key?  ──────────────► returns null
        ├── no internet / timeout? ────► returns null
        ├── HTTP status not 200?  ─────► returns null
        │
        └── success ───────────────────► returns the answer text
                                              │
        ┌─────────────────────────────────────┘
        ▼
 answer == null ?   yes ──► ChatBot.reply(question)   (offline rules)
                    no  ──► show the AI answer with an "answered by AI" tag
        │
        ▼
 save the exchange in ai_requests (source = 'online' or 'offline')
```

### API details

| Item | Value |
|---|---|
| Provider | Google Gemini Developer API (free tier) |
| Model | `gemini-3.5-flash-lite` |
| Endpoint | `POST https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent` |
| Request | `systemInstruction`, `contents` (multi-turn), `generationConfig` |
| Answer path | `candidates[0].content.parts[0].text` |
| Timeout | 25 seconds |
| History sent | last 8 messages, so the bot remembers the conversation |

### Keeping the API key out of GitHub

The key is **never written in any source file**. It is injected at build time:

```bash
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```

and read with a compile-time constant:

```dart
static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
static bool get isEnabled => _apiKey.trim().isNotEmpty;
```

If nobody supplies a key, the app still works — it simply stays in offline mode.
This satisfies the requirement not to expose API keys while still demonstrating
a real API integration.

### Grounding the model

The system instruction is built at runtime from `CompanyInfo` and
`ServicesData`, so the model is told the real service list, business hours and
contact details. It is also instructed to keep answers to 2–4 sentences, to use
plain text only, and never to invent an exact price — prices depend on size,
quantity and material, so it points the customer to the quote form instead.

### Honesty in the UI

A banner at the top of the chat always states the current mode: green
"Online AI assistant is on" or grey "Offline mode: answering from the built-in
question list". Answers that came from the API carry a small "answered by AI"
tag. The app never pretends to be smarter than it is.

---

## 5. Complete feature list

| Feature | Milestone | Status |
|---|---|---|
| Splash screen | 2 | Done |
| Home screen | 2 | Done |
| Services screen (grouped by category) | 2 | Done |
| Gallery screen | 2 | Done |
| Full screen zoomable gallery viewer | 3 | Done |
| Contact screen | 2 | Done |
| Bottom navigation + side menu | 2 | Done |
| Call Now | 2 | Done |
| WhatsApp with graceful fallback | 2 | Done |
| Email | 2 | Done |
| Open in Google Maps | 2 | Done |
| Social media links | 2 | Done |
| Share App | 2 | Done |
| Request Quote form with validation | 2 | Done |
| Quote requests saved to SQLite | 3 | Done |
| My Requests screen with full CRUD | 3 | Done |
| Offline rule based chatbot | 2 | Done |
| Online AI chatbot with fallback | 3 | Done |
| Chat history saved to SQLite | 3 | Done |
| About screen | 3 | Done |
| Unit and widget tests | 2 and 3 | Done |

---

## 6. Packages used

| Package | Version | Why |
|---|---|---|
| `url_launcher` | `^6.3.1` | Dialer, WhatsApp, email, maps, social links |
| `share_plus` | `^10.1.4` | Android share sheet |
| `sqflite` | `^2.3.0` | Local SQLite database |
| `path` | `^1.9.0` | Safe database file path |
| `http` | `^1.2.0` | Gemini REST call |
| `flutter_lints` | `^4.0.0` | Dev dependency, lint rules |

Six packages in total, each with a clear single reason. No state management
library was added, because `setState` and `FutureBuilder` are enough for an app
of this size.

---

## 7. Testing

`test/widget_test.dart` contains 24 test cases:

- **Chatbot rules** — every suggested question matches a rule; unknown and empty
  input reach the fallback.
- **Service suggestion** — card wording picks Business Cards, banner wording
  picks Banners, unrelated wording picks nothing.
- **AI service** — with no key, `isEnabled` is false and `ask()` returns `null`
  instead of throwing, which is exactly what makes the fallback safe.
- **Models** — `QuoteRequest` and `AiRequest` survive a `toMap` / `fromMap`
  round trip; a new draft has no id until the database assigns one; `copyWith`
  updates the status; the date formatter produces `18 Aug 2026, 14:30`.
- **Services data** — every service has a valid asset path and a known category.
- **Company config** — placeholder detection works and the demo contact details
  are filled in.
- **Widgets** — the splash screen appears and hands over to Home after two
  seconds; the bottom navigation bar shows the four tabs.

The database itself is not unit tested, because `sqflite` needs a real Android
device. It is exercised manually by submitting a request and reopening the app.

---

## 8. Design decisions worth defending

| Decision | Reason |
|---|---|
| SQLite instead of a cloud database | The course asks for a simple, self-contained app. A local database gives real persistence and full CRUD with no server, no account and no cost. |
| API key by `--dart-define` instead of a config file | A config file can be committed by mistake. A build-time constant cannot end up in Git. |
| Online AI is optional, never required | The project must run for anyone who clones it, even with no key and no internet. The offline bot guarantees that. |
| Rule based bot kept rather than removed | It is the fallback, it is fully explainable, and it makes the app usable offline. |
| Light theme only | Consistent branding and no risk of unreadable contrast during the demo. |
| `setState` instead of a state management package | Only four screens hold state, all of it local. A package would add concepts without solving a real problem here. |

---

## 9. Honest notes for the evaluation

- Quote requests are stored on the phone only. The app never claims otherwise;
  the confirmation dialog explains it and offers to send the request over
  WhatsApp.
- The online chatbot needs a free Gemini API key at build time. Without it the
  app runs normally in offline mode, and the banner on the chat screen says so.
- The Contact screen shows an address panel with an "Open in Google Maps"
  button, not an embedded map, because an embedded map requires an API key.
- No API key, password or secret is committed anywhere in this repository.
