<!DOCTYPE html>
<html lang="th" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="<?= e($pageDescription ?? 'Xclaude Framework - AI-Powered Development') ?>">

    <title><?= e($pageTitle ?? APP_NAME) ?></title>

    <!-- Tailwind CSS via CDN (สำหรับ development) -->
    <!-- ในการใช้งานจริง ให้ build ด้วย Vite -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    colors: {
                        primary: {
                            50: '#f0f9ff',
                            100: '#e0f2fe',
                            200: '#bae6fd',
                            300: '#7dd3fc',
                            400: '#38bdf8',
                            500: '#0ea5e9',
                            600: '#0284c7',
                            700: '#0369a1',
                            800: '#075985',
                            900: '#0c4a6e',
                        }
                    },
                    fontFamily: {
                        sans: ['Sarabun', 'Inter', 'sans-serif'],
                    }
                }
            }
        }
    </script>

    <!-- Google Fonts - Sarabun (ภาษาไทย) -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Sarabun:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <!-- Alpine.js -->
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>

    <!-- HTMX -->
    <script src="https://unpkg.com/htmx.org@1.9.10"></script>

    <!-- Custom Styles -->
    <style>
        [x-cloak] { display: none !important; }

        /* Smooth transitions */
        .fade-enter { opacity: 0; transform: translateY(-10px); }
        .fade-enter-active { transition: all 0.3s ease; }

        /* Loading spinner */
        .htmx-request .htmx-indicator { display: inline-flex; }
        .htmx-indicator { display: none; }
    </style>

    <?php if (isset($headContent)) echo $headContent; ?>
</head>
<body class="min-h-screen bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 font-sans antialiased"
      x-data="{ darkMode: localStorage.getItem('darkMode') === 'true' }"
      x-init="$watch('darkMode', val => localStorage.setItem('darkMode', val))"
      :class="{ 'dark': darkMode }">

    <!-- Skip to main content (Accessibility) -->
    <a href="#main-content" class="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 bg-primary-600 text-white px-4 py-2 rounded-lg">
        ข้ามไปเนื้อหาหลัก
    </a>

    <!-- Navigation -->
    <?php include __DIR__ . '/../components/nav.php'; ?>

    <!-- Main Content -->
    <main id="main-content" class="pt-16">
        <?php $pageContent(); ?>
    </main>

    <!-- Footer -->
    <?php include __DIR__ . '/../components/footer.php'; ?>

    <!-- Toast Notifications -->
    <div x-data="{ toasts: [] }"
         @notify.window="toasts.push({message: $event.detail.message, type: $event.detail.type || 'info'}); setTimeout(() => toasts.shift(), 3000)"
         class="fixed bottom-4 right-4 z-50 space-y-2">
        <template x-for="(toast, index) in toasts" :key="index">
            <div x-show="true"
                 x-transition:enter="transition ease-out duration-300"
                 x-transition:enter-start="opacity-0 transform translate-x-4"
                 x-transition:enter-end="opacity-100 transform translate-x-0"
                 x-transition:leave="transition ease-in duration-200"
                 x-transition:leave-start="opacity-100"
                 x-transition:leave-end="opacity-0"
                 :class="{
                     'bg-green-500': toast.type === 'success',
                     'bg-red-500': toast.type === 'error',
                     'bg-blue-500': toast.type === 'info',
                     'bg-yellow-500': toast.type === 'warning'
                 }"
                 class="px-4 py-3 rounded-lg text-white shadow-lg">
                <span x-text="toast.message"></span>
            </div>
        </template>
    </div>

    <!-- Page-specific scripts -->
    <?php if (isset($footerScripts)) echo $footerScripts; ?>

</body>
</html>
