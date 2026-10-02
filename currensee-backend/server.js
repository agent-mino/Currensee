require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const mysql = require('mysql2/promise');
const axios = require('axios');
const admin = require('firebase-admin');
const API_KEY = process.env.API_KEY;
// Initialize Firebase Admin SDK
const serviceAccount = require(process.env.FIREBASE_SERVICE_ACCOUNT);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const app = express();
app.use(cors());
app.use(bodyParser.json());

// MySQL Database Connection
const db = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || '',
  database: process.env.DB_NAME || 'currensee',
});

console.log(' Connected to MySQL Database');

// User Registration (Firebase + MySQL)
app.post('/register', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Email and password required' });

  try {
    // Register user in Firebase
    const userRecord = await admin.auth().createUser({ email, password });
    console.log(` Firebase User Created: ${userRecord.uid}`);

    // Store user in MySQL
    await db.query("INSERT INTO users (uid, email, password) VALUES (?, ?, ?)", [userRecord.uid, email, password]);

    res.json({ message: 'User registered successfully!', uid: userRecord.uid });
  } catch (error) {
    console.error(' Registration Error:', error);
    res.status(500).json({ error: error.message });
  }
});
// User Login (Firebase Auth)
app.post('/login', async (req, res) => {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: 'Email required' });
  
    try {
      const userRecord = await admin.auth().getUserByEmail(email);
      console.log(` Firebase Login Successful: ${userRecord.uid}`);
  
      res.json({ message: 'Login successful!', uid: userRecord.uid });
    } catch (error) {
      console.error(' Login Error:', error);
      res.status(401).json({ error: 'Invalid credentials' });
    }
  });
  // Update user profile
