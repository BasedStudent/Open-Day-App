require("dotenv").config();
const fs = require("fs");
const https = require("https");
const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
const bcrypt = require("bcrypt");

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Load SSL Certificate & Key
const sslOptions = {
  key: fs.readFileSync("server.key"),
  cert: fs.readFileSync("server.cert"),
};

const PORT = process.env.PORT || 8080;

// ✅ MySQL Connection (Using Promises)
const db = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
}).promise();

db.getConnection()
  .then(() => console.log("✅ Connected to MySQL Database"))
  .catch((err) => console.error("❌ Database connection failed:", err));

// ===========================================
// ✅ User Signup
// ===========================================
app.post("/signup", async (req, res) => {
  try {
    const { username, password, email } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: "Username and password required" });
    }

    const [existingUser] = await db.query("SELECT id FROM users WHERE username = ?", [username]);
    if (existingUser.length > 0) {
      return res.status(400).json({ error: "Username already taken. Please choose another." });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    await db.query(
      "INSERT INTO users (username, password, email, role) VALUES (?, ?, ?, 'user')",
      [username, hashedPassword, email || null]
    );

    console.log("✅ User Registered:", username);
    res.json({ success: true, message: "User registered successfully!" });

  } catch (error) {
    console.error("❌ Signup Error:", error);
    res.status(500).json({ error: "Server error" });
  }
});

// ===========================================
// ✅ User Login
// ===========================================
app.post("/login", async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: "Username and password required" });
    }

    const [results] = await db.query("SELECT id, username, password, role FROM users WHERE username = ?", [username]);
    if (results.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    const user = results[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: "Incorrect password" });
    }

    res.status(200).json({ id: user.id, username: user.username, role: user.role });

  } catch (error) {
    console.error("❌ Login Error:", error);
    res.status(500).json({ error: "Server error" });
  }
});

// ===========================================
// ✅ Anonymous Login
// ===========================================
app.post("/anonymous-login", async (req, res) => {
  try {
    let isUnique = false;
    let randomUsername = "";

    while (!isUnique) {
      const randomNumber = Math.floor(1000 + Math.random() * 9000);
      randomUsername = `Anonymous#${randomNumber}`;
      const [existingUsers] = await db.query("SELECT id FROM users WHERE username = ?", [randomUsername]);
      if (existingUsers.length === 0) isUnique = true;
    }

    const [result] = await db.query(
      "INSERT INTO users (username, password, role) VALUES (?, ?, 'anonymous')",
      [randomUsername, ""]
    );

    if (result.affectedRows > 0) {
      return res.json({ username: randomUsername, role: "anonymous" });
    } else {
      return res.status(500).json({ error: "Failed to create anonymous user." });
    }

  } catch (error) {
    console.error("❌ Anonymous Login Error:", error);
    return res.status(500).json({ error: "Server error" });
  }
});

// ===========================================
// ✅ Logout
// ===========================================
app.post("/logout", async (req, res) => {
  try {
    res.status(200).json({ message: "Logout successful" });
  } catch (error) {
    console.error("❌ Logout Error:", error);
    res.status(500).json({ error: "Server error" });
  }
});

// ===========================================
// ✅ Start Secure HTTPS Server
// ===========================================
https.createServer(sslOptions, app).listen(PORT, () => {
  console.log(`✅ Secure server running on https://localhost:${PORT}`);
});
