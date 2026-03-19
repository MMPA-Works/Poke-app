<?php
declare(strict_types=1);

require_once "hauconnect.php";

try {
    requireMethod('POST');

    $monsterName = requestValue(['monster_name', 'name', 'monsterName'], true);
    $monsterType = requestValue(['monster_type', 'type', 'monsterType'], true);
    $spawnLatitude = requestFloat(['spawn_latitude', 'latitude', 'lat', 'spawn_lat'], true);
    $spawnLongitude = requestFloat(['spawn_longitude', 'longitude', 'lng', 'long', 'spawn_lng'], true);
    $spawnRadius = requestFloat(['spawn_radius_meters', 'spawn_radius', 'radius', 'radius_meters'], true);
    $pictureUrl = normalizePictureUrl(
        requestValue(
            ['picture_url', 'image_url', 'picture', 'image', 'monster_image_url'],
            false,
            true
        )
    );

    $pdo = createDatabaseConnection();
    $statement = $pdo->prepare(
        'INSERT INTO monsterstbl (
            monster_name,
            monster_type,
            spawn_latitude,
            spawn_longitude,
            spawn_radius_meters,
            picture_url
        ) VALUES (
            :monster_name,
            :monster_type,
            :spawn_latitude,
            :spawn_longitude,
            :spawn_radius_meters,
            :picture_url
        )'
    );

    $statement->execute([
        ':monster_name' => $monsterName,
        ':monster_type' => $monsterType,
        ':spawn_latitude' => $spawnLatitude,
        ':spawn_longitude' => $spawnLongitude,
        ':spawn_radius_meters' => $spawnRadius,
        ':picture_url' => $pictureUrl,
    ]);

    jsonResponse(201, [
        'success' => true,
        'message' => 'Monster added successfully',
        'monster_id' => (int) $pdo->lastInsertId(),
    ]);
} catch (Throwable $exception) {
    handleServerException($exception);
}
