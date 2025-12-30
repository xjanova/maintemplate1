<?php
/**
 * ╔═══════════════════════════════════════════════════════════════════════════╗
 * ║                         XCLAUDE FRAMEWORK                                 ║
 * ║                     Entry Point - index.php                               ║
 * ╚═══════════════════════════════════════════════════════════════════════════╝
 *
 * จุดเริ่มต้นของแอพพลิเคชัน
 * Main entry point for the application
 */

// โหลด autoloader และ config
// Load autoloader and configuration
require_once __DIR__ . '/../config/app.php';

// ตั้งค่า error reporting สำหรับ development
// Set error reporting for development
if (APP_ENV === 'development') {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
} else {
    error_reporting(0);
    ini_set('display_errors', 0);
}

// เริ่ม session
// Start session
session_start();

// โหลด routes
// Load routes
require_once __DIR__ . '/../config/routes.php';

// ดึง path ปัจจุบัน
// Get current path
$requestUri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$requestMethod = $_SERVER['REQUEST_METHOD'];

// ค้นหา route ที่ตรงกัน
// Find matching route
$matchedRoute = null;
$params = [];

foreach ($routes as $route) {
    $pattern = preg_replace('/\{([^}]+)\}/', '([^/]+)', $route['path']);
    $pattern = '#^' . $pattern . '$#';

    if (preg_match($pattern, $requestUri, $matches) && $route['method'] === $requestMethod) {
        $matchedRoute = $route;
        array_shift($matches);
        $params = $matches;
        break;
    }
}

// รัน route หรือแสดง 404
// Run route or show 404
if ($matchedRoute) {
    // โหลดหน้าที่ตรงกัน
    // Load matched page
    $pagePath = __DIR__ . '/../src/pages/' . $matchedRoute['handler'] . '.php';

    if (file_exists($pagePath)) {
        // ตรวจสอบว่าเป็น API route หรือไม่ (ไม่ใช้ layout)
        // Check if API route (skip layout)
        $isApiRoute = str_starts_with($matchedRoute['handler'], 'api/');

        if ($isApiRoute) {
            // API routes: ไม่ใช้ layout, return JSON โดยตรง
            // API routes: no layout, return JSON directly
            extract(['params' => $params]);
            include $pagePath;
        } else {
            // เรียกใช้ layout พื้นฐาน
            // Use base layout
            $pageContent = function() use ($pagePath, $params) {
                extract(['params' => $params]);
                include $pagePath;
            };

            include __DIR__ . '/../src/layouts/base.php';
        }
    } else {
        http_response_code(404);
        include __DIR__ . '/../src/pages/errors/404.php';
    }
} else {
    http_response_code(404);
    include __DIR__ . '/../src/pages/errors/404.php';
}
