require("dotenv").config();
const express = require("express");
const axios = require("axios");
const cors = require("cors");

const app = express();
app.use(express.json());
app.use(cors());

const PHP_API_URL = "http://OpenDayApp.free.nf/api.php"; // ✅ Replace with your actual PHP API URL

// ✅ User Signup (Calls PHP API)
app.post("/signup", async (req, res) => {
    try {
        const response = await axios.post(PHP_API_URL, req.body, {
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
        });
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: "Failed to connect to backend." });
    }
});

// ✅ User Login (Calls PHP API)
app.post("/login", async (req, res) => {
    try {
        const response = await axios.post(PHP_API_URL + "?action=login", req.body, {
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
        });
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: "Failed to connect to backend." });
    }
});

// ✅ Anonymous Login (Calls PHP API)
app.post("/anonymous", async (req, res) => {
    try {
        const response = await axios.post(PHP_API_URL + "?action=anonymous", {}, {
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
        });
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: "Failed to connect to backend." });
    }
});

// ✅ Send Chat Message (Calls PHP API)
app.post("/chat", async (req, res) => {
    try {
        const response = await axios.post(PHP_API_URL + "?action=sendMessage", req.body, {
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
        });
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: "Failed to send message." });
    }
});

// ✅ Get Chat Messages (Calls PHP API)
app.get("/chat", async (req, res) => {
    try {
        const response = await axios.get(PHP_API_URL + "?action=getMessages");
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: "Failed to fetch chat messages." });
    }
});

// ✅ Start Server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`✅ Server running on port ${PORT}`);
});
