<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once 'hauconnect.php';

try {
    $query = "SELECT * FROM monsterstbl ORDER BY monster_id DESC";
    $stmt = $conn->prepare($query);
    $stmt->execute();

    $monsters = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "data" => $monsters
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Database error: " . $e->getMessage()
    ]);
}
?>