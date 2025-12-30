<?php
/**
 * ╔═══════════════════════════════════════════════════════════════════════════╗
 * ║                    XCLAUDE FRAMEWORK - App Config                         ║
 * ╚═══════════════════════════════════════════════════════════════════════════╝
 *
 * การตั้งค่าหลักของแอพพลิเคชัน
 * Main application configuration
 */

// โหลด .env ถ้ามี
// Load .env if exists
$envFile = __DIR__ . '/../.env';
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '#') === 0) continue;
        if (strpos($line, '=') !== false) {
            list($key, $value) = explode('=', $line, 2);
            $key = trim($key);
            $value = trim($value, " \t\n\r\0\x0B\"'");
            putenv("$key=$value");
            $_ENV[$key] = $value;
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// ค่าคงที่ของแอพ (Application Constants)
// ═══════════════════════════════════════════════════════════════════════════

// ชื่อแอพ / App name
define('APP_NAME', getenv('APP_NAME') ?: 'Xclaude App');

// Environment: development, staging, production
define('APP_ENV', getenv('APP_ENV') ?: 'development');

// Debug mode
define('APP_DEBUG', getenv('APP_DEBUG') === 'true');

// URL หลัก / Base URL
define('APP_URL', getenv('SITE_URL') ?: 'http://localhost');

// Timezone
define('APP_TIMEZONE', getenv('APP_TIMEZONE') ?: 'Asia/Bangkok');
date_default_timezone_set(APP_TIMEZONE);

// ═══════════════════════════════════════════════════════════════════════════
// Paths
// ═══════════════════════════════════════════════════════════════════════════

define('BASE_PATH', dirname(__DIR__));
define('PUBLIC_PATH', BASE_PATH . '/public');
define('SRC_PATH', BASE_PATH . '/src');
define('STORAGE_PATH', BASE_PATH . '/storage');
define('CACHE_PATH', STORAGE_PATH . '/cache');
define('LOGS_PATH', STORAGE_PATH . '/logs');
define('UPLOADS_PATH', STORAGE_PATH . '/uploads');

// ═══════════════════════════════════════════════════════════════════════════
// Security
// ═══════════════════════════════════════════════════════════════════════════

// Secret key สำหรับ encryption
define('APP_SECRET', getenv('APP_SECRET') ?: 'change-this-secret-key');

// CSRF Protection
define('CSRF_TOKEN_NAME', '_csrf_token');

// ═══════════════════════════════════════════════════════════════════════════
// Database (ถ้าใช้)
// ═══════════════════════════════════════════════════════════════════════════

define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
define('DB_PORT', getenv('DB_PORT') ?: '3306');
define('DB_NAME', getenv('DB_NAME') ?: 'xclaude');
define('DB_USER', getenv('DB_USER') ?: 'root');
define('DB_PASS', getenv('DB_PASS') ?: '');

// ═══════════════════════════════════════════════════════════════════════════
// Line Notification
// ═══════════════════════════════════════════════════════════════════════════

define('LINE_CHANNEL_TOKEN', getenv('LINE_CHANNEL_TOKEN') ?: '');
define('LINE_NOTIFY_TOKEN', getenv('LINE_NOTIFY_TOKEN') ?: '');

// ═══════════════════════════════════════════════════════════════════════════
// Helper Functions
// ═══════════════════════════════════════════════════════════════════════════

/**
 * สร้าง URL เต็ม
 * Generate full URL
 */
function url(string $path = ''): string {
    return rtrim(APP_URL, '/') . '/' . ltrim($path, '/');
}

/**
 * สร้าง asset URL
 * Generate asset URL
 */
function asset(string $path): string {
    $version = filemtime(PUBLIC_PATH . '/' . ltrim($path, '/')) ?: time();
    return url($path) . '?v=' . $version;
}

/**
 * Escape HTML
 */
function e(string $string): string {
    return htmlspecialchars($string, ENT_QUOTES, 'UTF-8');
}

/**
 * สร้าง CSRF token
 * Generate CSRF token
 */
function csrf_token(): string {
    if (!isset($_SESSION[CSRF_TOKEN_NAME])) {
        $_SESSION[CSRF_TOKEN_NAME] = bin2hex(random_bytes(32));
    }
    return $_SESSION[CSRF_TOKEN_NAME];
}

/**
 * สร้าง CSRF input field
 * Generate CSRF input field
 */
function csrf_field(): string {
    return '<input type="hidden" name="' . CSRF_TOKEN_NAME . '" value="' . csrf_token() . '">';
}

/**
 * ตรวจสอบ CSRF token
 * Verify CSRF token
 */
function verify_csrf(string $token): bool {
    return isset($_SESSION[CSRF_TOKEN_NAME]) && hash_equals($_SESSION[CSRF_TOKEN_NAME], $token);
}

/**
 * Redirect
 */
function redirect(string $url, int $code = 302): void {
    header("Location: $url", true, $code);
    exit;
}

/**
 * JSON Response
 */
function json_response(mixed $data, int $code = 200): void {
    http_response_code($code);
    header('Content-Type: application/json');
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * Log message
 */
function app_log(string $message, string $level = 'info'): void {
    $logFile = LOGS_PATH . '/' . date('Y-m-d') . '.log';
    $timestamp = date('Y-m-d H:i:s');
    $logMessage = "[$timestamp] [$level] $message" . PHP_EOL;
    file_put_contents($logFile, $logMessage, FILE_APPEND | LOCK_EX);
}
