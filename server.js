require('dotenv').config();
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();
app.use(express.json());
app.use(cors());

// ✅ Connect to MySQL (`db2342003`)
const db = mysql.createConnection({
    host: '134.220.4.152', 
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

db.connect(err => {
    if (err) throw err;
    console.log('✅ Connected to MySQL Database: db2342003');
});

// ✅ User Signup (Registers new users)
app.post('/signup', async (req, res) => {
    const { username, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);

    db.query("INSERT INTO users (username, password, role) VALUES (?, ?, 'user')", 
        [username, hashedPassword], 
        (err, result) => {
            if (err) return res.status(400).json({ error: "Username already exists!" });
            res.json({ message: "User registered successfully!" });
        }
    );
});

// ✅ User Login (Checks user credentials & role)
app.post('/login', (req, res) => {
    const { username, password } = req.body;

    db.query("SELECT * FROM users WHERE username = ?", [username], async (err, results) => {
        if (err) throw err;
        if (results.length === 0) return res.status(400).json({ error: "User not found!" });

        const isMatch = await bcrypt.compare(password, results[0].password);
        if (!isMatch) return res.status(400).json({ error: "Incorrect password!" });

        // ✅ Generate JWT Token
        const token = jwt.sign({ username, role: results[0].role }, process.env.JWT_SECRET, { expiresIn: "1h" });

        res.json({ message: "Login successful!", username: results[0].username, role: results[0].role, token });
    });
});

// ✅ Start Server
const PORT = 8080;
app.listen(PORT, '0.0.0.0', () => { // ✅ Listen on ALL IP addresses
    console.log(`✅ Server running on port ${PORT}`);
});

