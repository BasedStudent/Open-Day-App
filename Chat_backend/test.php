<?php
$servername = "sql210.infinityfree.com";  // ✅ Replace with your actual MySQL host
$username = "if0_38302289"; // ✅ Your MySQL username
$password = "t8kDVc69nrzMwyA"; // ✅ Your MySQL password
$dbname = "if0_38302289_users"; // ✅ Your database name  

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed: " . $conn->connect_error]));
}

echo json_encode(["message" => "Connected to MySQL!"]);
?>
