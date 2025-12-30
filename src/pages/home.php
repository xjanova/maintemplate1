<?php
/**
 * หน้าแรก (Home Page)
 * Main landing page
 */
$pageTitle = APP_NAME . ' - AI-Powered Development';
$pageDescription = 'Xclaude Framework - พัฒนาเว็บด้วย AI แค่บอก Claude ว่าต้องการอะไร';
?>

<!-- Hero Section -->
<section class="relative min-h-[80vh] flex items-center justify-center overflow-hidden">
    <!-- Background Gradient -->
    <div class="absolute inset-0 bg-gradient-to-br from-primary-50 via-white to-primary-100 dark:from-gray-900 dark:via-gray-900 dark:to-primary-900/20"></div>

    <!-- Animated Background Elements -->
    <div class="absolute inset-0 overflow-hidden">
        <div class="absolute -top-40 -right-40 w-80 h-80 bg-primary-400/20 rounded-full blur-3xl animate-pulse"></div>
        <div class="absolute -bottom-40 -left-40 w-80 h-80 bg-primary-600/20 rounded-full blur-3xl animate-pulse delay-1000"></div>
    </div>

    <!-- Content -->
    <div class="relative z-10 max-w-4xl mx-auto px-4 text-center">
        <!-- Badge -->
        <div class="inline-flex items-center space-x-2 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300 px-4 py-2 rounded-full text-sm font-medium mb-8">
            <span class="relative flex h-2 w-2">
                <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary-400 opacity-75"></span>
                <span class="relative inline-flex rounded-full h-2 w-2 bg-primary-500"></span>
            </span>
            <span>Xclaude Framework v1.0</span>
        </div>

        <!-- Heading -->
        <h1 class="text-4xl md:text-6xl font-bold text-gray-900 dark:text-white mb-6 leading-tight">
            พัฒนาเว็บด้วย
            <span class="bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
                AI
            </span>
            <br>
            แค่บอกว่าต้องการอะไร
        </h1>

        <!-- Subtitle -->
        <p class="text-xl text-gray-600 dark:text-gray-300 mb-8 max-w-2xl mx-auto">
            Xclaude Framework ช่วยให้ Claude เขียนโค้ด ทดสอบ และ Deploy อัตโนมัติ
            คุณแค่พิมพ์คำสั่ง ที่เหลือให้ Claude จัดการ
        </p>

        <!-- CTA Buttons -->
        <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
            <a href="<?= url('/contact') ?>"
               class="w-full sm:w-auto inline-flex items-center justify-center px-8 py-3 bg-primary-600 hover:bg-primary-700 text-white font-semibold rounded-xl shadow-lg shadow-primary-600/25 transition-all hover:scale-105">
                <span>เริ่มต้นใช้งาน</span>
                <svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"/>
                </svg>
            </a>
            <a href="<?= url('/about') ?>"
               class="w-full sm:w-auto inline-flex items-center justify-center px-8 py-3 bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 text-gray-900 dark:text-white font-semibold rounded-xl transition-all">
                <span>เรียนรู้เพิ่มเติม</span>
            </a>
        </div>
    </div>
</section>

