<?php
declare(strict_types=1);

require_once "hauconnect.php";

try {
    requireMethod('POST');

    $monsterId = requestInt(['monster_id', 'id', 'monsterId'], true);

    $pdo = createDatabaseConnection();
    $statement = $pdo->prepare('DELETE FROM monsterstbl WHERE monster_id = :monster_id');
    $statement->execute([':monster_id' => $monsterId]);

    if ($statement->rowCount() === 0) {
        jsonResponse(404, [
            'success' => false,
            'message' => 'Monster not found',
        ]);
    }

    jsonResponse(200, [
        'success' => true,
        'message' => 'Monster deleted successfully',
    ]);
} catch (Throwable $exception) {
    handleServerException($exception);
}
