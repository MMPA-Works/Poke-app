<?php
declare(strict_types=1);

require_once "hauconnect.php";

try {
    requireMethod('POST');

    $monsterId = requestInt(['monster_id', 'id', 'monsterId'], true);
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
        'UPDATE monsterstbl
         SET
            monster_name = :monster_name,
            monster_type = :monster_type,
            spawn_latitude = :spawn_latitude,
            spawn_longitude = :spawn_longitude,
            spawn_radius_meters = :spawn_radius_meters,
            picture_url = :picture_url
         WHERE monster_id = :monster_id'
    );

    $statement->execute([
        ':monster_id' => $monsterId,
        ':monster_name' => $monsterName,
        ':monster_type' => $monsterType,
        ':spawn_latitude' => $spawnLatitude,
        ':spawn_longitude' => $spawnLongitude,
        ':spawn_radius_meters' => $spawnRadius,
        ':picture_url' => $pictureUrl,
    ]);

    if ($statement->rowCount() === 0) {
        $checkStatement = $pdo->prepare('SELECT monster_id FROM monsterstbl WHERE monster_id = :monster_id');
        $checkStatement->execute([':monster_id' => $monsterId]);

        if ($checkStatement->fetchColumn() === false) {
            jsonResponse(404, [
                'success' => false,
                'message' => 'Monster not found',
            ]);
        }
    }

    jsonResponse(200, [
        'success' => true,
        'message' => 'Monster updated successfully',
    ]);
} catch (Throwable $exception) {
    handleServerException($exception);
}