<!-- Features Section -->
<section class="py-20 bg-white dark:bg-gray-900">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-16">
            <h2 class="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
                ความสามารถของ Framework
            </h2>
            <p class="text-gray-600 dark:text-gray-400 max-w-2xl mx-auto">
                ทุกอย่างที่คุณต้องการสำหรับการพัฒนาเว็บแบบอัตโนมัติ
            </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <!-- Feature 1 -->
            <div class="group p-6 bg-gray-50 dark:bg-gray-800 rounded-2xl hover:bg-primary-50 dark:hover:bg-primary-900/20 transition-all">
                <div class="w-12 h-12 bg-primary-100 dark:bg-primary-900/50 rounded-xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                    <span class="text-2xl">🤖</span>
                </div>
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                    AI เขียนโค้ดให้
                </h3>
                <p class="text-gray-600 dark:text-gray-400">
                    Claude เข้าใจความต้องการและเขียนโค้ดคุณภาพสูงอัตโนมัติ
                </p>
            </div>

            <!-- Feature 2 -->
            <div class="group p-6 bg-gray-50 dark:bg-gray-800 rounded-2xl hover:bg-primary-50 dark:hover:bg-primary-900/20 transition-all">
                <div class="w-12 h-12 bg-primary-100 dark:bg-primary-900/50 rounded-xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                    <span class="text-2xl">🚀</span>
                </div>
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                    Deploy อัตโนมัติ
                </h3>
                <p class="text-gray-600 dark:text-gray-400">
                    Merge แล้ว Deploy ขึ้น Server ทันที ไม่ต้องทำเอง
                </p>
            </div>

            <!-- Feature 3 -->
            <div class="group p-6 bg-gray-50 dark:bg-gray-800 rounded-2xl hover:bg-primary-50 dark:hover:bg-primary-900/20 transition-all">
                <div class="w-12 h-12 bg-primary-100 dark:bg-primary-900/50 rounded-xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                    <span class="text-2xl">👁️</span>
                </div>
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                    ตรวจสอบผลลัพธ์
                </h3>
                <p class="text-gray-600 dark:text-gray-400">
                    Claude เปิดหน้าเว็บจริงและตรวจสอบว่าถูกต้อง
                </p>
            </div>

            <!-- Feature 4 -->
            <div class="group p-6 bg-gray-50 dark:bg-gray-800 rounded-2xl hover:bg-primary-50 dark:hover:bg-primary-900/20 transition-all">
                <div class="w-12 h-12 bg-primary-100 dark:bg-primary-900/50 rounded-xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                    <span class="text-2xl">🔧</span>
                </div>
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                    แก้ไขอัตโนมัติ
                </h3>
                <p class="text-gray-600 dark:text-gray-400">
                    พบ error ก็แก้เอง ไม่ต้องรบกวนคุณ
                </p>
            </div>

            <!-- Feature 5 -->
            <div class="group p-6 bg-gray-50 dark:bg-gray-800 rounded-2xl hover:bg-primary-50 dark:hover:bg-primary-900/20 transition-all">
                <div class="w-12 h-12 bg-primary-100 dark:bg-primary-900/50 rounded-xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                    <span class="text-2xl">📱</span>
                </div>
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                    แจ้งเตือน Line
                </h3>
                <p class="text-gray-600 dark:text-gray-400">
                    มีปัญหาก็แจ้งผ่าน Line OA ทันที
                </p>
            </div>

            <!-- Feature 6 -->
            <div class="group p-6 bg-gray-50 dark:bg-gray-800 rounded-2xl hover:bg-primary-50 dark:hover:bg-primary-900/20 transition-all">
                <div class="w-12 h-12 bg-primary-100 dark:bg-primary-900/50 rounded-xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                    <span class="text-2xl">🔒</span>
                </div>
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                    Security Scan
                </h3>
                <p class="text-gray-600 dark:text-gray-400">
                    ตรวจช่องโหว่ความปลอดภัยทุกครั้งที่ Deploy
                </p>
            </div>
        </div>
    </div>
</section>

<!-- CTA Section -->
<section class="py-20 bg-gradient-to-r from-primary-600 to-primary-700">
    <div class="max-w-4xl mx-auto px-4 text-center">
        <h2 class="text-3xl md:text-4xl font-bold text-white mb-6">
            พร้อมเริ่มต้นหรือยัง?
        </h2>
        <p class="text-primary-100 text-lg mb-8 max-w-2xl mx-auto">
            ติดตั้ง Xclaude Framework แล้วเริ่มสร้างเว็บด้วย AI วันนี้
        </p>
        <a href="<?= url('/contact') ?>"
           class="inline-flex items-center px-8 py-4 bg-white text-primary-600 font-semibold rounded-xl shadow-lg hover:bg-primary-50 transition-all hover:scale-105">
            <span>เริ่มต้นใช้งาน</span>
            <svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"/>
            </svg>
        </a>
    </div>
</section>
