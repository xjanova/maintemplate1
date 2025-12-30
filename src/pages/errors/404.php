<?php
/**
 * 404 Error Page
 * หน้าแสดงข้อผิดพลาดเมื่อไม่พบหน้า
 */
$pageTitle = '404 - ไม่พบหน้า';
?>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= $pageTitle ?></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Sarabun:wght@400;600;700&display=swap" rel="stylesheet">
    <style>body { font-family: 'Sarabun', sans-serif; }</style>
</head>
<body class="min-h-screen bg-gray-50 flex items-center justify-center p-4">
    <div class="text-center">
        <h1 class="text-9xl font-bold text-gray-200">404</h1>
        <h2 class="text-2xl font-semibold text-gray-800 mt-4">ไม่พบหน้าที่ต้องการ</h2>
        <p class="text-gray-600 mt-2 mb-8">หน้าที่คุณกำลังมองหาอาจถูกย้ายหรือลบไปแล้ว</p>
        <a href="/" class="inline-flex items-center px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-xl transition-colors">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/>
            </svg>
            กลับหน้าแรก
        </a>
    </div>
</body>
</html>
