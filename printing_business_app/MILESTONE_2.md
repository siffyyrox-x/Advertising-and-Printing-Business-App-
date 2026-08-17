# Milestone 2 Report

**Project:** Advertising & Printing Business App
**Course:** Android Development
**Framework:** Flutter (Dart), Android target
**Milestone:** 2 — implementation checkpoint

---

## 1. Summary

Milestone 1 produced the planning documents: the wireframe, the navigation flow
diagram and the ER schema diagram. Milestone 2 turns those documents into a
working Flutter application.

Every screen in the wireframe has been built, and the contact features are
genuinely functional rather than static mock-ups. The estimated completion of the
planned application is **about 60%**, which is above the 50% required for this
milestone.

---

## 2. Screens implemented

| # | Screen | File | Status |
|---|---|---|---|
| 1 | Splash | `lib/screens/splash_screen.dart` | Complete |
| 2 | Home | `lib/screens/home_screen.dart` | Complete |
| 3 | Services | `lib/screens/services_screen.dart` | Complete |
| 4 | Gallery | `lib/screens/gallery_screen.dart` | Complete |
| 5 | Contact | `lib/screens/contact_screen.dart` | Complete |
| 6 | Request Quote | `lib/screens/quote_screen.dart` | Complete (no backend) |
| 7 | Service Helper (chatbot) | `lib/screens/chatbot_screen.dart` | Complete |

All seven screens from the navigation flow diagram are present.

---

## 3. Functional features

| Feature | How it works | Working |
|---|---|---|
| Splash to Home | `Timer` of 2 seconds, then `pushReplacementNamed` | Yes |
| Bottom navigation | `BottomNavigationBar` + `IndexedStack` for the four tabs | Yes |
| Side menu | `endDrawer` with all six destinations plus Share App | Yes |
| Call Now | `url_launcher` opens a `tel:` URI in the dialer | Yes |
| WhatsApp | tries `whatsapp://send`, falls back to `https://wa.me/...` | Yes |
| Email | `url_launcher` opens a `mailto:` URI with subject and body | Yes |
| Google Maps | opens a Google Maps search for the configured address, or a configured map link | Yes |
| Social media | Facebook / Instagram / YouTube buttons open the configured URLs | Yes |
| Share App | `share_plus` opens the Android share sheet | Yes |
| Gallery preview | tapping a picture opens an `AlertDialog` with a larger image | Yes |
| Request Quote form | `Form` + `TextFormField` + `DropdownButtonFormField` with validation | Yes |
| Service suggestion | keyword matching on the description pre-selects a service | Yes |
| Chatbot | rule based keyword matching with suggested question chips | Yes |

### Request Quote validation rules

| Field | Rule |
|---|---|
| Full Name | required, at least 3 characters |
| Phone Number | required, at least 7 digits, digits and `+ -` only |
| Email | optional, but must look like an email if entered |
| Service | required, chosen from a dropdown |
| Quantity | optional, must be a whole number greater than zero |
| Description | required, at least 10 characters |

On a valid submit the request is stored in an in-memory list, a dialog shows a
reference number, and the form is cleared. The dialog states plainly that the
request has **not** been sent to the company yet and offers to send it over
WhatsApp instead.

---

## 4. Chatbot implementation

The chatbot is deliberately simple and can be fully explained during evaluation.

- File: `lib/data/chatbot_data.dart`
- Approach: **rule based keyword matching**, not machine learning
- No internet connection, no AI API, no API key

Each rule is a list of keywords with one answer:

```dart
class ChatRule {
  final List<String> keywords;
  final String answer;
  const ChatRule(this.keywords, this.answer);
}
```

`ChatBot.reply()` lowercases the message, counts how many keywords of each rule
appear in it, and returns the answer of the rule with the highest count. If no
rule matches, a fallback answer is returned that lists what the bot can help with.

There are 11 rules covering: greetings, printing services, advertising services,
services in general, prices and quotations, contact details, location, business
hours, previous work, delivery time, and thanks/goodbye.

The same file also contains `ChatBot.suggestService()` for the
"AI Suggest a Suitable Service" button on the quote form.

---

## 5. Data classes and the schema diagram

The ER diagram from Milestone 1 is mirrored by plain Dart classes. No database is
used yet, so the data is held in constant lists.

| ER entity | Dart class | Data source |
|---|---|---|
| COMPANY | `CompanyInfo` | `lib/data/company_info.dart` |
| SOCIAL_LINK | `SocialLink` | `CompanyInfo.socialLinks` |
| SERVICE | `Service` | `lib/data/services_data.dart` |
| GALLERY_ITEM | `GalleryItem` | `lib/data/gallery_data.dart` |
| QUOTE_REQUEST | `QuoteRequest` | `QuoteStore` (in memory) |
| AI_REQUEST | represented by the chatbot and the suggestion helper; not yet stored |

One extra field, `category`, was added to `Service` so the Services screen can
separate printing work from advertising work as the requirements ask.

---

## 6. Packages used

| Package | Version | Why it is needed |
|---|---|---|
| `url_launcher` | `^6.3.1` | Flutter cannot open the dialer, WhatsApp, an email app, Google Maps or a browser on its own |
| `share_plus` | `^10.1.4` | Flutter has no built-in access to the Android share sheet |
| `flutter_lints` | `^4.0.0` | dev dependency, standard Flutter lint rules |

No other packages were added. No state management library, no HTTP client and no
database package are used, because nothing in Milestone 2 needs them.

---

## 7. Current implementation percentage

**Approximately 60% of the planned application.**

| Area | Weight | Done |
|---|---|---|
| Screens and layout | 30% | 30% |
| Navigation | 10% | 10% |
| Contact features (call, WhatsApp, email, maps, social, share) | 20% | 20% |
| Quote form (UI and validation) | 15% | 12% |
| Chatbot | 10% | 8% |
| Data storage and admin side | 15% | 0% |

---

## 8. What remains for the next milestone

1. **Persisting quote requests.** Save submissions with `sqflite` or
   `shared_preferences` so they survive an app restart, and add a "My requests"
   screen. This completes the `QUOTE_REQUEST` entity from the schema.
2. **Sending quote requests to the company.** Either an email intent with the
   full request, or a small backend endpoint if the course allows it.
3. **Storing chatbot conversations** to match the `AI_REQUEST` entity, so a quote
   request can be linked to the conversation that produced it.
4. **Real business information and photographs.** Replace the placeholders in
   `lib/data/company_info.dart` and the generated images in `assets/`.
5. **Polish.** App launcher icon, an application-wide dark theme, a full-screen
   pinch-to-zoom gallery viewer, and a small "About" screen.
6. **Testing.** Widget tests for the quote form validation and for the chatbot
   screen, in addition to the tests already in `test/widget_test.dart`.

---

## 9. Honest notes for the evaluation

- Quote data is kept in memory only. The app never claims it was sent to a server.
- The map on the Contact screen is an address panel with an "Open in Google Maps"
  button, not an embedded map, because an embedded map needs a Google Maps API
  key and no keys are stored in this project.
- The business phone number, email, address and social media links are clearly
  marked placeholders, because the real details were not part of the project
  documentation.
