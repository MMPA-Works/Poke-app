<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

require_once 'hauconnect.php';

// Read the raw JSON data sent by Flutter
$data = json_decode(file_get_contents("php://input"));

// Check if the required data is present
if (!isset($data->monster_id) || empty($data->monster_name) || empty($data->monster_type)) {
    echo json_encode(["success" => false, "message" => "Incomplete data. Name, Type, and ID are required."]);
    exit;
}

try {
    $query = "UPDATE monsterstbl SET
                monster_name = :monster_name,
                monster_type = :monster_type,
                spawn_latitude = :spawn_latitude,
                spawn_longitude = :spawn_longitude,
                spawn_radius_meters = :spawn_radius_meters,
                picture_url = :picture_url
              WHERE monster_id = :monster_id";

    $stmt = $conn->prepare($query);

    // Bind the JSON data to the SQL query safely
    $stmt->bindParam(':monster_name', $data->monster_name);
    $stmt->bindParam(':monster_type', $data->monster_type);
    $stmt->bindParam(':spawn_latitude', $data->spawn_latitude);
    $stmt->bindParam(':spawn_longitude', $data->spawn_longitude);
    $stmt->bindParam(':spawn_radius_meters', $data->spawn_radius_meters);
    $stmt->bindParam(':picture_url', $data->picture_url);
    $stmt->bindParam(':monster_id', $data->monster_id);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Monster updated successfully."]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to update monster."]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>