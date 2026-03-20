<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

require_once 'hauconnect.php';

$data = json_decode(file_get_contents("php://input"));

if (empty($data->username) || empty($data->password)) {
    echo json_encode(["success" => false, "message" => "Username and password are required."]);
    exit;
}

try {
    $query = "SELECT player_id, player_name, password FROM playerstbl WHERE username = :username";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':username', $data->username);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Verify the hashed password
        if (password_verify($data->password, $row['password'])) {
            echo json_encode([
                "success" => true,
                "message" => "Login successful.",
                "data" => [
                    "player_id" => $row['player_id'],
                    "player_name" => $row['player_name']
                ]
            ]);
        } else {
            echo json_encode(["success" => false, "message" => "Invalid password."]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "User not found."]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>