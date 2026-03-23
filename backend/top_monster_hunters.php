<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once 'hauconnect.php';

try {
    $query = "SELECT p.player_name, COUNT(c.catch_id) AS monsters_caught
              FROM playerstbl p
              JOIN monster_catchestbl c ON p.player_id = c.player_id
              GROUP BY p.player_id
              ORDER BY monsters_caught DESC, p.player_name ASC
              LIMIT 10";

    $stmt = $conn->prepare($query);
    $stmt->execute();

    $rankings = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "data" => $rankings
    ]);

} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>