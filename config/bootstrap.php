<?php
/**
 * Bootstrap Configuration
 *
 * Loads environment variables and sets up the application.
 *
 * @package XClaude Framework
 */

// Error reporting (disable in production)
if (getenv('APP_DEBUG') === 'true') {
    error_reporting(E_ALL);
    ini_set('display_errors', '1');
} else {
    error_reporting(0);
    ini_set('display_errors', '0');
}

// Set timezone
date_default_timezone_set(getenv('APP_TIMEZONE') ?: 'Asia/Bangkok');

// Load .env file if it exists
$envFile = __DIR__ . '/../.env';
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        // Skip comments
        if (strpos(trim($line), '#') === 0) {
            continue;
        }

        // Parse key=value
        if (strpos($line, '=') !== false) {
            list($key, $value) = explode('=', $line, 2);
            $key = trim($key);
            $value = trim($value);

            // Remove quotes if present
            if (preg_match('/^["\'](.*)["\']\s*$/', $value, $matches)) {
                $value = $matches[1];
            }

            // Set environment variable if not already set
            if (!getenv($key)) {
                putenv("{$key}={$value}");
                $_ENV[$key] = $value;
            }
        }
    }
}

// Ensure storage directories exist
$storageDirs = [
    __DIR__ . '/../storage',
    __DIR__ . '/../storage/logs',
    __DIR__ . '/../storage/cache',
    __DIR__ . '/../storage/conversations',
    __DIR__ . '/../storage/uploads',
];

foreach ($storageDirs as $dir) {
    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
    }
}

/**
 * Simple logging function
 */
function logMessage(string $level, string $message, array $context = []): void {
    $logFile = __DIR__ . '/../storage/logs/' . date('Y-m-d') . '.log';
    $timestamp = date('Y-m-d H:i:s');
    $contextStr = $context ? ' ' . json_encode($context) : '';
    $line = "[{$timestamp}] [{$level}] {$message}{$contextStr}\n";
    file_put_contents($logFile, $line, FILE_APPEND | LOCK_EX);
}

/**
 * Get environment variable with default
 */
function env(string $key, $default = null) {
    $value = getenv($key);
    return $value !== false ? $value : $default;
}
