<?php
declare(strict_types=1);

require_once __DIR__ . '/config/bootstrap.php';

try {
    requireMethod('POST');

    if (!isset($_FILES['image'])) {
        jsonResponse(400, [
            'success' => false,
            'message' => 'No image uploaded',
        ]);
    }

    $upload = $_FILES['image'];
    if (($upload['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
        jsonResponse(400, [
            'success' => false,
            'message' => 'Image upload failed',
        ]);
    }

    $temporaryPath = (string) ($upload['tmp_name'] ?? '');
    $originalName = (string) ($upload['name'] ?? '');

    $extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
    $allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

    if (!in_array($extension, $allowedExtensions, true)) {
        jsonResponse(400, [
            'success' => false,
            'message' => 'Only JPG, JPEG, PNG, and WEBP images are allowed',
        ]);
    }

    $uploadDirectory = __DIR__ . '/uploads';
    if (!is_dir($uploadDirectory) && !mkdir($uploadDirectory, 0777, true) && !is_dir($uploadDirectory)) {
        throw new RuntimeException('Unable to create uploads directory');
    }

    $fileName = sprintf(
        'monster_%s.%s',
        str_replace('.', '', uniqid('', true)),
        $extension
    );
    $destinationPath = $uploadDirectory . '/' . $fileName;

    if (!move_uploaded_file($temporaryPath, $destinationPath)) {
        throw new RuntimeException('Unable to store uploaded image');
    }

    jsonResponse(200, [
        'success' => true,
        'message' => 'Image uploaded successfully',
        'image_url' => currentBaseUrl() . '/uploads/' . $fileName,
    ]);
} catch (Throwable $exception) {
    handleServerException($exception);
}
