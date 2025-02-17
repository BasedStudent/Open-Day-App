<?php
// Enable full error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET");
header("Content-Type: application/json");

// Debugging message
echo json_encode(["debug" => "API is running"]);
exit;
?>
