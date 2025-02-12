<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET");
header("Content-Type: application/json");

$servername = "sql210.infinityfree.com";  // ✅ Replace with your actual MySQL host
$username = "if0_38302289"; // ✅ Your MySQL username
$password = "t8kDVc69nrzMwyA"; // ✅ Your MySQL password
$dbname = "if0_38302289_users"; // ✅ Your database name

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// ✅ User Signup
if ($_SERVER["REQUEST_METHOD"] === "POST" && !empty($_POST["username"]) && !empty($_POST["password"])) {
    $username = $_POST["username"];
    $password = password_hash($_POST["password"], PASSWORD_BCRYPT);

    $sql = "INSERT INTO users (username, password, is_anonymous) VALUES (?, ?, false)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $username, $password);

    if ($stmt->execute()) {
        echo json_encode(["message" => "User registered successfully!"]);
    } else {
        echo json_encode(["error" => "Error: " . $conn->error]);
    }
    $stmt->close();
}

// ✅ User Login
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_GET["action"]) && $_GET["action"] === "login") {
    $username = $_POST["username"];
    $password = $_POST["password"];

    $sql = "SELECT * FROM users WHERE username = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($user = $result->fetch_assoc()) {
        if (password_verify($password, $user["password"])) {
            echo json_encode(["message" => "Login successful!", "user" => $user]);
        } else {
            echo json_encode(["error" => "Incorrect password."]);
        }
    } else {
        echo json_encode(["error" => "User not found."]);
    }
    $stmt->close();
}

// ✅ Anonymous Login
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_GET["action"]) && $_GET["action"] === "anonymous") {
    $randomUsername = "Anonymous#" . rand(10000, 99999);

    $sql = "INSERT INTO users (username, password, is_anonymous) VALUES (?, NULL, true)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $randomUsername);

    if ($stmt->execute()) {
        echo json_encode(["message" => "Anonymous user created!", "username" => $randomUsername]);
    } else {
        echo json_encode(["error" => "Error: " . $conn->error]);
    }
    $stmt->close();
}

// ✅ Send Chat Message
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_GET["action"]) && $_GET["action"] === "sendMessage") {
    $username = $_POST["username"];
    $message = $_POST["message"];

    $sql = "INSERT INTO chat_messages (username, message) VALUES (?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $username, $message);

    if ($stmt->execute()) {
        echo json_encode(["message" => "Message sent!"]);
    } else {
        echo json_encode(["error" => "Error: " . $conn->error]);
    }
    $stmt->close();
}

// ✅ Get Chat Messages
if ($_SERVER["REQUEST_METHOD"] === "GET" && isset($_GET["action"]) && $_GET["action"] === "getMessages") {
    $sql = "SELECT * FROM chat_messages ORDER BY created_at ASC";
    $result = $conn->query($sql);

    $messages = [];
    while ($row = $result->fetch_assoc()) {
        $messages[] = $row;
    }
    echo json_encode($messages);
}

$conn->close();
?>
