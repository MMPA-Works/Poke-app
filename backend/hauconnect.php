<?php
$host = "localhost";
$dbname = "haumonstersDB";
$username = "root";
$password = "";

try {
    $conn = new PDO(
        // DATABASE VARIES
        // USER VARIES
        // PASSWORD VARIES
        "mysql:host=$host;dbname=$dbname;charset=utf8mb4",
        $username,
        $password
    );
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Database connection failed",
        "error" => $e->getMessage()
    ]);
    exit;
}
?>