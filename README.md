# CurrenSee

A full-stack currency exchange mobile application built with Flutter (Android/iOS) and a Node.js/Express backend.

## Repositories

| Directory | Description |
|---|---|
| [`currensee/`](./currensee) | Flutter mobile app |
| [`currensee-backend/`](./currensee-backend) | Node.js/Express REST API |

## Overview

CurrenSee lets users convert currencies in real time, track their conversion history, set rate-threshold alerts with push notification delivery, and read live market news — all behind a Firebase-authenticated account.

```
Flutter App  ──HTTP──►  Express API  ──►  ExchangeRate-API
                │                    ──►  NewsAPI
                │                    ──►  MySQL (history, alerts, prefs)
                └──Firebase Auth / FCM
```

## Quick Start

1. Set up and start the backend — see [`currensee-backend/README.md`](./currensee-backend/README.md)
2. Configure Firebase credentials for the Flutter app — see [`currensee/README.md`](./currensee/README.md)
3. Update the backend URL in `currensee/lib/main.dart`
4. Run `flutter pub get && flutter run`

## Security Notes

The following files contain credentials and must not be committed to public repositories:

- `currensee-backend/.env`
- `currensee-backend/firebase-adminsdk.json`
- `currensee/android/app/google-services.json`
- `currensee/ios/Runner/GoogleService-Info.plist`
