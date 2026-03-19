<?php
declare(strict_types=1);

require_once __DIR__ . '/database.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

function jsonResponse(int $statusCode, array $payload): void
{
    http_response_code($statusCode);
    echo json_encode($payload, JSON_UNESCAPED_SLASHES);
    exit;
}

function requireMethod(string $method): void
{
    if (strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET') !== strtoupper($method)) {
        jsonResponse(405, [
            'success' => false,
            'message' => sprintf('Only %s method is allowed', strtoupper($method)),
        ]);
    }
}

function requestValue(array $keys, bool $required = false, bool $allowEmpty = false): ?string
{
    foreach ($keys as $key) {
        if (!array_key_exists($key, $_POST)) {
            continue;
        }

        $value = trim((string) $_POST[$key]);
        if ($value === '' && !$allowEmpty) {
            continue;
        }

        return $value;
    }

    if ($required) {
        jsonResponse(400, [
            'success' => false,
            'message' => 'Missing required fields',
        ]);
    }

    return null;
}

function requestFloat(array $keys, bool $required = false): ?float
{
    $value = requestValue($keys, $required);
    if ($value === null) {
        return null;
    }

    if (!is_numeric($value)) {
        jsonResponse(400, [
            'success' => false,
            'message' => 'Invalid numeric value provided',
        ]);
    }

    return (float) $value;
}

function requestInt(array $keys, bool $required = false): ?int
{
    $value = requestValue($keys, $required);
    if ($value === null) {
        return null;
    }

    if (filter_var($value, FILTER_VALIDATE_INT) === false) {
        jsonResponse(400, [
            'success' => false,
            'message' => 'Invalid integer value provided',
        ]);
    }

    return (int) $value;
}

function normalizePictureUrl(?string $pictureUrl): ?string
{
    if ($pictureUrl === null) {
        return null;
    }

    $trimmed = trim($pictureUrl);
    return $trimmed === '' ? null : $trimmed;
}

function currentBaseUrl(): string
{
    $isHttps = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
        || (int) ($_SERVER['SERVER_PORT'] ?? 80) === 443;
    $scheme = $isHttps ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
    $scriptDirectory = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');

    if ($scriptDirectory === '' || $scriptDirectory === '.') {
        return sprintf('%s://%s', $scheme, $host);
    }

    return sprintf('%s://%s%s', $scheme, $host, $scriptDirectory);
}

function normalizeStoredImageUrl(?string $pictureUrl): ?string
{
    if ($pictureUrl === null || trim($pictureUrl) === '') {
        return null;
    }

    $trimmed = trim($pictureUrl);
    if (preg_match('/^https?:\/\//i', $trimmed) === 1) {
        return $trimmed;
    }

    if (substr($trimmed, 0, 1) === '/') {
        return currentBaseUrl() . $trimmed;
    }

    return currentBaseUrl() . '/' . ltrim($trimmed, '/');
}

function handleServerException(Throwable $exception): void
{
    jsonResponse(500, [
        'success' => false,
        'message' => 'Server error',
        'details' => $exception->getMessage(),
    ]);
}
