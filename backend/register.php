<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

require_once 'hauconnect.php';

$data = json_decode(file_get_contents("php://input"));

if (empty($data->player_name) || empty($data->username) || empty($data->password)) {
    echo json_encode(["success" => false, "message" => "Incomplete data. Name, username, and password are required."]);
    exit;
}

try {
    $checkQuery = "SELECT player_id FROM playerstbl WHERE username = :username";
    $checkStmt = $conn->prepare($checkQuery);
    $checkStmt->bindParam(':username', $data->username);
    $checkStmt->execute();

    if ($checkStmt->rowCount() > 0) {
        echo json_encode(["success" => false, "message" => "Username already exists."]);
        exit;
    }

    $query = "INSERT INTO playerstbl (player_name, username, password) VALUES (:player_name, :username, :password)";
    $stmt = $conn->prepare($query);

    // Hash the password for security
    $hashed_password = password_hash($data->password, PASSWORD_DEFAULT);

    $stmt->bindParam(':player_name', $data->player_name);
    $stmt->bindParam(':username', $data->username);
    $stmt->bindParam(':password', $hashed_password);

    if ($stmt->execute()) {
        echo json_encode([
            "success" => true, 
            "message" => "Player registered successfully.", 
            "player_id" => $conn->lastInsertId()
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to register player."]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>