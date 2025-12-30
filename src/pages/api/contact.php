<?php
/**
 * Contact Form API Handler
 * จัดการการส่งข้อความจากฟอร์มติดต่อ
 */

// ตรวจสอบว่าเป็น POST request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo '<div class="p-4 bg-red-100 text-red-700 rounded-xl">Method not allowed</div>';
    exit;
}

// ตรวจสอบ CSRF token
if (!isset($_POST[CSRF_TOKEN_NAME]) || !verify_csrf($_POST[CSRF_TOKEN_NAME])) {
    http_response_code(403);
    echo '<div class="p-4 bg-red-100 text-red-700 rounded-xl">Invalid CSRF token</div>';
    exit;
}

// รับข้อมูลจากฟอร์ม
$name = trim($_POST['name'] ?? '');
$email = trim($_POST['email'] ?? '');
$message = trim($_POST['message'] ?? '');

// Validate
$errors = [];

if (empty($name)) {
    $errors[] = 'กรุณากรอกชื่อ';
}

if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $errors[] = 'กรุณากรอกอีเมลที่ถูกต้อง';
}

if (empty($message)) {
    $errors[] = 'กรุณากรอกข้อความ';
}

if (!empty($errors)) {
    http_response_code(400);
    echo '<div class="p-4 bg-red-100 text-red-700 rounded-xl">';
    echo '<ul class="list-disc list-inside">';
    foreach ($errors as $error) {
        echo '<li>' . e($error) . '</li>';
    }
    echo '</ul>';
    echo '</div>';
    exit;
}

// บันทึก log
$logData = [
    'timestamp' => date('c'),
    'name' => $name,
    'email' => $email,
    'message' => $message,
    'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
];

$logFile = LOGS_PATH . '/contact.log';
file_put_contents($logFile, json_encode($logData, JSON_UNESCAPED_UNICODE) . PHP_EOL, FILE_APPEND | LOCK_EX);

// TODO: ส่งอีเมล หรือแจ้งเตือน Line OA

// ส่ง success response
echo '<div class="p-4 bg-green-100 text-green-700 rounded-xl">';
echo '<div class="flex items-center space-x-2">';
echo '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">';
echo '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>';
echo '</svg>';
echo '<span>ส่งข้อความสำเร็จ! เราจะติดต่อกลับโดยเร็ว</span>';
echo '</div>';
echo '</div>';
