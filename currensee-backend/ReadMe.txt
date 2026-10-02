import dotenv from "dotenv";
import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import mysql from "mysql2/promise";
import axios from "axios";
import admin from "firebase-admin";
import fs from "fs";

dotenv.config();
const API_KEY = process.env.API_KEY;



// ---------------- FIREBASE ----------------
if (process.env.FIREBASE_SERVICE_ACCOUNT && fs.existsSync(process.env.FIREBASE_SERVICE_ACCOUNT)) {
  const serviceAccount = JSON.parse(fs.readFileSync(process.env.FIREBASE_SERVICE_ACCOUNT, "utf-8"));
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log("🔥 Firebase initialized");
} else {
  console.warn("⚠️ Firebase service account not found");
}

// ---------------- APP ----------------
const app = express();
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});
app.use(cors());
app.use(bodyParser.json());

// ---------------- MYSQL ----------------
const db = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASS || "",
  database: process.env.DB_NAME || "currensee",
  waitForConnections: true,
  connectionLimit: 10,
});

console.log("✅ Connected to MySQL Database");

async function userExists(user_id) {
  if (!user_id) return false;
  const [rows] = await db.query("SELECT user_id FROM users WHERE user_id = ?", [user_id]);
  return rows.length > 0;
}

// ---------------- AUTH ----------------
app.post("/register", async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: "Email and password required" });

  try {
    const userRecord = await admin.auth().createUser({ email, password });
    console.log(`🔥 Firebase User Created: ${userRecord.uid}`);

    const [result] = await db.query(
      "INSERT INTO users (uid, email) VALUES (?, ?) ON DUPLICATE KEY UPDATE email = VALUES(email)",
      [userRecord.uid, email]
    );

    await db.query(
      "INSERT INTO user_preferences (user_id, base_currency, target_currency, currencies) VALUES (?, 'USD', 'EUR', JSON_ARRAY('USD','EUR','GBP','NGN')) ON DUPLICATE KEY UPDATE base_currency='USD'",
      [result.insertId]
    );

    res.json({ message: "User registered successfully!", uid: userRecord.uid });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post("/login", async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: "Email required" });

  try {
    const userRecord = await admin.auth().getUserByEmail(email);
    const [rows] = await db.query("SELECT * FROM users WHERE uid = ?", [userRecord.uid]);
    let mysqlUserId;

    if (rows.length === 0) {
      const [result] = await db.query("INSERT INTO users (uid, email) VALUES (?, ?)", [userRecord.uid, email]);
      mysqlUserId = result.insertId;
    } else {
      mysqlUserId = rows[0].user_id;
    }

    res.json({ message: "Login successful!", uid: userRecord.uid, user_id: mysqlUserId });
  } catch {
    res.status(401).json({ error: "Invalid credentials" });
  }
});

// ---------------- PROFILE ----------------
app.post("/update-profile", async (req, res) => {
  const { user_id, email, profile_image_url } = req.body;
  if (!user_id) return res.status(400).json({ error: "User ID is required" });

  try {
    if (!(await userExists(user_id))) return res.status(404).json({ error: "User not found" });

    await db.query("UPDATE users SET email = ?, profile_image_url = ? WHERE user_id = ?", [
      email,
      profile_image_url,
      user_id,
    ]);

    res.json({ message: "Profile updated successfully!" });
  } catch (error) {
    res.status(500).json({ error: "Error updating profile" });
  }
});

// ---------------- CONVERSION ----------------
const BASE_URL = `https://v6.exchangerate-api.com/v6/${API_KEY}`;

