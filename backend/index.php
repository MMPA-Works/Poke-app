<?php
declare(strict_types=1);

require_once __DIR__ . '/config/bootstrap.php';

jsonResponse(200, [
    'success' => true,
    'message' => 'HAUMonsters API is running',
    'endpoints' => [
        'get_monsters.php',
        'add_monster.php',
        'update_monster.php',
        'delete_monster.php',
        'upload_monster_image.php',
    ],
]);
