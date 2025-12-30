<?php
/**
 * ╔═══════════════════════════════════════════════════════════════════════════╗
 * ║                        API Health Check                                   ║
 * ║              ตรวจสอบสถานะของแอพพลิเคชัน                                     ║
 * ╚═══════════════════════════════════════════════════════════════════════════╝
 *
 * Endpoint นี้ใช้สำหรับ:
 * - Health check หลัง deploy
 * - Monitoring
 * - Load balancer health checks
 */

// ตั้งค่า header เป็น JSON
header('Content-Type: application/json');

// ข้อมูล health check
$health = [
    'status' => 'healthy',
    'timestamp' => date('c'),
    'version' => '1.0.0',
    'environment' => APP_ENV,
    'checks' => []
];

// ตรวจสอบ PHP version
$health['checks']['php'] = [
    'status' => version_compare(PHP_VERSION, '8.0.0', '>=') ? 'ok' : 'warning',
    'version' => PHP_VERSION
];

// ตรวจสอบ storage directories
$storageDirs = ['logs', 'cache', 'uploads'];
foreach ($storageDirs as $dir) {
    $path = STORAGE_PATH . '/' . $dir;
    $health['checks']['storage_' . $dir] = [
        'status' => is_writable($path) ? 'ok' : 'error',
        'writable' => is_writable($path)
    ];
}

// ตรวจสอบ Database (ถ้ามี)
if (DB_HOST && DB_NAME) {
    try {
        $dsn = "mysql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME;
        $pdo = new PDO($dsn, DB_USER, DB_PASS, [
            PDO::ATTR_TIMEOUT => 5,
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
        ]);
        $health['checks']['database'] = [
            'status' => 'ok',
            'connected' => true
        ];
    } catch (PDOException $e) {
        $health['checks']['database'] = [
            'status' => 'error',
            'connected' => false,
            'message' => 'Connection failed'
        ];
        $health['status'] = 'degraded';
    }
}

// ตรวจสอบ memory usage
$memoryUsage = memory_get_usage(true);
$memoryLimit = ini_get('memory_limit');
$health['checks']['memory'] = [
    'status' => 'ok',
    'usage' => round($memoryUsage / 1024 / 1024, 2) . ' MB',
    'limit' => $memoryLimit
];

// คำนวณสถานะรวม
$hasError = false;
foreach ($health['checks'] as $check) {
    if ($check['status'] === 'error') {
        $hasError = true;
        break;
    }
}

if ($hasError) {
    $health['status'] = 'unhealthy';
    http_response_code(503);
}

// ส่ง response
echo json_encode($health, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
exit;