app.get('/convert', async (req, res) => {
  const { base, target, amount, user_id, uid } = req.query;

  if (!base || !target || !amount) {
    return res.status(400).json({ error: 'Missing parameters' });
  }

  try {
    console.log(`💱 Fetching exchange rate: ${base} → ${target}`);
    const response = await axios.get(`${BASE_URL}/latest/${base}`);

    if (!response.data.conversion_rates) {
      return res.status(400).json({ error: 'Invalid base currency or API error.' });
    }

    const rate = response.data.conversion_rates[target];
    if (!rate) {
      return res.status(400).json({ error: `Invalid target currency: ${target}` });
    }

    const convertedAmount = (parseFloat(amount) * rate).toFixed(2);

    // 🔑 Resolve MySQL user_id from either `user_id` or `uid`
    let mysqlUserId = null;
    if (user_id && !isNaN(user_id)) {
      mysqlUserId = parseInt(user_id);
    } else if (uid) {
      const [rows] = await db.query("SELECT user_id FROM users WHERE uid = ?", [uid]);
      if (rows.length > 0) mysqlUserId = rows[0].user_id;
    }

    // Store conversion only if user exists
    if (mysqlUserId) {
      await db.query(
        "INSERT INTO conversions (user_id, base_currency, target_currency, amount, converted_amount, rate) VALUES (?, ?, ?, ?, ?, ?)",
        [mysqlUserId, base, target, amount, convertedAmount, rate]
      );
    }

    res.json({ base, target, rate, convertedAmount });
  } catch (error) {
    console.error('❌ Exchange rate error:', error.message);
    res.status(500).json({ error: 'Error fetching exchange rates', details: error.message });
  }
});



// ---------------- HISTORY ----------------
app.get('/history/:identifier', async (req, res) => {
  const { identifier } = req.params;
  let mysqlUserId = null;

  try {
    if (!isNaN(identifier)) {
      // it’s numeric → MySQL user_id
      mysqlUserId = parseInt(identifier);
    } else {
      // it’s a Firebase UID → resolve MySQL user_id
      const [rows] = await db.query("SELECT user_id FROM users WHERE uid = ?", [identifier]);
      if (rows.length > 0) mysqlUserId = rows[0].user_id;
    }

    if (!mysqlUserId) {
      return res.status(404).json({ error: 'User not found' });
    }

    const [history] = await db.query(
      "SELECT * FROM conversions WHERE user_id = ? ORDER BY conversion_date DESC",
      [mysqlUserId]
    );
    res.json(history);
  } catch (error) {
    console.error("❌ History Fetch Error:", error.message);
    res.status(500).json({ error: 'Error fetching history' });
  }
});

// ---------------- ALERTS ----------------
app.post('/set-alert', async (req, res) => {
  let { user_id, uid, base, target, threshold } = req.body;

  if ((!user_id && !uid) || !base || !target || !threshold) {
    return res.status(400).json({ error: 'Missing parameters' });
  }

  try {
    // Resolve MySQL user_id
    let mysqlUserId = null;
    if (user_id && !isNaN(user_id)) {
      mysqlUserId = parseInt(user_id);
    } else if (uid) {
      const [rows] = await db.query("SELECT user_id FROM users WHERE uid = ?", [uid]);
      if (rows.length > 0) mysqlUserId = rows[0].user_id;
    }

    if (!mysqlUserId) {
      return res.status(404).json({ error: 'User not found' });
    }

    const [result] = await db.query(
      "INSERT INTO rate_alerts (user_id, base_currency, target_currency, threshold, target_rate) VALUES (?, ?, ?, ?, ?)",
      [mysqlUserId, base, target, threshold, 0.00000]
    );

    res.json({ message: 'Alert set successfully!', alert_id: result.insertId });
  } catch (error) {
    console.error('❌ Alert Error:', error.message);
    res.status(500).json({ error: 'Error setting alert', details: error.message });
  }
});


app.get('/get-alerts/:identifier', async (req, res) => {
  const { identifier } = req.params;
  let mysqlUserId = null;

  try {
    if (!isNaN(identifier)) {
      mysqlUserId = parseInt(identifier);
    } else {
      const [rows] = await db.query("SELECT user_id FROM users WHERE uid = ?", [identifier]);
      if (rows.length > 0) mysqlUserId = rows[0].user_id;
    }

    if (!mysqlUserId) {
      return res.status(404).json({ error: 'User not found' });
    }

    const [alerts] = await db.query(
      "SELECT * FROM rate_alerts WHERE user_id = ?",
      [mysqlUserId]
    );
    res.json(alerts);
  } catch (error) {
    console.error('❌ Get Alerts Error:', error.message);
    res.status(500).json({ error: 'Error fetching alerts' });
  }
});

app.delete('/delete-alert/:alert_id', async (req, res) => {
  try {
    await db.query("DELETE FROM rate_alerts WHERE id = ?", [req.params.alert_id]);
    res.json({ message: 'Alert deleted successfully!' });
  } catch (error) {
    console.error('❌ Delete Alert Error:', error.message);
    res.status(500).json({ error: 'Error deleting alert' });
  }
});



// ---------------- START SERVER ----------------
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
}
);
export default app; // Export for testing purposes


