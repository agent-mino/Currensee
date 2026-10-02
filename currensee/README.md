# CurrenSee — Flutter Currency App

A cross-platform mobile app (Android & iOS) for real-time currency conversion, exchange rate tracking, and market news, built with Flutter and backed by a Node.js/Express REST API.

## Features

- **Currency Conversion** — Convert between 160+ currencies using live ExchangeRate-API data; per-user currency lists are persisted server-side
- **Exchange Rates** — Browse all live rates from a chosen base currency with flag icons, searchable by name or code
- **Conversion History** — Every conversion is saved to MySQL and accessible per-user
- **Rate Alerts** — Set threshold rates for any currency pair; push notifications are delivered via Firebase Cloud Messaging when the rate is hit
- **Market News** — Business headlines from NewsAPI with thumbnails and in-app URL launcher
- **Account Management** — Email/password auth via Firebase Auth; update email or password from within the app
- **User Preferences** — Save a default base/target currency pair per account

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3, Dart, Material 3 |
| Auth | Firebase Authentication |
| Push | Firebase Cloud Messaging |
| HTTP | `package:http` |
| Storage | `shared_preferences` |
| Backend | Node.js/Express (see `../currensee-backend`) |

## Project Structure

```
lib/
└── main.dart          # All screens and widgets (single-file architecture)
    ├── CurrenSeeApp   # App entry, theme, routing
    ├── LoginScreen    # Firebase email/password login
    ├── RegisterScreen # New account creation
    ├── HomeScreen     # FCM token setup, entry dashboard
    ├── CurrencyConverterScreen
    ├── ExchangeRateScreen
    ├── ConversionHistoryScreen
    ├── CurrencyListScreen
    ├── MarketNewsScreen
    ├── RateAlertsScreen
    ├── UserPreferencesScreen
    ├── SupportScreen  # Inline FAQs + feedback form
    ├── FeedbackScreen
    ├── AccountScreen  # Profile, email/password update
    ├── AppDrawer      # Slide-out navigation with profile header
    └── Footer
assets/
└── currency_data.json
```

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.6.1
- A running instance of [CurrenSee Backend](../currensee-backend)
- Firebase project with Authentication and Cloud Messaging enabled

### Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Configure Firebase — place your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the appropriate platform directories. These files are excluded from version control.

3. Update the backend base URL in `lib/main.dart` — replace `http://localhost:5001` with your server address.

4. Run the app:
   ```bash
   flutter run
   ```

## Configuration

| File | Purpose |
|---|---|
| `android/app/google-services.json` | Firebase Android config (not committed) |
| `ios/Runner/GoogleService-Info.plist` | Firebase iOS config (not committed) |
| `lib/firebase_options.dart` | Generated Firebase options |

## Screens

| Screen | Description |
|---|---|
| Login / Register | Firebase Auth with password visibility toggle |
| Home | Welcome screen, FCM token display |
| Currency Converter | Amount input, two currency dropdowns, live conversion result |
| Exchange Rates | All rates for a base currency, flag images, search filter |
| Conversion History | Chronological list of past conversions with amounts and rates |
| Rate Alerts | Set/delete threshold alerts; FCM delivers notifications |
| Market News | Business headlines with images, tappable to open in browser |
| Preferences | Save default base/target currency |
| My Account | Update email, update password, sign out |
