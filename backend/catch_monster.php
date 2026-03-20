<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

require_once 'hauconnect.php';

$data = json_decode(file_get_contents("php://input"));

if (empty($data->player_id) || empty($data->monster_id) || !isset($data->latitude) || !isset($data->longitude)) {
    echo json_encode(["success" => false, "message" => "Incomplete data. Player ID, Monster ID, Latitude, and Longitude are required."]);
    exit;
}

try {
    // Note: We omit location_id to let the database handle it with its default null state
    $query = "INSERT INTO monster_catchestbl (player_id, monster_id, latitude, longitude)
              VALUES (:player_id, :monster_id, :latitude, :longitude)";

    $stmt = $conn->prepare($query);

    $stmt->bindParam(':player_id', $data->player_id);
    $stmt->bindParam(':monster_id', $data->monster_id);
    $stmt->bindParam(':latitude', $data->latitude);
    $stmt->bindParam(':longitude', $data->longitude);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Monster caught successfully!"]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to record catch."]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>