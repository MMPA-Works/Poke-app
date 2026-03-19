<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

require_once 'hauconnect.php';

$data = json_decode(file_get_contents("php://input"));

if (!isset($data->monster_id)) {
    echo json_encode(["success" => false, "message" => "Monster ID is required."]);
    exit;
}

try {
    $query = "DELETE FROM monsterstbl WHERE monster_id = :monster_id";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':monster_id', $data->monster_id);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Monster deleted successfully."]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to delete monster."]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>