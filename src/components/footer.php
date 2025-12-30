<!--
╔═══════════════════════════════════════════════════════════════════════════╗
║                        Footer Component                                   ║
║                     ส่วนประกอบ Footer ของเว็บ                               ║
╚═══════════════════════════════════════════════════════════════════════════╝
-->
<footer class="bg-gray-900 text-gray-300 mt-auto">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8">

            <!-- Brand -->
            <div class="col-span-1 md:col-span-2">
                <div class="flex items-center space-x-2 mb-4">
                    <div class="w-8 h-8 bg-gradient-to-br from-primary-500 to-primary-700 rounded-lg flex items-center justify-center">
                        <span class="text-white font-bold text-lg">X</span>
                    </div>
                    <span class="font-bold text-xl text-white"><?= e(APP_NAME) ?></span>
                </div>
                <p class="text-gray-400 max-w-md">
                    Xclaude Framework - AI-Powered Development Framework
                    <br>
                    "Just tell Claude what you want"
                </p>
            </div>

            <!-- Links -->
            <div>
                <h3 class="text-white font-semibold mb-4">ลิงก์</h3>
                <ul class="space-y-2">
                    <li>
                        <a href="<?= url('/') ?>" class="text-gray-400 hover:text-white transition-colors">
                            หน้าแรก
                        </a>
                    </li>
                    <li>
                        <a href="<?= url('/about') ?>" class="text-gray-400 hover:text-white transition-colors">
                            เกี่ยวกับ
                        </a>
                    </li>
                    <li>
                        <a href="<?= url('/contact') ?>" class="text-gray-400 hover:text-white transition-colors">
                            ติดต่อ
                        </a>
                    </li>
                </ul>
            </div>

            <!-- Contact -->
            <div>
                <h3 class="text-white font-semibold mb-4">ติดต่อ</h3>
                <ul class="space-y-2 text-gray-400">
                    <li class="flex items-center space-x-2">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                  d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                        </svg>
                        <span>contact@example.com</span>
                    </li>
                    <li class="flex items-center space-x-2">
                        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"/>
                        </svg>
                        <span>GitHub</span>
                    </li>
                </ul>
            </div>
        </div>

        <!-- Copyright -->
        <div class="border-t border-gray-800 mt-8 pt-8 text-center text-gray-500">
            <p>&copy; <?= date('Y') ?> <?= e(APP_NAME) ?>. Powered by Xclaude Framework.</p>
        </div>
    </div>
</footer>
