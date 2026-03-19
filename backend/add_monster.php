<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

require_once 'hauconnect.php';

$data = json_decode(file_get_contents("php://input"));

if (empty($data->monster_name) || empty($data->monster_type)) {
    echo json_encode(["success" => false, "message" => "Incomplete data. Name and Type are required."]);
    exit;
}

try {
    $query = "INSERT INTO monsterstbl (monster_name, monster_type, spawn_latitude, spawn_longitude, spawn_radius_meters, picture_url)
              VALUES (:monster_name, :monster_type, :spawn_latitude, :spawn_longitude, :spawn_radius_meters, :picture_url)";

    $stmt = $conn->prepare($query);

    $stmt->bindParam(':monster_name', $data->monster_name);
    $stmt->bindParam(':monster_type', $data->monster_type);
    $stmt->bindParam(':spawn_latitude', $data->spawn_latitude);
    $stmt->bindParam(':spawn_longitude', $data->spawn_longitude);
    $stmt->bindParam(':spawn_radius_meters', $data->spawn_radius_meters);
    $stmt->bindParam(':picture_url', $data->picture_url);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Monster added successfully."]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to add monster."]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>