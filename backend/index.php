<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

echo json_encode([
    "success" => true,
    "message" => "HAUMonsters API is running",
    "endpoints" => [
        "get_monsters.php",
        "add_monster.php",
        "update_monster.php",
        "delete_monster.php",
        "upload_monster_image.php"
    ]
]);
?>