# CurrenSee Backend

Node.js/Express REST API powering the CurrenSee Flutter app. Handles currency conversion, user management, rate alerts, market news, and push notifications.

## Tech Stack

- **Runtime** — Node.js
- **Framework** — Express.js
- **Database** — MySQL (via `mysql2/promise`)
- **Auth** — Firebase Admin SDK (server-side Firebase Auth)
- **Push** — Firebase Cloud Messaging (via Admin SDK)
- **Exchange Rates** — ExchangeRate-API v6
- **News** — NewsAPI

## API Endpoints

### Auth
| Method | Path | Description |
|---|---|---|
| `POST` | `/register` | Create Firebase user + MySQL record |
| `POST` | `/login` | Verify Firebase user by email |
| `POST` | `/update-profile` | Update user email |

### Currency
| Method | Path | Description |
|---|---|---|
| `GET` | `/currencies` | All supported currency codes, names, symbols, flags |
| `GET` | `/currencies/:userId` | User's saved currency list |
| `POST` | `/add-currency/:userId` | Add a currency to user's list |
| `GET` | `/convert` | Convert amount between two currencies; logs to history |
| `GET` | `/exchange-rates` | All live rates (USD base) |
| `GET` | `/exchange-rates/:currencyCode` | Rates for a specific base currency |
| `GET` | `/history/:user_id` | User's conversion history (newest first) |

### Alerts & Preferences
| Method | Path | Description |
|---|---|---|
| `POST` | `/set-alert` | Create a rate alert threshold |
| `GET` | `/get-alerts/:user_id` | Fetch user's active alerts |
| `DELETE` | `/delete-alert/:alert_id` | Remove an alert |
| `GET` | `/preferences/:user_id` | Get saved base/target currency pair |
| `POST` | `/preferences` | Upsert user preferences |

### Misc
| Method | Path | Description |
|---|---|---|
| `GET` | `/market-news` | Business headlines from NewsAPI |
| `GET` | `/faqs` | Hardcoded FAQ list |
| `POST` | `/feedback` | Store user feedback message |
| `POST` | `/send-notification` | Send FCM push notification by device token |

## Database Schema

```sql
users              (uid, email, password)
conversions        (id, user_id, base_currency, target_currency, amount, converted_amount, rate, conversion_date)
rate_alerts        (id, user_id, base_currency, target_currency, threshold, target_rate)
user_preferences   (user_id, base_currency, target_currency, currencies)
feedback           (id, user_id, message)
```

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Create a `.env` file (see `.env.example`):
   ```
   DB_HOST=localhost
   DB_USER=root
   DB_PASS=yourpassword
   DB_NAME=currensee
   API_KEY=your_exchangerate_api_key
   NEWS_API_KEY=your_newsapi_key
   FIREBASE_SERVICE_ACCOUNT=./firebase-adminsdk.json
   PORT=5001
   ```

3. Place your Firebase service account JSON at `./firebase-adminsdk.json` (excluded from version control).

4. Create the MySQL database and run the schema.

5. Start the server:
   ```bash
   node server.js
   ```

The server starts on `http://localhost:5001` by default.

## Environment Variables

| Variable | Description |
|---|---|
| `DB_HOST` | MySQL host |
| `DB_USER` | MySQL username |
| `DB_PASS` | MySQL password |
| `DB_NAME` | Database name |
| `API_KEY` | ExchangeRate-API v6 key |
| `NEWS_API_KEY` | NewsAPI key |
| `FIREBASE_SERVICE_ACCOUNT` | Path to Firebase Admin SDK JSON |
| `PORT` | Server port (default: 5001) |