app.post('/update-profile', async (req, res) => {
  const { user_id, email} = req.body;

  if (!user_id) {
    return res.status(400).json({ error: 'User ID is required' });
  }

  try {
    const [user] = await db.query('SELECT * FROM users WHERE user_id = ?', [user_id]);
    if (user.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    await db.query(
      'UPDATE users SET email = ? WHERE user_id = ?',
      [email, profileImageUrl, user_id]
    );

    res.json({ message: 'Profile updated successfully!' });
  } catch (error) {
    console.error('Profile Update Error:', error.message);
    res.status(500).json({ error: 'Error updating profile' });
  }
});

  // Currency Conversion
  const API_URL = `https://v6.exchangerate-api.com/v6/${process.env.API_KEY}/latest`;

  app.get('/convert', async (req, res) => {
    const { base, target, amount, user_id } = req.query;
    
    if (!base || !target || !amount) {
      return res.status(400).json({ error: 'Missing parameters' });
    }try {
      console.log(`Fetching exchange rate: ${base} → ${target}`);
      const response = await axios.get(`https://v6.exchangerate-api.com/v6/${process.env.API_KEY}/latest/${base}`);
      if (!response.data.conversion_rates) {
        return res.status(400).json({ error: 'Invalid base currency or API error.' });
      }
      const rate = response.data.conversion_rates[target];
      if (!rate) {
        return res.status(400).json({ error: `Invalid target currency: ${target}` });
      } 
      const convertedAmount = (parseFloat(amount) * rate).toFixed(2); 
      // Store conversion in the database with user_id
      const user_id = req.query.user_id ? parseInt(req.query.user_id) : null;
      await db.query(
        "INSERT INTO conversions (user_id, base_currency, target_currency, amount, converted_amount, rate) VALUES (?, ?, ?, ?, ?, ?)",
        [user_id, base, target, amount, convertedAmount, rate]
      );
      res.json({ base, target, rate, convertedAmount });
    } catch (error) {
      console.error('Exchange rate error:', error.response?.data || error.message);
      res.status(500).json({ error: 'Error fetching exchange rates', details: error.message });
    }
  });
  const BASE_URL = `https://v6.exchangerate-api.com/v6/${API_KEY}`;

  // Currency symbol mapping
  const currencySymbols = {
    USD: '$', EUR: '€', GBP: '£', NGN: '₦', JPY: '¥', CNY: '¥', INR: '₹',
    CAD: 'C$', AUD: 'A$', CHF: 'CHF', SEK: 'kr', NZD: 'NZ$', MXN: 'Mex$',
    SGD: 'S$', HKD: 'HK$', NOK: 'kr', KRW: '₩', TRY: '₺', RUB: '₽', ZAR: 'R'
  };
  
  // Fetch all currencies
  app.get('/currencies', async (req, res) => {
    try {
      const response = await axios.get(`${BASE_URL}/codes`);
      if (response.data.result !== 'success') {
        return res.status(500).json({ error: 'Failed to fetch currencies' });
      }
  
      const currencies = response.data.supported_codes.map(([code, name]) => ({
        code,
        name: name || code,
        symbol: currencySymbols[code] || '',
        flag: `https://flagcdn.com/w320/${code.substring(0, 2).toLowerCase()}.png`,
      }));
  
      res.json(currencies);
    } catch (error) {
      console.error('Error fetching currencies:', error.message);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
  
  // Fetch all exchange rates
  app.get('/exchange-rates', async (req, res) => {
    try {
      const [codesResponse, ratesResponse] = await Promise.all([
        axios.get(`${BASE_URL}/codes`),
        axios.get(`${BASE_URL}/latest/USD`)
      ]);
  
      if (codesResponse.data.result !== 'success' || ratesResponse.data.result !== 'success') {
        return res.status(500).json({ error: 'Failed to fetch exchange rates or codes' });
      }
  
      const codeMap = new Map(codesResponse.data.supported_codes);
      const rates = Object.entries(ratesResponse.data.conversion_rates).map(([code, rate]) => ({
        code,
        name: codeMap.get(code) || 'Unknown Currency',
        rate,
        symbol: currencySymbols[code] || '',
        flag: `https://flagcdn.com/w320/${code.substring(0, 2).toLowerCase()}.png`,
      }));
  
      res.json(rates);
    } catch (error) {
      console.error('Error fetching exchange rates:', error.message);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
  
  
  // Fetch exchange rates for a specific currency
  app.get('/exchange-rates/:currencyCode', async (req, res) => {
    const { currencyCode } = req.params;
    try {
      const [codesResponse, ratesResponse] = await Promise.all([
        axios.get(`${BASE_URL}/codes`),
        axios.get(`${BASE_URL}/latest/${currencyCode}`)
      ]);
  
      if (codesResponse.data.result !== 'success' || ratesResponse.data.result !== 'success') {
        return res.status(500).json({ error: `Failed to fetch exchange rates or codes for ${currencyCode}` });
      }
  
      const codeMap = new Map(codesResponse.data.supported_codes);
      const rates = Object.entries(ratesResponse.data.conversion_rates).map(([code, rate]) => ({
        code,
        name: codeMap.get(code) || 'Unknown Currency',
        rate,
        symbol: currencySymbols[code] || '',
        flag: `https://flagcdn.com/w320/${code.substring(0, 2).toLowerCase()}.png`,
      }));
  
      res.json(rates);
    } catch (error) {
      console.error(`Error fetching exchange rates for ${currencyCode}:`, error.message);
      res.status(500).json({ error: 'Internal server error' });
    }
  });

// Fetch Conversion History

app.get('/history/:user_id', async (req, res) => {
  try {
    const [history] = await db.query(
      "SELECT * FROM conversions WHERE user_id = ? ORDER BY conversion_date DESC",
      [req.params.user_id]
    );
    res.json(history);
  } catch (error) {
    console.error('History Fetch Error:', error.message);
    res.status(500).json({ error: 'Error fetching history' });
  }
});


  
  // Fetch Market News
  const apiKey = process.env.NEWS_API_KEY;
  app.get('/market-news', async (req, res) => {
    try {
      const response = await axios.get(
        `https://newsapi.org/v2/top-headlines?category=business&apiKey=${apiKey}`
      );
  
      if (response.data.status !== "ok") {
        return res.status(500).json({ error: "Error fetching news from API" });
      }
  
      res.json({ news: response.data.articles });
    } catch (error) {
      console.error(' News Fetch Error:', error.message);
      res.status(500).json({ error: 'Error fetching news', details: error.message });
    }
  });
// Store Rate Alerts
app.post('/set-alert', async (req, res) => {
  let { user_id, base, target, threshold } = req.body;

  if (!user_id || !base || !target || !threshold) {
    return res.status(400).json({ error: 'Missing parameters' });
  }try {
    // Ensure user_id is an integer
    user_id = parseInt(user_id);
    if (isNaN(user_id)) {
      return res.status(400).json({ error: 'Invalid user_id' });
    }
    const [result] = await db.query(
      "INSERT INTO rate_alerts (user_id, base_currency, target_currency, threshold, target_rate) VALUES (?, ?, ?, ?, ?)",
      [user_id, base, target, threshold, 0.00000]
    );res.json({ message: 'Alert set successfully!', alert_id: result.insertId });
  } catch (error) {
    console.error('Alert Error:', error.message);
    res.status(500).json({ error: 'Error setting alert', details: error.message });
  }});
  app.get('/get-alerts/:user_id', async (req, res) => {
    try {
      const [alerts] = await db.query(
        "SELECT * FROM rate_alerts WHERE user_id = ?",
        [req.params.user_id]
      );
      res.json(alerts);
    } catch (error) {
      res.status(500).json({ error: 'Error fetching alerts' });
    }});
  app.delete('/delete-alert/:alert_id', async (req, res) => {
    try {
      await db.query("DELETE FROM rate_alerts WHERE id = ?", [req.params.alert_id]);
      res.json({ message: 'Alert deleted successfully!' });
    } catch (error) {
      res.status(500).json({ error: 'Error deleting alert' });
    }});
    
  
  
  // Get User Preferences
  // Fetch User Preferences
// Fetch User Preferences
app.get('/preferences/:user_id', async (req, res) => {
  const { user_id } = req.params;
  
  if (!user_id) {
    return res.status(400).json({ error: 'User ID is required' });
  }

  try {
    const [preferences] = await db.query(
      'SELECT base_currency, target_currency FROM user_preferences WHERE user_id = ?',
      [user_id]
    );

    if (preferences.length === 0) {
      return res.json({ base_currency: 'USD', target_currency: 'EUR' }); // Default values
    }

    res.json(preferences[0]);
  } catch (error) {
    console.error('Preferences Fetch Error:', error.message);
    res.status(500).json({ error: 'Error fetching preferences' });
  }
});

// Add new currency to user's list
app.post('/add-currency/:userId', async (req, res) => {
  const { userId } = req.params;
  const { currency } = req.body;
  if (!currency) {
    return res.status(400).json({ error: 'Currency is required' });
  }

  try {
    // Fetch the user's current currencies
    const [userPrefs] = await db.query('SELECT currencies FROM user_preferences WHERE user_id = ?', [userId]);
    let currentCurrencies = userPrefs[0]?.currencies ? JSON.parse(userPrefs[0].currencies) : ['USD', 'EUR', 'GBP', 'NGN'];
    // Check if the currency already exists
    if (currentCurrencies.includes(currency)) {
      return res.status(400).json({ error: 'Currency already added' });
    }
    // Add the new currency
    currentCurrencies.push(currency);
  // Update the database
   await db.query('UPDATE user_preferences SET currencies = ? WHERE user_id = ?', [JSON.stringify(currentCurrencies), userId]);
    res.json({ message: 'Currency added successfully', currencies: currentCurrencies });
  } catch (error) {
    console.error('Error adding currency:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Fetch user currencies
app.get('/currencies/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const [userPrefs] = await db.query('SELECT currencies FROM user_preferences WHERE user_id = ?', [userId]);
    let currentCurrencies = userPrefs[0]?.currencies ? JSON.parse(userPrefs[0].currencies) : ['USD', 'EUR', 'GBP', 'NGN'];

    res.json({ currencies: currentCurrencies });
  } catch (error) {
    console.error('Error fetching currencies:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update User Preferences
app.post('/preferences', async (req, res) => {
  const { user_id, base_currency, target_currency } = req.body;
if (!user_id || !base_currency || !target_currency) {
  return res.status(400).json({ error: 'Missing parameters' });
} try {
    await db.query(`
      INSERT INTO user_preferences (user_id, base_currency, target_currency)
      VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE base_currency = ?, target_currency = ?`,
      [user_id, base_currency, target_currency, base_currency, target_currency]
    );

    res.json({ message: 'Preferences updated successfully!' });
  } catch (error) {
    console.error('Preferences Update Error:', error.message);
    res.status(500).json({ error: 'Error updating preferences' });
  }
});
app.get('/faqs', async (req, res) => {
  const faqs = [
    { question: "How do I convert currencies?", answer: "Go to the conversion screen, select base and target currencies, enter the amount, and hit 'Convert'." },
    { question: "How do I set rate alerts?", answer: "In the rate alerts section, select the base and target currencies and set a threshold rate." },
    { question: "How do I view my conversion history?", answer: "You can access your conversion history from the 'History' section in the app." }
  ];
  res.json(faqs);
});

// Submit Feedback
app.post('/feedback', async (req, res) => {
  const { user_id, message } = req.body;
  if (!user_id || !message) {
    return res.status(400).json({ error: 'User ID and message are required' });
  }

  try {
    await db.query('INSERT INTO feedback (user_id, message) VALUES (?, ?)', [user_id, message]);
    res.json({ message: 'Feedback submitted successfully!' });
  } catch (error) {
    console.error('Error submitting feedback:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});
// Send Push Notification
app.post('/send-notification', async (req, res) => {
    const { token, title, body } = req.body;
  
    if (!token || !title || !body) {
      return res.status(400).json({ error: 'Missing parameters' });
    }
  
    try {
      const message = {
        token,
        notification: {
          title,
          body,
        },
        android: {
          priority: "high",
          notification: {
            sound: "default",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
            },
          },
        },
      };
  
      await admin.messaging().send(message);
      res.json({ message: 'Notification sent successfully!' });
    } catch (error) {
      console.error(' Notification Error:', error.message);
      res.status(500).json({ error: 'Error sending notification', details: error.message });
    }
  });
  
  // Root Route
  app.get('/', (req, res) => {
    res.send(' CurrenSee Backend is Running');
  });
  
  // Start Server
  const PORT = process.env.PORT || 5001;
  app.listen(PORT, () => {
    console.log(` Server running on port ${PORT}`);
  });
        