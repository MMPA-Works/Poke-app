<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

// We still include hauconnect to maintain API consistency
require_once 'hauconnect.php';

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        echo json_encode(["success" => false, "message" => "Invalid request method."]);
        exit;
    }

    if (!isset($_FILES['image'])) {
        echo json_encode(["success" => false, "message" => "No image uploaded."]);
        exit;
    }

    $upload = $_FILES['image'];
    if ($upload['error'] !== UPLOAD_ERR_OK) {
        echo json_encode(["success" => false, "message" => "Image upload failed with error code: " . $upload['error']]);
        exit;
    }

    $temporaryPath = $upload['tmp_name'];
    $originalName = $upload['name'];

    $extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
    $allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

    if (!in_array($extension, $allowedExtensions)) {
        echo json_encode(["success" => false, "message" => "Only JPG, JPEG, PNG, and WEBP images are allowed."]);
        exit;
    }

    $uploadDirectory = __DIR__ . '/uploads';
    if (!is_dir($uploadDirectory)) {
        // Create the directory if it does not exist
        mkdir($uploadDirectory, 0777, true);
    }

    $fileName = 'monster_' . uniqid() . '.' . $extension;
    $destinationPath = $uploadDirectory . '/' . $fileName;

    if (!move_uploaded_file($temporaryPath, $destinationPath)) {
        echo json_encode(["success" => false, "message" => "Unable to store uploaded image on the server."]);
        exit;
    }

    // Build the full URL to the image automatically
    $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http";
    $host = $_SERVER['HTTP_HOST'];
    $scriptDir = dirname($_SERVER['PHP_SELF']);
    
    // Ensure the script directory does not end with a slash
    $scriptDir = rtrim($scriptDir, '/');
    
    $imageUrl = $protocol . "://" . $host . $scriptDir . '/uploads/' . $fileName;

    echo json_encode([
        "success" => true,
        "message" => "Image uploaded successfully.",
        "image_url" => $imageUrl
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Server error: " . $e->getMessage()
    ]);
}
?>