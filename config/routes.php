<?php
/**
 * ╔═══════════════════════════════════════════════════════════════════════════╗
 * ║                    XCLAUDE FRAMEWORK - Routes                             ║
 * ╚═══════════════════════════════════════════════════════════════════════════╝
 *
 * กำหนดเส้นทาง URL ทั้งหมดของแอพ
 * Define all URL routes for the application
 *
 * รูปแบบ: ['method' => 'GET|POST', 'path' => '/url', 'handler' => 'folder/file']
 * Format: ['method' => 'GET|POST', 'path' => '/url', 'handler' => 'folder/file']
 */

$routes = [
    // ═══════════════════════════════════════════════════════════════════════
    // หน้าหลัก (Main Pages)
    // ═══════════════════════════════════════════════════════════════════════
    [
        'method' => 'GET',
        'path' => '/',
        'handler' => 'home'  // src/pages/home.php
    ],

    [
        'method' => 'GET',
        'path' => '/about',
        'handler' => 'about'
    ],

    [
        'method' => 'GET',
        'path' => '/contact',
        'handler' => 'contact'
    ],

    // ═══════════════════════════════════════════════════════════════════════
    // API Endpoints
    // ═══════════════════════════════════════════════════════════════════════
    [
        'method' => 'GET',
        'path' => '/api/health',
        'handler' => 'api/health'
    ],

    [
        'method' => 'POST',
        'path' => '/api/contact',
        'handler' => 'api/contact'
    ],

    // ═══════════════════════════════════════════════════════════════════════
    // เพิ่ม routes ใหม่ด้านล่างนี้
    // Add new routes below
    // ═══════════════════════════════════════════════════════════════════════
];
