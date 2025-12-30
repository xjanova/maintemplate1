<!--
╔═══════════════════════════════════════════════════════════════════════════╗
║                    Navigation Component                                   ║
║            ส่วนประกอบ Navigation Bar แบบ Responsive                        ║
╚═══════════════════════════════════════════════════════════════════════════╝
-->
<nav x-data="{ mobileMenuOpen: false }"
     class="fixed top-0 left-0 right-0 z-50 bg-white/80 dark:bg-gray-900/80 backdrop-blur-lg border-b border-gray-200 dark:border-gray-800">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">

            <!-- Logo -->
            <a href="<?= url('/') ?>" class="flex items-center space-x-2">
                <div class="w-8 h-8 bg-gradient-to-br from-primary-500 to-primary-700 rounded-lg flex items-center justify-center">
                    <span class="text-white font-bold text-lg">X</span>
                </div>
                <span class="font-bold text-xl bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
                    <?= e(APP_NAME) ?>
                </span>
            </a>

            <!-- Desktop Menu -->
            <div class="hidden md:flex items-center space-x-8">
                <a href="<?= url('/') ?>"
                   class="text-gray-600 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 transition-colors">
                    หน้าแรก
                </a>
                <a href="<?= url('/about') ?>"
                   class="text-gray-600 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 transition-colors">
                    เกี่ยวกับ
                </a>
                <a href="<?= url('/contact') ?>"
                   class="text-gray-600 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 transition-colors">
                    ติดต่อ
                </a>

                <!-- Dark Mode Toggle -->
                <button @click="darkMode = !darkMode"
                        class="p-2 rounded-lg text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
                        :aria-label="darkMode ? 'เปิดโหมดสว่าง' : 'เปิดโหมดมืด'">
                    <svg x-show="!darkMode" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                              d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/>
                    </svg>
                    <svg x-show="darkMode" x-cloak class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                              d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/>
                    </svg>
                </button>
            </div>

            <!-- Mobile Menu Button -->
            <button @click="mobileMenuOpen = !mobileMenuOpen"
                    class="md:hidden p-2 rounded-lg text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800"
                    :aria-expanded="mobileMenuOpen">
                <svg x-show="!mobileMenuOpen" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
                </svg>
                <svg x-show="mobileMenuOpen" x-cloak class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                </svg>
            </button>
        </div>

        <!-- Mobile Menu -->
        <div x-show="mobileMenuOpen"
             x-transition:enter="transition ease-out duration-200"
             x-transition:enter-start="opacity-0 -translate-y-1"
             x-transition:enter-end="opacity-100 translate-y-0"
             x-transition:leave="transition ease-in duration-150"
             x-transition:leave-start="opacity-100 translate-y-0"
             x-transition:leave-end="opacity-0 -translate-y-1"
             x-cloak
             class="md:hidden py-4 border-t border-gray-200 dark:border-gray-800">
            <div class="flex flex-col space-y-4">
                <a href="<?= url('/') ?>" class="text-gray-600 dark:text-gray-300 hover:text-primary-600 px-2 py-1">
                    หน้าแรก
                </a>
                <a href="<?= url('/about') ?>" class="text-gray-600 dark:text-gray-300 hover:text-primary-600 px-2 py-1">
                    เกี่ยวกับ
                </a>
                <a href="<?= url('/contact') ?>" class="text-gray-600 dark:text-gray-300 hover:text-primary-600 px-2 py-1">
                    ติดต่อ
                </a>

                <button @click="darkMode = !darkMode"
                        class="flex items-center space-x-2 text-gray-600 dark:text-gray-300 px-2 py-1">
                    <span x-text="darkMode ? '☀️ โหมดสว่าง' : '🌙 โหมดมืด'"></span>
                </button>
            </div>
        </div>
    </div>
</nav>
