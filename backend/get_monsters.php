<?php
declare(strict_types=1);

require_once "hauconnect.php";

try {
    requireMethod('GET');

    $pdo = createDatabaseConnection();
    $statement = $pdo->query(
        'SELECT monster_id, monster_name, monster_type, spawn_latitude, spawn_longitude, spawn_radius_meters, picture_url
         FROM monsterstbl
         ORDER BY monster_id DESC'
    );

    $monsters = [];
    foreach ($statement->fetchAll() as $row) {
        $row['monster_id'] = (int) $row['monster_id'];
        $row['spawn_latitude'] = (float) $row['spawn_latitude'];
        $row['spawn_longitude'] = (float) $row['spawn_longitude'];
        $row['spawn_radius_meters'] = (float) $row['spawn_radius_meters'];
        $row['picture_url'] = normalizeStoredImageUrl($row['picture_url']);
        $monsters[] = $row;
    }

    jsonResponse(200, [
        'success' => true,
        'data' => $monsters,
    ]);
} catch (Throwable $exception) {
    handleServerException($exception);
}
